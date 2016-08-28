module Entity.Map;

static import AOD;
static import Data;

enum Tile_Type {
  Nil, Floor, Wall, Player, Mob
}

class Tile : AOD.PolyEntity {
  int tile_x, tile_y;
  bool can_be_stepped_on;
  Tile_Type tile_type;
public:
  this(int x, int y, Tile_Type _tile_type, Data.Layer _layer = Data.Layer.Floor,
       bool _cbso = true) {
    super(cast(ubyte)_layer);
    can_be_stepped_on = _cbso;
    tile_type         = _tile_type;
    tile_x = x ;
    tile_y = y;
    Set_Position(tile_x*32 + 16, tile_y*32 + 16);
    Set_Image_Size(AOD.Vector(32, 32));
    Set_Size(32, 32);
  }
  override void Added_To_Realm() {
    import Game_Manager : map;
    map[tile_x][tile_y] ~= this;
  }
  override void Post_Update() {
    Set_Position(tile_x*32 + 16, tile_y*32 + 16);
  }
  void Set_Tile_Pos(int x, int y) {
    int ox = tile_x, oy = tile_y;
    tile_x = x;
    tile_y = y;
    import Game_Manager : map;
    foreach ( i; 0 .. map[ox][oy].length )
      if ( map[ox][oy][i] is this ) {
        map[ox][oy] = AOD.Util.Remove(map[ox][oy], cast(int) i);
      }
    /* if ( map[ox][oy].length != 0 ) */
    /*   map[ox][oy][$-1].Set_Visible(true); */
    /* if ( map[x][y].length != 0 ) */
    /*   map[x][y][$-1].Set_Visible(false); */
    /* Set_Visible(true); */
    map[x][y] ~= this;
    Post_Update();
  }
  AOD.Vector R_Tile_Pos() {
    return AOD.Vector(tile_x, tile_y);
  }
  bool R_Can_Be_Stepped_On() {
    return can_be_stepped_on;
  }
  Tile_Type R_Tile_Type() { return tile_type; }
  bool Blocks_Vision() {
    return false;
  }
}
class Prop : Tile {
public:
  this(int x, int y) {
    super(x, y, Tile_Type.Floor, Data.Layer.Item);
    Set_Sprite(Data.Image.props[cast(int)AOD.R_Rand(0, $)]);
  }
}

class Floor : Tile {
public:
  this(int x, int y, int id) {
    super(x, y, Tile_Type.Floor);
    int img = -(id + 200);
    Set_Sprite(Data.Image.floors[img]);
    if ( id == cast(int)Data.Image.MapGrid.floor_horiz ) {
    }
  }
}

class Wall : Tile {
public:
  this(int x, int y, int id) {
    super(x, y, Tile_Type.Wall, Data.Layer.Floor, false);
    int img = -(id + 100);
    /* // -- DEBUG START */
    /* import std.stdio : writeln; */
    /* import std.conv : to; */
    /* writeln("WALL: " ~ to!string(img)); */
    /* // -- DEBUG END */
    Set_Sprite(Data.Image.walls[img]);
  }
  override bool Blocks_Vision() {
    return true;
  }
}

class Black : Tile {
public:
  this(int x, int y) {
    super(x, y, Tile_Type.Nil, Data.Layer.Black);
    Set_Sprite(Data.Image.black);
  }
}
