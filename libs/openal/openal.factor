! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
IN: openal
USING: kernel alien ;

: load-openal-library ( -- )
  "openal" {
    { [ win32? ]  [ "OpenAL32.dll" ] }
    { [ macosx? ] [ "/System/Library/Frameworks/OpenAL.framework/OpenAL" ] }
    { [ unix?  ]  [ "libopenal.so" ] }
  } cond "cdecl" add-library ;

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