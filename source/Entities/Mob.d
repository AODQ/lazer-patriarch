module Entity.Mob;
static import AOD;
static import Entity.Map;
static import Game_Manager;

class Mob : Entity.Map.Tile {
  int think_timer;
  int Think_timer_start_min = 20,
      Think_timer_start_max = 25;
  AOD.Vector[] goal;
  int goal_x, goal_y;
  bool dir;
public:
  this(int x, int y, int m) {
    static import Data;
    super(x, y, Entity.Map.Tile_Type.Mob, Data.Layer.Mob, false);
    if ( m > 100 ) {
      m -= 100;
      Set_Colour(0.3, 0.3, 0.3, 1);
    }
    if ( m > Data.Image.mobs.length ) m = Data.Image.mobs.length-1;
    Set_Sprite(Data.Image.mobs[m]);
    think_timer = cast(int)AOD.R_Rand(0, Think_timer_start_max);
  }


  private AOD.Node[] Find_Surrounding(AOD.Node n) {
    AOD.Node[] p = [ new AOD.Node(0, -1), new AOD.Node(-1,  0),
                     new AOD.Node(1,  0), new AOD.Node( 0,  1) ];
    AOD.Node[] result;

    foreach ( i; 0 .. p.length ) {
      auto coord = new AOD.Node(n.x + p[i].x, n.y + p[i].y);
      int x = cast(int)coord.x,
          y = cast(int)coord.y;

      if ( Game_Manager.Valid_Position(x, y) ||
           (Game_Manager.Valid_Position_Light(x, y) &&
           (Game_Manager.map[x][y][$-1] is this ||
           Game_Manager.map[x][y][$-1] is Game_Manager.player) ) ) {
        result ~= coord;
      }
    }
    return result;
  }

  private bool Inside(AOD.Node n, AOD.Node[] arr) {
    foreach ( o; arr )
      if ( n.x == o.x && n.y == o.y ) return true;
    return false;
  }

  private AOD.Vector[] R_Path(int tile_x, int tile_y, AOD.Node end) {
    import std.math;
    AOD.Node start = new AOD.Node(tile_x, tile_y);
    AOD.Node[] open_set, closed_set;

    start.g = 0;
    start.f = start.Distance(end);
    open_set ~= start;

    AOD.Node cur = start, closest = null;
    float low_dist = start.Distance(end);
    int count = 0;
    while ( open_set.length >= 0 ) {
      if ( count >= 30 || cur is null ) {
        if ( closest is null )
          return [];
        else {
          AOD.Vector[] res;
          while ( cur.parent !is null ) {
            res = AOD.Vector(cur.x, cur.y) ~ res;
            cur = cur.parent;
          }
          return res;
        }
      }
      closed_set ~= cur;
      if ( cur.Distance(end) < low_dist ) {
        closest = cur;
        low_dist = cur.Distance(end);
        count = 0;
      } else
        ++ count;

      auto check = Find_Surrounding(cur);

      foreach ( i; 0 .. check.length ) {
        auto n = check[i];
        float g = cur.g + n.Distance(cur);
        float f = g + n.Distance(end);
        if ( Inside(n, closed_set) || Inside(n, open_set) ) {
          if ( n.f > f ) {
            n.f = f;
            n.g = g;
            n.parent = cur;
          }
        } else {
          n.f = f;
          n.g = g;
          n.parent = cur;
          open_set ~= n;
        }
      }

      if ( cur.x == end.x && cur.y == end.y ) {
        AOD.Vector[] res;
        while ( cur.parent !is null ) {
          res = AOD.Vector(cur.x, cur.y) ~ res;
          cur = cur.parent;
        }
        return res;
      }
      import std.algorithm;
      import std.algorithm.mutation;
      if ( open_set.length < 3 ) return [];
      sort!((a,b)=>a.f < b.f)(open_set);

      cur = open_set[0];
      open_set = open_set[1..$];
    }
    return [];
  }

  void Generate_New_Goal(int dx, int dy) {
    if ( dx != 0 || dy != 0 ) {
      return;
    }
    int i = 10;
    while ( !Game_Manager.Valid_Position(tile_x + dx*i, tile_y + dx*i) ) {
      if ( -- i == 0 ) return;
    }
    // -- DEBUG START
    import std.stdio : writeln;
    import std.conv : to;
    writeln("GOAL: " ~ to!string(goal));
    // -- DEBUG END
    goal = [AOD.Vector(tile_x + dx*i, tile_y + dy*i)];
  }

  override void Update() {
    if ( -- think_timer > 0 ) return;
    think_timer = cast(int)AOD.R_Rand(Think_timer_start_min,
                                      Think_timer_start_max);
    // -- look for player --
    if ( Game_Manager.player ) {
      auto p = Game_Manager.player.R_Tile_Pos();
      if ( p.Distance(R_Tile_Pos) < 10 ) {
        auto line = AOD.Util.Bresenham_Line(tile_x, tile_y,
                                           cast(int)p.x, cast(int)p.y);
        bool visible = true;
        for ( int i = 0; i < line.length - 1; ++ i ) {
          int line_x = cast(int)line[i].x, line_y = cast(int)line[i].y;
          if ( Game_Manager.map[line_x][line_y].length > 0 &&
               Game_Manager.map[line_x][line_y][$-1].Blocks_Vision() ) {
            visible = false;
            break;
          }
        }
        if ( visible ) {
          import std.math;
          /* if ( abs(tile_x - cast(int)p.x) == 1 || */
               /* abs(tile_y - cast(int)p.y) == 1 ) { */
            // attack
          /* } else { // get closer */
            goal = R_Path(tile_x, tile_y, new AOD.Node(p));
          /* } */
        }
      }
    }
    // -- movement --
    int gx = 0, gy = 0;
    int rx, ry;
    if ( goal.length > 0 ) {
      gx = cast(int)goal[$-1].x,
      gy = cast(int)goal[$-1].y;
      if ( gx != tile_x ) {
        rx = gx > tile_x ? 1 : -1;
        if ( Game_Manager.Valid_Position(tile_x + rx, tile_y) ) {
          Set_Tile_Pos(tile_x + rx, tile_y);
        }
      } else {
        ry = gy > tile_y ? 1 : -1;
        if ( Game_Manager.Valid_Position(tile_x, tile_y + ry) ) {
          Set_Tile_Pos(tile_x, tile_y + ry);
        }
      }
    }
    if ( gx == tile_x && gy == tile_y ) {
      if ( goal.length > 1 )
        goal = goal[0..$-2];
      else {
        Generate_New_Goal(rx, ry);
      }
    }
  }
}



