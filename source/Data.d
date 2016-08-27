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
    wall_ctl = -100, wall_ctr = -101, wall_cll = -102, wall_clr = -103,


    floor_topleft = -108, floor_top = -109, floor_topright = -110,
    floor_left = -111,              floor_right = -112,
    floor_botleft = -113, floor_bot = -114, floor_botright = -115,
  };
  AOD.SheetRect[] walls,
                  floors,
                  mobs;
  AOD.SheetRect black;
  AOD.SheetRect player;
  AOD.SheetContainer HUD, projectile;
  void Initialize() {
    auto sheet = AOD.SheetContainer("assets/tset_wall.png");
    walls = [
      AOD.SheetRect(sheet, 3*32,    0, 3*32 + 32,        32), // tl
      AOD.SheetRect(sheet,   32, 3*32,   32 + 32, 3*32 + 32), // t
      AOD.SheetRect(sheet, 4*32,    0, 4*32 + 32,        32), // tr
      AOD.SheetRect(sheet, 2*32,   32, 2*32 + 32,   32 + 32), // l
      AOD.SheetRect(sheet,    0,   32,   32 + 32,   32 + 32), // r
      AOD.SheetRect(sheet, 3*32,   32, 3*32 + 32,   32 + 32), // bl
      AOD.SheetRect(sheet,   32,    0,   32 + 32,        32), // b
      AOD.SheetRect(sheet, 2*32,    0,   32 + 32,        32)  // br

    ];
    floors = [
      AOD.SheetRect(sheet, 32, 5*32, 64, 5*32+32)
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
