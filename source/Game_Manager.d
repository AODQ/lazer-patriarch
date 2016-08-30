module Game_Manager;
static import AOD;
import std.string;
static import Data;
static import Entity.Player;
import Entity.Map;

static import Entity.Map;
Entity.Map.Tile[][][] map;
Entity.Player.Player player;
AOD.Entity[] projectiles;
AOD.Entity[] explosions;
Prop[] stone_doors;
int map_width, map_height;
enum Turn {
  Player, AI
};
Turn current_turn;

bool Valid_Position_Light(int x, int y) {
  if ( x <= 0 || y <= 0 ) return false;
  if ( x >= map.length || y >= map[0].length ) return false;
  if ( map[x][y].length == 0 ) return false;
  return true;
}

bool Valid_Position(int x, int y) {
  if ( !Valid_Position_Light(x, y) ) return false;
  foreach ( i; 0 .. map[x][y].length ) {
    if ( !map[x][y][i].R_Collideable()  ) return false;
  }
  return true;
}

void Initialize() {
  restarted = false;
  player = null;
  map.length = 0;
  projectiles = [];
  explosions = [];
  stone_doors = [];
  AOD.Camera.Set_Position(0, 0);
  if ( next_level )
    AOD.Add(Data.Construct_New_Menu());
  else
    AOD.Add(new Gmanage);
}

void Add(T)(T x) {
  import Entity.Projectile;
  static if ( is(T == Projectile   )) { projectiles ~= x; }
  static if ( is(T == Explosion    )) { explosions ~= x; }
  static if ( is(T == Prop         )) { stone_doors ~= x; }
  /* static if ( is(T == Paddle  )) { paddle     = x; } */
  AOD.Add(x);
}

// only purpose is to add things after menu
class Gmanage : AOD.Entity {
public:
  override void Added_To_Realm() {
    Generate_Map();
    AOD.Remove(this);
  }
}

void Remove(T)(T x) {
  import std.algorithm : remove;
  template Rem(string container) { const char[] Rem =
    "for ( int i = 0; i != " ~ container ~ ".length; ++ i )" ~
      "if ( " ~ container ~ "[i] is x ) {" ~
        container ~ " = remove("~container~", i);"~
        "break;" ~
      "}";
  }
  import Entity.Projectile;
  static if ( is(T == Projectile) ) {
    mixin(Rem!("projectiles" ));

  }
  static if ( is(T == Explosion) ) {
    mixin(Rem!("explosions" ));
  }
  static if ( is(T == Prop) ) {
    mixin(Rem!("stone_doors" ));
  }
  AOD.Remove(x);
}

bool restarted = false, next_level=  false;

void Restart_Game() {
  // -- DEBUG START
  import std.stdio : writeln;
  import std.conv : to;
  writeln("CLEANING UP");
  // -- DEBUG END
  AOD.Clean_Up();
  restarted = true;
  next_level = false;
  /* AOD.Clean_Up(Data.Construct_New_Menu); */
}
void Next_Level() {
  // -- DEBUG START
  import std.stdio : writeln;
  import std.conv : to;
  writeln("CLEANING UP");
  // -- DEBUG END
  AOD.Clean_Up();
  next_level = restarted = true;
  /* AOD.Clean_Up(Data.Construct_New_Menu); */
}

void Generate_Map() {
  // -------------- generate textual map ---------------------------------------
  int[][] tmap;
  int[][] lmap;
  int[] trooms_x, trooms_y, trooms_w, trooms_h;
  int twidth = 75; // cast(int)AOD.R_Rand(50, 100);
  int theight = 75; // cast(int)AOD.R_Rand(50, 100);
  tmap.length = lmap.length = twidth;
  for ( int i = 0; i != tmap.length; ++ i ) {
    tmap[i].length = theight;
    lmap[i].length = theight;
  }
  foreach ( i; 0 .. lmap.length )
    foreach ( j; 0 .. lmap[i].length )
      lmap[i][j] = -1;
  // return true if room valid loc
  bool Room_Intersects(int rx, int ry, int rw, int rh) {
    int lx = rx - rw, ly = ry - rh,
        hx = rx + rw, hy = ry + rh;
    // map boundaries
    if ( lx < 2 ) return false;
    if ( ly < 2 ) return false;
    if ( hx >= twidth-2 ) return false;
    if ( hy >= theight-2 ) return false;
    // r boundaries
    for ( int i = rx - rw; i != rx + rw; ++ i ) {
      for ( int j = ry - rh; j != ry + rh; ++ j ) {
        if ( tmap[i][j] != 0 ) return false;
      }
    }
    return true;
  }
  bool Generate_Horiz(int sx, int sy, int ex, bool ni) {
    if ( sx < 0 || ex < 0 || sy < 0 || ex >= tmap.length ||
         sx >= tmap.length || sy >= tmap[0].length )
      return false;
    if ( ex < sx ) {
      sx ^= ex;
      ex ^= sx;
      sx ^= ex;
    }
    /* // -- DEBUG START */
    /* import std.stdio : writeln; */
    /* import std.conv : to; */
    /* writeln("GENERATE HORIZ. SX: " ~ to!string(sx) ~ " SY: " ~ to!string(sy) ~ */
    /*                        " EX: " ~ to!string(ex)); */
    /* // -- DEBUG END */
    for ( int i = sx; i != ex; ++ i ) {
      if ( tmap[i][sy] == 0 ) {
        tmap[i][sy] = -1;
      }
      else if ( ni ) return false;
    }
    return true;
  }
  bool Generate_Verti(int sy, int sx, int ey, bool ni) {
    if ( sy < 0 || sx < 0 || ey < 0 || sx >= tmap.length ||
         sy >= tmap[0].length || ey >= tmap[0].length )
      return false;
    if ( ey < sy ) {
      sy ^= ey;
      ey ^= sy;
      sy ^= ey;
    }
    /* // -- DEBUG START */
    /* import std.stdio : writeln; */
    /* import std.conv : to; */
    /* writeln("GENERATE VERTI. SY: " ~ to!string(sy) ~ " SY: " ~ to!string(sx) ~ */
    /*                        " EY: " ~ to!string(ey)); */
    /* // -- DEBUG END */
    for ( int i = sy; i != ey+1; ++ i ) {
      if ( tmap[sx][i] == 0 )
        tmap[sx][i] = -1;
      else if ( ni ) return false;
    }
    return true;
  }
  bool Generate_Path(int i, int y, bool ni, int width = -1) {
    if ( i == y ) return 0;
    int srx = trooms_x [ i ] ,
        sry = trooms_y [ i ] ,
        srw = trooms_w [ i ] ,
        srh = trooms_h [ i ] ,
        erx = trooms_x [ y ] ,
        ery = trooms_y [ y ] ,
        erw = trooms_w [ y ] ,
        erh = trooms_h [ y ] ;


    int ox = cast(int)AOD.R_Rand(srx - srw, srx + srw),
        oy = cast(int)AOD.R_Rand(sry - srh, sry + srh),
        fx = cast(int)AOD.R_Rand(erx - erw, erx + erw),
        fy = cast(int)AOD.R_Rand(ery - ery, ery + erh);
    width = width == -1 ? (AOD.R_Rand(0, 50) > 40 ? 1 : 0) : 0;
    if ( AOD.R_Rand(0, 2) > 1.0f ) { // horiz?
      Generate_Horiz(ox, oy, fx, ni);
      Generate_Verti(oy, fx, fy, ni);
      Generate_Horiz(ox, oy+1, fx, ni);
      Generate_Verti(oy, fx+1, fy, ni);
      if ( width ) {
        Generate_Horiz(ox, oy-1, fx, ni);
        Generate_Verti(oy, fx-1, fy, ni);
      }
      return 0;
    } else {
      Generate_Verti(oy, ox, fy, ni);
      Generate_Horiz(ox, fy, fx, ni);
      Generate_Verti(oy+1, ox+1, fy-1, ni);
      Generate_Horiz(ox+1, fy+1, fx-1, ni);
      if ( width ) {
        Generate_Verti(oy+1, ox-1, fy-1, ni);
        Generate_Horiz(ox+1, fy-1, fx-1, ni);
      }
      return 1;
    }
  }
  // returns false if not enough room
  bool Create_Room(int room_id) {
    int rx, ry, rw, rh;
    int attempt = 0;
    import std.math;
    do {
      rw = cast(int)AOD.R_Rand(2, 5);
      rh = cast(int)AOD.R_Rand(2, 5);
      rx = cast(int)AOD.R_Rand(rw+1, twidth - rw-1);
      ry = cast(int)AOD.R_Rand(rh+1, theight - rh-1);
      if ( room_id == 0 ) {
        rx = ry = 50;
        rw = 6; rh = 6;
      }
      ++ attempt;
    } while ( !Room_Intersects(rx, ry, rw, rh) && attempt < 20
              && (sqrt(pow(rx, 2.0f) - 50.0f) + pow(ry, 2.0f)-50) < 15*room_id);
    if ( attempt >= 20 ) // not enough room
      return false;
    import std.math;
    alias Max = AOD.Util.R_Max;
    alias Min = AOD.Util.R_Min;
    for ( int i = Max(0, rx-rw); i != Min(twidth, rx + rw); ++ i ) {
      for ( int j = Max(0, ry-rh); j != Min(theight, ry+rh); ++ j ) {
        tmap[i][j] = -1;
      }
    }
    trooms_x ~= rx; trooms_y ~= ry;
    trooms_h ~= rh; trooms_w ~= rw;
    return true;
  }
  // gen rooms
  trooms_x ~= twidth - 3;
  trooms_y ~= theight - 3;
  trooms_h ~= 3;
  trooms_w ~= 3;
  int rm_amt = cast(int)AOD.R_Rand(25, 30);
  for ( int rms = 0; rms != rm_amt; ++ rms ) {
    if ( !Create_Room(rms) ) {
      break;
    }
    Generate_Path(rms, rms+1, false);
  }

  for ( int i = tmap.length-1; i != tmap.length-13; -- i )
    tmap[$-1][i] = -1;
  for(int i=0; i<tmap.length; ++ i) {
    tmap[i][0]   = -1;
    tmap[i][$-1] = -1;
  }
  for(int i=0; i < tmap[0].length-1; ++i) {
    tmap[0][i]   = -1;
    tmap[$-1][i] = -1;
  }
  // -- DEBUG START
  /* import std.stdio; */
  /* import std.conv : to; */
  /* writeln("WIDTH: " ~ to!string(tmap.length) ~ " HEIGHT: " */
  /*                   ~ to!string(tmap[0].length) ~ " ROOMS: " */
  /*                   ~ to!string(trooms_x.length)); */
  /* foreach ( i; 0 .. tmap.length ) { */
  /*   foreach ( j; 0 .. tmap[i].length ) { */
  /*     int z = tmap[i][j]; */
  /*     char c; */
  /*     if ( z == 0 ) */
  /*       c = ' '; */
  /*     else if ( z < 0 ) { */
  /*       /1* if ( z == -1 ) *1/ */
  /*         /1* c = 'V'; *1/ */
  /*       /1* else *1/ */
  /*         /1* c = 'H'; *1/ */
  /*       c = '0'; */
  /*     } else */
  /*       c = cast(char)('0' + z); */
  /*     /1* if ( z > 100 ) { *1/ */
  /*     /1*   if ( z > 200 ) *1/ */
  /*     /1*     c = cast(char)(cast(char)(z - 201) + 'a'); *1/ */
  /*     /1*   else *1/ */
  /*     /1*     c = cast(char)(cast(char)(z - 101) + 'A'); *1/ */
  /*     /1* } else { *1/ */
  /*     /1*   c = cast(char)(z - '0'); *1/ */
  /*     /1* } *1/ */
  /*     write(c); */
  /*   } */
  /*   writeln(""); */
  /* } */
  // -- DEBUG END

  // place player
  import Entity.Player;
  player = new Player(trooms_x[0], trooms_y[0]);

  // ensure tmap has boundaries
  tmap = [][]  ~ tmap ~ [][];
  foreach ( i; 0 .. tmap.length )
    tmap[i] = [] ~ tmap[i] ~ [];
  // generate wall
  bool Valid_Wall_Token(int x, int y) {
    return tmap[x][y] != 0 && tmap[x][y] > -100;
  }
  // --- first passthrough
  foreach ( i; 0 .. tmap.length ) {
    foreach ( j; 0 .. tmap[i].length ) {
      /* if ( tmap[i][j] != 0 ) continue; // empty */
      /*  [0, 0] [1, 0] [2, 0]
          [0, 1]        [2, 1]
          [0, 2] [1, 2] [2, 2]

          0 == nothing, 1 == floor
      */
      if ( tmap[i][j] != 0 ) continue;
      int[3][3] surroundings = [[0, 0, 0], [0, 0, 0], [0, 0, 0]];
      for ( int ii = cast(int) i-1; ii != i+2; ++ ii ) {
        if ( ii == -1 || ii == tmap.length ) continue; // lim
        for ( int jj = cast(int) j-1; jj != j+2; ++ jj ) {
          if ( jj == -1 || jj == tmap[ii].length ) continue; // lim
          int ti = ii - cast(int) i+1,
              tj = jj - cast(int) j+1;
          if ( tmap[ii][jj] == -1 )
            surroundings[ti][tj] = 1;
        }
      }
      alias M = Data.Image.MapGrid;
      /* // --- corners */
      auto s = surroundings;
      /* if ( !s[2][1] && !s[1][2] && s[2][2] ) tmap[i][j] = M.wall_ctl; */
      /* if ( !s[2][1] && !s[1][2] && s[2][0] ) tmap[i][j] = M.wall_ctr; */
      /* if ( !s[1][1] && !s[1][2] && s[0][2] ) tmap[i][j] = M.wall_cll; */
      /* if ( !s[1][0] && !s[1][1] && s[0][0] ) tmap[i][j] = M.wall_clr; */
      // --- | - walls
      if ( tmap[i][j] > -100 ) {
        if ( s[1][0] ) {
          if ( !s[0][1] && !s[2][1] )
            tmap[i][j] = M.wall_t;
        }
        if ( s[1][2] ) {
          if ( !s[0][1] && !s[2][1] )
            tmap[i][j] = M.brick;
        }
        if ( s[2][1] ) {
          if ( !s[1][0] && !s[1][2] )
            tmap[i][j] = M.wall_r;
        }
        if ( s[0][1] ) {
          if ( !(s[1][0] || s[1][2]) )
            tmap[i][j] = M.wall_l;
        }
        /* if ( s[2][2] && !s[2][1] && !s[1][2] ) tmap[i][j] = M.wall_ctl; */
        /* if ( s[0][2] && !s[0][1] && !s[1][2] ) tmap[i][j] = M.wall_ctr; */
        if ( s[0][0] && !s[0][1] && !s[1][0] ) tmap[i][j] = M.wall_clr;
        if ( s[2][0] && !s[1][0] && !s[2][1] ) tmap[i][j] = M.wall_cll;
        if ( s[0][1] && s[1][2] )              tmap[i][j] = M.brick_l;
        if ( s[0][1] && s[1][0] )              tmap[i][j] = M.wall_ptl;
        if ( s[2][1] && s[1][0] )              tmap[i][j] = M.wall_ptr;
        if ( s[2][1] && s[1][2] )              tmap[i][j] = M.brick_r;
      }
    }
  }
  // --- second passthrough
  bool Is_Brick(int x) {
    alias M = Data.Image.MapGrid;
    return x == M.brick || x == M.brick_r || x == M.brick_l;
  }
  foreach ( i; 0 .. tmap.length ) {
    foreach ( j; 0 .. tmap[i].length ) {
      /*  [0, 0] [1, 0] [2, 0]
          [0, 1]        [2, 1]
          [0, 2] [1, 2] [2, 2]

          0 == nothing, 1 == floor, otherwise M
      */
      int[3][3] surroundings = [[0, 0, 0], [0, 0, 0], [0, 0, 0]];
      for ( int ii = cast(int) i-1; ii != i+2; ++ ii ) {
        if ( ii == -1 || ii == tmap.length ) continue; // lim
        for ( int jj = cast(int) j-1; jj != j+2; ++ jj ) {
          if ( jj == -1 || jj == tmap[ii].length ) continue; // lim
          int ti = ii - cast(int) i+1,
              tj = cast(int) jj - cast(int) j+1;
          if ( tmap[ii][jj] == -1 )
            surroundings[ti][tj] = 1;
          if ( tmap[ii][jj] <= -100 )
            surroundings[ti][tj] = tmap[ii][jj];
        }
      }
      alias M = Data.Image.MapGrid;
      auto s = surroundings;

      if ( tmap[i][j] != M.brick && tmap[i][j] != M.brick_r
                                 && tmap[i][j] != M.brick_l ) {
        if ( Is_Brick(s[0][1]) ) {
          if ( tmap[i][j] != -1 )
            tmap[i][j] = M.wall_l;
        }
        if ( Is_Brick(s[2][1])) {
          if ( tmap[i][j] != -1 )
            tmap[i][j] = M.wall_r;
        }
      }

      if ( tmap[i][j] == 0 && s[0][1] != -1 && s[1][0] != -1 &&
                              s[1][2] != -1 && s[2][1] != -1 ) {
        // corner inside of wall
        if ( s[2][2] == M.brick && s[1][2] != M.brick ) {
          tmap[i][j] = M.wall_ctl; continue;
        }
        if ( s[0][2] == M.brick && s[1][2] != M.brick ) {
          tmap[i][j] = M.wall_ctr; continue;
        }
        if ( s[2][0] == M.brick ) {
          tmap[i][j] = M.wall_cll; continue;
        }
        if ( s[0][0] == M.brick ) {
          tmap[i][j] = M.wall_clr; continue;
        }
      }
        // top of wall
        if ( tmap[i][j] == 0 && s[1][2] == M.brick ) {
          tmap[i][j] = M.wall_b; continue;
        }
    }
  }

  // ------- third pass through { halls }
  foreach ( i; 0 .. tmap.length ) {
    foreach ( j; 0 .. tmap[i].length ) {
      /*  [0, 0] [1, 0] [2, 0]
          [0, 1]        [2, 1]
          [0, 2] [1, 2] [2, 2]

          0 == nothing, 1 == floor, otherwise M
      */
      int[3][3] surroundings = [[0, 0, 0], [0, 0, 0], [0, 0, 0]];
      for ( int ii = cast(int) i-1; ii != i+2; ++ ii ) {
        if ( ii == -1 || ii == tmap.length ) continue; // lim
        for ( int jj = cast(int) j-1; jj != j+2; ++ jj ) {
          if ( jj == -1 || jj == tmap[ii].length ) continue; // lim
          int ti = ii - cast(int) i+1,
              tj = jj - cast(int) j+1;
          if ( tmap[ii][jj] == -1 )
            surroundings[ti][tj] = 1;
          if ( tmap[ii][jj] <= -100 )
            surroundings[ti][tj] = tmap[ii][jj];
        }
      }
      alias M = Data.Image.MapGrid;
      auto s = surroundings;
      // corner outside of wall
      if ( s[1][2] == M.brick_l ) {
        tmap[i][j] = M.wall_pll;
        if ( s[1][0] == 1 )
          tmap[i][j] = M.hall_capl;
      }
      if ( s[1][2] == M.brick_r ) {
        tmap[i][j] = M.wall_plr;
        if ( s[1][0] == 1 )
          tmap[i][j] = M.hall_capr;
      }
      if ( tmap[i][j] < -101 ) {
        if ( (s[1][0] == 1 && s[1][2] == 1) ) {
          tmap[i][j] = M.hall_horiz;
          if ( s[0][1] == 1 )
            tmap[i][j] = M.hall_capl;
          if ( s[2][1] == 1 )
            tmap[i][j] = M.hall_capr;
        }
        if ( (s[0][1] == 1 && s[2][1] == 1) ){
          tmap[i][j] = M.hall_vert;
          if ( s[1][0] == 1 )
            tmap[i][j] = M.hall_capu;
          if ( s[1][2] == 1 )
            tmap[i][j] = M.hall_capd;
        }
      }
    }
  }

  bool Is_Wall(int x) {
    return x <= -100 && x >= -150;
  }

  // ------- fourth pass through { floors }
  foreach ( i; 0 .. tmap.length ) {
    foreach ( j; 0 .. tmap[i].length ) {
      /*  [0, 0] [1, 0] [2, 0]
          [0, 1]        [2, 1]
          [0, 2] [1, 2] [2, 2]

          0 == nothing, 1 == floor, otherwise M
      */
      int[3][3] surroundings = [[0, 0, 0], [0, 0, 0], [0, 0, 0]];
      for ( int ii = cast(int) i-1; ii != cast(int) i+2; ++ ii ) {
        if ( ii == -1 || ii == tmap.length ) continue; // lim
        for ( int jj = cast(int) j-1; jj != j+2; ++ jj ) {
          if ( jj == -1 || jj == tmap[ii].length ) continue; // lim
          int ti = ii - cast(int) i+1,
              tj = jj - cast(int) j+1;
          if ( tmap[ii][jj] == -1 )
            surroundings[ti][tj] = 1;
          if ( tmap[ii][jj] <= -100 )
            surroundings[ti][tj] = tmap[ii][jj];
        }
      }

      alias M = Data.Image.MapGrid;
      auto s = surroundings;
      if ( tmap[i][j] == -1 ) {
        tmap[i][j] = M.floor;
        // -- uld
        if ( Is_Wall(s[0][1]) ) tmap[i][j] = M.floor_left;
        if ( Is_Wall(s[2][1]) ) tmap[i][j] = M.floor_right;
        if ( Is_Wall(s[1][0]) ) tmap[i][j] = M.floor_up;
        /* if ( Is_Wall(s[1][2]) ) tmap[i][j] = M.floor_down; */
        // -- vertic/horiz
        if ( Is_Wall(s[0][1]) && Is_Wall(s[2][1]) )
          tmap[i][j] = M.floor_vert;
        /* if ( Is_Wall(s[1][0]) && Is_Wall(s[1][2]) ) */
          /* tmap[i][j] = M.floor_horiz; */
        // -- corner
        if ( Is_Wall(s[0][0]) && Is_Wall(s[1][0]) && Is_Wall(s[0][1]) )
          tmap[i][j] = M.floor_tl;
        if ( Is_Wall(s[2][0]) && Is_Wall(s[1][0]) && Is_Wall(s[2][1]) )
          tmap[i][j] = M.floor_tr;
        /* if ( Is_Wall(s[0][2]) && Is_Wall(s[0][1]) && Is_Wall(s[1][2]) ) */
        /*   tmap[i][j] = M.floor_ll; */
        /* if ( Is_Wall(s[2][2]) && Is_Wall(s[1][2]) && Is_Wall(s[2][1]) ) */
        /*   tmap[i][j] = M.floor_lr; */
        // -- shadow corner
        if ( Is_Wall(s[0][0]) && !Is_Wall(s[1][0]) && !Is_Wall(s[0][1]) )
          tmap[i][j] = M.floor_slr;
        if ( Is_Wall(s[2][0]) && !Is_Wall(s[1][0]) && !Is_Wall(s[2][1]) )
          tmap[i][j] = M.floor_sll;
        /* if ( Is_Wall(s[0][2]) && !Is_Wall(s[0][1]) && !Is_Wall(s[1][2]) ) */
        /*   tmap[i][j] = M.floor_str; */
        /* if ( Is_Wall(s[2][2]) && !Is_Wall(s[1][2]) && !Is_Wall(s[2][1]) ) */
        /*   tmap[i][j] = M.floor_stl; */

        if ( Is_Wall(s[0][1]) && !Is_Wall(s[0][0]) )
          tmap[i][j] = M.floor_str;
        if ( Is_Wall(s[2][1]) && !Is_Wall(s[2][0]) )
          tmap[i][j] = M.floor_stl;

        /* if ( Is_Wall(s[0][0]) && Is_Wall(s[2][1]) ) */
        /*   tmap[i][j] = M.floor_splittl; */
        /* if ( Is_Wall(s[2][0]) && Is_Wall(s[0][1]) ) */
        /*   tmap[i][j] = M.floor_splittr; */
      }
    }
  }

  bool Is_Cap(int x) {
    alias M = Data.Image.MapGrid;
    return x == M.hall_capd || x == M.hall_capl || x == M.hall_capr ||
           x == M.hall_capu || x == M.hall_vert || x == M.hall_horiz ||
           x == M.hall_cll  || x == M.hall_clr  || x == M.hall_ctl ||
           x == M.hall_ctr;
  }


  // -------- fifth pass through ( edge cases ) -------------
  foreach ( i; 0 .. tmap.length ) {
    foreach ( j; 0 .. tmap[i].length ) {
      /*  [0, 0] [1, 0] [2, 0]
          [0, 1]        [2, 1]
          [0, 2] [1, 2] [2, 2]

          0 == nothing, 1 == floor, otherwise M
      */
      int[3][3] surroundings = [[0, 0, 0], [0, 0, 0], [0, 0, 0]];
      for ( int ii = cast(int) i-1; ii != cast(int) i+2; ++ ii ) {
        if ( ii == -1 || ii == tmap.length ) continue; // lim
        for ( int jj = cast(int) j-1; jj != j+2; ++ jj ) {
          if ( jj == -1 || jj == tmap[ii].length ) continue; // lim
          int ti = ii - cast(int) i+1,
              tj = jj - cast(int) j+1;
          if ( tmap[ii][jj] <= -200 && tmap[ii][jj] >= -300 )
            surroundings[ti][tj] = 1;
          else if ( tmap[ii][jj] <= -100 )
            surroundings[ti][tj] = tmap[ii][jj];
        }
      }

      alias M = Data.Image.MapGrid;
      auto s = surroundings;

      /* if ( Is_Cap(s[0][1]) && Is_Cap(s[1][0]) ) { */
      /*   tmap[i][j] = M.hall_clr; */
      /* } */
      /* if ( Is_Cap(s[1][0]) && Is_Cap(s[2][1]) ) { */
      /*   tmap[i][j] = M.hall_cll; */
      /* } */
      /* if ( Is_Cap(s[2][1]) && Is_Cap(s[1][2]) ) { */
      /*   tmap[i][j] = M.hall_ctl; */
      /* } */
      /* if ( Is_Cap(s[1][2]) && Is_Cap(s[0][1]) ) { */
      /*   tmap[i][j] = M.hall_ctr; */
      /* } */

      if ( Is_Wall(tmap[i][j]) ) {
        if ( Is_Wall(s[1][0]) && s[1][2] == 1 ) {
          tmap[i][j] = M.brick;
          if ( s[0][1] == 1 )
            tmap[i][j] = M.brick_l;
          if ( s[2][1] == 1 )
            tmap[i][j] = M.brick_r;
        }
      }
    }
  }

  // ----- final pass through ( empty tiles )
  foreach ( i; 0 .. tmap.length ) {
    foreach ( j; 0 .. tmap[i].length ) {
      if ( tmap[i][j] == 0 ) {
        tmap[i][j] = -125;
      }
    }
  }


  map_width = cast(int) tmap.length;
  map_height = cast(int) tmap[0].length;
  // -------------- generate graphix map ---------------------------------------
  map.length = tmap.length;
  import Entity.Map, Entity.Mob;
  foreach ( i; 0 .. tmap.length) {
    map[i].length = tmap[0].length;
    foreach ( j;0 .. tmap[0].length ) {
      if ( tmap[i][j] != 0 && i>0 && i<tmap.length-1
                           && j>0 && j<tmap[i].length-1) {
        if ( tmap[i][j] > 100 ) {
          /* auto m = tmap[i][j] - 101; */
          /* AOD.Add(new Floor(i, j)); */
        } else if ( tmap[i][j] <= -100 ) {
          if ( tmap[i][j] > -200 ) {
            if ( j != 0 && j != tmap.length && tmap[i][j-1] <= -200 &&
                 tmap[i][j+1] >= -200 ) {
              AOD.Add(new Wall( cast(int) i, cast(int) j, tmap[i][j], true));
            } else
              AOD.Add(new Wall( cast(int) i, cast(int) j, tmap[i][j], false));
          } else
            AOD.Add(new Floor( cast(int) i, cast(int) j, tmap[i][j]));
        }
      }
    }
  }
  AOD.Add(player);
  static import Entity.UI;
  AOD.Add(new Entity.UI.HUD);
  // -----  props
  import Entity.Map : Prop;

  Prop[3] top, bot;
  { // statue/doors
    alias M = Game_Manager.map;
    int x = 0, y = 0;
    int ix, iy;
    int cnt = 0;
    do {
      x = cast(int)AOD.R_Rand(1, map.length);
      y = cast(int)AOD.R_Rand(1, map.length);
      ix = x - 4, iy = y - 3;
      if ( ix+5 < map.length && iy+5 < map[0].length &&
           map[ix+5][iy+4].length >= 1 &&
           map[ix+5][iy+5].length >= 1 &&
           M[ix+5][iy+4][0].R_Tile_Type == Tile_Type.Floor &&
           M[ix+5][iy+5][0].R_Tile_Type ==Tile_Type.Floor )
        break;
    } while ( true );
    /* foreach ( i; ix .. ix + 4 ) { */
    /*   foreach ( j; iy .. iy + 4 ) { */
    /*     // -- DEBUG START */
    /*     import std.stdio : writeln; */
    /*     import std.conv : to; */
    /*     writeln(to!string(map[i][j])); */
    /*     // -- DEBUG END */
    /*     foreach ( k; 0 .. map[i][j].length ) */
    /*       AOD.Remove(M[i][j][k]); */
    /*     M[i][j] = []; */
    /*   } */
    /* } */
    alias S = Data.Image.MapGrid;
    AOD.Add(new Wall( ix, iy, S.wall_ctl, false));
    AOD.Add(new Wall( ix+1, iy, S.wall_t, false));
    AOD.Add(new Wall( ix+2, iy, S.wall_t, false));
    AOD.Add(new Wall( ix+3, iy, S.wall_ctr, false));
    AOD.Add(new Wall( ix, iy+1, S.wall_l, false));
    AOD.Add(new Floor( ix+1, iy+1, S.floor_tl));
    AOD.Add(new Prop(ix+1, iy+1, Prop.Type.Statue_Bot));
    AOD.Add(new Prop(ix+1, iy, Prop.Type.Statue_Top));
    AOD.Add(new Floor( ix+2, iy+1, S.floor_tr));
    AOD.Add(new Wall( ix+3, iy+1, S.wall_r, false));
    AOD.Add(new Wall( ix,   iy+2, S.wall_l, false));
    AOD.Add(new Floor( ix+1, iy+2, S.floor_tl));
    AOD.Add(new Floor( ix+2, iy+2, S.floor_tr));
    top[0] = new Prop( ix+1, iy+2, Prop.Type.Closed_Door_Left );
    bot[0] = new Prop( ix+2, iy+2, Prop.Type.Closed_Door_Right );
    top[0].Set_Holder(bot[0]);
    bot[0].Set_Holder(top[0]);
    Game_Manager.Add(top[0]);
    Game_Manager.Add(bot[0]);
    AOD.Add(new Wall( ix+3, iy+2, S.wall_r, false));

    AOD.Add(new Wall( ix, iy+3, S.wall_l, false));
    AOD.Add(new Floor( ix+1, iy+3, S.floor));
    AOD.Add(new Floor( ix+2, iy+3, S.floor));
    AOD.Add(new Floor( ix+3,   iy+3, S.floor));
    AOD.Add(new Floor( ix+4,   iy+3, S.floor));
    top[1] = new Prop( ix+2, iy+3, Prop.Type.Closed_Door_Top );
    top[2] = new Prop( ix+4, iy+3, Prop.Type.Closed_Door_Top );
    Game_Manager.Add(top[1]); Game_Manager.Add(top[2]);

    AOD.Add(new Wall( ix, iy+4, S.wall_l, false));
    AOD.Add(new Floor( ix+1, iy+4, S.floor));
    AOD.Add(new Floor( ix+2, iy+4, S.floor));
    AOD.Add(new Floor( ix+3,   iy+4, S.floor));
    AOD.Add(new Floor( ix+4,   iy+4, S.floor));
    bot[1] = new Prop( ix+2, iy+4, Prop.Type.Closed_Door_Bot );
    bot[2] = new Prop( ix+4, iy+4, Prop.Type.Closed_Door_Bot );
    AOD.Add(bot[1]); AOD.Add(bot[2]);
    top[1].Set_Holder(bot[1]);
    top[2].Set_Holder(bot[2]);
    bot[1].Set_Holder(top[1]);
    bot[2].Set_Holder(top[2]);
    AOD.Add(new Wall( ix, iy+5, S.wall_cll, false));
    AOD.Add(new Wall( ix+1, iy+5, S.wall_b, false));
    AOD.Add(new Wall( ix+2, iy+5, S.wall_b, false));
    AOD.Add(new Wall( ix+3,   iy+5, S.wall_b, false));
    AOD.Add(new Wall( ix+4,   iy+5, S.wall_clr, false));
    if ( Game_Manager.Valid_Position(ix+5, iy+5) ) {

    }
    Game_Manager.player.Set_Tile_Pos(ix+5,iy+5);
    AOD.Add(new Prop(ix+1, iy+3, Prop.Type.Heart_Pickup));
    AOD.Add(new Prop(ix+3, iy+3, Prop.Type.Heart_Pickup));
    AOD.Add(new Prop(ix+1, iy+4, Prop.Type.Heart_Pickup));
    AOD.Add(new Prop(ix+3, iy+4, Prop.Type.Heart_Pickup));
  }
  /** generate doors */

  int amt_switches = 6;
  Prop[] tbot = [ top[0], bot[0], top[1], bot[1], top[2], bot[2] ];
  int cnt = 0;
  for ( int i = 0; i != amt_switches; ++ i ) {
    int x, y;
    bool pass_once = false;
    DOAGAIN:
    do {
      x = cast(int)AOD.R_Rand(2, map.length);
      y = cast(int)AOD.R_Rand(3, map[0].length);
      if ( map[x][y].length == 1 && map[x][y][0].R_Tile_Type == Tile_Type.Floor)
        break;
    } while ( true );
    if ( pass_once )
      AOD.Add(new Prop(x, y, Prop.Type.Switch, tbot[i]));
    else {
      Game_Manager.Add(new Prop(x, y-1, Prop.Type.Block_Top));
      Game_Manager.Add(new Prop(x, y,   Prop.Type.Block_Bot));
      pass_once = true;
      goto DOAGAIN;
    }
  }
  int charger = cast(int)AOD.R_Rand(0, 10);
  foreach ( i; 0 .. map.length ) { // sixth pass through ( props -- moss )
    foreach ( j; 0 .. map[i].length ) {
      if ( map[i][j].length != 1 ) continue;
      if ( map[i][j][0].R_Tile_Type() == Entity.Map.Tile_Type.Floor ) {
        if ( AOD.R_Rand(0, 100) > 70 && charger < 10 ) ++ charger;
        if ( AOD.R_Rand(0, 100)*(1 + charger/10) > 180 ) {
          charger = 0;
          if ( AOD.R_Rand(0, 100) > 40 )
            AOD.Add(new Prop(cast(int)i, cast(int)j, Prop.Type.Debris ));
        }
      }
    }
  }

  int amt_foilage = cast(int)AOD.R_Rand(40, 60);
  for ( int i = 0; i < amt_foilage; ++ i ) {
    int x, y;
    do {
      x = cast(int)AOD.R_Rand(2, map.length-2);
      y = cast(int)AOD.R_Rand(3, map[0].length-2);
      if ( tmap[x][y] == Data.Image.MapGrid.brick ) break;
    } while ( true );
      switch ( cast(int)(AOD.R_Rand(0, 3)) ) {
        default: break;
        case 0:
          AOD.Add(new Prop(x, y,   Prop.Type.Moss));
        break;
        case 1:
          AOD.Add(new Prop(x, y,   Prop.Type.Vine_Bot));
        break;
        case 2:
          AOD.Add(new Prop(x, y,   Prop.Type.Vine_Bot));
          AOD.Add(new Prop(x, y,   Prop.Type.Vine_Top));
        break;
      }
  }

  int amt_hearts = 4;
  for ( int i = 0; i < amt_hearts; ++ i ) {
    int x, y;
    do {
      x = cast(int)AOD.R_Rand(2, map.length-2);
      y = cast(int)AOD.R_Rand(3, map[0].length-2);
      if ( map[x][y].length == 1 && map[x][y][0].R_Tile_Type == Tile_Type.Floor)
        break;
    } while ( true );
    AOD.Add(new Prop(x, y,   Prop.Type.Heart_Pickup));
  }

  int amt_trees = cast(int)AOD.R_Rand(20, 25);
  for ( int i = 0; i != amt_trees; ++ i ){
    int x, y;
    do {
      x = cast(int)AOD.R_Rand(2, map.length);
      y = cast(int)AOD.R_Rand(3, map[0].length);
      if ( map[x][y].length == 1 && map[x][y][0].R_Tile_Type == Tile_Type.Floor)
        break;
    } while ( true );
    switch ( cast(int)(AOD.R_Rand(0, 2)) ) {
      default: break;
      case 0:
        AOD.Add(new Prop(x, y, Prop.Type.Tree_Bot));
        AOD.Add(new Prop(x, y-1, Prop.Type.Tree_Mid));
        AOD.Add(new Prop(x, y-2, Prop.Type.Tree_Top));
      break;
      case 1:
        AOD.Add(new Prop(x, y, Prop.Type.Rock));
      break;
    }
  }

  /* // generate mobs */
  /* int amt_mobs = cast(int)AOD.R_Rand(30, 50); */
  /* for ( int i = 0; i != trooms_x.length; ++ i ){ */
  /*   int x, y; */
  /*   do { */
  /*     x = cast(int)AOD.R_Rand(2, map.length); */
  /*     y = cast(int)AOD.R_Rand(3, map[0].length); */
  /*     if ( map[x][y].length == 1 && */
  /*          map[x][y][0].R_Tile_Type() == Entity.Map.Tile_Type.Floor ) break; */
  /*   } while ( true ); */
  /*   import Entity.Mob; */
  /*   AOD.Add(new Mob(x, y)); */
  /* } */

}

void Update() {
  if ( restarted ) {
    Initialize();
    return;
  }
  if ( player is null ) return;
  import std.math;
  auto px = player.R_Tile_Pos.x, py = player.R_Tile_Pos.y;
  int rlx = cast(int)AOD.Util.R_Max(0, px - 15),
      rhx = cast(int)AOD.Util.R_Min(Game_Manager.map.length-1, px + 15);
  int rly = cast(int)AOD.Util.R_Max(0, py - 15),
      rhy = cast(int)AOD.Util.R_Min(Game_Manager.map[0].length-1, py + 15);
  int cnt = 0;
  Entity.Map.Prop[] props_to_vis;
  for ( int i = rlx; i != rhx; ++ i)
  for ( int j = rly; j != rhy; ++ j ) {
    /* if ( i == px && j == py ) continue; */
    auto l = AOD.Util.Bresenham_Line(cast(int)px, cast(int)py, i, j);
    int amt = 0;
    foreach ( l_i; 1 .. l.length-1 ) {
      auto cx = cast(int)l[l_i].x, cy = cast(int)l[l_i].y;
      if ( Game_Manager.map[cx][cy].length == 0 ||
           Game_Manager.map[cx][cy][$-1].Blocks_Vision() ) {
        ++ amt;
      }
    }
    float d = Game_Manager.player.R_Light(i, j, amt);
    foreach ( exp; explosions ) {
      auto pr = cast(Entity.Projectile.Explosion)(exp);
      if ( exp !is null )
        d += pr.R_Light(AOD.Vector(i, j));
    }
    foreach ( proj; projectiles ) {
      auto pr = cast(Entity.Projectile.Projectile)(proj);
      if ( proj !is null )
        d += pr.R_Light(AOD.Vector(i*32, j*32));
    }
    foreach ( st; stone_doors ) {
      d += st.R_Light(AOD.Vector(i*32, j*32));
    }
    foreach ( k; 0 .. map[i][j].length ) {
      if ( map[i][j][k].R_Tile_Type == Entity.Map.Tile_Type.Mob ) {
        import Entity.Mob;
        auto e = cast(Mob)map[i][j][k];
        e.Shadow_Col(d);
      }
      map[i][j][k].Set_Colour(d, d, d, map[i][j][k].R_Alpha);
    }
  }
  /* player.Set_Colour(1.0, 1.0, 1.0, 1.0); */
}
