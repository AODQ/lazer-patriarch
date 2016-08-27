module AODCore.shader;
import std.string;
import derelict.opengl3.gl3;

/**
  Allows you to implement GLSL shaders into the rendering of AoD
*/
struct Shader {
  GLuint id;
public:
  /** postblist */
  this ( this ) {
    id = id;
  }
  /** Generates a GL Shader.*/
  this ( string vertex_file,
         string fragment_file  = "",
         string tess_ctrl_file = "",
         string tess_eval_file = "",
         string compute_file   = "" ) {
    bool is_frag = fragment_file   != "",
         is_tesc = tess_ctrl_file != "",
         is_tese = tess_eval_file != "",
         is_comp  = compute_file   != "";
    // --- create program/shaders
    id = glCreateProgram();
    GLuint vertex_ID    = glCreateShader ( GL_VERTEX_SHADER          ) ,
           fragment_ID  = glCreateShader ( GL_FRAGMENT_SHADER        ) ,
           tess_ctrl_ID = glCreateShader ( GL_TESS_CONTROL_SHADER    ) ,
           tess_eval_ID = glCreateShader ( GL_TESS_EVALUATION_SHADER ) ,
           compute_ID   = glCreateShader ( GL_COMPUTE_SHADER         ) ;
    // --- compile shader source & attach to program
    auto Create_Shader = (GLuint ID, GLuint progID, string fname, bool empty) {
      if ( !empty ) return;
      // compile shader
      static import std.file;
      char* fil = cast(char*)(std.file.read(fname).ptr);
      glShaderSource ( ID, 1, &fil, null );
      glCompileShader(ID);
      // -- check for error --
      GLint compile_status;
      glGetShaderiv(ID, GL_COMPILE_STATUS, &compile_status);
      if ( compile_status == GL_FALSE ) {
        import std.stdio : writeln;
        writeln(fname ~ " shader compilation failed");
        writeln("--------------------------------------");
        GLchar[256] error_message;
        glGetShaderInfoLog(ID, 256, null, error_message.ptr);
        writeln(error_message);
        writeln("--------------------------------------");
        return;
      }
      // attach
      glAttachShader(progID, ID);
    };
    Create_Shader( vertex_ID    , id , vertex_file    , true );
    Create_Shader( fragment_ID  , id , fragment_file  , is_frag );
    Create_Shader( tess_ctrl_ID , id , tess_ctrl_file , is_tesc );
    Create_Shader( tess_eval_ID , id , tess_eval_file , is_tese );
    Create_Shader( compute_ID   , id , compute_file   , is_comp );

    // --- link program
    glLinkProgram ( id );

    // --- cleanup
    glDeleteShader(vertex_ID    ) ;
    glDeleteShader(fragment_ID  ) ;
    glDeleteShader(tess_ctrl_ID ) ;
    glDeleteShader(tess_eval_ID ) ;
    glDeleteShader(compute_ID   ) ;
  }

  void Bind() {
    glUseProgram ( id );
  }
  static void Unbind() {
    glUseProgram ( 0 );
  }
  /** Returns the program/shader ID */
  GLuint R_Shader_ID() {
    return id;
  }
}
