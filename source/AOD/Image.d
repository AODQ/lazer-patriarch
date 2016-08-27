/**
  Contains basic image handling that the entirety of AOD uses. From here you
  can either load an image or pass a loaded image, referred to as either
  a SheetContainer or SheetRect, to various functions. Another way to look at
  these two image containers is as a spritesheet and individual sprite.
*/
module AODCore.image;

import derelict.opengl3.gl3;
import derelict.sdl2.sdl;
import derelict.devil.il;
import derelict.devil.ilu;
//import derelict.devil.ilut;
import AODCore.console;
import AODCore.vector;

/**
  Contains basic information of an image.
*/
struct SheetContainer {
public:
  /** */
  GLuint texture;
  /** */
  int width,
  /** */
      height;
  /** */
  this(GLuint t, int w, int h) {
    texture = t;
    width = w;
    height = h;
  }
  /** */
  this(string filename) {
    auto z = Load_Image(filename);
    texture = z.texture;
    width = z.width;
    height = z.height;
  }
  /** Casts the sheetcontainer to a sheetrect (of the entire image) */
  T opCast(T)() if (is(T == SheetRect)) {
    import AOD : Vector;
    return SheetRect(this, Vector(0.0f, 0.0f), Vector(cast(float)width,
                                                      cast(float)height));
  }
}

/**
  A sheetcontainer that contains the coordinates of a subsection of the image.
  Useful for spritesheets, image cropping, etc.
*/
struct SheetRect {
public:
  SheetContainer sc;
  alias sc this;
  /** */
  Vector ul,
  /** */
         lr;
  /**
    Creates sheet rect

    Params:
      sc = SheetContainer to use as image
      _ul = relative offset for the upper left coordinate from origin {0, 0}
      _lr = relative offset of the lower right coordinate from origin {0, 0}
  */
  this(SheetContainer sc, Vector _ul, Vector _lr) {
    ul = _ul;
    lr = _lr;
    import std.math;
    width   = cast(int)abs(ul.x - lr.x);
    height  = cast(int)abs(ul.y - lr.y);
    texture = sc.texture;
    ul.x /= sc.width; lr.y /= sc.height;
    lr.x /= sc.width; ul.y /= sc.height;
    import std.stdio;
    float ty = lr.y;
    lr.y = 1 - ul.y;
    ul.y = 1 - ty;
  }
  this(SheetContainer sc, int ulx, int uly, int lrx, int lry) {
    this(sc, Vector(ulx, uly), Vector(lrx, lry));
  }
}


import std.string;
SheetContainer Load_Image(const char* fil) {
  ILuint IL_ID;
  GLuint GL_ID;
  int width, height;

  ilGenImages(1, &IL_ID);
  ilBindImage(IL_ID);
  if ( ilLoadImage( fil ) == IL_TRUE ) {
    ILinfo ImageInfo;
    iluGetImageInfo(&ImageInfo);
    if ( ImageInfo.Origin == IL_ORIGIN_UPPER_LEFT )
      iluFlipImage();

    if ( !ilConvertImage(IL_RGBA, IL_UNSIGNED_BYTE) ) {
      import std.conv : to;
      auto t = iluErrorString(ilGetError());
      Debug_Output(to!string(t));
      return SheetContainer();
    }
    glBindTexture(GL_TEXTURE_2D, 0);
    glGenTextures(1, &GL_ID);
    glBindTexture(GL_TEXTURE_2D, GL_ID);
    if ( !glIsTexture(GL_ID) ) {
      Output("Error generating GL texture");
      return SheetContainer();
    }
    // set texture clamping method
    /* glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP); */
    /* glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP); */

    // set texture interpolation method
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);

    width  = ilGetInteger(IL_IMAGE_WIDTH);
    height = ilGetInteger(IL_IMAGE_HEIGHT);

    // texture specs
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0,
               ilGetInteger(IL_IMAGE_FORMAT), GL_UNSIGNED_BYTE, ilGetData());
  } else {
    auto t = ilGetError();
    import std.conv;
    Debug_Output("Error loading " ~ to!string(fil) ~ ": " ~
      to!string(iluErrorString(t)) ~ "(" ~ to!string(ilGetError()) ~ ")");
    return SheetContainer();
  }
  ilDeleteImages(1, &IL_ID);
  return SheetContainer(GL_ID, width, height);
}
import std.string;
SheetContainer Load_Image(string fil) {
  return Load_Image(fil.ptr);
}
