module Entity.Projectile;
static import AOD;
static import Entity.Map;
static import Game_Manager;
static import Data;

class Projectile : AOD.Entity {
  Entity.Map.Tile_Type caster;
  AOD.Entity caster_obj;
  int dx, dy;
  uint sound_handle;
  uint sound_timer;
  bool mob = false;
public:
  float R_Light(AOD.Vector other) {
    return mob ? 10/position.Distance(other) :
                 25/position.Distance(other);
  }

  this(int x, int y, int _dx, int _dy, Entity.Map.Tile_Type _caster,
       AOD.Entity _caster_obj) {
    caster_obj = _caster_obj;
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

    Game_Manager.Add(
        new Explosion(cast(int)position.x, cast(int)position.y,
                                                dx, dy, mob, false, caster_obj)
    );

  }
  void Explode() {
    auto e = new Explosion(cast(int)position.x, cast(int)position.y,
                                                dx, dy, mob, true);
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
            if ( py > 0 && Game_Manager.map[px][py-1].length == 1 &&
                           Game_Manager.map[px][py-1][0].R_Tile_Type ==
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
          if ( caster != Tile_Type.Player ) {
            Game_Manager.player.Damage();
            Explode();
          }
        break;
        case Tile_Type.Mob:
          if ( caster != Tile_Type.Mob ) {
            Explode();
            auto e = cast(Entity.Mob.Mob)(til);
            e.Kill();
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
  AOD.Entity holder;
  int dx, dy;
public:
  float R_Light(AOD.Vector other) {
    AOD.Vector pos = position/32;
    return mob ? 0.8/(1 + R_Anim_Index)/pos.Distance(other) :
                 1.5/(1 + R_Anim_Index)/pos.Distance(other);
  }
  this(int x, int y, int _dx, int _dy, bool _mob, bool type_eye,
      AOD.Entity _holder = null) {
    dx = _dx; dy = _dy;
    mob = _mob;
    holder = _holder;
    if ( !type_eye ) {
      x += dx*4;
      if ( mob )
        y += 7;
      if ( dx != 0 )
        y += 4;
      if ( dy == -1 ) {
        y += 2;
        super(Data.Layer.Player+1);
      } else
        super(Data.Layer.Explosion - 2*cast(int)(dx!=0));
    } else
      super(Data.Layer.Explosion - 2*cast(int)(dx!=0));
    /* auto ix = R_Position.x - Game_Manager.player.R_Position.x, */
         /* iy = R_Position.y - Game_Manager.player.R_Position.y; */
    AOD.Play_Sound(Data.Sound.laser_hit);
    anim_player = AOD.Animation_Player(
          mob ? Data.Image.Enemy.proj_explosion[cast(int)type_eye] :
                Data.Image.Player.proj_explosion[cast(int)type_eye]);
    Set_Sprite(anim_player.R_Current_Texture());
    Set_Position(x, y);
  }
  int R_Anim_Index() {
    return cast(int)anim_player.index;
  }
  override void Update() {
    if ( mob && holder !is null ) {
      auto e = cast(Entity.Mob.Mob)(holder);
      if ( e.R_Dead() ) {
        holder = null;
        AOD.Remove(this);
        return;
      }
    }
    if ( holder !is null ) {
      position = holder.R_Position();
      position.y += dy*5;
      if ( !mob && dy == 1 ) {
        position.y -= 4;
      } else if ( !mob && dy == 0 )
        position.x += dx*4;
      else
        position.x += dx*7;
      if ( mob && dx != 0 ) position.y += 7;
    }
    anim_player.Update();
    if ( anim_player.done ) {
      Game_Manager.Remove(this);
    }
    Set_Sprite(anim_player.R_Current_Texture());
  }
}
