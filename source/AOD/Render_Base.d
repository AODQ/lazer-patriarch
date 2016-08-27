module AODCore.render_base;

import AODCore.vector;

/**
  The base of rendering, I suppose if you wanted to create your own entity,
  text, etc for some reason you could use this.
*/
class Render_Base {
public:
  this(ubyte _layer = 5, Render_Base_Type _render_type = Render_Base_Type.nil) {
    layer = _layer;
    render_base_type = _render_type;
    static_position = 0;
    visible = 1;
    position = Vector(0, 0);
  }
  /** Type of render_base (only really useful for telling if it is native to
      the AOD engine) */
  enum Render_Base_Type {
    /** Not a type recognized by AOD */
    nil,
    /** */
    Entity,
    /** */
    Text
  };
  /** Sets position based on any two types that are casteable to float */
  void Set_Position(T)(T x, T y) {
    position.x = cast(float)x;
    position.y = cast(float)y;
  }
  /** Adds positionb ased on any two types that are casteable to float */
  void Add_Position(T)(T x, T y) {
    position.x = cast(float)x;
    position.y = cast(float)y;
  }
  /** Sets position based off vector */
  void Set_Position(Vector vec) {
    position = vec;
  }
  /** Adds position based off vector */
  void Add_Position(Vector vec) {
    position += vec;
  }
  /** Returns current position
  Params:
    apply_static = If this or static_position is false, will modify
            returned position based off the camera
  */
  Vector R_Position(bool apply_static = false) {
    static import AODCore.camera;
    if ( apply_static && !static_position ) {
      return Vector(position.x - AODCore.camera.R_Position.x,
                    position.y - AODCore.camera.R_Position.y);
    }
    return position;
  }
  /** Is the render_base visible? (is it rendered) */
  bool R_Visible()                      { return visible;                }
  /** Sets visibility of render_base */
  void Set_Visible(bool _visible)       { visible = _visible;            }
  /** Is the position static? (does it change relative to the camera) */
  bool R_Static_Pos()                   { return static_position;        }
  /** Sets if the position is static */
  void Set_Static_Pos(bool _sp)         { static_position = _sp;         }
  /** returns unique ID of this rendereable */
  uint R_ID()                           { return id; }
  /** Returns layer */
  ubyte R_Layer()                       { return layer; }
  /** Returns type of render_base */
  Render_Base_Type R_Render_Base_Type() { return render_base_type; }
  /** Called whenever AOD adds this to the realm (no reason to have a
      Removed_From_Realm since doing so calls the destructor) */
  void Added_To_Realm() { }
  /** Does rendering to the screen */
  abstract void Render();
  /** Called once every frame. Meant to be overriden. */
  abstract void Update();
  /** Called immediately after update, useful for if you want to have a base
      type that is gaurunteed to perform an action (look at Entity for example)
  */
  abstract void Post_Update();
  void Set_ID(uint _id) { id = _id; }
protected:
  /** The render type so Realm knows how to render this object (for custom
      render types I plan on having some function call in the future) */
  Render_Base_Type render_base_type;
  /** Whether the rendereable should be rendered to the screen */
  bool visible;
  /** Position on screen */
  Vector position;
  /** Whether position should be relative to the camera */
  bool static_position;
  /** unique ID to this rendereable */
  uint id;
private:
  /** The layer (z-index) of which the object is located. Used only to determine
      which objects get rendered first */
  ubyte layer;
}
