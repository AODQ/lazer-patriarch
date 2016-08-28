module Entity.Map;

static import AOD;
static import Data;

enum Tile_Type {
  Nil, Floor, Wall, Player, Mob, Prop
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
    tile_x = x;
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
    import Game_Manager : map;
    if ( x < 0 || y < 0 || x >= map.length || y >= map[0].length ) return;
    int ox = tile_x, oy = tile_y;
    tile_x = x;
    tile_y = y;
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
  enum Type {
    Debris = 0,
    Opened_Door = 8,
    Closed_Door = 9,
    Switch = 10,
    Moss = 11,
    Rock = 12,
    Block_Bot = 14,
    Block_Top = 13,
    Tree_Top = 15,
    Tree_Mid = 16,
    Tree_Bot = 17,
    Vine_Top = 18,
    Vine_Bot = 19
  };
  Type prop_type;
public:
  this(int x, int y, Type prop) {
    prop_type = prop;
    int prop_tex = prop;
    if ( prop == Type.Debris ) {
      prop_tex = cast(int)AOD.R_Rand(0, 7);
    }
    if (prop == Type.Closed_Door || prop == Type.Rock ||
        prop == Type.Block_Bot || prop == Type.Tree_Bot )
      super(x, y, Tile_Type.Prop, Data.Layer.Item, false);
    else if ( prop == Type.Tree_Top || prop == Type.Tree_Mid ||
              prop == Type.Block_Top )
      super(x, y, Tile_Type.Prop, Data.Layer.Front_Prop);
    else
      super(x, y, Tile_Type.Prop, Data.Layer.Item);
    Set_Sprite(Data.Image.props[prop_tex]);
  }
  Type R_Prop_Type() { return prop_type; }
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
  this(int x, int y, int id, bool passable) {
    super(x, y, Tile_Type.Wall,
              passable?Data.Layer.Front_Wall:Data.Layer.Floor, passable);
    int img = -(id + 100);
    /* // -- DEBUG START */
    /* import std.stdio : writeln; */
    /* import std.conv : to; */
    /* writeln("WALL: " ~ to!string(img)); */
    /* // -- DEBUG END */
    Set_Sprite(Data.Image.walls[img]);
    if ( id == Data.Image.MapGrid.hall_capu ) {
      Flip_Y();
    }
    if ( id == Data.Image.MapGrid.hall_capr ) {
      Flip_X();
    }
    if ( id == Data.Image.MapGrid.floor_splittr )
      Flip_X();
    if ( id == Data.Image.MapGrid.hall_horiz )
      Set_Rotation(AOD.Util.To_Rad(90));
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
    Set_Colour(0, 0, 0, 1);
  }
  override void Added_To_Realm() {}
  override void Set_Tile_Pos(int tx, int ty) {
    position.x = tx*32+16;
    position.y = ty*32+16;
  }
}
