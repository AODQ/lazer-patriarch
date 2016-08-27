module Entity.Projectile;
static import AOD;
static import Entity.Map;
static import Game_Manager;

class Projectile : AOD.Entity {
  Entity.Map.Tile_Type caster;
public:
  this(int x, int y, int ex, int ey, Entity.Map.Tile_Type _caster) {
    x *= 32; y *= 32;
    x += 16; y += 16;
    static import Data;
    super(Data.Layer.Projectile);
    Set_Sprite(Data.Image.projectile);
    // -- DEBUG START
    import std.stdio : writeln;
    import std.conv : to;
    writeln("X: " ~ to!string(x) ~ "Y: " ~ to!string(y) ~ " EX: " ~ to!string(ex
              ) ~ " EY: " ~ to!string(ey));
    // -- DEBUG END
    Set_Position(x, y);
    import std.math;
    float angle = atan2(cast(float)(ey - y), cast(float)(ex - x));
    Set_Velocity(cos(angle)*5.1, sin(angle)*5.1);
    caster = _caster;
  }
  override void Update() {
    int px = cast(int)(position.x/32), py = cast(int)(position.y/32);
    if ( px < 0 || px > Game_Manager.map_width ||
         py < 0 || py > Game_Manager.map_height ) {
      AOD.Remove(this);
      return;
    }
    if ( Game_Manager.map[px][py].length == 0 ) return;
    auto til = Game_Manager.map[px][py][$-1];
    alias Tile_Type = Entity.Map.Tile_Type;
    switch ( til.R_Tile_Type() ) {
      default: return;
      case Tile_Type.Wall:
        AOD.Remove(this);
        return;
      case Tile_Type.Player:
        if ( caster != Tile_Type.Player ) {
          AOD.Remove(this);
        }
      break;
      case Tile_Type.Mob:
        if ( caster != Tile_Type.Mob ) {
          AOD.Remove(this);
        }
      break;
    }
  }
}
