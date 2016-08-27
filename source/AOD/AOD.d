/**
  <br><br>
  The main interface to Art of Dwarficorn. Importing this file alone will
  give you access to the majority of the library. The functions defined here
  are only part of the Realm interface.
  <br>
Example:
<br>
---
// This is the "standard" way to initialize the engine. The console is set up
// first so that errors can be received as the AOD Engine is initialized.
// Afterwards the camera is adjusted to the center of the screen, the font is
// loaded , and the console key is assigned. Then we load the key config
void Init () {
  import AOD;
  Console.console_open = false;
  Console.Set_Console_Output_Type(AOD.Console.Type.Debug_In);
  Initialize(16, "ART OF DWARFICORN", 640, 480);
  Camera.Set_Size(AOD.Vector(AOD.R_Window_Width(), AOD.R_Window_Height()));
  Camera.Set_Position(AOD.Vector(AOD.R_Window_Width() /2,
                                     AOD.R_Window_Height()/2));
  Text.Set_Default_Font("assets/DejaVuSansMono.ttf", 13);
  Console.Initialize(Console.Type.Debug_In);
  Set_BG_Colour(.08, .08, .095);
  Load_Config();
}
---
*/
module AOD;

import derelict.opengl3.gl;
import derelict.opengl3.gl3;
import derelict.sdl2.sdl;
import std.stdio;
import std.string;

static import AODCore.camera;
static import AODCore.camera;
static import AODCore.clientvars;
static import AODCore.entity;
static import AODCore.matrix;
static import AODCore.realm;
static import AODCore.render_base;
static import AODCore.shader;
static import AODCore.sound;
static import AODCore.text;
static import AODCore.utility;
static import AODCore.vector;

// --------------------- realm -------------------------------------------------

private AODCore.realm.Realm realm = null;

/** Initializes the engine
  Params:
    msdt   = Amount of milliseconds between each update frame call
    name   = Name of the application (for the window title)
    width  = Window X dimension
    height = Window Y dimension
    ico    = File location of the icon to use for the application
*/
void Initialize(uint msdt, string name, int width, int height, string ico = "")
in {
  assert(realm is null);
} body {
  if ( name == "" )
    name = "Art of Dwarficorn";
  realm = new AODCore.realm.Realm(width, height, msdt, name.ptr, ico.ptr);
}
/** Changes the amount of milliseconds between each update frame call */
void Change_MSDT(Uint32 ms_dt) in { assert(realm !is null); } body {
  realm.Change_MSDT(ms_dt);
}
/** Resets the engine */
@disable void Reset() in { assert(realm  is null); } body { /* ... todo ... */ }
/** Ends the engine and deallocates all resources */
void End()   in { assert(realm !is null); } body {
  realm.End();
  realm = null;
}

/** Adds rbase to the engine to be updated and rendered */
int  Add   (AODCore.render_base.Render_Base o) in {assert(realm !is null);}
body { return realm.Add(o);    }
/** Removes rbase from the engine and deallocates it */
void Remove(AODCore.render_base.Render_Base o) in {assert(realm !is null);}
body {        realm.Remove(o); }
/** Removes entities and playing sounds (not loaded sounds or images)
Params:
  rendereable = Adds a rendereable after cleanup is done (cleanup doesn't take
                 place until after the frame is finished)
*/
void Clean_Up(AODCore.render_base.Render_Base rendereable = null) in {
  assert(realm !is null);
} body { realm.Clean_Up(rendereable); }
/** Sets the background colour when rendering
  Params:
    r = Red
    g = Green
    b = Blue
*/
void Set_BG_Colour(GLfloat r, GLfloat g, GLfloat b) in {
  assert(realm !is null);
} body {
  realm.Set_BG_Colours(r, g, b);
}

/** Runs the engine (won't return until SDL_Quit is called) */
void Run() in { assert(realm !is null); } body {
  // do splash screen
  /* import AODCore.Splashscreen; */
  /* AOD.Add(new Splash); */
  // now run
  realm.Run();
}

/** Returns the current MS per frame */
float R_MS()         { return realm.R_MS();   }
/** Calculates the minimal amount of frames required for the duration to occur
  Params:
    x = duration
*/
float To_MS(float x) { return realm.To_MS(x); }

/**
  Return:
    Returns the window width in pixels
*/
int R_Window_Width()  { return realm.R_Width();  }
/**
  Return:
    Returns the window height in pixels
*/
int R_Window_Height() { return realm.R_Height(); }

// --------------------- Menu --------------------------------------------------
/** */
alias Menu = AODCore.menu.Menu;
// --------------------- Vector/Matrix/Utility ---------------------------------

/** */
alias Vector = AODCore.vector.Vector;
/** */
alias Node   = AODCore.vector.Node;
/** */
alias Matrix = AODCore.matrix.Matrix;

/** Bindings to the AODCore.Utility module */
/** */
alias R_Rand = AODCore.utility.R_Rand;
class Util {
public: static:
  /** */
  alias R_Max  = AODCore.utility.R_Max;
  /** */
  alias R_Min  = AODCore.utility.R_Min;
  /** */
  alias To_Rad = AODCore.utility.To_Rad;
  /** */
  alias To_Deg = AODCore.utility.To_Deg;

  alias E         = AODCore.utility.E;
  alias Log10E    = AODCore.utility.Log10E;
  alias Log2E     = AODCore.utility.Log2E;
  alias Pi        = AODCore.utility.Pi;
  alias Tau       = AODCore.utility.Tau;
  alias Max_float = AODCore.utility.Max_float;
  alias Min_float = AODCore.utility.Min_float;
  alias Epsilon   = AODCore.utility.Epsilon;

  alias Remove    = AODCore.utility.Remove;

  /** */
  alias Bresenham_Line = AODCore.utility.Bresenham_Line;

  /** */
  alias Load_INI  = AODCore.utility.Load_INI;
  /** */
  alias INI_Data  = AODCore.utility.INI_Data;
}

alias Direction = AODCore.utility.Direction;

// --------------------- Entity ------------------------------------------------

  /** */
alias Entity     = AODCore.entity.Entity;
  /** */
alias PolyEntity = AODCore.entity.PolyEnt;
  /** */
alias AABBEntity = AODCore.entity.AABBEnt;

// --------------------- Text --------------------------------------------------

/** */
alias Text = AODCore.text.Text;

// --------------------- Image -------------------------------------------------

  /** */
alias SheetContainer   = AODCore.image.SheetContainer;
  /** */
alias SheetRect        = AODCore.image.SheetRect;
  /** */
alias Load_Image       = AODCore.image.Load_Image;

// --------------------- Animation ---------------------------------------------

  /** */
alias Animation        = AODCore.animation.Animation;
  /** */
alias Animation_Player = AODCore.animation.Animation_Player;

// --------------------- Shader ------------------------------------------------

 /** */
alias Shader = AODCore.shader.Shader;

// --------------------- Camera ------------------------------------------------

  /** */
class Camera {
public: static:
  /** */
  alias Set_Position    = AODCore.camera.Set_Position;
  /** */
  alias Set_Size        = AODCore.camera.Set_Size;
  /** */
  alias R_Size          = AODCore.camera.R_Size;
  /** */
  alias R_Position      = AODCore.camera.R_Position;
  /** */
  alias R_Origin_Offset = AODCore.camera.R_Origin_Offset;
}

// --------------------- ClientVars --------------------------------------------

  /** */
class ClientVars {
public: static:
  /** */
  alias Keybind       = AODCore.clientvars.Keybind;
  /** */
  alias keybinds      = AODCore.clientvars.keybinds;
  /** */
  alias commands      = AODCore.clientvars.commands;
  /** */
  alias Load_Config   = AODCore.clientvars.Load_Config;
}

// --------------------- Console -----------------------------------------------

  /** */
class Console {
public: static:
  /** */
  alias Type                    = AODCore.console.Type;
  /** */
  alias console_open            = AODCore.console.console_open;
  /** */
  alias Set_Open_Console_Key    = AODCore.console.Set_Open_Console_Key;
  /** */
  alias Set_Console_History     = AODCore.console.Set_Console_History;
  /** */
  alias Set_Console_Output_Type = AODCore.console.Set_Console_Output_Type;
  /** */
  alias Initialize              = AODCore.console.Initialize;
}
  /** */
alias Output = AODCore.console.Output;


// --------------------- Input -------------------------------------------------

  /** */
class Input {
  /** */
  alias Mouse_Bind         = AODCore.input.Mouse_Bind;
  /** */
  alias keystate           = AODCore.input.keystate;
  /** */
  alias R_LMB              = AODCore.input.R_LMB;
  /** */
  alias R_RMB              = AODCore.input.R_RMB;
  /** */
  alias R_MMB              = AODCore.input.R_MMB;
  /** */
  alias R_MX1              = AODCore.input.R_MX1;
  /** */
  alias R_MX2              = AODCore.input.R_MX2;
  /** */
  alias R_On_LMB           = AODCore.input.R_On_LMB;
  /** */
  alias R_On_RMB           = AODCore.input.R_On_RMB;
  /** */
  alias R_On_MMB           = AODCore.input.R_On_MMB;
  /** */
  alias R_On_MX1           = AODCore.input.R_On_MX1;
  /** */
  alias R_On_MX2           = AODCore.input.R_On_MX2;
  /** */
  alias R_Mouse_X          = AODCore.input.R_Mouse_X;
  /** */
  alias R_Mouse_Y          = AODCore.input.R_Mouse_Y;
  /** */
  alias Key_To_String = AODCore.input.Key_To_String;
}

// --------------------- Sound -------------------------------------------------

alias Load_Sound = AODCore.sound.Sound.Load_Sound;
alias Play_Sound = AODCore.sound.Sound.Play_Sound;
alias Stop_Sound = AODCore.sound.Sound.Stop_Sound;
class Sound {
  alias Change_Sample_Position = AODCore.sound.Sound.Change_Sound_Position;
  alias Clean_Up               = AODCore.sound.Sound.Clean_Up;
}


// ------------------- misc functions ------------------------------------------
// these functions are required to be put down here so that the documentation
// generator can use these aliases rather the internal names
// (AODCore.text.Text -> AOD.Text)

/** Sets current FPS Display text and adds it to the engine
  Params:
    fps_text = A text that the engine will use to calculate the FPS.
               You have to manually set the position and font yourself
*/
void Set_FPS_Display(AOD.Text fps_text) in { assert(realm !is null); }
body { realm.Set_FPS_Display(fps_text);}

// ------------------- s c r a p s  --------------------------------------------
/* case SDL_MOUSEWHEEL: */
/*   if ( _event.wheel.y > 0 ) // positive away from user */
/*     Input::keys[ MOUSEBIND::MWHEELUP ] = true; */
/*   else if ( _event.wheel.y < 0 ) */
/*     Input::keys[ MOUSEBIND::MWHEELDOWN ] = true; */
/* break; */
/* case SDL_KEYDOWN: */
/*   // check if backspace or copy/paste */
/*   if ( Console::console_open ) { */
/*     switch ( _event.key.keysym.sym ) { */
/*       case SDLK_BACKSPACE: */
/*         if ( Console::input->R_Str().length() > 0 ) { */
/*           Console::input.Set_S */
/*           Console::input.R_Str().pop_back(); */
/*           Update_Console_Input_Position(); */
/*         } */
/*       break; */
/*       case SDLK_DELETE: */
/*         if ( Console::input_after->R_Str().length() > 0 ) { */
/*           Console::input_after->R_Str().erase(0, 1); */
/*           Update_Console_Input_Position(); */
/*         } */
/*       break; */
/*       case SDLK_c: // copy */
/*         if ( SDL_GetModState() & KMOD_CTRL ) { */
/*           SDL_SetClipboardText( Console::input->R_Str().c_str() ); */
/*           Update_Console_Input_Position(); */
/*         } */
/*       break; */
/*       case SDLK_v: // paste */
/*         if ( SDL_GetModState() & KMOD_CTRL ) { */
/*           chptr = SDL_GetClipboardText(); */
/*           Console::input.Set_String( chptr ); */
/*           SDL_free(chptr); */
/*           Update_Console_Input_Position(); */
/*         } */
/*       break; */
/*       case SDLK_LEFT: // navigate cursor left */
/*         tex = Console::input->R_Str(); */
/*         if ( tex.length() > 0 ) { */
/*           tex = tex[tex.length()-1]; */
/*           Console::input->R_Str().pop_back(); */
/*           Console::input_after->R_Str().insert(0, tex); */

/*           // skip word */
/*           /1* if ( SDL_GetModState() & KMOD_CTRL ) { *1/ */
/*           /1*   alnum = isalnum(tex[0]); *1/ */
/*           /1*   while ( Console::input->R_Str().length() > 0 ) { *1/ */
/*           /1*     tex = Console::input->R_Str(); *1/ */
/*           /1*     tex = tex[tex.length()-1]; *1/ */
/*           /1*     if ( (bool)isalnum(tex[0]) == alnum ) { *1/ */
/*           /1*       Console::input->R_Str().pop_back(); *1/ */
/*           /1*       Console::input_after->R_Str().insert(0, tex); *1/ */
/*           /1*     } else break; *1/ */
/*           /1*   } *1/ */
/*           /1* } *1/ */

/*           Update_Console_Input_Position(); */
/*         } */
/*       break; */
/*       case SDLK_RIGHT: // navigate cursor right */
/*         tex = Console::input_after->R_Str(); */
/*         if ( tex.length() > 0 ) { */
/*           tex = tex[0]; */
/*           Console::input_after->R_Str().erase(0, 1); */
/*           Console::input->R_Str().push_back(tex[0]); */

/*           // skip word */
/*           /1* if ( SDL_GetModState() & KMOD_CTRL ) { *1/ */
/*           /1*   alnum = isalnum(tex[0]); *1/ */
/*           /1*   while ( Console::input_after->R_Str().length() > 0 ) { *1/ */
/*           /1*     tex = Console::input_after->R_Str(); *1/ */
/*           /1*     tex = tex[0]; *1/ */
/*           /1*     if ( (bool)isalnum(tex[0]) == alnum ) { *1/ */
/*           /1*       Console::input_after->R_Str().erase(0, 1); *1/ */
/*           /1*       Console::input->R_Str().push_back(tex[0]); *1/ */
/*           /1*     } else break; *1/ */
/*           /1*   } *1/ */
/*           /1* } *1/ */

/*           Update_Console_Input_Position(); */
/*         } */
/*       break; */
/*       case SDLK_RETURN: case SDLK_RETURN2: */
/*         to_handle = Console::input->R_Str() + */
/*                     Console::input_after->R_Str(); */
/*         if ( to_handle != "" ) { */
/*           Console::input->Set_String(""); */
/*           Console::input_after->Set_String(""); */
/*           Handle_Console_Input(to_handle); */
/*           Update_Console_Input_Position(); */
/*         } */
/*       break; */
/*       case SDLK_END: */
/*         Console::input->R_Str() += Console::input_after->R_Str(); */
/*         Console::input_after->R_Str().clear(); */
/*         Update_Console_Input_Position(); */
/*       break; */
/*       case SDLK_HOME: */
/*         // since appending is faster than prepending */
/*         Console::input->R_Str() += Console::input_after->R_Str(); */
/*         Console::input_after->R_Str() = Console::input->R_Str(); */
/*         Console::input->R_Str().clear(); */
/*         Update_Console_Input_Position(); */
/*       break; */
/*     } */
/*   } */
/* break; */
/* case SDL_TEXTINPUT: */
/*   if ( AOD::Console::console_open ) { */
/*     if ( (SDL_GetModState() & KMOD_CTRL) || */
/*           _event.text.text[0] == '~' || _event.text.text[0] == '`' ) */
/*       break; */
/*     Console::input->R_Str() += _event.text.text; */
/*     Update_Console_Input_Position(); */
/*   } */
/* break; */
