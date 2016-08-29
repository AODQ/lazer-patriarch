module Entity.Projectile;
static import AOD;
static import Entity.Map;
static import Game_Manager;
static import Data;

class Projectile : AOD.Entity {
  Entity.Map.Tile_Type caster;
  int dx, dy;
  uint sound_handle;
  uint sound_timer;
  bool mob = false;
public:
  float R_Light(AOD.Vector other) {
    return mob ? 10/position.Distance(other) :
                 25/position.Distance(other);
  }

  this(int x, int y, int _dx, int _dy, Entity.Map.Tile_Type _caster) {
    mob = ( _caster == Entity.Map.Tile_Type.Mob );
    x *= 32; y *= 32;
    x += 16; y += 16;
    sound_handle = AOD.Play_Sound(Data.Sound.laser_fire);
    int l = cast(int)Data.Layer.Projectile;
    sound_timer = cast(int)(1041/AOD.R_MS());
    dx = _dx; dy = _dy;
    if ( dx != 0 )
      y -= 20;
    if ( dy == 1 )
      y -= 15;
    if ( dy == -1 ) {
      y -= 25;
      ++ l;
    }
    super(cast(ubyte)l);
    Set_Sprite(dx != 0 ? (mob ? Data.Image.Enemy.proj_horiz :
                                Data.Image.Player.proj_horiz) :
                         (mob ? Data.Image.Enemy.proj_vert :
                                Data.Image.Player.proj_vert));
    if ( dx == 1 ) Flip_X();
    if ( dy == -1 ) Flip_Y();

    Set_Position(x, y);
    import std.math;
    Set_Velocity(dx*(mob ? 6.3 : 12.1), dy* (mob ? 6.3 : 12.1));
    caster = _caster;
  }
  void Explode() {
    auto e = new Explosion(cast(int)position.x, cast(int)position.y,
                                                       dx, dy, mob);
    Game_Manager.Add(e);
    Game_Manager.Remove(this);
  }
  override void Update() {
    if ( -- sound_timer > 0 ) {
      auto x = R_Position.x - Game_Manager.player.R_Position.x,
           y = R_Position.y - Game_Manager.player.R_Position.y;
      AOD.Sound.Change_Sound_Position(sound_handle, x, y, 0);
    }
    int px = cast(int)(position.x), py = cast(int)(position.y);
    if ( dx != 0 ) py += 20;
    px = cast(int)(px/32);
    py = cast(int)(py/32);
    if ( px < 0 || px >= Game_Manager.map.length ||
         py < 0 || py >= Game_Manager.map[0].length ) {
      Game_Manager.Remove(this);
      return;
    }
    foreach ( t; 0 .. Game_Manager.map[px][py].length ) {
      auto til = Game_Manager.map[px][py][t];
      alias Tile_Type = Entity.Map.Tile_Type;
      if ( til is null ) continue;
      switch ( til.R_Tile_Type() ) {
        default: break;
        case Tile_Type.Wall:
          if ( dx != 0 || (dy == 1 && cast(int)(position.y)%32 > 16) ) {
            import std.stdio : writeln;
            import std.conv : to;
            writeln(to!string(Game_Manager.map[px][py][0].R_Tile_Type));
            if ( py > 0 && Game_Manager.map[px][py-1][0].R_Tile_Type ==
                            Entity.Map.Tile_Type.Floor ) {
              continue;
            }
          }
          Explode();
        break;
        case Tile_Type.Prop:
          import Entity.Map : Prop;
          auto c = cast(Prop)(til);
          switch ( c.R_Prop_Type() ) {
            case Prop.Type.Tree_Bot:
              Explode();
            break;
            case Prop.Type.Block_Bot:
              Explode();
            break;
            default: break;
          }
        break;
        case Tile_Type.Player:
          if ( caster != Tile_Type.Player )
            Explode();
        break;
        case Tile_Type.Mob:
          if ( caster != Tile_Type.Mob ) {
            Explode();
            Game_Manager.map[px][py] =
              AOD.Util.Remove(Game_Manager.map[px][py], t);
            AOD.Remove(til);
            return;
          }
        break;
      }
    }
  }
}

class Explosion : AOD.Entity {
  AOD.Animation_Player anim_player;
  bool mob;
public:
  float R_Light(AOD.Vector other) {
    AOD.Vector pos = position/32;
    return mob ? 0.8/(1 + R_Anim_Index)/pos.Distance(other) :
                 1.5/(1 + R_Anim_Index)/pos.Distance(other);
  }
  this(int x, int y, int dx, int dy, bool _mob) {
    mob = _mob;
    super(Data.Layer.Explosion - 2*cast(int)(dx!=0));
    /* auto ix = R_Position.x - Game_Manager.player.R_Position.x, */
         /* iy = R_Position.y - Game_Manager.player.R_Position.y; */
    AOD.Play_Sound(Data.Sound.laser_hit);
    int ind = cast(int)AOD.R_Rand(0, 2);
    anim_player = AOD.Animation_Player(
          mob ? Data.Image.Enemy.proj_explosion[ind] :
                Data.Image.Player.proj_explosion[ind]);
    Set_Sprite(anim_player.R_Current_Texture());
    if ( ind == 0 && dx != 0 )
      y += 4;
    Set_Position(x, y);
  }
  int R_Anim_Index() {
    return anim_player.index;
  }
  override void Update() {
    anim_player.Update();
    if ( anim_player.done ) {
      Game_Manager.Remove(this);
    }
    Set_Sprite(anim_player.R_Current_Texture());
  }
}
