/**
  Menu -- Not very useful for many things outside of prototypes. But also
          showcases how you could use AOD.
          As of now it does not support customizing controls but that can be
          done so using the INI file anyways

Example:
---
  class Game_Manager {
    Player pl;
  public:
    override void Added_To_AOD() {
      pl = new Player();
      AOD.Add
    }
  }

  void main ( ) {
    Initialize();
    auto m = new AOD.Menu( ... );
    AOD.Add(m);
    AOD.Run();
  }
---
*/
module AODCore.menu;

static import AOD;

/**
  <b>DIAGRAM</b>

  <img src="https://aodq.github.io/files/MENU-base-diagram.png">


<b>BUTTON</b>

---
start    : destroys menu and adds add_on_start to AOD
controls : Initiates control window
credits  : Initiates credits window
quit     : Ends program
back     : Goes back to main menu
---

<b>BUTTON POSITIONING</b> (origin = center of image)

---
start    : button_y * button_y_it*0
controls : button_y * button_y_it*1
credits  : button_y * button_y_it*2
quit     : button_y * button_y_it*3
back     : <48, 48>
---

<b>TEXT</b>

---
general    : font will always be set as def font, origins located at  top-left
credits    : an array of strings containing name and role of team members
---

<b>IMAGE</b>

---
general    : all image origins are the center of the image and use the
              SheetRect structure
buttons    : start, controls, credits, quit, back
background : background, background-submenu
credits    : array of each member
---

<b>BACKGROUND</b>

---
background         : displayed on all menus, should be size of window
background-submenu : displayed on all submenus, after background. Size can
                      vary but it will always be placed at center of window
---

<b>BASE MENU</b>

---
background : Placed at center of window behind all other components
             of the menu
buttons    : start, controls, credits, quit
---


  <img src="https://aodq.github.io/files/MENU-base.png">

<b>CONTROLS MENU</b>

---
button      : back
backgrounds : background, background-submenu
text        : controls (generated from ClientVars.keybinds)
---

  <img src="https://aodq.github.io/files/MENU-controls.png">


<b>CREDITS MENU</b>

---
buttons     : back
backgrounds : background, background-submenu
text        : credits
image       : credits
---

  <img src="https://aodq.github.io/files/MENU-credits.png">
*/
class Menu : AOD.Entity {
  AOD.Entity add_on_start;
  immutable( uint ) Button_size = Button.max+1;
  AOD.Entity[Button.max+1] buttons;
  AOD.Entity background;
  AOD.Entity background_submenu_credits, background_submenu_controls;
  AOD.Text[] credit_texts,
             controls_text,
             controls_key_text;
  int control_index = -1;
public:
  /** */
  enum Button {
    /** */Start,
    /** */Controls,
    /** */Credits,
    /** */Quit,
    /** */Back };
  /** Constructs a new menu
Params:
  img_background         = background image
  img_background_submenu = submenu background image
  img_buttons   = An array of images for the buttons (use Button for index)
  text_credits  = A name and role of each member (if applicable)
  _add_on_start = A reference to an Entity to add to the realm when the menu
                   button "start" has been pressed
  button_y      = Distance from top on y-axis for the first button
  button_y_it   = Distance between each button on the y-axis
  credit_y      = Distance from top of y-axis for each credit slot
  credit_y_it   = Distance between each credit slot on the y-axis
  credit_text_x = Distance from left on x-axis for all credit text
  credit_img_x  = Distance from left on x-axis for all credit images
  */
  this(AOD.SheetRect img_background, AOD.SheetRect img_background_submenu,
      AOD.SheetRect img_background_submenu_controls,
       AOD.SheetRect[Button.max+1] img_buttons,
       string[] text_credits, AOD.Entity _add_on_start,
       int button_y, int button_y_it, int credit_y, int credit_y_it,
       int credit_text_x, int credit_img_x) {
    Set_Visible(0);
    add_on_start = _add_on_start;
    // set up background and buttons
    background = new AOD.Entity;
    background.Set_Sprite(img_background, 1);
    background.Set_Position(AOD.R_Window_Width/2, AOD.R_Window_Height/2);
    /* import std.conv : to; */
    /* import std.stdio : writeln; */
    /* writeln("Creating menu"); */
    /* writeln("BG POSITION: " ~ cast(string)background.R_Position); */
    background_submenu_credits = new AOD.Entity;
    background_submenu_credits.Set_Sprite(img_background_submenu, 1);
    background_submenu_credits.Set_Size(
                                background_submenu_credits.R_Img_Size());
    background_submenu_credits.Set_Position(AOD.R_Window_Width/2,
                                           AOD.R_Window_Height/2);
    background_submenu_credits.Set_Visible(0);
    background_submenu_credits.Set_Static_Pos(true);
    background_submenu_controls = new AOD.Entity;
    background_submenu_controls.Set_Sprite(img_background_submenu_controls, 1);
    background_submenu_controls.Set_Size(
                            background_submenu_controls.R_Img_Size());
    background_submenu_controls.Set_Position(AOD.R_Window_Width/2,
                                            AOD.R_Window_Height/2);
    background_submenu_controls.Set_Static_Pos(true);
    background_submenu_controls.Set_Visible(0);
    import std.stdio;
    /* import std.conv : to; */
    /* writeln(to!string(img_background)); */
    for ( int i = 0; i != Button.max+1; ++ i ) {
      buttons[i] = new AOD.Entity(3);
      with ( buttons[i] ) {
        Set_Sprite(img_buttons[i], 1);
        /* writeln("BT: " ~ to!string(img_buttons[i])); */
        Set_Position(AOD.R_Window_Width/2, button_y + (button_y_it * i));
      }
    }
    buttons[Button.Back].Set_Position(62, 62);
    buttons[Button.Back].Set_Visible(false);

    // set up credits
    for ( int i = 0; i != text_credits.length; ++ i ) {
      auto cy  = credit_y,
           cyi = credit_y_it;
      // text
      credit_texts ~= new AOD.Text(credit_text_x,
                                   cy + cyi*i, text_credits[i]);
      credit_texts[$-1].Set_Visible(0);
      // -- DEBUG START
      import std.stdio : writeln;
      import std.conv : to;
      writeln(to!string(credit_texts[$-1].R_Position));
      // -- DEBUG END
    }

    // set up controls
    auto ri  = AOD.Text.R_Default_Pt_Size;
    int rw  = AOD.R_Window_Width, rh = AOD.R_Window_Height, _rh;
    int i;
    for ( i = 0; i != AOD.ClientVars.keybinds.length; ++ i ) {
      auto k = AOD.ClientVars.keybinds[i];
      _rh = rh/2 + rh/16 + ((1+i)*(ri+2));
      controls_key_text ~= new AOD.Text(rw/2, _rh,
                                        AOD.Input.Key_To_String(k.key));
      controls_text     ~= new AOD.Text(20, _rh, k.command);
    }
    _rh = rh/2 + rh/16;
    controls_key_text ~= new AOD.Text(rw/2, _rh, "CONTROLS");
    controls_text     ~= new AOD.Text(20, _rh, "KEYS");
    _rh = rh/2 + rh/16 + ((1+i)*(ri+2));
    controls_key_text ~= new AOD.Text(20, _rh, "Edit controls at config.ini");
    foreach ( c; controls_text ) {
      c.Set_Visible(0);
      c.Set_Static_Pos(true);
    }
    foreach ( c; controls_key_text ) {
      c.Set_Visible(0);
      c.Set_Static_Pos(true);
    }
  }

  override void Added_To_Realm() {
    foreach ( c; controls_key_text )
      AOD.Add(c);
    /* foreach ( c; controls_text ) */
      /* AOD.Add(c); */
    /* foreach ( c; credit_texts ) */
      /* AOD.Add(c); */
    AOD.Add(buttons[0]);
    AOD.Add(buttons[3]);
    /* foreach ( c; buttons ) */
      /* AOD.Add(c); */
    buttons[0].Set_Visible(true);
    AOD.Add(background);
    AOD.Add(background_submenu_controls);
    AOD.Add(background_submenu_credits);
    AOD.Set_BG_Colour(0, 0, 0);
    static import Data;
    AOD.Play_Sound(Data.Sound.bg_music, 2.00f);
  }

  ~this() {
    AOD.Add(add_on_start);
  }

  private void Flip_Menu() {
    foreach ( b; buttons )
      b.Set_Visible(b.R_Visible^1);
  }

  // since an entity can be clickeable even though it is not visible
  private bool Clicked(AOD.Entity e) {
    return e.R_Visible && e.Clicked_On(0);
  }

  private void Set_Controls_Visibility(bool visible) {
    foreach (c; controls_text )
      c.Set_Visible(visible);
    foreach (c; controls_key_text )
      c.Set_Visible(visible);
    background_submenu_controls.Set_Visible(visible);
    // -- DEBUG START
    import std.stdio : writeln;
    import std.conv : to;
    writeln(cast(string)(background_submenu_controls.R_Position));
    // -- DEBUG END
  }

  private void Set_Credits_Visibility(bool visible) {
    foreach ( c; credit_texts ) {
      c.Set_Visible(visible);
      // -- DEBUG START
      import std.stdio : writeln;
      import std.conv : to;
      writeln(to!string(c.R_Visible));
      // -- DEBUG END
    }
    background_submenu_credits.Set_Visible(visible);
  }

  override void Update() {
    import derelict.sdl2.sdl;
    if ( Clicked( buttons[Button.Start]) ||
         AOD.Input.keystate [SDL_SCANCODE_SPACE] ) {
      foreach ( b; buttons )
        AOD.Remove(b);
      foreach ( c; controls_text )
        AOD.Remove(c);
      foreach ( c; controls_key_text )
        AOD.Remove(c);
      foreach ( c; credit_texts )
        AOD.Remove(c);
      AOD.Remove(background);
      AOD.Remove(this);
      return;
    }
    if ( Clicked( buttons[Button.Credits] ) ) {
      Flip_Menu();
      Set_Credits_Visibility(true);
      return;
    }
    if ( Clicked( buttons[Button.Controls] ) ) {
      Flip_Menu();
      Set_Controls_Visibility(true);
    }
    if ( Clicked( buttons[Button.Back] ) ) {
      Set_Controls_Visibility(false);
      Set_Credits_Visibility(false);
      Flip_Menu();
    }
    if ( Clicked( buttons[Button.Quit] ) ) {
      AOD.End();
    }
  }
}
