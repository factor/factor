! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
IN: openal
USING: kernel alien system combinators alien.syntax namespaces
       alien.c-types sequences vocabs.loader shuffle combinators.lib ;

: load-alut-library ( -- )
    "alut" {
        { [ win32? ]  [ "alut.dll" ] }
        { [ macosx? ] [ "/System/Library/Frameworks/OpenAL.framework/OpenAL" ] }
        { [ unix?  ]  [ "libalut.so" ] }
    } cond "cdecl" add-library ; parsing

: load-openal-library ( -- )
    "openal" {
        { [ win32? ]  [ "OpenAL32.dll" ] }
        { [ macosx? ] [ "/System/Library/Frameworks/OpenAL.framework/OpenAL" ] }
        { [ unix?  ]  [ "libopenal.so" ] }
    } cond "cdecl" add-library ; parsing

load-alut-library
load-openal-library

LIBRARY: openal

TYPEDEF: char ALboolean 
TYPEDEF: char ALchar
TYPEDEF: char ALbyte
TYPEDEF: uchar ALubyte
TYPEDEF: short ALshort
TYPEDEF: ushort ALushort
TYPEDEF: int ALint
TYPEDEF: uint ALuint
TYPEDEF: int ALsizei
TYPEDEF: int ALenum
TYPEDEF: float ALfloat
TYPEDEF: double ALdouble

: AL_INVALID ( -- number ) -1 ; inline
: AL_NONE ( -- number ) 0 ; inline
: AL_FALSE ( -- number ) 0 ; inline
: AL_TRUE ( -- number ) 1 ; inline
: AL_SOURCE_RELATIVE ( -- number ) HEX: 202 ; inline
: AL_CONE_INNER_ANGLE ( -- nmber ) HEX: 1001 ; inline
: AL_CONE_OUTER_ANGLE ( -- number ) HEX: 1002 ; inline
: AL_PITCH ( -- number ) HEX: 1003 ; inline
: AL_POSITION ( -- number ) HEX: 1004 ; inline
: AL_DIRECTION ( -- number ) HEX: 1005 ; inline
: AL_VELOCITY ( -- number ) HEX: 1006 ; inline
: AL_LOOPING ( -- number ) HEX: 1007 ; inline
: AL_BUFFER ( -- number ) HEX: 1009 ; inline
: AL_GAIN ( -- number ) HEX: 100A ; inline
: AL_MIN_GAIN ( -- number ) HEX: 100D ; inline
: AL_MAX_GAIN ( -- number ) HEX: 100E ; inline
: AL_ORIENTATION ( -- number ) HEX: 100F ; inline
: AL_CHANNEL_MASK ( -- number ) HEX: 3000 ; inline
: AL_SOURCE_STATE ( -- number ) HEX: 1010 ; inline
: AL_INITIAL ( -- number ) HEX: 1011 ; inline
: AL_PLAYING ( -- number ) HEX: 1012 ; inline
: AL_PAUSED ( -- number ) HEX: 1013 ; inline
: AL_STOPPED ( -- number ) HEX: 1014 ; inline
: AL_BUFFERS_QUEUED ( -- number ) HEX: 1015 ; inline
: AL_BUFFERS_PROCESSED ( -- number ) HEX: 1016 ; inline
: AL_SEC_OFFSET ( -- number ) HEX: 1024 ; inline
: AL_SAMPLE_OFFSET ( -- number ) HEX: 1025 ; inline
: AL_BYTE_OFFSET ( -- number ) HEX: 1026 ; inline
: AL_SOURCE_TYPE ( -- number ) HEX: 1027 ; inline
: AL_STATIC ( -- number ) HEX: 1028 ; inline
: AL_STREAMING ( -- number ) HEX: 1029 ; inline
: AL_UNDETERMINED ( -- number ) HEX: 1030 ; inline
: AL_FORMAT_MONO8 ( -- number ) HEX: 1100 ; inline
: AL_FORMAT_MONO16 ( -- number ) HEX: 1101 ; inline
: AL_FORMAT_STEREO8 ( -- number ) HEX: 1102 ; inline
: AL_FORMAT_STEREO16 ( -- number ) HEX: 1103 ; inline
: AL_REFERENCE_DISTANCE ( -- number ) HEX: 1020 ; inline
: AL_ROLLOFF_FACTOR ( -- number ) HEX: 1021 ; inline
: AL_CONE_OUTER_GAIN ( -- number ) HEX: 1022 ; inline
: AL_MAX_DISTANCE ( -- number ) HEX: 1023 ; inline
: AL_FREQUENCY ( -- number ) HEX: 2001 ; inline
: AL_BITS ( -- number ) HEX: 2002 ; inline
: AL_CHANNELS ( -- number ) HEX: 2003 ; inline
: AL_SIZE ( -- number ) HEX: 2004 ; inline
: AL_UNUSED ( -- number ) HEX: 2010 ; inline
: AL_PENDING ( -- number ) HEX: 2011 ; inline
: AL_PROCESSED ( -- number ) HEX: 2012 ; inline
: AL_NO_ERROR ( -- number ) AL_FALSE ; inline
: AL_INVALID_NAME ( -- number ) HEX: A001 ; inline
: AL_ILLEGAL_ENUM ( -- number ) HEX: A002 ; inline
: AL_INVALID_ENUM ( -- number ) HEX: A002 ; inline
: AL_INVALID_VALUE ( -- number ) HEX: A003 ; inline
: AL_ILLEGAL_COMMAND ( -- number ) HEX: A004 ; inline
: AL_INVALID_OPERATION ( -- number ) HEX: A004 ; inline
: AL_OUT_OF_MEMORY ( -- number ) HEX: A005 ; inline
: AL_VENDOR ( -- number ) HEX: B001 ; inline
: AL_VERSION ( -- number ) HEX: B002 ; inline
: AL_RENDERER ( -- number ) HEX: B003 ; inline
: AL_EXTENSIONS ( -- number ) HEX: B004 ; inline
: AL_DOPPLER_FACTOR ( -- number ) HEX: C000 ; inline
: AL_DOPPLER_VELOCITY ( -- number ) HEX: C001 ; inline
: AL_SPEED_OF_SOUND ( -- number ) HEX: C003 ; inline
: AL_DISTANCE_MODEL ( -- number ) HEX: D000 ; inline
: AL_INVERSE_DISTANCE ( -- number ) HEX: D001 ; inline
: AL_INVERSE_DISTANCE_CLAMPED ( -- number ) HEX: D002 ; inline
: AL_LINEAR_DISTANCE ( -- number ) HEX: D003 ; inline
: AL_LINEAR_DISTANCE_CLAMPED ( -- number ) HEX: D004 ; inline
: AL_EXPONENT_DISTANCE ( -- number ) HEX: D005 ; inline
: AL_EXPONENT_DISTANCE_CLAMPED ( -- number ) HEX: D006 ; inline

FUNCTION: void alEnable ( ALenum capability ) ;
FUNCTION: void alDisable ( ALenum capability ) ; 
FUNCTION: ALboolean alIsEnabled ( ALenum capability ) ; 
FUNCTION: ALchar* alGetString ( ALenum param ) ;
FUNCTION: void alGetBooleanv ( ALenum param, ALboolean* data ) ;
FUNCTION: void alGetIntegerv ( ALenum param, ALint* data ) ;
FUNCTION: void alGetFloatv ( ALenum param, ALfloat* data ) ;
FUNCTION: void alGetDoublev ( ALenum param, ALdouble* data ) ;
FUNCTION: ALboolean alGetBoolean ( ALenum param ) ;
FUNCTION: ALint alGetInteger ( ALenum param ) ;
FUNCTION: ALfloat alGetFloat ( ALenum param ) ;
FUNCTION: ALdouble alGetDouble ( ALenum param ) ;
FUNCTION: ALenum alGetError (  ) ;
FUNCTION: ALboolean alIsExtensionPresent ( ALchar* extname ) ;
FUNCTION: void* alGetProcAddress ( ALchar* fname ) ;
FUNCTION: ALenum alGetEnumValue ( ALchar* ename ) ;
FUNCTION: void alListenerf ( ALenum param, ALfloat value ) ;
FUNCTION: void alListener3f ( ALenum param, ALfloat value1, ALfloat value2, ALfloat value3 ) ;
FUNCTION: void alListenerfv ( ALenum param, ALfloat* values ) ; 
FUNCTION: void alListeneri ( ALenum param, ALint value ) ;
FUNCTION: void alListener3i ( ALenum param, ALint value1, ALint value2, ALint value3 ) ;
FUNCTION: void alListeneriv ( ALenum param, ALint* values ) ;
FUNCTION: void alGetListenerf ( ALenum param, ALfloat* value ) ;
FUNCTION: void alGetListener3f ( ALenum param, ALfloat* value1, ALfloat* value2, ALfloat* value3 ) ;
FUNCTION: void alGetListenerfv ( ALenum param, ALfloat* values ) ;
FUNCTION: void alGetListeneri ( ALenum param, ALint* value ) ;
FUNCTION: void alGetListener3i ( ALenum param, ALint* value1, ALint* value2, ALint* value3 ) ;
FUNCTION: void alGetListeneriv ( ALenum param, ALint* values ) ;
FUNCTION: void alGenSources ( ALsizei n, ALuint* sources ) ; 
FUNCTION: void alDeleteSources ( ALsizei n, ALuint* sources ) ;
FUNCTION: ALboolean alIsSource ( ALuint sid ) ; 
FUNCTION: void alSourcef ( ALuint sid, ALenum param, ALfloat value ) ; 
FUNCTION: void alSource3f ( ALuint sid, ALenum param, ALfloat value1, ALfloat value2, ALfloat value3 ) ;
FUNCTION: void alSourcefv ( ALuint sid, ALenum param, ALfloat* values ) ; 
FUNCTION: void alSourcei ( ALuint sid, ALenum param, ALint value ) ; 
FUNCTION: void alSource3i ( ALuint sid, ALenum param, ALint value1, ALint value2, ALint value3 ) ;
FUNCTION: void alSourceiv ( ALuint sid, ALenum param, ALint* values ) ;
FUNCTION: void alGetSourcef ( ALuint sid, ALenum param, ALfloat* value ) ;
FUNCTION: void alGetSource3f ( ALuint sid, ALenum param, ALfloat* value1, ALfloat* value2, ALfloat* value3) ;
FUNCTION: void alGetSourcefv ( ALuint sid, ALenum param, ALfloat* values ) ;
FUNCTION: void alGetSourcei ( ALuint sid,  ALenum param, ALint* value ) ;
FUNCTION: void alGetSource3i ( ALuint sid, ALenum param, ALint* value1, ALint* value2, ALint* value3) ;
FUNCTION: void alGetSourceiv ( ALuint sid,  ALenum param, ALint* values ) ;
FUNCTION: void alSourcePlayv ( ALsizei ns, ALuint* sids ) ;
FUNCTION: void alSourceStopv ( ALsizei ns, ALuint* sids ) ;
FUNCTION: void alSourceRewindv ( ALsizei ns, ALuint* sids ) ;
FUNCTION: void alSourcePausev ( ALsizei ns, ALuint* sids ) ;
FUNCTION: void alSourcePlay ( ALuint sid ) ;
FUNCTION: void alSourceStop ( ALuint sid ) ;
FUNCTION: void alSourceRewind ( ALuint sid ) ;
FUNCTION: void alSourcePause ( ALuint sid ) ;
FUNCTION: void alSourceQueueBuffers ( ALuint sid, ALsizei numEntries, ALuint* bids ) ;
FUNCTION: void alSourceUnqueueBuffers ( ALuint sid, ALsizei numEntries, ALuint* bids ) ;
FUNCTION: void alGenBuffers ( ALsizei n, ALuint* buffers ) ;
FUNCTION: void alDeleteBuffers ( ALsizei n, ALuint* buffers ) ;
FUNCTION: ALboolean alIsBuffer ( ALuint bid ) ;
FUNCTION: void alBufferData ( ALuint bid, ALenum format, void* data, ALsizei size, ALsizei freq ) ;
FUNCTION: void alBufferf ( ALuint bid, ALenum param, ALfloat value ) ;
FUNCTION: void alBuffer3f ( ALuint bid, ALenum param, ALfloat value1, ALfloat value2, ALfloat value3 ) ;
FUNCTION: void alBufferfv ( ALuint bid, ALenum param, ALfloat* values ) ;
FUNCTION: void alBufferi ( ALuint bid, ALenum param, ALint value ) ;
FUNCTION: void alBuffer3i ( ALuint bid, ALenum param, ALint value1, ALint value2, ALint value3 ) ;
FUNCTION: void alBufferiv ( ALuint bid, ALenum param, ALint* values ) ;
FUNCTION: void alGetBufferf ( ALuint bid, ALenum param, ALfloat* value ) ;
FUNCTION: void alGetBuffer3f ( ALuint bid, ALenum param, ALfloat* value1, ALfloat* value2, ALfloat* value3) ;
FUNCTION: void alGetBufferfv ( ALuint bid, ALenum param, ALfloat* values ) ;
FUNCTION: void alGetBufferi ( ALuint bid, ALenum param, ALint* value ) ;
FUNCTION: void alGetBuffer3i ( ALuint bid, ALenum param, ALint* value1, ALint* value2, ALint* value3) ;
FUNCTION: void alGetBufferiv ( ALuint bid, ALenum param, ALint* values ) ;
FUNCTION: void alDopplerFactor ( ALfloat value ) ;
FUNCTION: void alDopplerVelocity ( ALfloat value ) ;
FUNCTION: void alSpeedOfSound ( ALfloat value ) ;
FUNCTION: void alDistanceModel ( ALenum distanceModel ) ;

LIBRARY: alut

: ALUT_API_MAJOR_VERSION ( -- number ) 1 ; inline
: ALUT_API_MINOR_VERSION ( -- number ) 1 ; inline
: ALUT_ERROR_NO_ERROR ( -- number ) 0 ; inline
: ALUT_ERROR_OUT_OF_MEMORY ( -- number ) HEX: 200 ; inline
: ALUT_ERROR_INVALID_ENUM ( -- number ) HEX: 201 ; inline
: ALUT_ERROR_INVALID_VALUE ( -- number ) HEX: 202 ; inline
: ALUT_ERROR_INVALID_OPERATION ( -- number ) HEX: 203 ; inline
: ALUT_ERROR_NO_CURRENT_CONTEXT ( -- number ) HEX: 204 ; inline
: ALUT_ERROR_AL_ERROR_ON_ENTRY ( -- number ) HEX: 205 ; inline
: ALUT_ERROR_ALC_ERROR_ON_ENTRY ( -- number ) HEX: 206 ; inline
: ALUT_ERROR_OPEN_DEVICE ( -- number ) HEX: 207 ; inline
: ALUT_ERROR_CLOSE_DEVICE ( -- number ) HEX: 208 ; inline
: ALUT_ERROR_CREATE_CONTEXT ( -- number ) HEX: 209 ; inline
: ALUT_ERROR_MAKE_CONTEXT_CURRENT ( -- number ) HEX: 20A ; inline
: ALUT_ERROR_DESTRY_CONTEXT ( -- number ) HEX: 20B ; inline
: ALUT_ERROR_GEN_BUFFERS ( -- number ) HEX: 20C ; inline
: ALUT_ERROR_BUFFER_DATA ( -- number ) HEX: 20D ; inline
: ALUT_ERROR_IO_ERROR ( -- number ) HEX: 20E ; inline
: ALUT_ERROR_UNSUPPORTED_FILE_TYPE ( -- number ) HEX: 20F ; inline
: ALUT_ERROR_UNSUPPORTED_FILE_SUBTYPE ( -- number ) HEX: 210 ; inline
: ALUT_ERROR_CORRUPT_OR_TRUNCATED_DATA ( -- number ) HEX: 211 ; inline
: ALUT_WAVEFORM_SINE ( -- number ) HEX: 100 ; inline
: ALUT_WAVEFORM_SQUARE ( -- number ) HEX: 101 ; inline
: ALUT_WAVEFORM_SAWTOOTH ( -- number ) HEX: 102 ; inline
: ALUT_WAVEFORM_WHITENOISE ( -- number ) HEX: 103 ; inline
: ALUT_WAVEFORM_IMPULSE ( -- number ) HEX: 104 ; inline
: ALUT_LOADER_BUFFER ( -- number ) HEX: 300 ; inline
: ALUT_LOADER_MEMORY ( -- number ) HEX: 301 ; inline

FUNCTION: ALboolean alutInit ( int* argcp, char** argv ) ;
FUNCTION: ALboolean alutInitWithoutContext ( int* argcp, char** argv ) ;
FUNCTION: ALboolean alutExit ( ) ;
FUNCTION: ALenum alutGetError ( ) ;
FUNCTION: char* alutGetErrorString ( ALenum error ) ;
FUNCTION: ALuint alutCreateBufferFromFile ( char* fileName ) ;
FUNCTION: ALuint alutCreateBufferFromFileImage ( void* data, ALsizei length ) ;
FUNCTION: ALuint alutCreateBufferHelloWorld ( ) ;
FUNCTION: ALuint alutCreateBufferWaveform ( ALenum waveshape, ALfloat frequency, ALfloat phase, ALfloat duration ) ;
FUNCTION: void* alutLoadMemoryFromFile ( char* fileName, ALenum* format, ALsizei* size, ALfloat* frequency ) ;
FUNCTION: void* alutLoadMemoryFromFileImage ( void* data, ALsizei length, ALenum* format, ALsizei* size, ALfloat* frequency ) ;
FUNCTION: void* alutLoadMemoryHelloWorld ( ALenum* format, ALsizei* size, ALfloat* frequency ) ;
FUNCTION: void* alutLoadMemoryWaveform ( ALenum waveshape, ALfloat frequency, ALfloat phase, ALfloat duration, ALenum* format, ALsizei* size, ALfloat* freq ) ;
FUNCTION: char* alutGetMIMETypes ( ALenum loader ) ;
FUNCTION: ALint alutGetMajorVersion ( ) ;
FUNCTION: ALint alutGetMinorVersion ( ) ;
FUNCTION: ALboolean alutSleep ( ALfloat duration ) ;

FUNCTION: void alutUnloadWAV ( ALenum format, void* data, ALsizei size, ALsizei frequency ) ;

SYMBOL: init

: init-openal ( -- )
  init get-global expired? [
    f f alutInit drop
    1337 <alien> init set-global
  ] when ;

: exit-openal ( -- )
  init get-global expired? [
    alutExit drop
    f init set-global
  ] unless ;

: <uint-array> "ALuint" <c-array> ;

: gen-sources ( size -- seq )
  dup <uint-array> 2dup alGenSources swap c-uint-array> ;

: gen-buffers ( size -- seq )
  dup <uint-array> 2dup alGenBuffers swap c-uint-array> ;

: gen-buffer ( -- buffer ) 1 gen-buffers first ;

: create-buffer-from-file ( filename -- buffer )
  alutCreateBufferFromFile dup AL_NONE = [
    "create-buffer-from-file failed" throw
  ] when ;

SYMBOL: openal-impl
HOOK: load-wav-file openal-impl ( filename -- format data size frequency )
TUPLE: macosx-openal-impl ;
TUPLE: other-openal-impl ;

macosx? [ 
    "openal.macosx" require
    macosx-openal-impl
] [ 
    "openal.other" require
    other-openal-impl
] if construct-empty openal-impl set-global

: create-buffer-from-wav ( filename -- buffer )
  gen-buffer dup rot load-wav-file
  [ alBufferData ] 4keep alutUnloadWAV ;

: set-source-param ( source param value -- )
  alSourcei ;

: get-source-param ( source param -- value )
  0 <uint> dup >r alGetSourcei r> *uint ;

: set-buffer-param ( source param value -- )
  alBufferi ;

: get-buffer-param ( source param -- value )
  0 <uint> dup >r alGetBufferi r> *uint ;

: source-play ( source -- )
  alSourcePlay ;

: source-stop ( source -- )
  alSourceStop ;

: check-error ( -- )
  alGetError dup ALUT_ERROR_NO_ERROR = [
    drop
  ] [
    alGetString throw
  ] if ;

: source-playing? ( source -- bool )
  AL_SOURCE_STATE get-source-param AL_PLAYING = ;

