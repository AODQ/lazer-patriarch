module Entity.Mob;
static import AOD;
static import Entity.Map;
static import Game_Manager;

class Mob : Entity.Map.Tile {
  int think_timer;
  int Think_timer_start_min = 20,
      Think_timer_start_max = 25;
  int goal_x, goal_y;
  bool dir;
  int[] prev_x, prev_y;
public:
  this(int x, int y, int m) {
    static import Data;
    prev_x = [0, 0];
    prev_y = [0, 0];
    super(x, y, Data.Layer.Mob);
    if ( m > 100 ) {
      m -= 100;
      Set_Colour(0.3, 0.3, 0.3, 1);
    }
    if ( m > Data.Image.mobs.length ) m = Data.Image.mobs.length-1;
    Set_Sprite(Data.Image.mobs[m]);
    think_timer = cast(int)AOD.R_Rand(0, Think_timer_start_max);
    Generate_New_Goal();
  }

  void Generate_New_Goal() {
    goal_x = cast(int)AOD.R_Rand(0, Game_Manager.map_width);
    goal_y = cast(int)AOD.R_Rand(0, Game_Manager.map_height);
  }

  override void Update() {
    if ( -- think_timer > 0 ) return;
    think_timer = cast(int)AOD.R_Rand(Think_timer_start_min,
                                      Think_timer_start_max);
    // -- look for player --
    if ( Game_Manager.player ) {

    }
    // -- movement --
    if ( goal_x == tile_x && goal_y == tile_y ) {
      Generate_New_Goal();
    }
    prev_x = [tile_x] ~ [prev_x[0]];
    prev_y = [tile_y] ~ [prev_y[0]];
    int rx = 0, ry = 0;
    if ( dir && goal_x != tile_x )
      rx = goal_x > tile_x ? 1 : -1;
    else
      ry = goal_y > tile_y ? 1 : -1;
    if ( Game_Manager.Valid_Position(tile_x + rx, tile_y + ry) ) {
      Set_Tile_Pos(tile_x + rx, tile_y + ry);
    }
    if ( tile_x == prev_x[1] || tile_y == prev_y[1] ) {
      Generate_New_Goal();
    }
  }
}
