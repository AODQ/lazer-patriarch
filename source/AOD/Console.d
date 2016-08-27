/**
  Gives a form of communication between the user and the program.
*/
module AODCore.console;
import AODCore.text;
import AODCore.entity;
import AODCore.input;
import AODCore.clientvars;
import AODCore.vector;
import derelict.opengl3.gl3;
import std.stdio : writeln;
import derelict.sdl2.sdl;
import std.string;

/** Initializes the Console (it will not function until this is done,
    meaning that if you dislike the Console you do not need to
    use it)
params:
  console_type = Sets the console_type (see Type)
  key          = Sets key for which console will open to
*/
void Initialize(Type console_type, SDL_Keycode key = SDL_SCANCODE_GRAVE) {
  ConsEng.console_type = console_type;
  Debug_Output("Created new console");
  ConsEng.key = key;
  ConsEng.Construct();
}

/** Outputs a message to the console
Params:
  msg = A message that has no new lines
*/
void Output(string msg) {
  writeln(msg);
  Out(msg);
}

/** Should be used only by the AOD engine but if you want to have messages that
    only appear in a debug enviornment then this would be a good choice.
*/
void Debug_Output(string ot) {
  writeln("AOD SAYS: " ~ ot);
  if ( ConsEng.console_type == Type.Debug_In )
    Out(ot);
}

/** Determines if the console is open or not */
bool console_open = 0;

/** Sets the key for which the console will open to */
void Set_Open_Console_Key(SDL_Keycode k) {
  ConsEng.key = k;
}

/** Sets the amount of messages the console will keep */
void Set_Console_History(int history_limit) {
  ConsEng.console_history = history_limit;
}

/** */
void Set_Console_Output_Type(Type otype) {
  ConsEng.console_type = otype;
}

private void Out ( string o ) {
  ConsEng.to_console ~= o;
}

/**
  Used to determine the type of console output
*/
enum Type {
  /** Disable console */
  None      = 0,
  /** Allow debug messages generated from the AOD engine to be outputted */
  Debug_In  = 1,
  /** Forbid debug messages generated from the AOD engine to be outputted */
  Debug_Out = 2
}

class ConsEng {
static:
  Type console_type = Type.None;
  GLuint console_image = 0;
  Text[] console_text;
  Text input, input_after, input_sig;
  Entity cursor, background;
  int console_input_cursor,
      console_input_select_len;
  string[] to_console;
  int console_history = 9;
  ubyte console_message_count;
  int key;

  void Construct() {
    input = new Text(12, 100, "");
    input_after = new Text(10, 100, "");
    input_sig   = new Text(0, 100, ">>");
    input_sig.Set_Visible(0);
    cursor = new Entity(0);
    cursor.Set_Image_Size(Vector(1, 10));
    cursor.Set_Visible(0);
    cursor.Set_Position(13, 96);
    background = new Entity(0);
    static import AOD;
    background.Set_Image_Size(Vector(AOD.R_Window_Width(), 103));
    background.Set_Visible(0);
    background.Set_Position(AOD.R_Window_Width()/2, 103/2);
    background.Set_Colour(0.3, 0.3, 0.2);
    AOD.Add(input);
    AOD.Add(input_after);
    AOD.Add(input_sig);
    AOD.Add(background);
    AOD.Add(cursor);
  }
  void Deconstruct() {
    console_text = [];
    static import AOD;
    AOD.Remove(input);
    AOD.Remove(input_after);
    AOD.Remove(cursor);
  }

  void Refresh() {
    if ( console_type == Type.Debug_In || console_type == Type.Debug_Out ) {
      if ( keystate[ key ] ) {
        console_open ^= 1;
        if ( console_open ) {
          for ( int i = 0; i != console_text.length; ++ i ) {
            console_text[i].Set_Visible(1);
            console_text[i].Set_To_Default();
          }
          input.Set_Visible(1);
          input_after.Set_Visible(1);
          input_sig.Set_Visible(1);
          cursor.Set_Visible(1);
          background.Set_Visible(1);
          SDL_StartTextInput();
        } else {
          input.Set_Visible(0);
          input_sig.Set_Visible(0);
          input_after.Set_Visible(0);
          cursor.Set_Visible(0);
          background.Set_Visible(0);
          SDL_StopTextInput();
        }
      }
      keystate[ key ] = 0;
      if ( console_open )
        for ( int i = cast(int)(console_text.length-1); i != -1; -- i )
          console_text[i].Set_Position(3, 1 + (console_text.length - i)*10);
    }
    // push back new texts
    foreach ( i; to_console ) {
      auto txt = new Text(-20,-20,i);
      console_text = txt ~ console_text;
    }
    to_console = [];
    // pop back old debugs
    while ( console_text.length > console_history ) {
      static import AOD;
      AOD.Remove(console_text[console_text.length-1]);
      -- console_text.length;
    }
  }
}

