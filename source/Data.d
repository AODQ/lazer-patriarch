module Data;
static import AOD;

enum Layer {
  UIT = 19,
  UI = 20,
  Front_Wall = 31,
  Front_Prop = 32,
  Explosion = 33,
  Player = 33,
  Block  = 34,
  Mob    = 33,
  Projectile = 33,
  Item   = 37,
  Foilage   = 38,
  Shadow = 39,
  Floor  = 40
}
class Menu {
public: static:
  AOD.SheetRect splashscreen;
  AOD.SheetRect background, background_submenu_credits,
                background_submenu_controls;
  AOD.SheetRect[] credits;
  AOD.SheetRect[AOD.Menu.Button.max+1] buttons;
  string[] text_credits;
  immutable(int) button_y      = 280,
                 button_y_it   = 50,
                 credit_y      = 255,
                 credit_y_it   = 60,
                 credit_text_x = 20,
                 credit_img_x  = 500;
  void Initialize() {
    alias SR = AOD.SheetRect;
    alias SC = AOD.SheetContainer;
    background = cast(SR)SC("assets/menu/background.png");
    background_submenu_credits=
      cast(SR)SC("assets/menu/background-submenu.png");
    background_submenu_controls=
      cast(SR)SC("assets/menu/background-submenu.png");
    buttons = [
      cast(SR)SC("assets/menu/button_start.png"),
      cast(SR)SC("assets/menu/button_controls.png"),
      cast(SR)SC("assets/menu/button_credits.png"),
      cast(SR)SC("assets/menu/button_quit.png"),
      cast(SR)SC("assets/menu/button_back.png")
    ];
    text_credits = [
                    "AODQ - Engine, Code",
                    "Smilecythe   - Pixels, Music"
                   ];
  }
}

auto Construct_New_Menu() {
  static import Game_Manager;
  return new AOD.Menu(
    Data.Menu.background, Data.Menu.background_submenu_credits,
    Data.Menu.background_submenu_controls,
    Data.Menu.buttons,    Data.Menu.text_credits,
    new Game_Manager.Gmanage, Data.Menu.button_y, Data.Menu.button_y_it,
    Data.Menu.credit_y, Data.Menu.credit_y_it, Data.Menu.credit_text_x,
    Data.Menu.credit_img_x
  );
}

class Image {
public: static:
  class Player {
  public: static:
    enum Dir { Down = 0, Up = 1, Side = 2 };
    AOD.Animation[3] walk, push;
    AOD.Animation[2] proj_explosion;
    AOD.Animation spawn;
    AOD.SheetRect proj_vert, proj_horiz, shadow, dead;
  }
  class Enemy{
  public: static:
    enum Dir { Down = 0, Up = 1, Side = 2 };
    AOD.Animation[3] walk;
    AOD.Animation[2] proj_explosion;
    AOD.Animation spawn;
    AOD.SheetRect proj_vert, proj_horiz, shadow, dead;
  }

  enum MapGrid {
    // ---- wall
    wall_ctl = -100,
    wall_ctr = -101,
    wall_cll = -102,
    wall_clr = -103,

    wall_b = -104,
    wall_l = -105,
    wall_r = -106,
    wall_t = -107,

    wall_ptl = -108,
    wall_ptr = -109,
    wall_pll = -110,
    wall_plr = -111,

    brick = -112,
    brick_l = -113,
    brick_r = -114,

    hall_vert = -115,
    hall_horiz = -116,
    hall_capl = -117,
    hall_capr = -118,
    hall_capu = -119,
    hall_capd  = -120,

    hall_ctl = -121,
    hall_ctr = -122,
    hall_clr = -123,
    hall_cll = -124,

    empty    = -125,

    // ---- floor
    floor = -200,
    floor_left = -201,
    floor_right = -202,
    floor_up = -203,
    floor_down = -204,

    floor_tl = -205,
    floor_tr = -206,
    floor_ll = -207,
    floor_lr = -208,

    floor_stl = -209,
    floor_str = -210,
    floor_sll = -211,
    floor_slr = -212,

    floor_vert = -213,
    floor_horiz = -214,

    floor_splittl = -215,
    floor_splittr = -216
  };
  AOD.SheetRect[] walls, floors, props;
  AOD.SheetRect black;
  AOD.SheetRect player;
  AOD.SheetContainer HUD;
  void Initialize() {
    auto sheet = AOD.SheetContainer("assets/grampion.png");
    auto Gen_SR(int x, int y) {
      return AOD.SheetRect(sheet, x*32, y*32, x*32 + 32, y*32 + 32);
    }
    auto Gen_PSR(int x, int y ) {
      return AOD.SheetRect(sheet, x*32, y*32, x*32 + 32, y*32 + 32);
    }
    foreach ( i; 0 .. Player.Dir.max+1 ) {
      Player.walk[i] = new AOD.Animation (AOD.Animation.Type.Linear,
         [Gen_PSR(0,i  ),Gen_PSR(1,i  ),Gen_PSR(2,i  )],
         cast(int)(200.0f/AOD.R_MS()));
      Player.push[i] = new AOD.Animation (AOD.Animation.Type.Linear,
         [Gen_PSR(0,i+3),Gen_PSR(1,i+3),Gen_PSR(2,i+3)],
         cast(int)(300.0f/AOD.R_MS()));
    }
    Player.proj_explosion = [ new AOD.Animation(AOD.Animation.Type.Linear,
         [Gen_PSR(3, 0), Gen_PSR(4, 0), Gen_PSR(5, 0), Gen_PSR(6, 0),
          Gen_PSR(7, 0), Gen_PSR(8, 0)], cast(int)(75.0f/AOD.R_MS())),
       new AOD.Animation(AOD.Animation.Type.Linear,
         [Gen_PSR(3, 2), Gen_PSR(4, 2), Gen_PSR(5, 2), Gen_PSR(6, 2),
          Gen_PSR(7, 2)], cast(int)(150.0f/AOD.R_MS()))
    ];
    Player.spawn = new AOD.Animation(AOD.Animation.Type.Linear,
        [ Gen_PSR(3, 3), Gen_PSR(4, 3), Gen_PSR(5, 3), Gen_PSR(6, 3),
          Gen_PSR(7, 3), Gen_PSR(8, 3) ], cast(int)(100.0f/AOD.R_MS()));
    Player.proj_vert = Gen_PSR(3, 1); Player.proj_horiz = Gen_PSR(4, 1);
    Player.shadow    = Gen_PSR(3, 5);
    Player.dead      = Gen_PSR(3, 4);

    sheet = AOD.SheetContainer("assets/enemy.png");
    foreach ( i; 0 .. Enemy.Dir.max+1 ) {
      Enemy.walk[i] = new AOD.Animation (AOD.Animation.Type.Linear,
         [Gen_PSR(0,i  ),Gen_PSR(1,i  ),Gen_PSR(2,i  )],
         cast(int)(200.0f/AOD.R_MS()));
    }
    Enemy.proj_explosion = [ new AOD.Animation(AOD.Animation.Type.Linear,
         [Gen_PSR(3, 0), Gen_PSR(4, 0), Gen_PSR(5, 0), Gen_PSR(6, 0),
          Gen_PSR(7, 0), Gen_PSR(8, 0)], cast(int)(75.0f/AOD.R_MS())),
       new AOD.Animation(AOD.Animation.Type.Linear,
         [Gen_PSR(3, 2), Gen_PSR(4, 2), Gen_PSR(5, 2), Gen_PSR(6, 2),
          Gen_PSR(7, 2)], cast(int)(150.0f/AOD.R_MS()))
    ];
    Enemy.spawn = new AOD.Animation(AOD.Animation.Type.Linear,
        [ Gen_PSR(3, 3), Gen_PSR(4, 3), Gen_PSR(5, 3), Gen_PSR(6, 3),
          Gen_PSR(7, 3), Gen_PSR(8, 3) ], cast(int)(100.0f/AOD.R_MS()));
    Enemy.proj_vert = Gen_PSR(3, 1); Enemy.proj_horiz = Gen_PSR(4, 1);
    Enemy.shadow    = Gen_PSR(3, 5);
    Enemy.dead      = Gen_PSR(3, 4);

    sheet = AOD.SheetContainer("assets/tset_wall.png");
    walls = [
      Gen_SR(3, 0), Gen_SR(4, 0), Gen_SR(3, 1), Gen_SR(4, 1), // corners
      Gen_SR(1, 2), Gen_SR(0, 1), Gen_SR(2, 1), Gen_SR(1, 0), // walls
      Gen_SR(0, 0), Gen_SR(2, 0), Gen_SR(0, 2), Gen_SR(2, 2), // pokers
      Gen_SR(7, 1), Gen_SR(6, 1), Gen_SR(8, 1), // bricks
      Gen_SR(0, 4), Gen_SR(0, 4), Gen_SR(3, 5), Gen_SR(3, 5),  // hall
      Gen_SR(0, 5), Gen_SR(0, 5),                              // hall
      Gen_SR(2, 4), Gen_SR(3, 4), Gen_SR(4, 4), Gen_SR(5, 4),  // hall corn
      Gen_SR(1, 1)
    ];
    sheet = AOD.SheetContainer("assets/tset_props.png");
    props = [
      Gen_SR(0, 0), Gen_SR(1, 0), Gen_SR(2, 0), Gen_SR(3, 0),// debris
      Gen_SR(0, 1), Gen_SR(1, 1), Gen_SR(2, 1), Gen_SR(3, 1),// debris 7
      Gen_SR(5, 0), Gen_SR(5, 0), Gen_SR(5, 0), Gen_SR(5, 0), // door close
      Gen_SR(5, 1), Gen_SR(5, 1), Gen_SR(5, 1), Gen_SR(5, 1), // door close
      Gen_SR(4, 0), Gen_SR(4, 0), // door open
      Gen_SR(4, 1), Gen_SR(1, 3),
      Gen_SR(1, 4),

      Gen_SR(3, 3), Gen_SR(3, 2),
      Gen_SR(4, 3), Gen_SR(4, 2),

      Gen_SR(0, 2),
      Gen_SR(0, 3), Gen_SR(0, 4), Gen_SR(2, 2), Gen_SR(2, 3),

      Gen_SR(5, 3), Gen_SR(5, 2),

      Gen_SR(2, 4)
    ];
    sheet = AOD.SheetContainer("assets/tset_floor.png");
    floors = [
      Gen_SR(1, 1), Gen_SR(0, 1), Gen_SR(2, 1), Gen_SR(1, 0), Gen_SR(1, 2),//fl
      Gen_SR(0, 0), Gen_SR(2, 0), Gen_SR(0, 2), Gen_SR(2, 2), // corner
      Gen_SR(3, 0), Gen_SR(4, 0), Gen_SR(3, 1), Gen_SR(4, 1), // shadow
      Gen_SR(0, 4), Gen_SR(5, 3), Gen_SR(2, 3), Gen_SR(2, 3)
    ];
    sheet = AOD.SheetContainer("assets/tset_player.png");
    player = AOD.SheetRect(sheet, 0, 0, 32, 32);
    black = AOD.SheetRect(sheet, 32, 0, 64, 32);
    HUD = AOD.SheetContainer("assets/HUD.png");
  }
}

class Sound {
public: static:
  uint spawn, door_open, gramp_dies, stage_complete, monster_dies,
       laser_hit, laser_fire, switch_activate, gramp_push, bg_music,
       monster_hit, monster_fire, health;
  uint[3] gramp_hurt, step;
  uint[10] block_move;
  void Initialize() {
    spawn           = AOD.Load_Sound("assets/sounds/spawn.ogg"           ) ;
    door_open       = AOD.Load_Sound("assets/sounds/door-open.ogg"       ) ;
    gramp_dies      = AOD.Load_Sound("assets/sounds/gramp-dies.ogg"      ) ;
    stage_complete  = AOD.Load_Sound("assets/sounds/stage-complete.ogg"  ) ;
    monster_dies    = AOD.Load_Sound("assets/sounds/monster-dies.ogg"    ) ;
    laser_hit       = AOD.Load_Sound("assets/sounds/laser-hit.ogg"       ) ;
    laser_fire      = AOD.Load_Sound("assets/sounds/laser-fire.ogg"      ) ;
    monster_hit     = AOD.Load_Sound("assets/sounds/monster-hit.ogg"       ) ;
    monster_fire    = AOD.Load_Sound("assets/sounds/monster-fire.ogg"      ) ;
    switch_activate = AOD.Load_Sound("assets/sounds/switch-activate.ogg" ) ;
    gramp_push      = AOD.Load_Sound("assets/sounds/gramp-push.ogg"      ) ;
    health          = AOD.Load_Sound("assets/sounds/pick-health.pgg");
    bg_music = AOD.Load_Sound("assets/sounds/background-music.ogg");
    gramp_hurt = [
      AOD.Load_Sound  ("assets/sounds/gramp-hurt1.ogg"),
      AOD.Load_Sound  ("assets/sounds/gramp-hurt2.ogg"),
      AOD.Load_Sound  ("assets/sounds/gramp-hurt3.ogg")
    ];
    step = [
      AOD.Load_Sound  ("assets/sounds/step1.ogg"),
      AOD.Load_Sound  ("assets/sounds/step2.ogg"),
      AOD.Load_Sound  ("assets/sounds/step2.ogg")
    ];
    block_move = [
      AOD.Load_Sound  ("assets/sounds/block1.ogg"),
      AOD.Load_Sound  ("assets/sounds/block2.ogg"),
      AOD.Load_Sound  ("assets/sounds/block3.ogg"),
      AOD.Load_Sound  ("assets/sounds/block4.ogg"),
      AOD.Load_Sound  ("assets/sounds/block5.ogg"),
      AOD.Load_Sound  ("assets/sounds/block6.ogg"),
      AOD.Load_Sound  ("assets/sounds/block7.ogg"),
      AOD.Load_Sound  ("assets/sounds/block8.ogg"),
      AOD.Load_Sound  ("assets/sounds/block9.ogg"),
      AOD.Load_Sound  ("assets/sounds/block10.ogg"),
    ];
  }
}

void Initialize() {
  Sound.Initialize();
  Image.Initialize();
  Menu.Initialize();
}
