import derelict.opengl3.gl3;
import derelict.sdl2.sdl;
import std.stdio;
static import AOD;

// This is the "standard" way to initialize the engine. My thought process is
// to immediately set up the console so we can receive errors as we initialize
// the AOD engine. Then afterwards we adjust the camera to center of screen
// and load the font & assign console key so we can start reading from the
// console. Everything else after is usually control configuration or debug
void Init () {
  AOD.ClientVars.Load_Config();
  writeln("app.d@Init Setting up console");
  AOD.Console.console_open = false;
  AOD.Console.Set_Console_Output_Type(AOD.Console.Type.Debug_In);
  import std.conv : to;
  AOD.Initialize(16, "LUDUM DARE PREP", 800, 600,
      /* to!int(AOD.ClientVars.commands["resolution_x"]), */
      /* to!int(AOD.ClientVars.commands["resolution_y"]), */
      "assets/credit_aod.bmp");
  AOD.Camera.Set_Size(AOD.Vector(AOD.R_Window_Width(), AOD.R_Window_Height()));
  AOD.Camera.Set_Position(AOD.Vector(AOD.R_Window_Width() /2,
                                     AOD.R_Window_Height()/2));
  AOD.Text.Set_Default_Font("assets/DejaVuSansMono.ttf", 20);
  AOD.Console.Initialize(AOD.Console.Type.Debug_In);
  AOD.Set_BG_Colour(1.0, 1.0, 1.0);
  // --- debug ---
}


void Game_Init () {
/*
*/
  AOD.Sound.Clean_Up();
  static import Data;
  Data.Initialize();
  import Entity.Splashscreen;
  /* AOD.Add(new Splash(Data.Construct_New_Menu)); */
  AOD.Add((Data.Construct_New_Menu));
  /* Game_Manager.Generate_Map(); */
  AOD.Camera.Set_Position(0, 0);
  // -- map
}

int main () {
  Init();
  Game_Init();
  AOD.Run();
  writeln("Ending program");
  return 0;
}
