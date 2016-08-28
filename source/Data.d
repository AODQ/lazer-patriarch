module Data;
static import AOD;

enum Layer {
  UI = 30,
  Player = 31,
  Black  = 32,
  Mob    = 33,
  Projectile = 34,
  Item   = 35,
  Floor  = 36
}
class Menu {
public: static:
  AOD.SheetRect splashscreen;
  AOD.SheetRect background, background_submenu;
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
    background_submenu = cast(SR)SC("assets/menu/background-submenu.png");
    buttons = [
      cast(SR)SC("assets/menu/button_start.png"),
      cast(SR)SC("assets/menu/button_controls.png"),
      cast(SR)SC("assets/menu/button_credits.png"),
      cast(SR)SC("assets/menu/button_quit.png"),
      cast(SR)SC("assets/menu/button_back.png")
    ];
    text_credits = [
                    "AODQ - Engine, Code",
                    "Smilecythe   - Pixels, Music",
                   ];
  }
}

auto Construct_New_Menu() {
  static import Game_Manager;
  return new AOD.Menu(
    Data.Menu.background, Data.Menu.background_submenu,
    Data.Menu.buttons,    Data.Menu.text_credits,
    new Game_Manager.Gmanage, Data.Menu.button_y, Data.Menu.button_y_it,
    Data.Menu.credit_y, Data.Menu.credit_y_it, Data.Menu.credit_text_x,
    Data.Menu.credit_img_x
  );
}

class Image {
public: static:
  enum MapGrid {
    // ---- wall
    wall_ctl = -100, wall_ctr = -101, wall_cll = -102, wall_clr = -103,

    wall_b = -104, wall_l = -105, wall_r = -106, wall_t = -107,

    wall_ptl = -108, wall_ptr = -109, wall_pll = -110, wall_plr = -111,

    brick = -112, brick_l = -113, brick_r = -114,

    hall_vert = -115, hall_horiz = -116, hall_capl = -117, hall_capr = -118,
    hall_capu = -119, hall_capd  = -120,

    // ---- floor
    floor = -200, floor_left = -201, floor_right = -202, floor_up = -203,
    floor_down = -204,

    floor_tl = -205, floor_tr = -206, floor_ll = -207, floor_lr = -208,

    floor_stl = -209, floor_str = -210, floor_sll = -211, floor_slr = -212,

    floor_vert = -213, floor_horiz = -214,

    floor_splittl = -215, floor_splittr = -216
  };
  AOD.SheetRect[] walls, floors, mobs, props;
  AOD.SheetRect black;
  AOD.SheetRect player;
  AOD.SheetContainer HUD, projectile;
  void Initialize() {
    auto sheet = AOD.SheetContainer("assets/tset_wall.png");
    auto Gen_SR(int x, int y) {
      return AOD.SheetRect(sheet, x*32, y*32, x*32 + 33, y*32 + 33);
    }
    walls = [
      Gen_SR(3, 0), Gen_SR(4, 0), Gen_SR(3, 1), Gen_SR(4, 1), // corners
      Gen_SR(1, 2), Gen_SR(0, 1), Gen_SR(2, 1), Gen_SR(1, 0), // walls
      Gen_SR(0, 0), Gen_SR(2, 0), Gen_SR(0, 2), Gen_SR(2, 2), // pokers
      Gen_SR(7, 1), Gen_SR(6, 1), Gen_SR(8, 1), // bricks
      Gen_SR(0, 4), Gen_SR(0, 4), Gen_SR(3, 5), Gen_SR(3, 5),  // hall
      Gen_SR(0, 5), Gen_SR(0, 5)                               // hall
    ];
    sheet = AOD.SheetContainer("assets/tset_props.png");
    props = [
      Gen_SR(0, 0), Gen_SR(1, 0), Gen_SR(2, 0), Gen_SR(3, 0),
      Gen_SR(0, 1), Gen_SR(1, 1), Gen_SR(2, 1), Gen_SR(3, 1)
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
    HUD = AOD.SheetContainer("assets/HUD.png");
    sheet = AOD.SheetContainer("assets/tset_mob.png");
    black = walls[1];
    projectile = AOD.SheetContainer("assets/projectile.png");
    mobs = [
      AOD.SheetRect(sheet , 0   , 0 , 32  , 32) ,
      AOD.SheetRect(sheet , 32  , 0 , 64  , 32) ,
      AOD.SheetRect(sheet , 64  , 0 , 96  , 32) ,
      AOD.SheetRect(sheet , 96  , 0 , 128 , 32) ,
      AOD.SheetRect(sheet , 128 , 0 , 160 , 32) ,

      AOD.SheetRect(sheet , 0   , 32 , 32  , 64) ,
      AOD.SheetRect(sheet , 32  , 32 , 64  , 64) ,
      AOD.SheetRect(sheet , 64  , 32 , 96  , 64) ,
      AOD.SheetRect(sheet , 96  , 32 , 128 , 64) ,
      AOD.SheetRect(sheet , 128 , 32 , 160 , 64) ,

      AOD.SheetRect(sheet , 0   , 64 , 32  , 96) ,
      AOD.SheetRect(sheet , 32  , 64 , 64  , 96) ,
      AOD.SheetRect(sheet , 64  , 64 , 96  , 96) ,
      AOD.SheetRect(sheet , 96  , 64 , 128 , 96) ,
      AOD.SheetRect(sheet , 128 , 64 , 160 , 96) ,

      AOD.SheetRect(sheet , 0   , 96 , 32  , 128) ,
      AOD.SheetRect(sheet , 32  , 96 , 64  , 128) ,
      AOD.SheetRect(sheet , 64  , 96 , 96  , 128) ,
      AOD.SheetRect(sheet , 96  , 96 , 128 , 128) ,
      AOD.SheetRect(sheet , 128 , 96 , 160 , 128) ,

      AOD.SheetRect(sheet , 0   , 128 , 32  , 160) ,
      AOD.SheetRect(sheet , 32  , 128 , 64  , 160) ,
      AOD.SheetRect(sheet , 64  , 128 , 96  , 160) ,
      AOD.SheetRect(sheet , 96  , 128 , 128 , 160) ,
      AOD.SheetRect(sheet , 128 , 128 , 160 , 160) ,

      AOD.SheetRect(sheet , 0   , 128 , 32  , 160) ,
      AOD.SheetRect(sheet , 32  , 128 , 64  , 160) ,
      AOD.SheetRect(sheet , 64  , 128 , 96  , 160) ,
      AOD.SheetRect(sheet , 96  , 128 , 128 , 160) ,
      AOD.SheetRect(sheet , 128 , 128 , 160 , 160)
    ];
  }
}

class Sound {
public: static:
  void Initialize() {

  }
}
