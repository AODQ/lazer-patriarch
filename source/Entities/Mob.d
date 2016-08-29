module Entity.Mob;
static import AOD;
static import Entity.Map;
static import Game_Manager;
static import Data;
import Entity.Projectile;

class Mob : Entity.Map.Tile {
  int think_timer, shoot_timer;
  int Think_timer_start_min = 20,
      Think_timer_start_max = 25,
      Shoot_timer_min       = 4,
      Shoot_timer_max       = 6;
  AOD.Vector[] goal;
  int goal_x, goal_y;
  bool dir;
  float smooth_scroll;
  int prev_x, prev_y;
  AOD.Animation_Player anim_player;
  AOD.Entity shadow;
  bool flip = false;
  bool spawning;
  int spawn_timer;
public:
  this(int x, int y) {
    super(x, y, Entity.Map.Tile_Type.Mob, Data.Layer.Mob, false);
    shadow = new AOD.Entity(Data.Layer.Shadow);
    shadow.Set_Sprite(Data.Image.Enemy.shadow);
    AOD.Add(shadow);
    shadow.Set_Visible(false);
    smooth_scroll = 0.0f;
    spawning = 1;
    think_timer = cast(int)AOD.R_Rand(0, Think_timer_start_max);
    anim_player.Set(Data.Image.Enemy.spawn);
    Set_Visible(false);
    prev_x = x; prev_y = y+1;
  }

  ~this() {
    // -- DEBUG START
    import std.stdio : writeln;
    import std.conv : to;
    writeln("REMOVING SHADOW");
    // -- DEBUG END
    AOD.Remove(shadow);
    shadow.Set_Visible(false);
  }

  void Shadow_Col(float x) {
    shadow.Set_Colour(x, x, x, 1.0);
    shadow.Set_Visible(x > 0.005);
    Set_Visible(x > 0.005);
  }

  override void Update() {
    // -- POSITION SMOOTH
    if ( prev_x != tile_x || prev_y != tile_y ) {
      smooth_scroll += 0.10f;
      if ( smooth_scroll >= 1.0f ) {
        smooth_scroll = 1.0f;
      }
      auto v = AOD.Vector(
                 (1.0f-smooth_scroll)*(prev_x) + smooth_scroll*(tile_x),
                 (1.0f-smooth_scroll)*(prev_y) + smooth_scroll*(tile_y),
               ) * 32.0f;
      Set_Position(v + AOD.Vector(16, 0));
      shadow.Set_Position(R_Position + AOD.Vector(0, 16));
      if ( smooth_scroll >= 1.0f ) {
        prev_x = tile_x;
        prev_y = tile_y;
      }
    }

    // --- SPAWN
    if ( spawning ) {
      Set_Visible(true);
      shadow.Set_Visible(true);
      shadow.Set_Colour(1.0, 1.0, 1.0, (anim_player.index+1)/6.0f);
      anim_player.Update();
      Set_Sprite(anim_player.R_Current_Texture());
      if ( anim_player.done ) {
        anim_player = AOD.Animation_Player(Data.Image.Enemy.walk[0]);
        spawning = false;
        shadow.Set_Colour(1.0, 1.0, 1.0, 1);
      }
      return;
    }

    if ( -- think_timer < 0 ) {
      think_timer = cast(int)AOD.R_Rand(Think_timer_start_min,
                                        Think_timer_start_max);
      Movement();
      if ( goal.length == 0 ) {
        int x, y;
        do {
          x = cast(int)AOD.R_Rand(0, Game_Manager.map.length);
          y = cast(int)AOD.R_Rand(0, Game_Manager.map[0].length);
        } while ( Game_Manager.Valid_Position(x, y) );
        goal = R_Path(tile_x, tile_y, new AOD.Node(AOD.Vector(x, y)));
        if ( goal.length != 0 )
          goal = goal[0 .. $-1];
      }
    }
    anim_player.Update();
    Set_Sprite(anim_player.R_Current_Texture());
    if ( flip && !R_Flipped_X )
      Flip_X();
    if ( !flip && R_Flipped_X )
      Flip_X();
  }
  override void Post_Update() {}

  void Movement () {
    // -- look for player --
    auto px = cast(int)Game_Manager.player.R_Tile_Pos.x,
         py = cast(int)Game_Manager.player.R_Tile_Pos.y;
    bool is_los_visible = true;
    bool is_visible = R_Coloured() && R_Red() > 0.025;
    if ( Game_Manager.player ) {
      if ( is_visible ) {
        // -- DEBUG START
        import std.stdio : writeln;
        import std.conv : to;
        writeln("VISIBLE");
        // -- DEBUG END
        auto line = AOD.Util.Bresenham_Line(tile_x, tile_y, px, py);
        for ( int i = 1; i < line.length - 1; ++ i ) {
          int line_x = cast(int)line[i].x, line_y = cast(int)line[i].y;
          if ( Game_Manager.map[line_x][line_y][$-1].R_Tile_Type !=
                    Entity.Map.Tile_Type.Mob &&
               Game_Manager.map[line_x][line_y][$-1].Blocks_Vision() ) {
            is_los_visible = false;
            break;
          }
        }
      }
      auto p = Game_Manager.player.R_Tile_Pos();
      if ( is_visible ) {
        goal = R_Path(tile_x, tile_y, new AOD.Node(p));
        if ( goal.length != 0 )
          goal = goal[0 .. $-1];
      }
    }
    // -- movement --
    int gx = 0, gy = 0;
    if ( goal.length > 0 ) {
      gx = cast(int)goal[0].x,
      gy = cast(int)goal[0].y;
      prev_x = tile_x;
      prev_y = tile_y;
      Set_Tile_Pos(gx, gy);
      gx -= prev_x;
      gy -= prev_y;
      goal = goal[1 .. $];
    }
    // -- shooting --
    if ( -- shoot_timer < 0 && is_los_visible && is_visible ) {
      shoot_timer = cast(int)AOD.R_Rand(Shoot_timer_min, Shoot_timer_max);
      auto Type_Mob = Entity.Map.Tile_Type.Mob;
      if ( px - tile_x == 0 ) { // vertic
        if ( py > tile_y ) {
          auto e=new Projectile(tile_x, tile_y, 0, 1, Type_Mob);
          Game_Manager.Add(e);
        } else {
          auto e=new Projectile(tile_x,tile_y, 0, -1, Type_Mob);
          Game_Manager.Add(e);
        }
      } else if ( py - tile_y == 0 ) {
        if ( px > tile_x ) {
          auto e=new Projectile(tile_x, tile_y, 1, 0, Type_Mob);
          Game_Manager.Add(e);
        } else {
          auto e=new Projectile(tile_x,tile_y, -1, 0, Type_Mob);
          Game_Manager.Add(e);
        }
      }
    }
    flip = false;
    alias Img = Data.Image.Enemy;
    switch ( gx*10 + gy ) {
      default: break;
      case 1 :   anim_player.Set(Img.walk[Img.Dir.Down]);
      break;
      case -1:   anim_player.Set(Img.walk[Img.Dir.Up]  );
      break;
      case 10:  flip = true; anim_player.Set(Img.walk[Img.Dir.Side]);
      break;
      case -10:  anim_player.Set(Img.walk[Img.Dir.Side]);
      break;
    }
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
      if ( count >= 100 || cur is null ) {
        if ( closest is null ) {
          return [];
        } else {
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
      if ( open_set.length == 0 ) break;
      try {
        sort!((a,b)=>a.f < b.f)(open_set);
      } catch ( Throwable o ) {
      }


      cur = open_set[0];
      open_set = open_set[1..$];
    }
    return [];
  }
}



