module Entity.Map;
static import AOD;
static import Data;

class Tile : AOD.Entity {
  int tile_x, tile_y;
  bool can_be_stepped_on;
public:
  this(int x, int y, Data.Layer _layer = Data.Layer.Floor, bool _cbso = true) {
    super(cast(ubyte)_layer);
    can_be_stepped_on = _cbso;
    tile_x = x ;
    tile_y = y;
    Set_Position(tile_x*32 + 16, tile_y*32 + 16);
    Set_Image_Size(AOD.Vector(32, 32));
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
        /* map[ox][oy] = AOD.Util.Remove(map[ox][oy], i); */
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
}

class Floor : Tile {
public:
  this(int x, int y) {
    super(x, y);
    Set_Sprite(Data.Image.floors[0]);
  }
}

class Wall : Tile {
public:
  this(int x, int y) {
    super(x, y, Data.Layer.Floor, false);
    Set_Sprite(Data.Image.walls[0]);
  }
}

class Black : Tile {
public:
  this(int x, int y) {
    super(x, y, Data.Layer.Black);
    Set_Sprite(Data.Image.black);
  }
}
