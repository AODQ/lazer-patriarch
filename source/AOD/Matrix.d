module AODCore.matrix;
import AODCore.vector;


/**
  A simple 2x2 matrix capable of 2D translation, rotation and scaling
*/
struct Matrix {
public:
  float a, b, c, d, tx, ty;
  float rot, prev_rot;
  Vector scale;

  /**
    Constructs a new matrix based off the parameters (if you do not know
       what params to supply use `Matrix.New()` instead)
    Params:
      _a  = (0, 0)
      _b  = (0, 1)
      _c  = (1, 0)
      _d  = (1, 1)
      _tx = translation x
      _ty = translation y
  */
  this(float _a, float _b, float _c,
       float _d, float _tx, float _ty) {
    a = _a; b = _b; c = _c; d = _d; tx = _tx; ty = _ty;
    rot = prev_rot = 0;
    scale = Vector( 1,1 ); 
  }

  /**
    Constructs a new matrix with default parameters. That is, the matrix starts
    off as an identity matrix. This is probably what you want to use.
    Returns:
      An identity matrix at translation (0, 0)
  */
  static Matrix New() {
    return Matrix(1, 0, 0, 1, 0, 0);
  }

  /**
    Sets the matrix to be an identity, that is, the main diagonal is 1 and every
    other element is set to 0 (including the position)
  */
  void Identity() {
    a = 1;  b = 0;    c = 0;
    d = 1;  tx = 0;  ty = 0;
  }

  /**
    Translates the matrix relative to the current position
    Params:
      vec = Vector to translate relative to the current position
  */
  void Translate(inout(Vector) vec) {
    tx += vec.x;
    ty += vec.y;
  }

  /**
    Translates the matrix relative to the current position
    Params:
      x = Value to translate on the x-axis relative to the current position
      y = Value to translate on the y-axis relative to the current position
  */
  void Translate(float x, float y) {
    tx += x;
    ty += y;
  }

  /**
    Translates the matrix relative to the origin (0, 0)
    Params:
      vec = Vector to translate relative to origin
  */
  void Set_Translation(inout(Vector) vec) {
    tx = vec.x;
    ty = vec.y;
  }

  /**
    Translates the matrix relative to the origin (0, 0)
    Params:
      x = Value to translate on the x-axis relative to origin
      y = Value to translate on the y-axis relative to origin
  */
  void Set_Translation(float x, float y) {
    tx = x;
    ty = y;
  }

  /**
    Composes the matrix with a new translation, rotation and scale
    Params:
      pos = vector to set translation of matrix
      rot = Angle to rotate matrix (in radians)
      scale = vector to set scale of matrix; (1, 1) is default
  */
  void Compose(inout(Vector) pos, float rot,
                     Vector scale) {
    Identity();

    Scale( scale );
    Rotate( rot );
    Set_Translation( pos );
  }

  /**
    Rotates the matrix
    Params:
      rot = Angle to rotate matrix (in radians)
  */
  void Rotate(float rot) {
    import std.math;
    float x = cos(rot),
          y = sin(rot);

    float a1 = a * x - b * y;
    b = a * y + b * x;
    a = a1;

    float c1 = c * x - d * y;
    d = c * y + d * x;
    c = c1;

    float tx1 = tx * x - ty * y;
    ty = tx * y + ty * x;
    tx = tx1;
  }

  /**
    Scales the matrix
    Params:
      sc = vector to set scale of matrix; (1, 1) is default
  */
  void Scale(Vector sc) {
    a *= sc.x;
    b *= sc.y;

    c *= sc.x;
    d *= sc.y;

    tx *= sc.x;
    ty *= sc.y;
  }
}
