/**
  <br><br>
    Allows you to play sounds as well as manipulate them (position, volume, etc)
    At the moment only works with OGG filetypes.
    <br>
Example:
<br>
---
  uint s = AOD.Load_Sound("test-song.ogg");
  AOD.Play_Sound(s);
---
*/
module AODCore.sound;
import derelict.openal.al;
import derelict.vorbis.vorbis;
import derelict.vorbis.file;

import AODCore.console : Output, Debug_Output;
import std.string;
import std.conv : to;

/*
   Sounds contains an array that allows the programmer to index
   their sounds (so instead of typing in a filename they can type a variable).


   The Sound generates the handle, and each time a sample is sent to SoundEng
   to play, SoundEng generates a new Sample and returns the engine index
*/

class SoundEng {
static:
  class Sample {
    ALint state;
    bool loop;
    ALuint[Buffer_amt] buffer_id;
    ALuint source_id;
    OggVorbis_File ogg_file;
    ALenum format;
    ALint freq;
    string file_name;
    uint index;
  };


  ALCdevice*  al_device;
  ALCcontext* al_context;
  immutable(int) Buffer_size = 4096;
  immutable(int) Buffer_amt = 3;

  ALfloat[] listener_position    = [0.0,0.0,4.0              ] ;
  ALfloat[] listener_velocity    = [0.0,0.0,0.0              ] ;
  ALfloat[] listener_orientation = [0.0,0.0,1.0, 0.0,1.0,0.0 ] ;

  void Set_Up() {
    import derelict.util.exception;
    import std.stdio;
    al_device = alcOpenDevice(null);
    Check_AL_Errors() ;
    if ( al_device == null ) {
      throw new Exception("Failed to open ALC device");
    }
    al_context = alcCreateContext(al_device, null);
    Check_AL_Errors() ;
    alcMakeContextCurrent(al_context);
    Check_AL_Errors() ;

    alListenerfv(AL_POSITION, listener_position.ptr);
    Check_AL_Errors() ;
    alListenerfv(AL_VELOCITY, listener_velocity.ptr);
    Check_AL_Errors() ;
    alListenerfv(AL_ORIENTATION, listener_orientation.ptr);
    Check_AL_Errors() ;

    import std.concurrency;
    thread_id = spawn(&Main_Sound_Loop);

    writeln("Finished with setting up AL");
  }

  import std.concurrency : Tid;

  private Tid thread_id;

  Sample LoadOGG(immutable(string) file_name) {
    Sample s = new Sample();

    alGenBuffers(Buffer_amt, s.buffer_id.ptr);
    Check_AL_Errors();
    alGenSources(1, &s.source_id);
    Check_AL_Errors();
    s.file_name = file_name;

    import std.stdio;
    import core.stdc.stdio : fopen;
    FILE* f = fopen(file_name.ptr, "rb".ptr);
    if ( f == null ) {
      writeln("Error opening file for playing: " ~ file_name);
      return null;
    }
    vorbis_info* p_info;
    OggVorbis_File ogg_file;
    auto x = ov_open(f, &ogg_file, null, 0);
    if ( x != 0 ) {
      import std.conv : to;
      switch ( x ) {
        default:                                                         break ;
        case OV_EREAD:      writeln ("eread ");                          break ;
        case OV_ENOTVORBIS: writeln ("not vorbis");                      break ;
        case OV_EVERSION:   writeln ("mismatch version");                break ;
        case OV_EBADHEADER: writeln ("invalid vorbis bitstream header"); break ;
        case OV_EFAULT:     writeln ("Internal logic fault");            break ;
      }
      writeln("error: "~ to!string(x));
      throw new Exception("OGG file not found: " ~ file_name);
    }
    Check_AL_Errors() ;
    p_info = ov_info(&ogg_file, -1);
    if ( p_info is null ) {
      throw new Exception("Could not generate info for OGG file");
    }
    Check_AL_Errors() ;

    s.format = p_info.channels == 1 ? AL_FORMAT_MONO16 : AL_FORMAT_STEREO16;
    s.freq = p_info.rate;

    s.ogg_file = ogg_file;
    Check_AL_Errors() ;
    return s;
  }

  // returns true if error
  bool Check_AL_Errors() {
    import std.stdio;
    int error = alGetError();
    switch ( error ) {
      default: break;
      case AL_NO_ERROR: return false;
    }
    write("OpenAL error: ");
    switch ( error ) {
      default: assert(0);
      case AL_INVALID_NAME:
        writeln("AL_INVALID_NAME");
      break;
      case AL_INVALID_ENUM:
        writeln("AL_INVALID_ENUM");
      break;
      case AL_INVALID_VALUE:
        writeln("AL_INVALID_VALUE");
      break;
      case AL_INVALID_OPERATION:
        writeln("AL_INVALID_OPERATION");
      break;
      case AL_OUT_OF_MEMORY:
        writeln("AL_OUT_OF_MEMORY");
      break;
    }
    return true;
  }

  // returns TRUE if file has finished loading or errored
  bool Stream_Buffer( Sample s, ALuint buffer_id ) {
    // load buffer
    byte[Buffer_size] buffer;
    int result, section = 0, size = 0;
    while ( size < Buffer_size ) {
      result = cast(int)ov_read(&s.ogg_file, buffer.ptr + (size),
                                (Buffer_size) - ( size ),
                       0, 2, 1, &section);

      if ( result > 0 ) size += result;
      else if ( result < 0 ) {
        import std.stdio : writeln;
        writeln("Error while attempting to buffer sample" ~ s.file_name);
        return true;
      } else {
        break;
      }
    }
if ( size == 0 ) {
      return true;
    }

    // set to OpenAL
    alBufferData ( buffer_id, s.format, buffer.ptr, size, s.freq );
    SoundEng.Check_AL_Errors();
    return false;
  }

}

private void Main_Sound_Loop() {
  SoundEng.Sample[] samples;

  void DestroySample(int index, bool deprecate_samples = true) {
    if ( index < 0 || index >= samples.length ) return;
    auto sound = samples[index];
    if ( sound is null ) return;
    alSourceStop(sound.source_id);
    alDeleteSources(1, &sound.source_id);
    alDeleteBuffers(SoundEng.Buffer_amt, sound.buffer_id.ptr);
    ov_clear(&sound.ogg_file);
    destroy(samples[index]);
    samples[index] = null;
    if ( deprecate_samples ) {
      while ( samples.length > 0 && samples[$-1] is null ) {
        -- samples.length;
      }
    }
  }

  while ( true ) {
    // check for messages
    import std.concurrency;
    import std.stdio : writeln;
    import std.conv : to;
    import core.time;
    receiveTimeout(dur!"msecs"(1), /* no hanging */
      (ThreadMsg msg, immutable(string)[] params) {
        switch ( msg ) {
          default: break;
          case ThreadMsg.StopSample:
            /* writeln("REMOVING: " ~ params[0]); */
            int i = to!int(params[0]);
            if ( i >= 0 && i < samples.length && samples[i] !is null )
              DestroySample(i);
          break;
          case ThreadMsg.StopAllSamples:
            for ( int i = 0; i != samples.length; ++ i )
              if ( samples[i] !is null )
                DestroySample(i, false);
            samples = [];
          break;
          case ThreadMsg.End:
            alcCloseDevice(SoundEng.al_device);
            // -- DEBUG START
            import std.stdio : writeln;
            import std.conv : to;
            writeln("ALC device closed");
            // -- DEBUG END
            return;
          case ThreadMsg.PlaySample:
            // find empty slot
            int slot = 0;
            for ( ; slot < samples.length; ++ slot ) {
              if ( samples[slot] is null ) break;
            }
            writeln("slot: " ~ to!string(slot));
            if ( slot == samples.length ) ++ samples.length;
            send(ownerTid, ThreadMsg.QueueID, slot);
            writeln("ID: " ~ to!string(slot));
            auto s  = SoundEng.LoadOGG(params[0]);
            s.index = slot;
            samples[slot] = s;
            // -- initialize song
            foreach ( i; 0 .. SoundEng.Buffer_amt )
              SoundEng.Stream_Buffer(s, s.buffer_id[i]);
            alSourceQueueBuffers(s.source_id, s.buffer_id.length,
                                              s.buffer_id.ptr);
            SoundEng.Check_AL_Errors();
            alSourcei(s.source_id, AL_LOOPING, AL_FALSE);
            // -- set position
            immutable(float)[] position_params = [ to!float (params[1]),
                                                   to!float (params[2]),
                                                   to!float (params[3]) ];
            alSourcefv(s.source_id, AL_POSITION, position_params.ptr);
            SoundEng.Check_AL_Errors();
            // -- play song
            alSourcePlay(s.source_id);
            SoundEng.Check_AL_Errors();
          break;
        }
      },
      (ThreadMsg msg, int index, immutable( float )[] params) {
        switch ( msg ) {
          default: break;
          case ThreadMsg.ChangePosition:
            if ( index >= samples.length ) break;
            auto s = samples[index];
            alSourcefv(s.source_id, AL_POSITION, params.ptr);
            if ( SoundEng.Check_AL_Errors() ) {
              writeln("Couldn't update sound's position");
            }
          break;
        }
      }
    );

    for ( int i = 0; i < samples.length; ++ i ) {
      auto sound = samples[i];
      if ( samples[i] is null ) continue;
      int state, processed;
      bool ended = false;

      alGetSourcei(sound.source_id, AL_SOURCE_STATE, &state);
      alGetSourcei(sound.source_id, AL_BUFFERS_PROCESSED, &processed);

      while ( processed -- > 0) {
        ALuint buffer;
        ALenum error;

        alSourceUnqueueBuffers(sound.source_id, 1, &buffer);
        SoundEng.Check_AL_Errors();
        ended = SoundEng.Stream_Buffer(sound, buffer);
        if ( ended ) {
          DestroySample(i);
          continue;
        }
        alSourceQueueBuffers(sound.source_id, 1, &buffer);
        SoundEng.Check_AL_Errors();
        if ( state != AL_PLAYING && state != AL_PAUSED )
          alSourcePlay(sound.source_id);
      }
    }
    import core.thread;
    Thread.sleep(dur!("msecs")(10));
  }
}

private enum ThreadMsg {
  PlaySample, PauseSample, StopSample,
  ChangePosition,
  StopAllSamples, End,

  QueueID
}

/** */
class Sound {
static: private:
  immutable(string)[] sounds;
  uint cur_slot;
static: public:
  /**
    Registers sound to be playable
    Return:
      A handle to the sound
  */
  uint Load_Sound(string file_name) {
    import File = std.file;
    if ( !File.exists(file_name) ) {
      import std.stdio : writeln;
      writeln("Error opening file " ~ file_name);
      return 0;
    }
    sounds ~= file_name;
    return cast(uint)(sounds.length)-1;
  }

  /**
    Plays sound from given handle
    Return:
      Index to the given handle
  */
  uint Play_Sound(uint handle, float x = 0.0f, float y = 0.0f, float z = 0.0f)
  in {
    assert(handle >= 0 && handle < sounds.length);
  } body {
    import std.concurrency;
    import std.stdio : writeln;
    import std.conv : to;
    immutable(string) s  = sounds[handle];
    immutable(string) sx = to!string(x);
    immutable(string) sy = to!string(y);
    immutable(string) sz = to!string(z);
    /* writeln("playing sound"); */
    send(SoundEng.thread_id, ThreadMsg.PlaySample, [s, sx, sy, sz]);
    Update(5000);
    /* writeln("Using index: " ~ to!string(handle)); */
    return cur_slot;
  }

  /**
    Stops sound from given index
  */
  void Stop_Sound(uint index) {
    import std.concurrency;
    import std.conv;
    import std.stdio;
    /* writeln("STOPPING: " ~ to!string(index)); */
    immutable(string) s = to!string(index);
    send(SoundEng.thread_id, ThreadMsg.StopSample, [s]);
  }

  /**
    Changes the position of the sound from given handle
  */
  void Change_Sound_Position(immutable ( uint  ) handle,
                             immutable ( float ) x,
                             immutable ( float ) y,
                             immutable ( float ) z       ) {
    import std.concurrency;
    immutable(float) h = cast(immutable( float ))(handle);
    send(SoundEng.thread_id, ThreadMsg.ChangePosition, [h, x, y, z]);
  }

  /** Stops all sounds
  */
  void Clean_Up() {
    import std.concurrency;
    immutable(string) s = "";
    send(SoundEng.thread_id, ThreadMsg.StopAllSamples, [s]);
  }

  /** clens up and closes ALC Device
  */
  void End() {
    Clean_Up();
    import std.concurrency;
    send(SoundEng.thread_id, ThreadMsg.End);
  }

  void Update(int nanosecond_duration = 0) {
    import std.concurrency;
    import core.time;
    receiveTimeout(dur!("nsecs")(nanosecond_duration),
      (ThreadMsg msg, uint index) {
        switch ( msg ) {
          default: break;
          case ThreadMsg.QueueID:
            import std.conv;
            cur_slot = index;
            import std.stdio;
            writeln("Received slot index: " ~ to!string ( cur_slot ));
          break;
        }
      }
    );
  }
}
