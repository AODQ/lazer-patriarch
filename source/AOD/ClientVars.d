/**
  Used to keep track of variables defined by the client. This mostly at the
  moment is just keybinds which give the user a direct interface to the console
  through keypresses. Since there are no native console commands, what the user
  can do is completely up to the application writer. In the future audio and
  display settings will be stored here.
*/
module AODCore.clientvars;
import std.string;

/** A binded key */
struct Keybind {
public:
  /**A valid <a href="https://wiki.libsdl.org/SDL_Scancode">SDL_SCANCODE</a>
         or AOD.Input.Mouse_Bind*/
  int key;
  /** A console command, in the majority of cases the user will probably expect
      the console command to occur when the 'key' is pressed */
  string command;
}

/**
  How you wish to use this is entirely up to you. For the majority of cases
  I'd expect the entire array to be iterated and if a key was pressed then the
  associated command would be executed. AOD does not touch this outside of
  Load_Config though
  for the majority of cases I'd expect the entire array to be iterated and
  if a key is pressed then the command will be executed.
*/
Keybind[] keybinds;
/**
  Just stored commands. What you do with this is up to you.
*/
string[string] commands;

import derelict.sdl2.sdl;

/**
  Loads the user config from "config.ini" and stores results in keybinds.<br>
  Will clear keybinds beforehand
*/
void Load_Config() {
  static import AOD;
  keybinds = [];
  R_SDL_Scancode_Conv("", false, true); // reconstruct the scancode map
  auto ini_file = AOD.Util.Load_INI("config.ini");
  auto binds = "keybinds" in ini_file;
  if ( binds !is null ) {
    foreach ( item; (*binds) ) {
      auto b = R_SDL_Scancode_Conv(item.key);
      if ( b !is null )
        keybinds ~= Keybind((*b), item.value);
      else {
        import AODCore.console;
        Debug_Output("Could not parse keybind '" ~ item.key ~ "'");
      }
    }
  }
  auto coms = "command" in ini_file;
  if ( coms !is null ) {
    foreach ( item; (*coms) ) {
      commands[item.key] = item.value;
      // -- DEBUG START
      import std.stdio : writeln;
      import std.conv : to;
      writeln(item.key ~ " -- " ~ item.value);
      // -- DEBUG END
    }
  }
  R_SDL_Scancode_Conv("", true); // destroy scancode map
}

/**
  Saves the user config from keybinds and stores into "config.ini"
*/
void Save_Config() {
  static import AOD;
}

import AODCore.input;

// lazy implementation w/e it's private to only Load Config
private auto R_SDL_Scancode_Conv(string x, bool erase = false,
                                           bool recon = false) {
  static int[immutable(string)] sdl_bind_conv;
  if ( erase )
    sdl_bind_conv.clear();
  if ( recon ) {
    sdl_bind_conv.clear();
    sdl_bind_conv = [
      "mouseleft"               : Mouse_Bind.Left                 ,
      "mouseright"              : Mouse_Bind.Right                ,
      "mousemiddle"             : Mouse_Bind.Middle               ,
      "mouse4"                  : Mouse_Bind.X1                   ,
      "mouse5"                  : Mouse_Bind.X2                   ,
      "mwheelup"                : Mouse_Bind.Wheelup              ,
      "mwheeldown"              : Mouse_Bind.Wheeldown            ,
      "0"                       : SDL_SCANCODE_0                  ,
      "1"                       : SDL_SCANCODE_1                  ,
      "2"                       : SDL_SCANCODE_2                  ,
      "3"                       : SDL_SCANCODE_3                  ,
      "4"                       : SDL_SCANCODE_4                  ,
      "5"                       : SDL_SCANCODE_5                  ,
      "6"                       : SDL_SCANCODE_6                  ,
      "7"                       : SDL_SCANCODE_7                  ,
      "8"                       : SDL_SCANCODE_8                  ,
      "9"                       : SDL_SCANCODE_9                  ,
      "a"                       : SDL_SCANCODE_A                  ,
      "acback"                  : SDL_SCANCODE_AC_BACK            ,
      "acbookmarks"             : SDL_SCANCODE_AC_BOOKMARKS       ,
      "acforward"               : SDL_SCANCODE_AC_FORWARD         ,
      "achome"                  : SDL_SCANCODE_AC_HOME            ,
      "acrefresh"               : SDL_SCANCODE_AC_REFRESH         ,
      "acsearch"                : SDL_SCANCODE_AC_SEARCH          ,
      "acstop"                  : SDL_SCANCODE_AC_STOP            ,
      "again"                   : SDL_SCANCODE_AGAIN              ,
      "alterase"                : SDL_SCANCODE_ALTERASE           ,
      "singlequote"             : SDL_SCANCODE_APOSTROPHE         ,
      "application"             : SDL_SCANCODE_APPLICATION        ,
      "audiomute"               : SDL_SCANCODE_AUDIOMUTE          ,
      "audionext"               : SDL_SCANCODE_AUDIONEXT          ,
      "audioplay"               : SDL_SCANCODE_AUDIOPLAY          ,
      "audioprev"               : SDL_SCANCODE_AUDIOPREV          ,
      "audiostop"               : SDL_SCANCODE_AUDIOSTOP          ,
      "b"                       : SDL_SCANCODE_B                  ,
      "backslash"               : SDL_SCANCODE_BACKSLASH          ,
      "backspace"               : SDL_SCANCODE_BACKSPACE          ,
      "brightnessdown"          : SDL_SCANCODE_BRIGHTNESSDOWN     ,
      "brightnessup"            : SDL_SCANCODE_BRIGHTNESSUP       ,
      "c"                       : SDL_SCANCODE_C                  ,
      "calculator"              : SDL_SCANCODE_CALCULATOR         ,
      "cancel"                  : SDL_SCANCODE_CANCEL             ,
      "capslock"                : SDL_SCANCODE_CAPSLOCK           ,
      "clear"                   : SDL_SCANCODE_CLEAR              ,
      "clear/again"             : SDL_SCANCODE_CLEARAGAIN         ,
      "comma"                   : SDL_SCANCODE_COMMA              ,
      "computer"                : SDL_SCANCODE_COMPUTER           ,
      "copy"                    : SDL_SCANCODE_COPY               ,
      "crsel"                   : SDL_SCANCODE_CRSEL              ,
      "currencysubunit"         : SDL_SCANCODE_CURRENCYSUBUNIT    ,
      "currencyunit"            : SDL_SCANCODE_CURRENCYUNIT       ,
      "cut"                     : SDL_SCANCODE_CUT                ,
      "d"                       : SDL_SCANCODE_D                  ,
      "decimalseparator"        : SDL_SCANCODE_DECIMALSEPARATOR   ,
      "delete"                  : SDL_SCANCODE_DELETE             ,
      "displayswitch"           : SDL_SCANCODE_DISPLAYSWITCH      ,
      "down"                    : SDL_SCANCODE_DOWN               ,
      "e"                       : SDL_SCANCODE_E                  ,
      "eject"                   : SDL_SCANCODE_EJECT              ,
      "end"                     : SDL_SCANCODE_END                ,
      "equals"                  : SDL_SCANCODE_EQUALS             ,
      "escape"                  : SDL_SCANCODE_ESCAPE             ,
      "execute"                 : SDL_SCANCODE_EXECUTE            ,
      "exsel"                   : SDL_SCANCODE_EXSEL              ,
      "f"                       : SDL_SCANCODE_F                  ,
      "f1"                      : SDL_SCANCODE_F1                 ,
      "f10"                     : SDL_SCANCODE_F10                ,
      "f11"                     : SDL_SCANCODE_F11                ,
      "f12"                     : SDL_SCANCODE_F12                ,
      "f13"                     : SDL_SCANCODE_F13                ,
      "f14"                     : SDL_SCANCODE_F14                ,
      "f15"                     : SDL_SCANCODE_F15                ,
      "f16"                     : SDL_SCANCODE_F16                ,
      "f17"                     : SDL_SCANCODE_F17                ,
      "f18"                     : SDL_SCANCODE_F18                ,
      "f19"                     : SDL_SCANCODE_F19                ,
      "f2"                      : SDL_SCANCODE_F2                 ,
      "f20"                     : SDL_SCANCODE_F20                ,
      "f21"                     : SDL_SCANCODE_F21                ,
      "f22"                     : SDL_SCANCODE_F22                ,
      "f23"                     : SDL_SCANCODE_F23                ,
      "f24"                     : SDL_SCANCODE_F24                ,
      "f3"                      : SDL_SCANCODE_F3                 ,
      "f4"                      : SDL_SCANCODE_F4                 ,
      "f5"                      : SDL_SCANCODE_F5                 ,
      "f6"                      : SDL_SCANCODE_F6                 ,
      "f7"                      : SDL_SCANCODE_F7                 ,
      "f8"                      : SDL_SCANCODE_F8                 ,
      "f9"                      : SDL_SCANCODE_F9                 ,
      "find"                    : SDL_SCANCODE_FIND               ,
      "g"                       : SDL_SCANCODE_G                  ,
      "grave"                   : SDL_SCANCODE_GRAVE              ,
      "h"                       : SDL_SCANCODE_H                  ,
      "help"                    : SDL_SCANCODE_HELP               ,
      "home"                    : SDL_SCANCODE_HOME               ,
      "i"                       : SDL_SCANCODE_I                  ,
      "insert"                  : SDL_SCANCODE_INSERT             ,
      "j"                       : SDL_SCANCODE_J                  ,
      "k"                       : SDL_SCANCODE_K                  ,
      "kbdillumdown"            : SDL_SCANCODE_KBDILLUMDOWN       ,
      "kbdillumtoggle"          : SDL_SCANCODE_KBDILLUMTOGGLE     ,
      "kbdillumup"              : SDL_SCANCODE_KBDILLUMUP         ,
      "keypad0"                 : SDL_SCANCODE_KP_0               ,
      "keypad00"                : SDL_SCANCODE_KP_00              ,
      "keypad000"               : SDL_SCANCODE_KP_000             ,
      "keypad1"                 : SDL_SCANCODE_KP_1               ,
      "keypad2"                 : SDL_SCANCODE_KP_2               ,
      "keypad3"                 : SDL_SCANCODE_KP_3               ,
      "keypad4"                 : SDL_SCANCODE_KP_4               ,
      "keypad5"                 : SDL_SCANCODE_KP_5               ,
      "keypad6"                 : SDL_SCANCODE_KP_6               ,
      "keypad7"                 : SDL_SCANCODE_KP_7               ,
      "keypad8"                 : SDL_SCANCODE_KP_8               ,
      "keypad9"                 : SDL_SCANCODE_KP_9               ,
      "keypada"                 : SDL_SCANCODE_KP_A               ,
      "keypadampersand"         : SDL_SCANCODE_KP_AMPERSAND       ,
      "keypadat"                : SDL_SCANCODE_KP_AT              ,
      "keypadb"                 : SDL_SCANCODE_KP_B               ,
      "keypadbackspace"         : SDL_SCANCODE_KP_BACKSPACE       ,
      "keypadbinary"            : SDL_SCANCODE_KP_BINARY          ,
      "keypadc"                 : SDL_SCANCODE_KP_C               ,
      "keypadclear"             : SDL_SCANCODE_KP_CLEAR           ,
      "keypadclearentry"        : SDL_SCANCODE_KP_CLEARENTRY      ,
      "keypadcolon"             : SDL_SCANCODE_KP_COLON           ,
      "keypadcomma"             : SDL_SCANCODE_KP_COMMA           ,
      "keypadd"                 : SDL_SCANCODE_KP_D               ,
      "keypadand"               : SDL_SCANCODE_KP_DBLAMPERSAND    ,
      "keypador"                : SDL_SCANCODE_KP_DBLVERTICALBAR  ,
      "keypaddecimal"           : SDL_SCANCODE_KP_DECIMAL         ,
      "keypadslash"             : SDL_SCANCODE_KP_DIVIDE          ,
      "keypade"                 : SDL_SCANCODE_KP_E               ,
      "keypadenter"             : SDL_SCANCODE_KP_ENTER           ,
      "keypadequals"            : SDL_SCANCODE_KP_EQUALS          ,
      "keypadequals2"           : SDL_SCANCODE_KP_EQUALSAS400     ,
      "keypadexclamation"       : SDL_SCANCODE_KP_EXCLAM          ,
      "keypadf"                 : SDL_SCANCODE_KP_F               ,
      "keypadlessthan"          : SDL_SCANCODE_KP_GREATER         ,
      "keypadpound"             : SDL_SCANCODE_KP_HASH            ,
      "keypadhexadecimal"       : SDL_SCANCODE_KP_HEXADECIMAL     ,
      "keypadcurlybracketstart" : SDL_SCANCODE_KP_LEFTBRACE       ,
      "keypad"                  : SDL_SCANCODE_KP_LEFTPAREN       ,
      "keypadgreaterthan"       : SDL_SCANCODE_KP_LESS            ,
      "keypadmemadd"            : SDL_SCANCODE_KP_MEMADD          ,
      "keypadmemclear"          : SDL_SCANCODE_KP_MEMCLEAR        ,
      "keypadmemdivide"         : SDL_SCANCODE_KP_MEMDIVIDE       ,
      "keypadmemmultiply"       : SDL_SCANCODE_KP_MEMMULTIPLY     ,
      "keypadmemrecall"         : SDL_SCANCODE_KP_MEMRECALL       ,
      "keypadmemstore"          : SDL_SCANCODE_KP_MEMSTORE        ,
      "keypadmemsubtract"       : SDL_SCANCODE_KP_MEMSUBTRACT     ,
      "keypadminus"             : SDL_SCANCODE_KP_MINUS           ,
      "keypadmultiply"          : SDL_SCANCODE_KP_MULTIPLY        ,
      "keypadoctal"             : SDL_SCANCODE_KP_OCTAL           ,
      "keypadmodulo"            : SDL_SCANCODE_KP_PERCENT         ,
      "keypaddot"               : SDL_SCANCODE_KP_PERIOD          ,
      "keypadplus"              : SDL_SCANCODE_KP_PLUS            ,
      "keypadplusorminus"       : SDL_SCANCODE_KP_PLUSMINUS       ,
      "keypadcaret"             : SDL_SCANCODE_KP_POWER           ,
      "keypadcurlybracketend"   : SDL_SCANCODE_KP_RIGHTBRACE      ,
      "keypadparenthesisend"    : SDL_SCANCODE_KP_RIGHTPAREN      ,
      "keypadspace"             : SDL_SCANCODE_KP_SPACE           ,
      "keypadtab"               : SDL_SCANCODE_KP_TAB             ,
      "keypadbitwiseor"         : SDL_SCANCODE_KP_VERTICALBAR     ,
      "keypadxor"               : SDL_SCANCODE_KP_XOR             ,
      "l"                       : SDL_SCANCODE_L                  ,
      "leftalt"                 : SDL_SCANCODE_LALT               ,
      "leftctrl"                : SDL_SCANCODE_LCTRL              ,
      "left"                    : SDL_SCANCODE_LEFT               ,
      "squarebracketstart"      : SDL_SCANCODE_LEFTBRACKET        ,
      "leftgui"                 : SDL_SCANCODE_LGUI               ,
      "lshift"                  : SDL_SCANCODE_LSHIFT             ,
      "m"                       : SDL_SCANCODE_M                  ,
      "mail"                    : SDL_SCANCODE_MAIL               ,
      "mediaselect"             : SDL_SCANCODE_MEDIASELECT        ,
      "menu"                    : SDL_SCANCODE_MENU               ,
      "minus"                   : SDL_SCANCODE_MINUS              ,
      "modeswitch"              : SDL_SCANCODE_MODE               ,
      "mute"                    : SDL_SCANCODE_MUTE               ,
      "n"                       : SDL_SCANCODE_N                  ,
      "numlock"                 : SDL_SCANCODE_NUMLOCKCLEAR       ,
      "o"                       : SDL_SCANCODE_O                  ,
      "oper"                    : SDL_SCANCODE_OPER               ,
      "out"                     : SDL_SCANCODE_OUT                ,
      "p"                       : SDL_SCANCODE_P                  ,
      "pagedown"                : SDL_SCANCODE_PAGEDOWN           ,
      "pageup"                  : SDL_SCANCODE_PAGEUP             ,
      "paste"                   : SDL_SCANCODE_PASTE              ,
      "pause"                   : SDL_SCANCODE_PAUSE              ,
      "dot"                     : SDL_SCANCODE_PERIOD             ,
      "power"                   : SDL_SCANCODE_POWER              ,
      "printscreen"             : SDL_SCANCODE_PRINTSCREEN        ,
      "prior"                   : SDL_SCANCODE_PRIOR              ,
      "q"                       : SDL_SCANCODE_Q                  ,
      "r"                       : SDL_SCANCODE_R                  ,
      "rightalt"                : SDL_SCANCODE_RALT               ,
      "rightctrl"               : SDL_SCANCODE_RCTRL              ,
      "return"                  : SDL_SCANCODE_RETURN             ,
      "return2"                 : SDL_SCANCODE_RETURN2            ,
      "rightgui"                : SDL_SCANCODE_RGUI               ,
      "right"                   : SDL_SCANCODE_RIGHT              ,
      "squarebracketend"        : SDL_SCANCODE_RIGHTBRACKET       ,
      "rshift"                  : SDL_SCANCODE_RSHIFT             ,
      "s"                       : SDL_SCANCODE_S                  ,
      "scrolllock"              : SDL_SCANCODE_SCROLLLOCK         ,
      "select"                  : SDL_SCANCODE_SELECT             ,
      "semicolon"               : SDL_SCANCODE_SEMICOLON          ,
      "separator"               : SDL_SCANCODE_SEPARATOR          ,
      "slash"                   : SDL_SCANCODE_SLASH              ,
      "sleep"                   : SDL_SCANCODE_SLEEP              ,
      "space"                   : SDL_SCANCODE_SPACE              ,
      "stop"                    : SDL_SCANCODE_STOP               ,
      "sysreq"                  : SDL_SCANCODE_SYSREQ             ,
      "t"                       : SDL_SCANCODE_T                  ,
      "tab"                     : SDL_SCANCODE_TAB                ,
      "thousandsseparator"      : SDL_SCANCODE_THOUSANDSSEPARATOR ,
      "u"                       : SDL_SCANCODE_U                  ,
      "undo"                    : SDL_SCANCODE_UNDO               ,
      "up"                      : SDL_SCANCODE_UP                 ,
      "v"                       : SDL_SCANCODE_V                  ,
      "volumedown"              : SDL_SCANCODE_VOLUMEDOWN         ,
      "volumeup"                : SDL_SCANCODE_VOLUMEUP           ,
      "w"                       : SDL_SCANCODE_W                  ,
      "www"                     : SDL_SCANCODE_WWW                ,
      "x"                       : SDL_SCANCODE_X                  ,
      "y"                       : SDL_SCANCODE_Y                  ,
      "z"                       : SDL_SCANCODE_Z
    ];
  }
  return x in sdl_bind_conv;
}
