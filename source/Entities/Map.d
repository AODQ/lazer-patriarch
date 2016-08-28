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
        break;
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
  bool R_Collideable() {
    return can_be_stepped_on;
  }
  Tile_Type R_Tile_Type() { return tile_type; }
  bool Blocks_Vision() {
    return false;
  }
}
class Prop : Tile {
  enum Type {
    Debris            = 0,
    Closed_Door_Top   = 8,
    Closed_Door_Bot   = 9,
    Closed_Door_Left  = 10,
    Closed_Door_Right = 11,
    Open_Door_Vertic  = 12,
    Open_Door_Horiz   = 13,
    Switch            = 14,
    Moss              = 15,
    Rock              = 16,
    Block_Bot         = 17,
    Block_Top         = 18,
    Tree_Top          = 19,
    Tree_Mid          = 20,
    Tree_Bot          = 21,
    Vine_Top          = 22,
    Vine_Bot          = 23,
    Pillar_Top        = 24,
    Pillar_Bot        = 25,
    Arch_Left         = 26,
    Arch_Right        = 27
  };
  Type prop_type;
public:
  this(int x, int y, Type prop) {
    prop_type = prop;
    int prop_tex = prop;
    if ( prop == Type.Debris ) {
      prop_tex = cast(int)AOD.R_Rand(0, 7);
    }
    if (prop == Type.Moss || prop == Type.Vine_Top || prop == Type.Vine_Bot) 
      super(x, y, Tile_Type.Floor, Data.Layer.Foilage);
    
    else if (prop == Type.Closed_Door_Bot || prop == Type.Rock ||
        prop == Type.Block_Bot || prop == Type.Tree_Bot )
      super(x, y, Tile_Type.Prop, Data.Layer.Block, false);
    else if ( prop == Type.Tree_Top || prop == Type.Tree_Mid ||
              prop == Type.Block_Top )
      super(x, y, Tile_Type.Prop, Data.Layer.Front_Prop);
    else
      super(x, y, Tile_Type.Prop, Data.Layer.Item);
    Set_Sprite(Data.Image.props[prop_tex]);
  }
  Type R_Prop_Type() { return prop_type; }
  // block bot -> block top
  // bot -> mid -> top
  Prop R_Top() {
    import Game_Manager : map;
    if ( prop_type == Type.Block_Bot ) {
      foreach ( b; map[tile_x][tile_y-1] )
        if ( b.R_Tile_Type == Tile_Type.Prop ) {
          auto c = cast(Prop)(b);
          if ( c.R_Prop_Type == Type.Block_Top ) return c;
        }
    }
    if ( prop_type == Type.Tree_Bot ) {
      foreach ( b; map[tile_x][tile_y-1] )
        if ( b.R_Tile_Type == Tile_Type.Prop ) {
          auto c = cast(Prop)(b);
          if ( c.R_Prop_Type == Type.Tree_Mid ) return c;
        }
    }
    if ( prop_type == Type.Tree_Mid ) {
      foreach ( b; map[tile_x][tile_y-1] )
        if ( b.R_Tile_Type == Tile_Type.Prop ) {
          auto c = cast(Prop)(b);
          if ( c.R_Prop_Type == Type.Tree_Top ) return c;
        }
    }
    return null;
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
    return !R_Collideable();
  }
}
