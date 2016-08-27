/**
  The camera has two important factors: position and size.<br>The position is at
  which point the screen will render (the origin is at the center of the
  screen).<br>The size is the diameter of the rendered area.
Example:
---
  // To render a 640x480 area at origin
  AOD.Camera.Set_Position(0,     0);
  AOD.Camera.Set_Size    (640, 480);
---
*/

module AODCore.camera;
import AODCore.vector;

private Vector position;
private Vector size;

/**
  Sets the position of the camera
  Params:
    pos = position of the camera relative to origin (0, 0)
*/
void Set_Position(Vector pos) {
  position = pos;
}

/**
  Sets the position of the camera
  Params:
    x = position of the camera on the x-axis relative to origin
    x = position of the camera on the y-axis relative to origin
*/
void Set_Position(float x, float y) {
  position = Vector(x, y);
}

/**
  Sets the size of the camera ( the screen renders )
  Params:
    siz = dimension of the camera in pixels
*/
void Set_Size(Vector siz) {
  if ( siz.x <= 0 || siz.y <= 0 ) return;
  size = siz;
}

/**
  Sets the size of the camera
  Params:
    x = dimension of the camera on the x-axis in pixels
    y = dimension of the camera on the y-axis in pixels
*/
void Set_Size(float x, float y) {
  if ( x <= 0 || y <= 0 ) return;
  size = Vector(x, y);
}

/** Returns the size of the camera */
Vector R_Size()     { return size;     }
/** Returns the position of the camera */
Vector R_Position() { return position; }
/** Returns the position of the screen if the origin were to be at
    the top-left of the screen */
Vector R_Origin_Offset() { return position - (size/2.0); }
