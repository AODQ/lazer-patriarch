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
  AOD.Initialize(16, "SOME SORT OF SYNTHESIZER", 800, 600,
      /* to!int(AOD.ClientVars.commands["resolution_x"]), */
      /* to!int(AOD.ClientVars.commands["resolution_y"]), */
      "assets/credit_aod.bmp");
  AOD.Camera.Set_Size(AOD.Vector(AOD.R_Window_Width(), AOD.R_Window_Height()));
  AOD.Camera.Set_Position(AOD.Vector(AOD.R_Window_Width() /2,
                                     AOD.R_Window_Height()/2));
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
  /* AOD.Add((Data.Construct_New_Menu)); */
  /* Game_Manager.Generate_Map(); */
  AOD.Camera.Set_Position(0, 0);
  AOD.Add(new Entity.UI.HUD);
  // -- map
}

int main () {
  Load_Sounds();
  Init();
  Game_Init();
  AOD.Run();
  writeln("Ending program");
  return 0;
}



import std.stdio, std.math, std.algorithm, std.range, std.random;
import dlib.audio;
// A fun little synthesizer

auto New_sound ( float dur, uint freq ) {
  return new GenericSound(dur, freq, 2, SampleFormat.S16);
}

float fract(float t) {
  return (t - cast(int)(t));
}

float Play_Note ( float time, int index ) {
  import std.random;
  switch ( index ) {
    default:return 0.0f;
    case 1: return sin(6.2831*440.0*time)*exp(-3.0*time);
    case 2: return sin(uniform(0.0f, 0.2f)*140.00f*time) * exp(-3.0*time);
    case 0:
      float f1 = fract(time*0.34f),
            f2 = fract(time*0.34f * 0.95f),
            f3 = fract(time*0.34f * 2.01f);
      return sin(((f1+f2+f3)/1.5f - 1.0f)*1840.0*time)*exp(-6.0*time);
  }
}

void Sound_Create(int index) {
  auto sound = New_sound(3.0f, 1000);
  float time = 0.0f;
  float sample_period = 1.0f/cast(float)sound.sampleRate;
  foreach ( i; 0 .. sound.size ) {
    sound[0, i] = sound[1, i] = Play_Note(time, index);
    time += sample_period;
  }
  writeln("CREATED");
  saveWAV(sound, "test.wav");
}

void Load_Sounds() {
  foreach ( i; 0 .. 3 ) {
    Sound_Create(i);
    import std.process;
    { // lame -V2 test.wav test.ogg
      string estr;
      switch ( i ) {
        default:break;
        case 0: estr = "genz.ogg"; break;
        case 1: estr = "geny.ogg"; break;
        case 2: estr = "genx.ogg"; break;
      }
      auto pid = spawnShell(`oggenc -q 3 -o ` ~ estr ~ ` test.wav`);
      wait(pid);
    }
    { // delete
      auto pid = spawnShell(`rm test.wav`);
      wait(pid);
    }
  }
}
