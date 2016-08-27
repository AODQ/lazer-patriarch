module Entity.Player;
static import AOD;
static import Entity.Map;
static import Game_Manager;

class Player : Entity.Map.Tile {
  bool key_left, key_right, key_up, key_down;
  float walk_timer = 0;
  immutable(float) Walk_timer_start = 10;
public:
  this(int x, int y) {
    static import Data;
    super(x, y, Data.Layer.Player);
    Set_Sprite(Data.Image.player);
  }
  override void Update() {
    key_left = key_right = key_up = key_down = false;
    foreach ( k; AOD.ClientVars.keybinds ) {
      if ( AOD.Input.keystate[ k.key ] ) {
        switch ( k.command ) {
          default      : break;
          case "up"    : key_up    = true; break;
          case "down"  : key_down  = true; break;
          case "left"  : key_left  = true; break;
          case "right" : key_right = true; break;
        }
      }
    }

    -- walk_timer;

    if ( walk_timer <= 0 && key_left ) {
      walk_timer = Walk_timer_start;
      if ( Game_Manager.Valid_Position(tile_x-1, tile_y) ) {
        Set_Tile_Pos(tile_x-1, tile_y);
      }
    }
    if ( walk_timer <= 0 && key_right ) {
      walk_timer = Walk_timer_start;
      if ( Game_Manager.Valid_Position(tile_x+1, tile_y) ) {
        Set_Tile_Pos(tile_x+1, tile_y);
      }
    }
    if ( walk_timer <= 0 && key_up ) {
      walk_timer = Walk_timer_start;
      if ( Game_Manager.Valid_Position(tile_x, tile_y-1) ) {
        Set_Tile_Pos(tile_x, tile_y-1);
      }
    }
    if ( walk_timer <= 0 && key_down ) {
      walk_timer = Walk_timer_start;
      if ( Game_Manager.Valid_Position(tile_x, tile_y+1) ) {
        Set_Tile_Pos(tile_x, tile_y+1);
      }
    }
  }
  override void Post_Update() {
    Set_Position(tile_x*32 + 16, tile_y*32 + 16);
    static immutable(float) window_width  = 595,
                            window_height = 395;
    AOD.Camera.Set_Position(R_Position() - AOD.Vector(window_width /2 + 4,
                                                      window_height/2 + 4));
  }
}
