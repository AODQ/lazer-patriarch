module Game_Manager;
static import AOD;
import std.string;

static import Entity.Map;
Entity.Map.Tile[][][] map;
Entity.Map.Tile[] darkness;
Entity.Map.Tile player;
int map_width, map_height;
enum Turn {
  Player, AI
};
Turn current_turn;

bool Valid_Position(int x, int y) {
  if ( x <= 0 || y <= 0 ) return false;
  if ( x >= map.length || y >= map[0].length ) return false;
  if ( map[x][y].length == 0 ) return false;
  return map[x][y][$-1].R_Can_Be_Stepped_On();
}


void Add(T)(T x) {
  AOD.Add(x);
}

void Add(T)(T x) {
  /* static if ( is(T == Paddle  )) { paddle     = x; } */
  AOD.Add(x);
  if ( tile_x < 0 || tile_y < 0 ) {
    // not a tile map
  }}

// only purpose is to add things after menu
class Gmanage : AOD.Entity {
public:
  override void Added_To_Realm() {
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
  /* static if ( is(T == Upgrade )) { mixin(Rem!("upgrades" )); } */
  AOD.Remove(x);
}

void Restart_Game() {
  static import Data;
  AOD.Clean_Up(Data.Construct_New_Menu);
}

void Generate_Map() {
  // -------------- generate textual map ---------------------------------------
  int[][] tmap;
  int[] trooms_x, trooms_y, trooms_w, trooms_h;
  int twidth = cast(int)AOD.R_Rand(50, 100);
  int theight = cast(int)AOD.R_Rand(50, 100);
  tmap.length = twidth;
  for ( int i = 0; i != tmap.length; ++ i )
    tmap[i].length = theight;
  // return true if room valid loc
  bool Room_Intersects(int rx, int ry, int rw, int rh) {
    int lx = rx - rw,
        ly = ry - rh,
        hx = rx + rw,
        hy = ry + rh;
    // map boundaries
    if ( lx < 0 ) return false;
    if ( ly < 0 ) return false;
    if ( hx >= twidth ) return false;
    if ( hy >= theight ) return false;
    // r boundaries
    for ( int i = rx - rw; i != rx + rw; ++ i ) {
      for ( int j = ry - rh; j != ry + rh; ++ j ) {
        if ( tmap[i][j] != 0 ) return false;
      }
    }
    return true;
  }
  // returns false if not enough room
  bool Create_Room(int room_id) {
    int rx, ry, rw, rh;
    int attempt = 0;
    do {
      rx = cast(int)AOD.R_Rand(0, twidth);
      ry = cast(int)AOD.R_Rand(0, theight);
      rw = cast(int)AOD.R_Rand(2, 5);
      rh = cast(int)AOD.R_Rand(2, 5);
      ++ attempt;
    } while ( !Room_Intersects(rx, ry, rw, rh) && attempt < 20 );
    if ( attempt >= 20 ) // not enough room
      return false;
    for ( int i = rx - rw; i != rx + rw; ++ i ) {
      for ( int j = ry - rh; j != ry + rh; ++ j ) {
        tmap[i][j] = room_id;
      }
    }
    trooms_x ~= rx;
    trooms_y ~= ry;
    trooms_h ~= rh;
    trooms_w ~= rw;
    return true;
  }
  // gen rooms
  int rm_amt = cast(int)AOD.R_Rand(15, 30);
  for ( int rms = 0; rms != rm_amt; ++ rms ) {
    if ( !Create_Room(rms) ) {
      break;
    }
  }

  void Generate_Horiz(int sx, int sy, int ex) {
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
      if ( tmap[i][sy] == 0 )
        tmap[i][sy] = -1;
    }
  }
  void Generate_Verti(int sy, int sx, int ey) {
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
    }
  }
  void Generate_Path(int i, int y) {
    if ( i == y ) return;
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
    if ( AOD.R_Rand(0, 2) > 1.0f ) { // horiz?
      Generate_Horiz(srx, sry, erx);
      Generate_Verti(sry, erx, ery);
    } else {
      Generate_Verti(sry, srx, ery);
      Generate_Horiz(srx, ery, erx);
    }
  }

  // gen paths
  for ( int i = 0; i < trooms_x.length - 1; ++ i ) {
    Generate_Path(i, i+1);
  }
  uint rand_paths = cast(int)AOD.R_Rand(trooms_x.length/40,
                                        trooms_x.length/10);
  for ( int i = 0; i != rand_paths; ++ i ) {
    int x, y;
    do {
      x = cast(int)AOD.R_Rand(1, trooms_x.length);
      y = cast(int)AOD.R_Rand(1, trooms_x.length);
    } while ( x != y );
    Generate_Path(i, y);
  }

  /* // generate mobs */
  for ( int i = 0; i != trooms_x.length; ++ i ){
    int amt_mobs = cast(int)AOD.R_Rand(0, trooms_w[i] + trooms_h[i]);
    int srx = trooms_x [ i   ] ,
        sry = trooms_y [ i   ] ,
        srw = trooms_w [ i   ] ,
        srh = trooms_h [ i   ] ;
    foreach ( m; 0 .. amt_mobs ) {
      REGEN_MOB:
      int mx = cast(int)AOD.R_Rand(srx - srw, srx + srw),
          my = cast(int)AOD.R_Rand(sry - srh, sry + srh);
      if ( tmap[mx][my] > 100 ) { // generate 'super' mob
        if ( cast(int)AOD.R_Rand(0, trooms_w[i] + trooms_h[i]) < 3 ) {
          tmap[mx][my] += 100;
        }
      } else {
        tmap[mx][my] = cast(int)AOD.R_Rand(101, 126);
      }
    }
  }
  // -- DEBUG START
  import std.stdio;
  import std.conv : to;
  writeln("WIDTH: " ~ to!string(tmap.length) ~ " HEIGHT: "
                    ~ to!string(tmap[0].length) ~ " ROOMS: "
                    ~ to!string(trooms_x.length));
  foreach ( i; 0 .. tmap.length ) {
    foreach ( j; 0 .. tmap[i].length ) {
      int z = tmap[i][j];
      char c;
      if ( z == 0 )
        c = ' ';
      else if ( z < 0 ) {
        /* if ( z == -1 ) */
          /* c = 'V'; */
        /* else */
          /* c = 'H'; */
        c = '0';
      } else
        c = cast(char)('0' + z);
      /* if ( z > 100 ) { */
      /*   if ( z > 200 ) */
      /*     c = cast(char)(cast(char)(z - 201) + 'a'); */
      /*   else */
      /*     c = cast(char)(cast(char)(z - 101) + 'A'); */
      /* } else { */
      /*   c = cast(char)(z - '0'); */
      /* } */
      write(c);
    }
    writeln("");
  }
  // -- DEBUG END

  // place player
  import Entity.Player;
  {
    int rx = trooms_x [ 1 ] ,
        ry = trooms_y [ 1 ] ;
    player = new Player(rx, ry);
  }

  // ensure tmap has boundaries
  tmap = [][]  ~ tmap ~ [][];
  foreach ( i; 0 .. tmap.length )
    tmap[i] = [] ~ tmap[i] ~ [];
  // generate wall
  bool Valid_Wall_Token(int x, int y) {
    return tmap[x][y] != 0 && tmap[x][y] != -3;
  }
  foreach ( i; 0 .. tmap.length ) {
    foreach ( j; 0 .. tmap[i].length ) {
      if ( tmap[i][j] != 0 ) continue; // empty
      for ( int ii = i-1; ii != i+2; ++ ii ) {
        if ( ii == -1 || ii == tmap.length ) continue; // lim
        for ( int jj = j-1; jj != j+2; ++ jj ) {
          if ( jj == -1 || jj == tmap[ii].length ) continue; // lim
          if ( Valid_Wall_Token(ii, jj) ) {
            tmap[i][j] = -3;
            goto __NEXT_WALL_GENERATE;
          }
        }
      }
      __NEXT_WALL_GENERATE:
    }
  }

  map_width = tmap.length;
  map_height = tmap[0].length;
  // -------------- generate graphix map ---------------------------------------
  import Entity.Map, Entity.Mob;
  map.length = tmap.length;
  foreach ( i; 0 .. tmap.length ) {
    map[i].length = tmap[0].length;
    foreach ( j; 0 .. tmap[0].length ) {
      if ( tmap[i][j] != 0 ) {
        if ( tmap[i][j] > 100 ) {
          auto m = tmap[i][j] - 101;
          AOD.Add(new Mob(i, j, m));
          AOD.Add(new Floor(i, j));
        } else if ( tmap[i][j] == -3 )
          AOD.Add(new Wall(i, j));
        else
          AOD.Add(new Floor(i, j));
      }
    }
  }
  AOD.Add(player);
  static import Entity.UI;
  AOD.Add(new Entity.UI.HUD);
  darkness.length = 300;
  foreach ( i; 0 .. darkness.length ) {
    darkness[i] = new Entity.Map.Black(0, 0);
    AOD.Add(darkness[i]);
  }
}

void Update() {
  int rlx = player.R_Tile_Pos().x - 10, rhx = player.R_Tile_Pos.x + 10;
  int rly = player.R_Tile_Pos().y - 7,  rhy = player.R_Tile_Pos.y + 7;
  for ( int i = rlx; i != rhx; ++ i)
  for ( int j = rly; i != rhy; ++ j ) {

  }
}
