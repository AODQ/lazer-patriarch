module Entity.UI;
static import AOD;
static import Data;

class HUD : AOD.Entity {
public:
  this() {
    super(Data.Layer.UI);
    Set_Static_Pos(true);
    Set_Position(AOD.R_Window_Width/2, 18/2);
    Set_Sprite(Data.Image.HUD);
  }
  override void Update() {
    import std.stdio;
    import derelict.sdl2.sdl;
    static bool z, x, c;
    // probably the worst code i have ever wrote but whatever
    if ( AOD.Input.keystate[ SDL_SCANCODE_Z ] ) {
      if ( !z ) {
        z = true;
        AOD.Play_Sound(Data.Sound.Z);
      }
    } else z = false;
    if ( AOD.Input.keystate[ SDL_SCANCODE_X ] ) {
      if ( !x ) {
        x = true;
        AOD.Play_Sound(Data.Sound.X);
      }
    } else x = false;
    if ( AOD.Input.keystate[ SDL_SCANCODE_C ] ) {
      if ( !c ) {
        c = true;
        AOD.Play_Sound(Data.Sound.C);
      }
    } else c = false;
  }
}
