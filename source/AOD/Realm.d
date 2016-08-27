/** Check AOD.d instead, this module is reserved for engine use only */
module AODCore.realm;

import AODCore.console;
import AODCore.entity;
import AODCore.input;
import AODCore.sound;
import AODCore.text;
import Camera = AODCore.camera;
import derelict.devil.il;
import derelict.devil.ilu;
import derelict.devil.ilut;
import derelict.freetype.ft;
import derelict.openal.al;
import derelict.opengl3.gl;
import derelict.opengl3.gl3;
import derelict.sdl2.sdl;
import derelict.vorbis.file;
import derelict.vorbis.vorbis;
import AODCore.render_base;

/** */
private SDL_Window* screen = null;

/** */
class Realm {
/** objects in realm, index [layer][it]*/
  Render_Base[][] objects;
/** objects to remove at end of each frame */
  Render_Base[] objs_to_rem;
  bool cleanup_this_frame;
  Render_Base add_after_cleanup;

/** colour to clear buffer with */
  GLfloat bg_red, bg_blue, bg_green;

/** if the realm run loop has started yet */
  bool started;
/** */
  bool ended;
/** width/height of window */
  int width, height;
/** delta time (in milliseconds) for a frame */
  uint ms_dt;
/** calculates frames per second */
  float[20] fps = [ 0 ];
/** Outputs frames_per_second to screen */
  AODCore.text.Text fps_display;
public:
/** */
  void Change_MSDT(uint ms_dt_) in {
    assert(ms_dt_ > 0);
  } body {
    ms_dt = ms_dt_;
  }

/** */
  int R_Width ()       { return width;                        }
/** */
  int R_Height()       { return height;                       }
/** */
  float R_MS  ()       { return cast(float)ms_dt;             }
/** */
  float To_MS(float x) { return cast(float)(x*ms_dt)/1000.0f; }

/** */
  void Set_FPS_Display(AODCore.text.Text fps) {
    if ( fps_display !is null )
      Remove(fps_display);
    fps_display = fps;
    if ( fps_display !is null )
      Add(fps_display);
  }

/** */
  this(int window_width, int window_height, uint ms_dt_,
       immutable(char)* window_name, immutable(char)* icon = "") {
    static import AODCore.utility;
    AODCore.utility.Seed_Random();
    // -- DEBUG START
    import std.stdio : writeln;
    import std.conv : to;
    writeln("S: " ~ to!string(AODCore.utility.R_Rand(0.0f, 100.0f)));
    writeln("S: " ~ to!string(AODCore.utility.R_Rand(0.0f, 100.0f)));
    writeln("S: " ~ to!string(AODCore.utility.R_Rand(0.0f, 100.0f)));
    // -- DEBUG END
    width  = window_width;
    height = window_height;
    ended = 0;
    ms_dt = ms_dt_;
    Debug_Output("Initializing SDL");
    import std.conv : to;
    import derelict.util.exception;
    import std.stdio;
    writeln("AOD@Realm.d@Initialize Initializing Art of Dwarficorn engine");
    writeln("AOD@Realm.d@Initialize Loading external libraries");

    template Load_Library(string lib, string params) {
      const char[] Load_Library =
        "try { " ~ lib ~ ".load(" ~ params ~ ");" ~
        "} catch ( DerelictException de ) {" ~
            "writeln(\"--------------------------------------------------\");"~
            "writeln(\"Failed to load: " ~ lib ~ ", \" ~ to!string(de));"     ~
        "}";
    }

    mixin(Load_Library!("DerelictGL3"       ,""));
    mixin(Load_Library!("DerelictGL"        ,""));
    version(linux) {
      mixin(Load_Library!("DerelictSDL2", "SharedLibVersion(2, 0, 2)"));
    } else {
      mixin(Load_Library!("DerelictSDL2",
                          "\"SDL2.dll\",SharedLibVersion(2 ,0 ,2)"));
    }
    mixin(Load_Library!("DerelictIL"        ,""));
    mixin(Load_Library!("DerelictILU"       ,""));
    mixin(Load_Library!("DerelictILUT"      ,""));
    mixin(Load_Library!("DerelictAL"        ,""));
    version (linux) {
      mixin(Load_Library!("DerelictFT"        , ""));
      mixin(Load_Library!("DerelictVorbis"    , ""));
      mixin(Load_Library!("DerelictVorbisFile", ""));
    } else {
      mixin(Load_Library!("DerelictFT"        ,"\"freetype265.dll\""));
      mixin(Load_Library!("DerelictVorbis"    ,"\"libvorbis-0.dll\""));
      mixin(Load_Library!("DerelictVorbisFile","\"libvorbisfile-3.dll\""));
    }

    writeln("AOD@Realm.d@Initialize Initializing SDL");
    SDL_Init ( SDL_INIT_EVERYTHING );


    writeln("AOD@Realm.d@Initialize Creating SDL Window");
    screen = SDL_CreateWindow(window_name, SDL_WINDOWPOS_UNDEFINED,
                                           SDL_WINDOWPOS_UNDEFINED,
                                           window_width,
                                           window_height,
                                           SDL_WINDOW_OPENGL |
                                           SDL_WINDOW_SHOWN );
    writeln("AOD@Realm.d@Creating OpenGL Context");
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 0);
    SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
    SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE,  24);
    SDL_GL_SetAttribute(SDL_GL_ALPHA_SIZE,   8);
    import std.conv : to;
    if ( screen is null ) {
      throw new Exception("Error SDL_CreateWindow: "
                          ~ to!string(SDL_GetError()));
    }

    if ( SDL_GL_CreateContext(screen) is null ) {
      throw new Exception("Error SDL_GL_CreateContext: "
                          ~ to!string(SDL_GetError()));
    }
    writeln("AOD@Realm.d@OpenGL version: " ~
             to!string(glGetString(GL_VERSION)));

    try {
      DerelictGL3.reload();
      DerelictGL.reload();
    } catch ( DerelictException de ) {
      writeln("\n----------------------------------------------------------\n");
      writeln("Failed to reload DerelictGL3: " ~ to!string(de));
      writeln("\n----------------------------------------------------------\n");
    }

    glEnable(GL_TEXTURE_2D);
    /* glEnable(GL_BLEND); */
    if ( icon != "" ) {
      writeln("AOD@Realm.d@Loading window icon");
      SDL_Surface* ico = SDL_LoadBMP(icon);
      if ( ico == null ) {
        writeln("AOD@Realm.d@Error loading icon BMP");
      }
      SDL_SetWindowIcon(screen, ico);
    }

    glClearDepth(1.0f);
    glPolygonMode(GL_FRONT, GL_FILL);
    glShadeModel(GL_FLAT);
    /* glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_FASTEST); */
    glDepthFunc(GL_LEQUAL);
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    glMatrixMode(GL_PROJECTION);
    glEnable(GL_ALPHA);

    glLoadIdentity();

    ilInit();
    iluInit();
    ilutInit();
    if ( !ilutRenderer(ILUT_OPENGL) )
      writeln("Error setting ilut Renderer to ILUT_OPENGL");
    import AODCore.vector;
    writeln("AOD@Realm.d@window dimensions: " ~ cast(string)Vector(window_width,
                                                       window_height));

    glOrtho(0, window_width, window_height, 0, 0, 1);
    glViewport(0, 0, window_width, window_height);

    glDisable(GL_DEPTH_TEST);
    glMatrixMode(GL_MODELVIEW);
    { // others
      writeln("AOD@Realm.d@Initializing sounds core");
      writeln("Initializing Sounds Core");
      SoundEng.Set_Up();
      writeln("Initializing Font Core");
      TextEng.Font.Init();
      /* objs_to_rem = []; */
      /* bg_red   = 0; */
      /* bg_blue  = 0; */
      /* bg_green = 0; */
    }
    static import AODCore.camera;
    AODCore.camera.Set_Position(Vector(0, 0));
    AODCore.camera.Set_Size(Vector(cast(float)window_width,
                                   cast(float)window_height));
    writeln("AOD@Realm.d@Initialize Finalized initializing AOD main core");
  }

/** */
  int Add(Render_Base o) in {
    assert(o !is null);
  } body {
    static uint id_count = 0;
    o.Set_ID(id_count ++);
    int l = o.R_Layer();
    if ( objects.length <= l ) objects.length = l+1;
    objects[l] ~= o;
    o.Added_To_Realm();
    return o.R_ID();
  }
/** */
  void End() {
    Clean_Up(null);
    import AODCore.sound;
    Sound.End();
    ended = true;
  }
/** */
  void Remove(Render_Base o) in {
    assert(o !is null);
  } body {
    objs_to_rem ~= o;
  }
/**  */
  void Clean_Up(Render_Base rendereable) {
    cleanup_this_frame = true;
    add_after_cleanup  = rendereable;
  }
/** */
  void Set_BG_Colours(GLfloat r, GLfloat g, GLfloat b) {
    bg_red = r;
    bg_green = g;
    bg_blue = g;
  }

/** */
  void Run() {
    float prev_dt        = 0, // DT from previous frame
          curr_dt        = 0, // DT for beginning of current frame
          elapsed_dt     = 0, // DT elapsed between previous and this frame
          accumulated_dt = 0; // DT needing to be processed
    started = 1;
    SDL_Event _event;
    _event.user.code = 2;
    _event.user.data1 = null;
    _event.user.data2 = null;
    SDL_PushEvent(&_event);

    // so I can set up keys and not have to rely that update is ran first
    /* writeln("AOD@AODCore.d@Run pumping events before first update"); */
    SDL_PumpEvents();
    MouseEngine.Refresh_Input();
    SDL_PumpEvents();
    MouseEngine.Refresh_Input();

    while ( SDL_PollEvent(&_event) ) {
      switch ( _event.type ) {
        case SDL_QUIT:
          if ( !ended )
            End();
        break;
        default: break;
      }
    }
    prev_dt = cast(float)SDL_GetTicks();
    /* writeln("AOD@AODCore.d@Run Now beginning main engine loop"); */
    while ( true ) {
      // refresh time handlers
      curr_dt = cast(float)SDL_GetTicks();
      elapsed_dt = curr_dt - prev_dt;
      accumulated_dt += elapsed_dt;

      // refresh calculations
      while ( accumulated_dt >= ms_dt ) {
        // sdl
        SDL_PumpEvents();
        MouseEngine.Refresh_Input();

        // actual update
        accumulated_dt -= ms_dt;
        Update();
        if ( ended ) break;

        string tex;
        string to_handle;
        bool alnum;
        char* chptr = null;

        /* auto input = Console::input->R_Str(), */
        /*      input_after = Console::input_after->R_Str(); */

        while ( SDL_PollEvent(&_event) ) {
          switch ( _event.type ) {
            default: break;
            case SDL_QUIT:
              if ( !ended )
                End();
            return;
          }
        }
      }

      if ( ended ) {
        destroy(this);
        return;
      }

      { // refresh screen
        float _FPS = 0;
        for ( int i = 0; i != 19; ++ i ) {
          fps[i+1] = fps[i];
          _FPS += fps[i+1];
        }
        fps[0] = elapsed_dt;
        _FPS += fps[0];

        if ( fps_display !is null ) {
          import std.conv : to;
          fps_display.Set_String( to!string(cast(int)(20000/_FPS)) ~ " FPS");
        }

        // check console key
        AODCore.console.ConsEng.Refresh();

        Render(); // render the screen
      }

      { // sleep until temp dt reaches ms_dt
        float temp_dt = accumulated_dt;
        temp_dt = cast(float)(SDL_GetTicks()) - curr_dt;
        while ( temp_dt < ms_dt ) {
          SDL_PumpEvents();
          SDL_Delay(1);
          temp_dt = cast(float)(SDL_GetTicks()) - curr_dt;
        }
      }
      // set current frame timemark
      prev_dt = curr_dt;
    }
  }
/** */
  void Update() {
    // update objects
    foreach ( l ; objects )
    foreach ( a ; l ) {
      a.Update();
      a.Post_Update();
    }
    // ---- NON AOD CODE -----
    // ---- NON AOD CODE -----
    // ---- NON AOD CODE -----

    {
      static import Game_Manager;
      Game_Manager.Update();
    }

    // ---- NON AOD CODE -----
    // ---- NON AOD CODE -----
    // ---- NON AOD CODE -----

    // remove objects
    foreach ( rem_it; 0 .. objs_to_rem.length ) {
      int layer_it = objs_to_rem[rem_it].R_Layer();
      foreach ( obj_it; 0 .. objects[layer_it].length ) {
        if ( objects[layer_it][obj_it] is objs_to_rem[rem_it] ) {
          destroy(objects[layer_it][obj_it]);
          objects[layer_it][obj_it] = null;
          objects[layer_it] = objects[layer_it][0 .. obj_it] ~
                              objects[layer_it][obj_it+1 .. $];
          break;
        }
      }
    }
    objs_to_rem = [];

    // destroy everything this frame?
    if ( cleanup_this_frame ) {
      cleanup_this_frame = false;
      for ( int i = 0; i != objects.length; ++ i ) {
        for ( int j = 0; j != objects[i].length; ++ j ) {
          if ( objects[i][j] != fps_display ) {
            destroy(objects[i][j]);
            objects[i][j] = null;
          }
        }
      }
      objects = [];
      if ( fps_display ) {
        Add(fps_display);
      }
      if ( add_after_cleanup !is null ) {
        Add(add_after_cleanup);
      }
      import AODCore.sound;
      Sound.Clean_Up();
    }
  }

  ~this() {
    // todo...
    SDL_DestroyWindow(screen);
    SDL_Quit();
  }

/** */
  void Render() {
    glClear(GL_COLOR_BUFFER_BIT| GL_DEPTH_BUFFER_BIT);
    glClearColor(bg_red,bg_green,bg_blue,0);

    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glEnable(GL_TEXTURE_2D);

    float off_x = Camera.R_Origin_Offset().x,
          off_y = Camera.R_Origin_Offset().y;

    static GLubyte[6] index = [ 0,1,2, 1,2,3 ];

    // --- rendereables ---
    for ( size_t layer = objects.length-1; layer != -1; -- layer ) {
      foreach ( obj ; objects[layer] ) {
        switch ( obj.R_Render_Base_Type ) {
          case Render_Base.Render_Base_Type.Entity:
            auto e = cast(Entity)obj;
            e.Render();
          break;
          case Render_Base.Render_Base_Type.Text:
            auto t = cast(Text)obj;
            t.Render();
          break;
          default:
            obj.Render();
          break;
        }
      }
    }

    // ---- console
    static import AODCore.console;
    if ( AODCore.console.console_open ) {
      foreach ( tz; AODCore.console.ConsEng.console_text ) {
        import std.stdio;
        tz.Render();
      }
    }

    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glDisableClientState(GL_TEXTURE_2D);


    SDL_GL_SwapWindow(screen);
  }
}
