module AODCore.animation;
import AODCore.image;
/**
  An animation that stores an array of sheetrects
*/
class Animation {
public:
  /** Type of animation playback to occur */
  enum Type {
    /** 0 .. $ */
    Linear,
    /** $ .. 0 */
    Reverse,
    /** 0 .. $ .. 0 */
    Zigzag,
    /** */
    Nil
  }

  /** Animation textures in the order they should be played */
  SheetRect[] textures;
  /** frames that should occur per every texture iteration */
  int frames_per_texture;
  /** */
  Type type;
  /** Must be at least two textures */
  this(Type _type, SheetRect[] _textures, int _frames_per_texture) {
    type = _type;
    textures = _textures.dup;
    textures = _textures;
    frames_per_texture = _frames_per_texture;
  }
}

/**
  Keeps track of animation and time left along with index. Make sure to call
  Update_Index.
*/
struct Animation_Player {
  Animation.Type type;
public:
  /* @disable this(); */
  /** See Set */
  this(Animation _animation, Animation.Type override_type = Animation.Type.Nil)
  { Set(_animation, true, override_type); }
  /** Animation to 'play' */
  Animation animation;
  /** Current texture index of the animation */
  size_t index;
  /** Frames left before index is incremented */
  int frames_left;
  /** The current direction of playback, 1 = positive.
      Only applies to Zigzag animation type */
  bool direction;
  /** Indicates whether the animation has finished playing, if another update
        is called after this is set, it is reset to false */
  bool done;
  /** Updates the animation player, should be called once every frame
Return:
    Current index
   */
  int Update() {
    done = false;
    if ( animation.textures.length <= 1 ) return 0;
    if ( -- frames_left <= 0 ) {
      frames_left = animation.frames_per_texture;
      switch ( type ) {
        default: break;
        case Animation.Type.Linear:
          if ( ++ index >= animation.textures.length ) {
            index = 0;
            done = true;
          }
        break;
        case Animation.Type.Zigzag:
          if ( (direction && ++ index >= animation.textures.length) ) {
            index = animation.textures.length - 2;
            direction ^= 1;
            break;
          }
          if ( (!direction && -- index <  0) ) {
            index = 1;
            direction ^= 1;
          }
        break;
        case Animation.Type.Reverse:
          if ( -- index < 0 ) {
            done = true;
            index = animation.textures.length - 1;
          }
        break;
      }
    }
    return cast(int)index;
  }
  /** Returns current texture based off the index */
  SheetRect R_Current_Texture() {
    if ( animation.textures.length != 0 )
      return animation.textures[index];
    return SheetRect();
  }
  /** Sets a new animation
Params:
  _animation    = new animation
  force_reset   = if animation already playing, will force variables to reset
  override_type = overrides default animation type
    */
  void Set(Animation _animation, bool force_reset = false,
                 Animation.Type override_type = Animation.Type.Nil ) {
    if ( animation !is _animation || force_reset ) {
      done = false;
      animation = _animation;
      type = override_type == Animation.Type.Nil ?
                    animation.type : override_type;
      frames_left = animation.frames_per_texture;
      direction = true;
      index = 0;
      if ( type == Animation.Type.Reverse ) {
        index = animation.textures.length - 1;
        direction = false;
      }
    }
  }
}
