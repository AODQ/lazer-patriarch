/**
  Describes the input of the current state of the Engine
*/
module AODCore.input;
import derelict.sdl2.sdl;
import Camera = AODCore.camera;

// These represent SDL_ScanCodes. These are prefereable
// to just calling R_LMB() or w/e b/c these are bindeable
// from INI file
/**
  These represent SDL_ScanCodes. These are preferable to just calling
  mouse functions because these are bindeable from the config INI
*/
enum Mouse_Bind
     { Left = 300, Right = 301, Middle = 302,
       Wheelup  = 303, Wheeldown = 304,
       /** (also known as "mouse4") */
       X1   = 305,
       /** (also known as "mouse5") */
       X2    = 306
     };

/**
  The current state of the keyboard (and mouse). Use either Mouse_Bind or
  <a href="https://wiki.libsdl.org/SDL_Scancode">SDL_SCANCODE</a> for index.
Example:
---
  if ( keystate [ SDL_SCANCODE_A ] ) Output("A pressed");
---
*/
ubyte* keystate;

class MouseEngine {
static: private:
  uint mouse, last_frame_mouse;
  int mouse_x, mouse_y;
static: public:
  void Refresh_Input() {
    last_frame_mouse = mouse;
    keystate = cast(ubyte*)(SDL_GetKeyboardState(null));
    mouse = SDL_GetMouseState(&mouse_x, &mouse_y);
    keystate[ Mouse_Bind.Left   ] = R_LMB();
    keystate[ Mouse_Bind.Right  ] = R_RMB();
    keystate[ Mouse_Bind.Middle ] = R_MMB();
    keystate[ Mouse_Bind.X1     ] = R_MX1();
    keystate[ Mouse_Bind.X2     ] = R_MX2();
    // Let AODCore.D handle mouse wheel
  }
}

private alias MEngine = MouseEngine;

private uint  MLEFT   = SDL_BUTTON(SDL_BUTTON_LEFT),
              MRIGHT  = SDL_BUTTON(SDL_BUTTON_RIGHT),
              MMIDDLE = SDL_BUTTON(SDL_BUTTON_MIDDLE),
              MX1     = SDL_BUTTON(SDL_BUTTON_X1),
              MX2     = SDL_BUTTON(SDL_BUTTON_X2);

/** Returns: if the Left Mouse button is pressed */
bool R_LMB() { return cast(bool)MEngine.mouse&MLEFT  ; }
/** Returns: if the Right Mouse button is pressed */
bool R_RMB() { return cast(bool)MEngine.mouse&MRIGHT ; }
/** Returns: if the Middle Mouse button is pressed */
bool R_MMB() { return cast(bool)MEngine.mouse&MMIDDLE; }
/** Returns: if MouseX1 (mouse4) button is pressed */
bool R_MX1() { return cast(bool)MEngine.mouse&MX1    ; }
/** Returns: if MouseX2 (mouse5) button is pressed */
bool R_MX2() { return cast(bool)MEngine.mouse&MX2    ; }

/** Returns: if the Left Mouse button was clicked on this frame */
bool R_On_LMB() { return cast(bool)MEngine.mouse            &MLEFT &&
                        !cast(bool)MEngine.last_frame_mouse&MLEFT; }
/** Returns: if the Right Mouse button was clicked on this frame */
bool R_On_RMB() { return cast(bool)MEngine.mouse           &MRIGHT &&
                        !cast(bool)MEngine.last_frame_mouse&MRIGHT; }
/** Returns: if the Middle Mouse button was clicked on this frame */
bool R_On_MMB() { return cast(bool)MEngine.mouse           &MMIDDLE &&
                        !cast(bool)MEngine.last_frame_mouse&MMIDDLE; }
/** Returns: if MouseX1 (mouse4) button was clicked on this frame */
bool R_On_MX1() { return cast(bool)MEngine.mouse           &MX1 &&
                        !cast(bool)MEngine.last_frame_mouse&MX1; }
/** Returns: if MouseX2 (mouse5) button was clicked on this frame */
bool R_On_MX2() { return cast(bool)MEngine.mouse           &MX2 &&
                        !cast(bool)MEngine.last_frame_mouse&MX2; }
/**
Params:
  camoffset = Whether to offset the position of the mouse with the camera
Returns:
  The position of the mouse on the x-axis
*/
float R_Mouse_X(bool camoffset) {
  return MouseEngine.mouse_x + (camoffset ?
          Camera.R_Position().x - Camera.R_Size().x/2 : 0);
}
/**
Params:
  camoffset = Whether to offset the position of the mouse with the camera
Returns:
  The position of the mouse on the y-axis
*/
float R_Mouse_Y(bool camoffset) {
  return MouseEngine.mouse_y + (camoffset ?
          Camera.R_Position().y - Camera.R_Size().y/2 : 0);
}

/**
  Converts an SDL_Keycode (SDL_SCANCODE) to a string, but the addition of
  using this over Scancode_To_String is that it includes the mousebinds
*/
string Key_To_String(SDL_Keycode k) {
  import std.conv : to;
  switch ( k ) {
    default: return to!string(SDL_GetKeyName(k));
    case Mouse_Bind.Left                  : return "mouseleft"          ;
    case Mouse_Bind.Right                 : return "mouseright"         ;
    case Mouse_Bind.Middle                : return "mousemiddle"        ;
    case Mouse_Bind.X1                    : return "mouse4"             ;
    case Mouse_Bind.X2                    : return "mouse5"             ;
    case Mouse_Bind.Wheelup               : return "mwheelup"           ;
    case Mouse_Bind.Wheeldown             : return "mwheeldown"         ;
    case SDL_SCANCODE_0                   : return "0"                  ;
    case SDL_SCANCODE_1                   : return "1"                  ;
    case SDL_SCANCODE_2                   : return "2"                  ;
    case SDL_SCANCODE_3                   : return "3"                  ;
    case SDL_SCANCODE_4                   : return "4"                  ;
    case SDL_SCANCODE_5                   : return "5"                  ;
    case SDL_SCANCODE_6                   : return "6"                  ;
    case SDL_SCANCODE_7                   : return "7"                  ;
    case SDL_SCANCODE_8                   : return "8"                  ;
    case SDL_SCANCODE_9                   : return "9"                  ;
    case SDL_SCANCODE_A                   : return "a"                  ;
    case SDL_SCANCODE_AC_BACK             : return "acback"             ;
    case SDL_SCANCODE_AC_BOOKMARKS        : return "acbookmarks"        ;
    case SDL_SCANCODE_AC_FORWARD          : return "acforward"          ;
    case SDL_SCANCODE_AC_HOME             : return "achome"             ;
    case SDL_SCANCODE_AC_REFRESH          : return "acrefresh"          ;
    case SDL_SCANCODE_AC_SEARCH           : return "acsearch"           ;
    case SDL_SCANCODE_AC_STOP             : return "acstop"             ;
    case SDL_SCANCODE_AGAIN               : return "again"              ;
    case SDL_SCANCODE_ALTERASE            : return "alterase"           ;
    case SDL_SCANCODE_APOSTROPHE          : return "singlequote"        ;
    case SDL_SCANCODE_APPLICATION         : return "application"        ;
    case SDL_SCANCODE_AUDIOMUTE           : return "audiomute"          ;
    case SDL_SCANCODE_AUDIONEXT           : return "audionext"          ;
    case SDL_SCANCODE_AUDIOPLAY           : return "audioplay"          ;
    case SDL_SCANCODE_AUDIOPREV           : return "audioprev"          ;
    case SDL_SCANCODE_AUDIOSTOP           : return "audiostop"          ;
    case SDL_SCANCODE_B                   : return "b"                  ;
    case SDL_SCANCODE_BACKSLASH           : return "backslash"          ;
    case SDL_SCANCODE_BACKSPACE           : return "backspace"          ;
    case SDL_SCANCODE_BRIGHTNESSDOWN      : return "brightnessdown"     ;
    case SDL_SCANCODE_BRIGHTNESSUP        : return "brightnessup"       ;
    case SDL_SCANCODE_C                   : return "c"                  ;
    case SDL_SCANCODE_CALCULATOR          : return "calculator"         ;
    case SDL_SCANCODE_CANCEL              : return "cancel"             ;
    case SDL_SCANCODE_CAPSLOCK            : return "capslock"           ;
    case SDL_SCANCODE_CLEAR               : return "clear"              ;
    case SDL_SCANCODE_CLEARAGAIN          : return "clear/again"        ;
    case SDL_SCANCODE_COMMA               : return "comma"              ;
    case SDL_SCANCODE_COMPUTER            : return "computer"           ;
    case SDL_SCANCODE_COPY                : return "copy"               ;
    case SDL_SCANCODE_CRSEL               : return "crsel"              ;
    case SDL_SCANCODE_CURRENCYSUBUNIT     : return "currencysubunit"    ;
    case SDL_SCANCODE_CURRENCYUNIT        : return "currencyunit"       ;
    case SDL_SCANCODE_CUT                 : return "cut"                ;
    case SDL_SCANCODE_D                   : return "d"                  ;
    case SDL_SCANCODE_DECIMALSEPARATOR    : return "decimalseparator"   ;
    case SDL_SCANCODE_DELETE              : return "delete"             ;
    case SDL_SCANCODE_DISPLAYSWITCH       : return "displayswitch"      ;
    case SDL_SCANCODE_DOWN                : return "down"               ;
    case SDL_SCANCODE_E                   : return "e"                  ;
    case SDL_SCANCODE_EJECT               : return "eject"              ;
    case SDL_SCANCODE_END                 : return "end"                ;
    case SDL_SCANCODE_EQUALS              : return "equals"             ;
    case SDL_SCANCODE_ESCAPE              : return "escape"             ;
    case SDL_SCANCODE_EXECUTE             : return "execute"            ;
    case SDL_SCANCODE_EXSEL               : return "exsel"              ;
    case SDL_SCANCODE_F                   : return "f"                  ;
    case SDL_SCANCODE_F1                  : return "f1"                 ;
    case SDL_SCANCODE_F10                 : return "f10"                ;
    case SDL_SCANCODE_F11                 : return "f11"                ;
    case SDL_SCANCODE_F12                 : return "f12"                ;
    case SDL_SCANCODE_F13                 : return "f13"                ;
    case SDL_SCANCODE_F14                 : return "f14"                ;
    case SDL_SCANCODE_F15                 : return "f15"                ;
    case SDL_SCANCODE_F16                 : return "f16"                ;
    case SDL_SCANCODE_F17                 : return "f17"                ;
    case SDL_SCANCODE_F18                 : return "f18"                ;
    case SDL_SCANCODE_F19                 : return "f19"                ;
    case SDL_SCANCODE_F2                  : return "f2"                 ;
    case SDL_SCANCODE_F20                 : return "f20"                ;
    case SDL_SCANCODE_F21                 : return "f21"                ;
    case SDL_SCANCODE_F22                 : return "f22"                ;
    case SDL_SCANCODE_F23                 : return "f23"                ;
    case SDL_SCANCODE_F24                 : return "f24"                ;
    case SDL_SCANCODE_F3                  : return "f3"                 ;
    case SDL_SCANCODE_F4                  : return "f4"                 ;
    case SDL_SCANCODE_F5                  : return "f5"                 ;
    case SDL_SCANCODE_F6                  : return "f6"                 ;
    case SDL_SCANCODE_F7                  : return "f7"                 ;
    case SDL_SCANCODE_F8                  : return "f8"                 ;
    case SDL_SCANCODE_F9                  : return "f9"                 ;
    case SDL_SCANCODE_FIND                : return "find"               ;
    case SDL_SCANCODE_G                   : return "g"                  ;
    case SDL_SCANCODE_GRAVE               : return "grave"              ;
    case SDL_SCANCODE_H                   : return "h"                  ;
    case SDL_SCANCODE_HELP                : return "help"               ;
    case SDL_SCANCODE_HOME                : return "home"               ;
    case SDL_SCANCODE_I                   : return "i"                  ;
    case SDL_SCANCODE_INSERT              : return "insert"             ;
    case SDL_SCANCODE_J                   : return "j"                  ;
    case SDL_SCANCODE_K                   : return "k"                  ;
    case SDL_SCANCODE_KBDILLUMDOWN        : return "kbdillumdown"       ;
    case SDL_SCANCODE_KBDILLUMTOGGLE      : return "kbdillumtoggle"     ;
    case SDL_SCANCODE_KBDILLUMUP          : return "kbdillumup"         ;
    case SDL_SCANCODE_KP_0                : return "kp0"                ;
    case SDL_SCANCODE_KP_00               : return "kp00"               ;
    case SDL_SCANCODE_KP_000              : return "kp000"              ;
    case SDL_SCANCODE_KP_1                : return "kp1"                ;
    case SDL_SCANCODE_KP_2                : return "kp2"                ;
    case SDL_SCANCODE_KP_3                : return "kp3"                ;
    case SDL_SCANCODE_KP_4                : return "kp4"                ;
    case SDL_SCANCODE_KP_5                : return "kp5"                ;
    case SDL_SCANCODE_KP_6                : return "kp6"                ;
    case SDL_SCANCODE_KP_7                : return "kp7"                ;
    case SDL_SCANCODE_KP_8                : return "kp8"                ;
    case SDL_SCANCODE_KP_9                : return "kp9"                ;
    case SDL_SCANCODE_KP_A                : return "kpa"                ;
    case SDL_SCANCODE_KP_AMPERSAND        : return "kpamprsand"         ;
    case SDL_SCANCODE_KP_AT               : return "kpat"               ;
    case SDL_SCANCODE_KP_B                : return "kpb"                ;
    case SDL_SCANCODE_KP_BACKSPACE        : return "kpbackspace"        ;
    case SDL_SCANCODE_KP_BINARY           : return "kpbinary"           ;
    case SDL_SCANCODE_KP_C                : return "kpc"                ;
    case SDL_SCANCODE_KP_CLEAR            : return "kpclear"            ;
    case SDL_SCANCODE_KP_CLEARENTRY       : return "kpclearentry"       ;
    case SDL_SCANCODE_KP_COLON            : return "kpcolon"            ;
    case SDL_SCANCODE_KP_COMMA            : return "kpcomma"            ;
    case SDL_SCANCODE_KP_D                : return "kpd"                ;
    case SDL_SCANCODE_KP_DBLAMPERSAND     : return "kpand"              ;
    case SDL_SCANCODE_KP_DBLVERTICALBAR   : return "kpor"               ;
    case SDL_SCANCODE_KP_DECIMAL          : return "kpdecimal"          ;
    case SDL_SCANCODE_KP_DIVIDE           : return "kpslash"            ;
    case SDL_SCANCODE_KP_E                : return "kpe"                ;
    case SDL_SCANCODE_KP_ENTER            : return "kpenter"            ;
    case SDL_SCANCODE_KP_EQUALS           : return "kpequals"           ;
    case SDL_SCANCODE_KP_EQUALSAS400      : return "kpequals2"          ;
    case SDL_SCANCODE_KP_EXCLAM           : return "kpexclamation"      ;
    case SDL_SCANCODE_KP_F                : return "kpf"                ;
    case SDL_SCANCODE_KP_GREATER          : return "kplessthan"         ;
    case SDL_SCANCODE_KP_HASH             : return "kppound"            ;
    case SDL_SCANCODE_KP_HEXADECIMAL      : return "kphexadecimal"      ;
    case SDL_SCANCODE_KP_LEFTBRACE        : return "kpcurlyst"          ;
    case SDL_SCANCODE_KP_LEFTPAREN        : return "kp"                 ;
    case SDL_SCANCODE_KP_LESS             : return "kpgreaterthan"      ;
    case SDL_SCANCODE_KP_MEMADD           : return "kpmemadd"           ;
    case SDL_SCANCODE_KP_MEMCLEAR         : return "kpmemclear"         ;
    case SDL_SCANCODE_KP_MEMDIVIDE        : return "kpmemdivide"        ;
    case SDL_SCANCODE_KP_MEMMULTIPLY      : return "kpmemmultiply"      ;
    case SDL_SCANCODE_KP_MEMRECALL        : return "kpmemrecall"        ;
    case SDL_SCANCODE_KP_MEMSTORE         : return "kpmemstore"         ;
    case SDL_SCANCODE_KP_MEMSUBTRACT      : return "kpmemsubtract"      ;
    case SDL_SCANCODE_KP_MINUS            : return "kpminus"            ;
    case SDL_SCANCODE_KP_MULTIPLY         : return "kpmultiply"         ;
    case SDL_SCANCODE_KP_OCTAL            : return "kpoctal"            ;
    case SDL_SCANCODE_KP_PERCENT          : return "kpmodulo"           ;
    case SDL_SCANCODE_KP_PERIOD           : return "kpdot"              ;
    case SDL_SCANCODE_KP_PLUS             : return "kpplus"             ;
    case SDL_SCANCODE_KP_PLUSMINUS        : return "kpplusorminus"      ;
    case SDL_SCANCODE_KP_POWER            : return "kpcaret"            ;
    case SDL_SCANCODE_KP_RIGHTBRACE       : return "kpcurlyend"         ;
    case SDL_SCANCODE_KP_RIGHTPAREN       : return "kpparenend"         ;
    case SDL_SCANCODE_KP_SPACE            : return "kpspace"            ;
    case SDL_SCANCODE_KP_TAB              : return "kptab"              ;
    case SDL_SCANCODE_KP_VERTICALBAR      : return "kpbitwiseor"        ;
    case SDL_SCANCODE_KP_XOR              : return "kpxor"              ;
    case SDL_SCANCODE_L                   : return "l"                  ;
    case SDL_SCANCODE_LALT                : return "leftalt"            ;
    case SDL_SCANCODE_LCTRL               : return "leftctrl"           ;
    case SDL_SCANCODE_LEFT                : return "left"               ;
    case SDL_SCANCODE_LEFTBRACKET         : return "squarestart"        ;
    case SDL_SCANCODE_LGUI                : return "leftgui"            ;
    case SDL_SCANCODE_LSHIFT              : return "lshift"             ;
    case SDL_SCANCODE_M                   : return "m"                  ;
    case SDL_SCANCODE_MAIL                : return "mail"               ;
    case SDL_SCANCODE_MEDIASELECT         : return "mediaselect"        ;
    case SDL_SCANCODE_MENU                : return "menu"               ;
    case SDL_SCANCODE_MINUS               : return "minus"              ;
    case SDL_SCANCODE_MODE                : return "modeswitch"         ;
    case SDL_SCANCODE_MUTE                : return "mute"               ;
    case SDL_SCANCODE_N                   : return "n"                  ;
    case SDL_SCANCODE_NUMLOCKCLEAR        : return "numlock"            ;
    case SDL_SCANCODE_O                   : return "o"                  ;
    case SDL_SCANCODE_OPER                : return "oper"               ;
    case SDL_SCANCODE_OUT                 : return "out"                ;
    case SDL_SCANCODE_P                   : return "p"                  ;
    case SDL_SCANCODE_PAGEDOWN            : return "pagedown"           ;
    case SDL_SCANCODE_PAGEUP              : return "pageup"             ;
    case SDL_SCANCODE_PASTE               : return "paste"              ;
    case SDL_SCANCODE_PAUSE               : return "pause"              ;
    case SDL_SCANCODE_PERIOD              : return "dot"                ;
    case SDL_SCANCODE_POWER               : return "power"              ;
    case SDL_SCANCODE_PRINTSCREEN         : return "printscreen"        ;
    case SDL_SCANCODE_PRIOR               : return "prior"              ;
    case SDL_SCANCODE_Q                   : return "q"                  ;
    case SDL_SCANCODE_R                   : return "r"                  ;
    case SDL_SCANCODE_RALT                : return "rightalt"           ;
    case SDL_SCANCODE_RCTRL               : return "rightctrl"          ;
    case SDL_SCANCODE_RETURN              : return "return"             ;
    case SDL_SCANCODE_RETURN2             : return "return2"            ;
    case SDL_SCANCODE_RGUI                : return "rightgui"           ;
    case SDL_SCANCODE_RIGHT               : return "right"              ;
    case SDL_SCANCODE_RIGHTBRACKET        : return "squarebracketend"   ;
    case SDL_SCANCODE_RSHIFT              : return "rshift"             ;
    case SDL_SCANCODE_S                   : return "s"                  ;
    case SDL_SCANCODE_SCROLLLOCK          : return "scrolllock"         ;
    case SDL_SCANCODE_SELECT              : return "select"             ;
    case SDL_SCANCODE_SEMICOLON           : return "semicolon"          ;
    case SDL_SCANCODE_SEPARATOR           : return "separator"          ;
    case SDL_SCANCODE_SLASH               : return "slash"              ;
    case SDL_SCANCODE_SLEEP               : return "sleep"              ;
    case SDL_SCANCODE_SPACE               : return "space"              ;
    case SDL_SCANCODE_STOP                : return "stop"               ;
    case SDL_SCANCODE_SYSREQ              : return "sysreq"             ;
    case SDL_SCANCODE_T                   : return "t"                  ;
    case SDL_SCANCODE_TAB                 : return "tab"                ;
    case SDL_SCANCODE_THOUSANDSSEPARATOR  : return "thousandsseparator" ;
    case SDL_SCANCODE_U                   : return "u"                  ;
    case SDL_SCANCODE_UNDO                : return "undo"               ;
    case SDL_SCANCODE_UP                  : return "up"                 ;
    case SDL_SCANCODE_V                   : return "v"                  ;
    case SDL_SCANCODE_VOLUMEDOWN          : return "volumedown"         ;
    case SDL_SCANCODE_VOLUMEUP            : return "volumeup"           ;
    case SDL_SCANCODE_W                   : return "w"                  ;
    case SDL_SCANCODE_WWW                 : return "www"                ;
    case SDL_SCANCODE_X                   : return "x"                  ;
    case SDL_SCANCODE_Y                   : return "y"                  ;
    case SDL_SCANCODE_Z                   : return "z"                  ;
  }
}

