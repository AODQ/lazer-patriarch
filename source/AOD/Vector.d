module AODCore.vector;

/**
  A two-dimensional vector capable of interacting with Matrix and
  performing simple linear algebra functions

  Only supports floats
*/
struct Vector {
public:
  float x, y;
  this(float _x, float _y ) { x = _x; y = _y; }
  this(int   _x, int   _y ) { x = cast(float)_x; y = cast(float)_y; }
  this(Vector v) { x = v.x; y = v.y; }

  Vector opAssign(Vector rhs) {
    x = rhs.x;
    y = rhs.y;
    return this;
  }
  Vector opBinary(string op)(Vector rhs)   if ( op == "+" ) {
    return Vector(x + rhs.x, y + rhs.y);
  }
  Vector opBinary(string op)(float rhs)    if ( op == "+" ) {
    return Vector(x + rhs, y + rhs);
  }
  Vector opOpAssign(string op)(Vector rhs) if ( op == "+" ) {
    x += rhs.x;
    y += rhs.y;
    return this;
  }
  Vector opOpAssign(string op)(float rhs)  if ( op == "+" ) {
    x += rhs;
    y += rhs;
    return this;
  }
  Vector opBinary(string op)(Vector rhs)   if ( op == "-" ) {
    return Vector(x - rhs.x, y - rhs.y);
  }
  Vector opBinary(string op)(float rhs)    if ( op == "-" ) {
    return Vector(x - rhs, y - rhs);
  }
  Vector opOpAssign(string op)(Vector rhs) if ( op == "-" ) {
    x -= rhs.x;
    y -= rhs.y;
    return this;
  }
  Vector opOpAssign(string op)(float rhs)  if ( op == "-" ) {
    x -= rhs;
    y -= rhs;
    return this;
  }
  Vector opBinary(string op)(Vector rhs)   if ( op == "*" ) {
    return Vector(x * rhs.x, y * rhs.y);
  }
  Vector opBinary(string op)(float rhs)    if ( op == "*" ) {
    return Vector(x * rhs, y * rhs);
  }
  Vector opOpAssign(string op)(Vector rhs) if ( op == "*" ) {
    x *= rhs.x;
    y *= rhs.y;
    return this;
  }
  Vector opOpAssign(string op)(float rhs)  if ( op == "*" ) {
    x *= rhs;
    y *= rhs;
    return this;
  }
  Vector opBinary(string op)(Vector rhs)   if ( op == "/" ) {
    return Vector(x / rhs.x, y / rhs.y);
  }
  Vector opBinary(string op)(float rhs)    if ( op == "/" ) {
    return Vector(x / rhs, y / rhs);
  }
  Vector opOpAssign(string op)(Vector rhs) if ( op == "/" ) {
    x /= rhs.x;
    y /= rhs.y;
    return this;
  }
  Vector opOpAssign(string op)(float rhs)  if ( op == "/" ) {
    x /= rhs;
    y /= rhs;
    return this;
  }
  /**
    Casts vector to string
    Return:
      A string with format: &lt;x, y&gt;
  */
  string opCast(T)() if (is(T == string)) {
    import std.conv : to;
    return "< " ~ to!string(x) ~ ", " ~ to!string(y) ~ " >";
  }

  //                      utility methods

  /**
    Divides this vector by its Magnitude
  */
  void Normalize() {
    float mag = Magnitude();
    if ( mag > 0 ) {
      x /= mag;
      y /= mag;
    }
  }

  import std.math;

  /**
    Return:
      Length between two vectors, using this vector as origin
  */
  float Distance(Vector _vector) {
    return sqrt(pow(x - _vector.x, 2) + pow(y - _vector.y, 2));
  }

  /**
    Return:
      Relative angle from this vector and origin in radians
  */
  float Angle() {
    return atan2(y, x);
  }

  /**
    Return:
      Relative angle from this vector and _vector in radians
  */
  float Angle(Vector _vector) {
    return atan2(_vector.y - y, _vector.x - x);
  }

  /**
    Return:
      Distance of this vector from origin
  */
  float Magnitude() {
    return sqrt((x*x) + (y*y));
  }

  /**
    Return:
      Dot product of this and _vector (both components multiplied and summed)
  */
  float Dot_Product(Vector _vector) {
    return x * _vector.x + y * _vector.y;
  }


  /**
    Projects _vector onto this vector
  */
  void Project(Vector _vector) {
    float dot_prod = Dot_Product(_vector);
    x = (dot_prod / (pow(_vector.x, 2 ) +
                     pow(_vector.y, 2 )) ) * _vector.x;
    y = (dot_prod / (pow(_vector.x, 2 ) +
                     pow(_vector.y, 2 )) ) * _vector.y;
  }

  /**
    Sets vector to be the right-hand normal of _vector
  */
  void Right_Normal(Vector _vector) {
    x =  (_vector.x - x);
    y = -(_vector.y - y);
  }
  /**
    Sets vector to be the right-hand normal of _vector
  */
  void Left_Normal(Vector _vector) {
    x = -(_vector.x - x);
    y =  (_vector.y - y);
  }

  /**
    Return:
      Result of reflecting I onto N
  */
  static Vector Reflect(Vector I, Vector N) {
    return I - (N*2.0f * I) * N;
  }

  import AODCore.matrix;

  /**
    Multiplies _matrix to _vector
    Return:
      Transformed matrix
  */
  static Vector Transform(Matrix _matrix, Vector _vector) {
    Vector v;
    v.x = _vector.x * _matrix.a + _vector.y * _matrix.c + _matrix.tx;
    v.y = _vector.x * _matrix.b + _vector.y * _matrix.d + _matrix.ty;
    return v;
  }

}

/** has an f,  g, and parent component */
class Node {
public:
  float f, g;
  float x, y;
  Node parent;

  this(float _x, float _y ) { x = _x; y = _y; }
  this(int   _x, int   _y ) { x = cast(float)_x; y = cast(float)_y; }
  this(Vector v) { x = v.x; y = v.y; }
  this(Node v) { x = v.x; y = v.y; }

  Node opBinary(string op)(Node rhs)   if ( op == "+" ) {
    return Node(x + rhs.x, y + rhs.y);
  }
  Node opBinary(string op)(float rhs)    if ( op == "+" ) {
    return Node(x + rhs, y + rhs);
  }
  Node opOpAssign(string op)(Node rhs) if ( op == "+" ) {
    x += rhs.x;
    y += rhs.y;
    return this;
  }
  Node opOpAssign(string op)(float rhs)  if ( op == "+" ) {
    x += rhs;
    y += rhs;
    return this;
  }
  Node opBinary(string op)(Node rhs)   if ( op == "-" ) {
    return Node(x - rhs.x, y - rhs.y);
  }
  Node opBinary(string op)(float rhs)    if ( op == "-" ) {
    return Node(x - rhs, y - rhs);
  }
  Node opOpAssign(string op)(Node rhs) if ( op == "-" ) {
    x -= rhs.x;
    y -= rhs.y;
    return this;
  }
  Node opOpAssign(string op)(float rhs)  if ( op == "-" ) {
    x -= rhs;
    y -= rhs;
    return this;
  }
  Node opBinary(string op)(Node rhs)   if ( op == "*" ) {
    return Node(x * rhs.x, y * rhs.y);
  }
  /**
    Casts vector to string
    Return:
      A string with format: &lt;x, y&gt;
  */
  string opCast(T)() if (is(T == string)) {
    import std.conv : to;
    return "< " ~ to!string(x) ~ ", " ~ to!string(y) ~ " >";
  }

  override int opCmp(Object o) {
    return super.opCmp(o);
  }

  int opCmp(Node other) {
    if ( f < other.f ) return -1;
    if ( f > other.f ) return  1;
    return 0;
  }

  //                      utility methods

  /**
    Divides this vector by its Magnitude
  */
  void Normalize() {
    float mag = Magnitude();
    if ( mag > 0 ) {
      x /= mag;
      y /= mag;
    }
  }

  import std.math;

  /**
    Return:
      Length between two vectors, using this vector as origin
  */
  float Distance(Node _vector) {
    return sqrt((x*x - _vector.x*_vector.x) + (y*y - _vector.y*_vector.y));
  }

  /**
    Return:
      Relative angle from this vector and origin in radians
  */
  float Angle() {
    return atan2(y, x);
  }

  /**
    Return:
      Relative angle from this vector and _vector in radians
  */
  float Angle(Node _vector) {
    return atan2(_vector.y - y, _vector.x - x);
  }

  /**
    Return:
      Distance of this vector from origin
  */
  float Magnitude() {
    return sqrt((x*x) + (y*y));
  }

  /**
    Return:
      Dot product of this and _vector (both components multiplied and summed)
  */
  float Dot_Product(Node _vector) {
    return x * _vector.x + y * _vector.y;
  }


  /**
    Projects _vector onto this vector
  */
  void Project(Node _vector) {
    float dot_prod = Dot_Product(_vector);
    x = (dot_prod / (pow(_vector.x, 2 ) +
                     pow(_vector.y, 2 )) ) * _vector.x;
    y = (dot_prod / (pow(_vector.x, 2 ) +
                     pow(_vector.y, 2 )) ) * _vector.y;
  }

  /**
    Sets vector to be the right-hand normal of _vector
  */
  void Right_Normal(Node _vector) {
    x =  (_vector.x - x);
    y = -(_vector.y - y);
  }
  /**
    Sets vector to be the right-hand normal of _vector
  */
  void Left_Normal(Node _vector) {
    x = -(_vector.x - x);
    y =  (_vector.y - y);
  }

  /**
    Return:
      Result of reflecting I onto N
  */
}
