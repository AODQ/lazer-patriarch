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
    if ( tile_x < map.length && tile_y < map[0].length &&
         tile_x >= 0 && tile_y >= 0 )
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
    Closed_Door_Top_H   = 12,
    Closed_Door_Bot_H   = 13,
    Closed_Door_Left_H  = 14,
    Closed_Door_Right_H = 15,
    Open_Door_Vertic  = 16,
    Open_Door_Horiz   = 17,
    Switch            = 18,
    Moss              = 19,
    Rock              = 20,
    Block_Bot         = 21,
    Block_Top         = 22,
    Block_Bot_Hilit   = 23,
    Block_Top_Hilit   = 24,
    Tree_Top          = 25,
    Tree_Mid          = 26,
    Tree_Bot          = 27,
    Vine_Top          = 28,
    Vine_Bot          = 29,
    Statue_Bot        = 30,
    Statue_Top        = 31,
    Heart_Pickup      = 32,
    Pillar_Top        = 33,
    Pillar_Bot        = 34,
    Arch_Left         = 35,
    Arch_Right        = 36
  };
  Type prop_type;
  Prop holder;
public:
  override void Post_Update() {}
  Prop R_Holder() { return holder; }
  void Set_Holder(Prop x) { holder = x; }
  void Set_Prop_Type(int x) { prop_type = cast(Type)x; }
  this(int x, int y, Type prop, Prop _holder = null) {
    holder = _holder;
    prop_type = prop;
    int prop_tex = prop;
    if ( prop == Type.Debris ) {
      prop_tex = cast(int)AOD.R_Rand(0, 7);
    }
    if (prop == Type.Moss || prop == Type.Vine_Top || prop == Type.Vine_Bot) {
      super(x, y, Tile_Type.Floor, Data.Layer.Foilage);
    } else if (prop == Type.Rock || prop == Type.Block_Bot
            || prop == Type.Tree_Bot || prop == Type.Statue_Bot
            || prop == Type.Closed_Door_Top || prop == Type.Closed_Door_Left
            || prop == Type.Closed_Door_Bot || prop == Type.Closed_Door_Right )
      super(x, y, Tile_Type.Prop, Data.Layer.Block, false);
    else if ( prop == Type.Tree_Top || prop == Type.Tree_Mid ||
              prop == Type.Block_Top || prop == Type.Statue_Top )
      super(x, y, Tile_Type.Prop, Data.Layer.Front_Prop);
    else
      super(x, y, Tile_Type.Prop, Data.Layer.Item);
    Set_Sprite(Data.Image.props[prop_tex]);
    Do_Flip();
  }
  void Set_Collideable(bool x) {
    can_be_stepped_on = !x;
  }
  void Do_Flip() {
    if ( prop_type == Type.Closed_Door_Top ||
         prop_type == Type.Closed_Door_Top_H ) {
      Set_Collideable(true);
      Flip_Y();
    }
    if ( prop_type == Type.Open_Door_Horiz ||
         prop_type == Type.Closed_Door_Left ||
         prop_type == Type.Closed_Door_Right)
      Set_Rotation(90.0f * (3.14156f/180.0f));
    if ( prop_type == Type.Closed_Door_Right
         || prop_type == Type.Closed_Door_Right_H ) {
      Set_Rotation(270.0f * (3.14156f/180.0f));
    }
  }
  float R_Light(AOD.Vector other) {
    if ( (prop_type >= Type.Closed_Door_Left_H &&
          prop_type <= Type.Closed_Door_Right_H)
          || prop_type == Type.Block_Bot_Hilit
          || prop_type == Type.Block_Top_Hilit )
      return 20.0f/position.Distance(other);
    return 0.0f;
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
