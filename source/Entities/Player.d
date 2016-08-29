module Entity.Player;
static import AOD;
static import Entity.Map;
static import Game_Manager;
static import Data;

class Player : Entity.Map.Tile {
  bool key_left, key_right, key_up, key_down, key_grab, key_shoot;
  float walk_timer = 0, shoot_timer = 0;
  immutable(float) Walk_timer_start = 10,
                   Pull_timer_start = 30;
  Entity.Map.Prop grabbed_top, grabbed_bot;
  int grabbed_dx, grabbed_dy;
  AOD.Animation_Player anim_player;
  bool flip;
  int dir_dx, dir_dy;
  float smooth_scroll;
  int prev_x, prev_y;
  bool spawning;
  int spawn_timer;
  static immutable(float) window_width  = 800,
                          window_height = 600;
  AOD.Entity shadow;
public:
  this(int x, int y) {
    super(x, y, Entity.Map.Tile_Type.Player, Data.Layer.Player, false);
    Set_Sprite(Data.Image.player);
    shadow = new AOD.Entity(Data.Layer.Shadow);
    shadow.Set_Sprite(Data.Image.Player.shadow);
    AOD.Add(shadow);
    shadow.Set_Visible(false);
    flip = false;
    dir_dy = 1;
    prev_x = x; prev_y = y+1;
    smooth_scroll = 0.0f;
    spawning = 1;
    anim_player.Set(Data.Image.Player.spawn);
    Set_Visible(false);
    spawn_timer = cast(int)(500.0f/AOD.R_MS());
    AOD.Camera.Set_Position(position -
                      AOD.Vector(window_width /2 + 4, window_height/2 + 4));
  }

  float R_Light(int i, int j, int amt) {
    auto px = tile_x, py = tile_y;
    if ( !spawning ) {
      float d = 10/(AOD.Vector(px, py).Distance(AOD.Vector(i, j)));
      d /= (amt+2.0)*2;
      d -= 0.4;
      return d;
    } else {
      if ( spawn_timer > 0 ) return 0.0f;
      float d = 10/(AOD.Vector(px, py).Distance(AOD.Vector(i, j)));
      d /= ((amt+8.1)*2);
      d *= anim_player.index;
      d -= 0.4;
      return d;
    }
  }


  override void Update() {
    if ( prev_x != tile_x || prev_y != tile_y ) {
      smooth_scroll += 0.10f;
      if ( smooth_scroll >= 1.0f ) {
        smooth_scroll = 1.0f;
      }
      auto v = AOD.Vector(
                 (1.0f-smooth_scroll)*(prev_x) + smooth_scroll*(tile_x),
                 (1.0f-smooth_scroll)*(prev_y) + smooth_scroll*(tile_y),
               ) * 32.0f;
      AOD.Camera.Set_Position(v - AOD.Vector(window_width /2 + 4,
                                             window_height/2 + 4));
      Set_Position(v + AOD.Vector(16, 0));
      shadow.Set_Position(R_Position + AOD.Vector(0, 10));
      if ( grabbed_bot ) {
        grabbed_bot.Set_Position(v);
        grabbed_top.Set_Position(v);
        grabbed_bot.Add_Position(AOD.Vector(grabbed_dx*-32+16,
                                            grabbed_dy*-32+16));
        grabbed_top.Add_Position(AOD.Vector(grabbed_dx*-32+16,
                                            grabbed_dy*-32-16));
      }
      if ( smooth_scroll >= 1.0f ) {
        prev_x = tile_x;
        prev_y = tile_y;
      }
    }
    if ( spawning ) {
      if ( -- spawn_timer <= 0 ) {
        if ( spawn_timer == 0 ) {
          AOD.Play_Sound(Data.Sound.spawn);
          Set_Visible(true);
        }
        shadow.Set_Visible(true);
        shadow.Set_Colour(1.0, 1.0, 1.0, (anim_player.index+1)/6.0f);
        anim_player.Update();
        Set_Sprite(anim_player.R_Current_Texture());
        if ( anim_player.done ) {
          anim_player = AOD.Animation_Player(Data.Image.Player.walk[0]);
          spawning = false;
          shadow.Set_Colour(1.0, 1.0, 1.0, 1);
          spawn_timer = cast(int)(200/AOD.R_MS());
        }
      }
      return;
    } else if ( spawn_timer > 0 && -- spawn_timer == 0 ) {
      AOD.Play_Sound(Data.Sound.bg_music, 0.25f);
    }

    key_shoot = key_left = key_right = key_up = key_down = key_grab = false;
    foreach ( k; AOD.ClientVars.keybinds ) {
      if ( AOD.Input.keystate[ k.key ] ) {
        switch ( k.command ) {
          default      : break;
          case "up"    : key_up    = true; break;
          case "down"  : key_down  = true; break;
          case "left"  : key_left  = true; break;
          case "right" : key_right = true; break;
          case "grab"  : key_grab  = true; break;
          case "shoot" : key_shoot = true; break;
        }
      }
    }

    if ( -- shoot_timer < 0 && key_shoot ) {
      shoot_timer = 80;
      import Entity.Projectile;
      Game_Manager.Add(new Projectile(tile_x, tile_y, dir_dx, dir_dy,
                             Entity.Map.Tile_Type.Player));
    }

    -- walk_timer;
    int dx = 0, dy = 0;
    if      (key_left  ) { dx = - 1 ; dir_dx = dx; dir_dy =  0; }
    else if (key_right ) { dx =   1 ; dir_dx = dx; dir_dy =  0; }
    else if (key_up    ) { dy = - 1 ; dir_dx =  0; dir_dy = dy; }
    else if (key_down  ) { dy =   1 ; dir_dx =  0; dir_dy = dy; }
    if ( !key_grab && smooth_scroll >= 1.0f ) {
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
      walk_timer = grabbed_bot ? Pull_timer_start : Walk_timer_start;
      blocked = !Valid_Position(tile_x+dx, tile_y+dy, dx, dy);
      if ( !blocked ) {
        if ( (dx != 0 && grabbed_dx != 0) || (dy != 0 && grabbed_dy != 0) ||
              grabbed_bot is null ) {
          smooth_scroll = 0.0f;
          prev_x = tile_x;
          prev_y = tile_y;
          Set_Tile_Pos(tile_x+dx, tile_y+dy);
          AOD.Play_Sound(Data.Sound.step[cast(int)(AOD.R_Rand(0, $))]);
          if ( grabbed_bot !is null ) {
            AOD.Play_Sound(Data.Sound.block_move);
            grabbed_bot.Set_Tile_Pos(cast(int)grabbed_bot.R_Tile_Pos.x+dx,
                                     cast(int)grabbed_bot.R_Tile_Pos.y+dy);
            grabbed_top.Set_Tile_Pos(cast(int)grabbed_top.R_Tile_Pos.x+dx,
                                     cast(int)grabbed_top.R_Tile_Pos.y+dy);
          }
        }
      else if ( map[tile_x+dx][tile_y+dy].length > 0 ) {
        import std.stdio;
        writeln( (map[tile_x+dx][tile_y+dy].length));
        foreach ( i ; 0 ..  map[tile_x+dx][tile_y+dy].length ) {
          auto c = 
                 cast(Entity.Map.Prop)(map[tile_x+dx][tile_y+dy][cast(int) i]);
          if( c.R_Prop_Type() == Entity.Map.Prop.Type.Closed_Door_Bot ) {
            AOD.Remove(c);
            AOD.Util.Remove(map[tile_x+dx][tile_y+dy], cast(int) i);
            AOD.Add(new Entity.Map.Prop(tile_x+dx, tile_y+dy,
                    Entity.Map.Prop.Type.Open_Door_Vertic));
          }
          if( c.R_Prop_Type() == Entity.Map.Prop.Type.Closed_Door_Left ) {
            AOD.Remove(c);
            AOD.Util.Remove(map[tile_x+dx][tile_y+dy],  cast(int) i);
        }
          if( c.R_Prop_Type() == Entity.Map.Prop.Type.Closed_Door_Left ) {
            AOD.Remove(c);
            AOD.Util.Remove(map[tile_x+dx][tile_y+dy],  cast(int) i);
        }
      }
      } else if ( key_grab || !grab_frame ) {
        grab_last_frame = true;
        if ( map[tile_x+dx][tile_y+dy].length > 0 ) {
          foreach ( p ; map[tile_x+dx][tile_y+dy] ) {
            if ( p.R_Tile_Type() == Entity.Map.Tile_Type.Prop ) {
              auto c = cast(Entity.Map.Prop)(p);
              if ( c.R_Prop_Type() == Entity.Map.Prop.Type.Block_Bot ) {
                AOD.Play_Sound(Data.Sound.gramp_push);
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
}
  override void Post_Update() {
    /* Set_Position(tile_x*32 + 16, tile_y*32); */
  }
}
