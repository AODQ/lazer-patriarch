/**
  Just general utility that is useful in AOD. Was much more useful in C++, now
  in D most of these are not necessary
*/
module AODCore.utility;
import std.string;

/** */
const(float) E         =  2.718282f,
/** */
             Log10E    =  0.4342945f,
/** */
             Log2E     =  1.442695f,
/** */
             Pi        =  3.141593f,
/** */
             Tau       =  6.283185f,
/** use float.max instead */
             Max_float =  3.402823E+38,
/** use float.min instead */
             Min_float = -3.402823E+38,
/** */
             Epsilon   =  0.000001f;

import std.random;
private Mt19937 gen;

void Seed_Random() {
  import std.algorithm.iteration : map;
  import std.range : repeat;
  gen.seed(map!((a) => unpredictableSeed)(repeat(0)));
}

/** Returns: A random float bot .. top*/
float R_Rand(float bot, float top) {
  return uniform(bot, top, gen);
}

/** */
enum Direction {
  NW,  N, NE,
   W,      E,
  SW,  S, SE
};

/** Returns: Max value between the two parameters */
T R_Max(T)(T x, T y) { return x > y ? x : y; }
/** Returns: Min value between the two parameters */
T R_Min(T)(T x, T y) { return x < y ? x : y; }

/** Returns array with indexed element removed */
T Remove(T)(T array, int index) in {
  assert(index >= 0 && index < array.length);
} body {
  if ( array.length-1 == index ) return array[0 .. index];
  else {
    return array[0 .. index] ~
           array[index .. $];
  }
}

import AODCore.vector;

/** Converts from degrees to radians */
float To_Rad(float x) {
  return x * (Pi/180.0);
}

/** Converts from radians to degrees*/
float To_Deg(float x) {
  return x * (180.0/Pi);
}

/**
  Describes a variable assignment from an INI file
*/
struct INI_Item {
  /** The left-hand side of the assignment */
  string key,
  /** The right-hand side of the assignment */
         value;
  /** */
  this(string key_, string value_) {
    key = key_; value = value_;
  }
}

/** Hashmap representing categories. Each category contains an array of INI_Item
Example:
---
  if ( data["audio"].key == "volume" )
    volume = to!int(data["audio"].value);
---
*/
alias INI_Data = INI_Item[][string];

import std.file;
import std.stdio;
/**
  Loads an entire INI file
Params:
  filename = file to load
Returns:
  A hashmap representing categories, each of which is an array of INI_Item.
*/
INI_Data Load_INI(string filename) in {
  assert(std.file.exists(filename));
}  body {
  INI_Data data;
  string current_section = "";
  File fil = File(filename, "rb");
  while ( !fil.eof() ) {
    string current_line = fil.readln().strip();
    if ( current_line    == ""  ) continue; // empty line
    if ( current_line[0] == ';' ) continue; // comment
    if ( current_line[0] == '[' && current_line[$-1] == ']' ) { // section
      current_section = current_line[1 .. $-1].strip();
      /// ----- debug ----
      import std.stdio : writeln;
      import std.conv : to;
      writeln("CURRENT SECTION: " ~ to!string(current_section));
      /// ----- debug ----
      continue;
    }
    // regular item assignment
    auto split_data = current_line.split("=");
    if ( split_data.length == 2 ) {
      data [ current_section ] ~= INI_Item(split_data[0].strip(),
                                           split_data[1].strip());
    }
  }
  return data;
}
