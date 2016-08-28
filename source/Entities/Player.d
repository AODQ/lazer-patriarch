module Entity.Player;
static import AOD;
static import Entity.Map;
static import Game_Manager;
static import Data;

class Player : Entity.Map.Tile {
  bool key_left, key_right, key_up, key_down, key_grab;
  float walk_timer = 0, shoot_timer = 0;
  immutable(float) Walk_timer_start = 10;
  Entity.Map.Prop grabbed_top, grabbed_bot;
  int grabbed_dx, grabbed_dy;
  AOD.Animation_Player anim_player;
  bool flip;
public:
  this(int x, int y) {
    super(x, y, Entity.Map.Tile_Type.Player, Data.Layer.Player, false);
    // -- DEBUG START
    import std.stdio : writeln;
    import std.conv : to;
    writeln(to!string(tile_type));
    // -- DEBUG END
    Set_Sprite(Data.Image.player);
    anim_player = AOD.Animation_Player(Data.Image.Player.walk[0]);
    flip = false;
  }
  override void Update() {
    key_left = key_right = key_up = key_down = key_grab = false;
    foreach ( k; AOD.ClientVars.keybinds ) {
      if ( AOD.Input.keystate[ k.key ] ) {
        switch ( k.command ) {
          default      : break;
          case "up"    : key_up    = true; break;
          case "down"  : key_down  = true; break;
          case "left"  : key_left  = true; break;
          case "right" : key_right = true; break;
          case "grab"  : key_grab  = true; break;
        }
      }
    }

    if ( -- shoot_timer < 0 && AOD.Input.R_LMB() ) {
      shoot_timer = 20;
      import Entity.Projectile;
      int mx = cast(int)AOD.Input.R_Mouse_X(0),
          my = cast(int)AOD.Input.R_Mouse_Y(0);
      mx += cast(int)(position.x - 595/2);
      my += cast(int)(position.y - 395/2);
      AOD.Add(new Projectile(tile_x, tile_y, mx, my,
                             Entity.Map.Tile_Type.Player));
    }

    -- walk_timer;
    int dx = 0, dy = 0;
    if      (key_left  ) dx = - 1 ;
    else if (key_right ) dx =   1 ;
    else if (key_up    ) dy = - 1 ;
    else if (key_down  ) dy =   1 ;

    if ( !key_grab ) {
      grabbed_bot = null;
      grabbed_bot = null;

    }
    bool blocked = false, grab_last_frame = false, grab_frame = false,
         blocked_by_block = false;

    bool Valid_Position(int x, int y, int dx, int dy) {
      import Game_Manager : map;
      if ( x <= 0 || y <= 0 ) return false;
      if ( x >= map.length || y >= map[0].length ) return false;
      if ( map[x][y].length == 0 ) return false;
      if ( grabbed_bot is null ) {
        foreach ( i; 0 .. map[x][y].length )
          if ( !map[x][y][i].R_Collideable() ) {
            if ( map[x][y][i].R_Tile_Type == Entity.Map.Tile_Type.Prop ) {
              auto c = cast(Entity.Map.Prop)map[x][y][i];
              if ( c.R_Prop_Type() == Entity.Map.Prop.Type.Block_Bot ) {
                blocked_by_block = true;
              }
            }
            blocked = true;
            return false;
          }
      } else {
        auto p = grabbed_bot.R_Tile_Pos;
        auto px = cast(int)(p.x+dx),
             py = cast(int)(p.y+dy);
        foreach ( i; 0 .. map[px][py].length )
          if (  !map[px][py][i].R_Collideable()
              && map[px][py][i] !is this ) {
            blocked = true;
            return false;
          }
        foreach ( i; 0 .. map[x][y].length )
          if (  !map[x][y][i].R_Collideable()
              && map[x][y][i] !is grabbed_bot ) {
            blocked = true;
            return false;
          }
      }
      return true;
    }

    import Game_Manager : map;
    /** check grab */
    if ( walk_timer <= 0 && (key_left || key_right || key_up || key_down) ) {
      walk_timer = Walk_timer_start;
      blocked = !Valid_Position(tile_x+dx, tile_y+dy, dx, dy);
      if ( !blocked ) {
        if ( (dx != 0 && grabbed_dx != 0) || (dy != 0 && grabbed_dy != 0) ||
              grabbed_bot is null ) {
          Set_Tile_Pos(tile_x+dx, tile_y+dy);
          if ( grabbed_bot !is null ) {
            grabbed_bot.Set_Tile_Pos(cast(int)grabbed_bot.R_Tile_Pos.x+dx,
                                     cast(int)grabbed_bot.R_Tile_Pos.y+dy);
            grabbed_top.Set_Tile_Pos(cast(int)grabbed_top.R_Tile_Pos.x+dx,
                                     cast(int)grabbed_top.R_Tile_Pos.y+dy);
          }
        }

      } else if ( key_grab || !grab_frame ) {
        grab_last_frame = true;
        if ( map[tile_x+dx][tile_y+dy].length > 0 ) {
          foreach ( p ; map[tile_x+dx][tile_y+dy] ) {
            if ( p.R_Tile_Type() == Entity.Map.Tile_Type.Prop ) {
              auto c = cast(Entity.Map.Prop)(p);
              if ( c.R_Prop_Type() == Entity.Map.Prop.Type.Block_Bot ) {
                grabbed_top = c.R_Top();
                grabbed_bot = c;
                grabbed_dx = cast(int)(tile_x - c.R_Tile_Pos.x);
                grabbed_dy = cast(int)(tile_y - c.R_Tile_Pos.y);
                break;
              }
            }
          }
        }
      }
    }

    if ( blocked_by_block ) {
      grabbed_dx = -1*dx;
      grabbed_dy = -1*dy;
      goto FORCE_PULL;
    }

    alias Img_Pl = Data.Image.Player;

    if ( (dx != 0 || dy != 0) && !blocked && grabbed_bot is null) {
      flip = false;
      switch ( dx*10 + dy ) {
        default: break;
        case 1 :   anim_player.Set(Img_Pl.walk[Img_Pl.Dir.Down]);
        break;
        case -1:   anim_player.Set(Img_Pl.walk[Img_Pl.Dir.Up]  );
        break;
        case 10:  flip = true; anim_player.Set(Img_Pl.walk[Img_Pl.Dir.Side]);
        break;
        case -10:  anim_player.Set(Img_Pl.walk[Img_Pl.Dir.Side]);
        break;
      }
      anim_player.Update();
    } else {
      /* if ( (dx != 0 || dy != 0) && blocked_by_block && grabbed_bot is null) { */
      /*   flip = false; */
      /*   switch ( dx*10 + dy ) { */
      /*     default: break; */
      /*     case -1  : anim_player.Set(Img_Pl.push[Img_Pl.Dir.Down]); */
      /*     break; */
      /*     case  1  : anim_player.Set(Img_Pl.push[Img_Pl.Dir.Up]); */
      /*     break; */
      /*     case -10 : flip = true; anim_player.Set(Img_Pl.push[Img_Pl.Dir.Side]); */
      /*     break; */
      /*     case 10  : anim_player.Set(Img_Pl.push[Img_Pl.Dir.Side]); */
      /*     break; */
      /*   } */
      /*   goto REDO_ANIM; */
      /* } */
      if ( grabbed_bot !is null ) {
        if ( (dx != 0 || dy != 0) && !blocked ) {
          FORCE_PULL:
          flip = false;
          switch ( grabbed_dx*10 + grabbed_dy ) {
            default: break;
            case -1  : anim_player.Set(Img_Pl.push[Img_Pl.Dir.Down]);
            break;
            case  1  : anim_player.Set(Img_Pl.push[Img_Pl.Dir.Up]);
            break;
            case -10 : flip = true; anim_player.Set(Img_Pl.push[Img_Pl.Dir.Side]);
            break;
            case 10  : anim_player.Set(Img_Pl.push[Img_Pl.Dir.Side]);
            break;
          }
        } else goto REDO_ANIM;
        anim_player.Update();
      } else {
        REDO_ANIM:
        blocked = true;
        anim_player.Set(anim_player.animation, true);
        anim_player.frames_left = 1;
      }
    }
    Set_Sprite(anim_player.R_Current_Texture());
    if ( flip && !R_Flipped_X )
      Flip_X();
    if ( !flip && R_Flipped_X )
      Flip_X();
    grab_last_frame = blocked;
  }

  override void Post_Update() {
    Set_Position(tile_x*32 + 16, tile_y*32);
    static immutable(float) window_width  = 595,
                            window_height = 395;
    AOD.Camera.Set_Position(R_Position() - AOD.Vector(window_width /2 + 4,
                                                      window_height/2 + 4));
  }
}
