module Entity.Splashscreen;

static import AOD;


class Splash : AOD.Entity {
  float timer, timer_start, pop, time;
  AOD.SheetContainer[][] img;
  uint[] img_start, img_stages;
  uint start_fade, end_fade;
  AOD.SheetContainer reg;
  uint music;
  AOD.Entity add_after_done;
  uint ind = 0;
public:
  this(AOD.Entity _add_after_done) {
    add_after_done = _add_after_done;
    super();
    auto commands = AOD.ClientVars.commands;
    img = [
       [ AOD.SheetContainer("assets/splash/anim1/frame1.png"  ) ,
         AOD.SheetContainer("assets/splash/anim1/frame2.png"  ) ,
         AOD.SheetContainer("assets/splash/anim1/frame3.png"  ) ,
         AOD.SheetContainer("assets/splash/anim1/frame4.png"  ) ], // STEP 1
       [ AOD.SheetContainer("assets/splash/anim7/frame1.png"  ) ,
         AOD.SheetContainer("assets/splash/anim7/frame2.png"  ) ,
         AOD.SheetContainer("assets/splash/anim7/frame3.png"  ) ,
         AOD.SheetContainer("assets/splash/anim7/frame4.png"  ) ], // STEP 2
       [ AOD.SheetContainer("assets/splash/anim5/frame1.png"  ) ,
         AOD.SheetContainer("assets/splash/anim5/frame2.png"  ) ,
         AOD.SheetContainer("assets/splash/anim5/frame3.png"  ) ,
         AOD.SheetContainer("assets/splash/anim5/frame4.png"  ) ], // STEP 3
       [ AOD.SheetContainer("assets/splash/anim4/frame1.png"  ) ,
         AOD.SheetContainer("assets/splash/anim4/frame2.png"  ) ,
         AOD.SheetContainer("assets/splash/anim4/frame3.png"  ) ,
         AOD.SheetContainer("assets/splash/anim4/frame4.png"  ) ], // STEP 4
       [ AOD.SheetContainer("assets/splash/anim2/frame1.png"  ) ,
         AOD.SheetContainer("assets/splash/anim2/frame2.png"  ) ,
         AOD.SheetContainer("assets/splash/anim2/frame3.png"  ) ,
         AOD.SheetContainer("assets/splash/anim2/frame4.png"  ) ,
         AOD.SheetContainer("assets/splash/anim2/frame5.png"  ) ,
         AOD.SheetContainer("assets/splash/anim2/frame6.png"  ) ,
         AOD.SheetContainer("assets/splash/anim2/frame7.png"  ) ,
         AOD.SheetContainer("assets/splash/anim2/frame8.png"  ) ,
         AOD.SheetContainer("assets/splash/anim2/frame9.png"  ) ,
         AOD.SheetContainer("assets/splash/anim2/frame10.png" ) ,
         AOD.SheetContainer("assets/splash/anim2/frame11.png" ) ,
         AOD.SheetContainer("assets/splash/anim2/frame12.png" ) ,
         AOD.SheetContainer("assets/splash/anim2/frame13.png" ) ,
         AOD.SheetContainer("assets/splash/anim2/frame14.png" ) ,
         AOD.SheetContainer("assets/splash/anim2/frame15.png" ) ], // STEP 5
       [ AOD.SheetContainer("assets/splash/anim8/frame1.png"  ) ,
         AOD.SheetContainer("assets/splash/anim8/frame2.png"  ) ,
         AOD.SheetContainer("assets/splash/anim8/frame3.png"  ) ,
         AOD.SheetContainer("assets/splash/anim8/frame4.png"  ) ], // STEP 6
       [ AOD.SheetContainer("assets/splash/anim3/frame1.png"  ) ,
         AOD.SheetContainer("assets/splash/anim3/frame2.png"  ) ,
         AOD.SheetContainer("assets/splash/anim3/frame3.png"  ) ], // ANIM 3
       [ AOD.SheetContainer("assets/splash/anim4/frame2.png"  ) ,
         AOD.SheetContainer("assets/splash/anim4/frame3.png"  ) ,
         AOD.SheetContainer("assets/splash/anim4/frame4.png"  ) ], // ANIM 4 2-4
       [ AOD.SheetContainer("assets/splash/anim5/frame3.png"  ) ,
         AOD.SheetContainer("assets/splash/anim5/frame2.png"  ) ], // ANIM 5 3-2
       [ AOD.SheetContainer("assets/splash/anim6/frame1.png"  ) ,
         AOD.SheetContainer("assets/splash/anim6/frame2.png"  ) ,
         AOD.SheetContainer("assets/splash/anim6/frame3.png"  ) ,
         AOD.SheetContainer("assets/splash/anim6/frame4.png"  ) ,
         AOD.SheetContainer("assets/splash/anim6/frame5.png"  ) ,
         AOD.SheetContainer("assets/splash/anim6/frame6.png"  ) ], // ANIM 6
       [ AOD.SheetContainer("assets/splash/anim1/frame4.png"  ) ,
         AOD.SheetContainer("assets/splash/anim1/frame3.png"  ) ,
         AOD.SheetContainer("assets/splash/anim1/frame2.png"  ) ,
         AOD.SheetContainer("assets/splash/anim1/frame1.png"  ) ], // ANIM 1
    ];

    img_start  = [ 1570, 2300, 2680, 2850, 3700, 4500, 5340, 5680,
                   5850, 6080, 6780 ];
    for ( int i = 0; i != img_start.length; ++ i )
      img_start[i] = cast(uint)(img_start[i]/AOD.R_MS());
    img_stages = [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ];
    start_fade = cast(uint)(7200.0f/AOD.R_MS());
    end_fade   = cast(uint)(7300.0f/AOD.R_MS());
    /* foreach ( c; commands.byKeyValue() ) { */
    /*   // -- DEBUG START */
    /*   import std.stdio : writeln; */
    /*   import std.conv : to; */
    /*   writeln("VAL: " ~ c.value ~ ", key: " ~ to!string(c.key)); */
    /*   if ( c.key == "STARTFADE" ) { */
    /*     start_fade = cast(uint)(to!float(c.value)/AOD.R_MS()); */
    /*     continue; */
    /*   } else if ( c.key == "ENDFADE" ) { */
    /*     end_fade  = cast(uint)(to!float(c.value)/AOD.R_MS()); */
    /*     continue; */
    /*   } */
    /*   import std.conv : to; */
    /*   import std.stdio; */
    /*   img_start[c.key[4] - '1'] = cast(uint)(to!float(c.value)/AOD.R_MS()); */
    /* } */
    /* foreach ( s; img_start ) { */
    /*   /// ----- debug ---- */
    /*   import std.stdio : writeln; */
    /*   import std.conv : to; */
    /*   writeln("TIMES: " ~ to!string(s)); */
    /*   /// ----- debug ---- */
    /* } */
    /* foreach ( s; img_start ) { */
    /*   /// ----- debug ---- */
    /*   import std.stdio : writeln; */
    /*   import std.conv : to; */
    /*   writeln("TIMES: " ~ to!string(s)); */
    /*   /// ----- debug ---- */
    /* } */
    Set_Sprite(img[1][1]);
    Set_Position(AOD.R_Window_Width/2, AOD.R_Window_Height/2);
    Set_Static_Pos(true);
    /* Set_Colour(1, 1, 1, 1.0); */
    timer_start = (12500.0f/AOD.R_MS());
    timer = 8.5f;
    time = 0.0f;
    pop = 0.0f;
    ind = 0;
    uint tid = AOD.Load_Sound("assets/menu/Smilecythe- BulkherPlatoon.ogg");
    music = AOD.Play_Sound(tid);
    Set_Visible(false);
  }

  uint stage = 0, stage_it = 0, img_stage, img_ind;
  bool fadeblack = false;
  bool skipped;
  override void Update() {
    if ( fadeblack ) {
      float dt = skipped ? 0.5 : 0.015;
      time += dt;
      if ( time >= 1.00f ) {
        AOD.Set_BG_Colour(.08, .08, .095);
        AOD.Stop_Sound(music);
        AOD.Remove(this);
        AOD.Set_FPS_Display(new AOD.Text(20, 460, ""));
        if ( add_after_done !is null )
          AOD.Add(add_after_done);
      } else {
        AOD.Set_BG_Colour(1 - 0.92*time, 1 - 0.92*time, 1 - 0.905*time);
      }
      return;
    }
    import std.math;
    import std.conv;
    import std.stdio;
    // -- fade --
    if ( time >= start_fade ) {
      Set_Colour(1, 1, 1, 1 - 1/((end_fade - start_fade)/(time - start_fade)));
    }
    // -- frames --
    ++ time;
    if ( img_ind == -1 )
      Set_Sprite(img[0][3]);
    else
      Set_Sprite(img[img_stage][img_ind]);
    // -- DEBUG START
    /* import std.stdio : writeln; */
    /* import std.conv : to; */
    // -- DEBUG END
    Set_Visible(false);
    if ( stage > 0 || (stage == 0 && time >= img_start[0]) ) {
      Set_Visible(true);
      if ( stage < img_start.length && time >= img_start[stage] ) {
        /* writeln(" ( " ~ to!string(img_ind) ~ " ) "); */
        if ( ++ stage_it >= 50.0f/AOD.R_MS() ) {
          stage_it = 0;
          if ( ++ ind >= img[stage].length + 1 ) {
            img_ind = -1;
            ind = 0;
            ++ stage;
            if ( stage < img_stages.length )
              img_stage = img_stages[stage];
            else {
              img_ind = 3;
              img_stage = 0;
            }
            // -- DEBUG START
            /* import std.stdio : writeln; */
            /* import std.conv : to; */
            /* writeln("STAGE: " ~ to!string(stage)); */
            // -- DEBUG END
          } else
            img_ind = ind-1;
          /* writeln(" ( " ~ to!string(img_ind) ~ " ) "); */
        }
      } else {
        if ( stage == img_start.length ) {
          Set_Visible(false);
          img_ind = 0;
          img_stage = 0;
        } else
          img_ind = -1;
      }
    }
    import derelict.sdl2.sdl;
    if ( time >= end_fade+(400.0f/AOD.R_MS()) ||
         AOD.Input.keystate[SDL_SCANCODE_SPACE]) {
      skipped = cast(bool)AOD.Input.keystate[SDL_SCANCODE_SPACE];
      /* writeln("FADING"); */
      fadeblack = true;
      Set_Visible(false);
      time = 0;
    }
  }
}
