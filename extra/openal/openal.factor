! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors arrays alien system combinators
alien.syntax namespaces sequences vocabs.loader
shuffle alien.libraries generalizations
specialized-arrays alien.destructors alien.data ;
FROM: alien.c-types => char double float int short uchar uint
ushort void ;
SPECIALIZED-ARRAY: uint
IN: openal

<< "openal" {
        { [ os windows? ]  [ "OpenAL32.dll" ] }
        { [ os macosx? ] [
            "/System/Library/Frameworks/OpenAL.framework/OpenAL"
        ] }
        { [ os unix?  ]  [ "libopenal.so" ] }
    } cond cdecl add-library >>

<< os macosx? [ "openal" deploy-library ] unless >>

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

CONSTANT: AL_INVALID -1
CONSTANT: AL_NONE 0
CONSTANT: AL_FALSE 0
CONSTANT: AL_TRUE 1
CONSTANT: AL_SOURCE_RELATIVE HEX: 202
CONSTANT: AL_CONE_INNER_ANGLE HEX: 1001
CONSTANT: AL_CONE_OUTER_ANGLE HEX: 1002
CONSTANT: AL_PITCH HEX: 1003
CONSTANT: AL_POSITION HEX: 1004
CONSTANT: AL_DIRECTION HEX: 1005
CONSTANT: AL_VELOCITY HEX: 1006
CONSTANT: AL_LOOPING HEX: 1007
CONSTANT: AL_BUFFER HEX: 1009
CONSTANT: AL_GAIN HEX: 100A
CONSTANT: AL_MIN_GAIN HEX: 100D
CONSTANT: AL_MAX_GAIN HEX: 100E
CONSTANT: AL_ORIENTATION HEX: 100F
CONSTANT: AL_CHANNEL_MASK HEX: 3000
CONSTANT: AL_SOURCE_STATE HEX: 1010
CONSTANT: AL_INITIAL HEX: 1011
CONSTANT: AL_PLAYING HEX: 1012
CONSTANT: AL_PAUSED HEX: 1013
CONSTANT: AL_STOPPED HEX: 1014
CONSTANT: AL_BUFFERS_QUEUED HEX: 1015
CONSTANT: AL_BUFFERS_PROCESSED HEX: 1016
CONSTANT: AL_SEC_OFFSET HEX: 1024
CONSTANT: AL_SAMPLE_OFFSET HEX: 1025
CONSTANT: AL_BYTE_OFFSET HEX: 1026
CONSTANT: AL_SOURCE_TYPE HEX: 1027
CONSTANT: AL_STATIC HEX: 1028
CONSTANT: AL_STREAMING HEX: 1029
CONSTANT: AL_UNDETERMINED HEX: 1030
CONSTANT: AL_FORMAT_MONO8 HEX: 1100
CONSTANT: AL_FORMAT_MONO16 HEX: 1101
CONSTANT: AL_FORMAT_STEREO8 HEX: 1102
CONSTANT: AL_FORMAT_STEREO16 HEX: 1103
CONSTANT: AL_REFERENCE_DISTANCE HEX: 1020
CONSTANT: AL_ROLLOFF_FACTOR HEX: 1021
CONSTANT: AL_CONE_OUTER_GAIN HEX: 1022
CONSTANT: AL_MAX_DISTANCE HEX: 1023
CONSTANT: AL_FREQUENCY HEX: 2001
CONSTANT: AL_BITS HEX: 2002
CONSTANT: AL_CHANNELS HEX: 2003
CONSTANT: AL_SIZE HEX: 2004
CONSTANT: AL_UNUSED HEX: 2010
CONSTANT: AL_PENDING HEX: 2011
CONSTANT: AL_PROCESSED HEX: 2012
CONSTANT: AL_NO_ERROR AL_FALSE
CONSTANT: AL_INVALID_NAME HEX: A001
CONSTANT: AL_ILLEGAL_ENUM HEX: A002
CONSTANT: AL_INVALID_ENUM HEX: A002
CONSTANT: AL_INVALID_VALUE HEX: A003
CONSTANT: AL_ILLEGAL_COMMAND HEX: A004
CONSTANT: AL_INVALID_OPERATION HEX: A004
CONSTANT: AL_OUT_OF_MEMORY HEX: A005
CONSTANT: AL_VENDOR HEX: B001
CONSTANT: AL_VERSION HEX: B002
CONSTANT: AL_RENDERER HEX: B003
CONSTANT: AL_EXTENSIONS HEX: B004
CONSTANT: AL_DOPPLER_FACTOR HEX: C000
CONSTANT: AL_DOPPLER_VELOCITY HEX: C001
CONSTANT: AL_SPEED_OF_SOUND HEX: C003
CONSTANT: AL_DISTANCE_MODEL HEX: D000
CONSTANT: AL_INVERSE_DISTANCE HEX: D001
CONSTANT: AL_INVERSE_DISTANCE_CLAMPED HEX: D002
CONSTANT: AL_LINEAR_DISTANCE HEX: D003
CONSTANT: AL_LINEAR_DISTANCE_CLAMPED HEX: D004
CONSTANT: AL_EXPONENT_DISTANCE HEX: D005
CONSTANT: AL_EXPONENT_DISTANCE_CLAMPED HEX: D006

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

C-TYPE: ALCdevice
C-TYPE: ALCcontext
TYPEDEF: char ALCboolean
TYPEDEF: char ALCchar
TYPEDEF: int ALCenum
TYPEDEF: int ALCint
TYPEDEF: int ALCsizei
TYPEDEF: uint ALCuint

CONSTANT: ALC_FALSE                                0
CONSTANT: ALC_TRUE                                 1
CONSTANT: ALC_FREQUENCY                            HEX: 1007
CONSTANT: ALC_REFRESH                              HEX: 1008
CONSTANT: ALC_SYNC                                 HEX: 1009
CONSTANT: ALC_MONO_SOURCES                         HEX: 1010
CONSTANT: ALC_STEREO_SOURCES                       HEX: 1011

CONSTANT: ALC_NO_ERROR                             0

CONSTANT: ALC_INVALID_DEVICE                       HEX: A001
CONSTANT: ALC_INVALID_CONTEXT                      HEX: A002
CONSTANT: ALC_INVALID_ENUM                         HEX: A003
CONSTANT: ALC_INVALID_VALUE                        HEX: A004
CONSTANT: ALC_OUT_OF_MEMORY                        HEX: A005

CONSTANT: ALC_DEFAULT_DEVICE_SPECIFIER             HEX: 1004
CONSTANT: ALC_DEVICE_SPECIFIER                     HEX: 1005
CONSTANT: ALC_EXTENSIONS                           HEX: 1006

CONSTANT: ALC_MAJOR_VERSION                        HEX: 1000
CONSTANT: ALC_MINOR_VERSION                        HEX: 1001

CONSTANT: ALC_ATTRIBUTES_SIZE                      HEX: 1002
CONSTANT: ALC_ALL_ATTRIBUTES                       HEX: 1003
CONSTANT: ALC_DEFAULT_ALL_DEVICES_SPECIFIER        HEX: 1012
CONSTANT: ALC_ALL_DEVICES_SPECIFIER                HEX: 1013
CONSTANT: ALC_CAPTURE_DEVICE_SPECIFIER             HEX: 310
CONSTANT: ALC_CAPTURE_DEFAULT_DEVICE_SPECIFIER     HEX: 311
CONSTANT: ALC_CAPTURE_SAMPLES                      HEX: 312

FUNCTION: ALCdevice* alcOpenDevice ( ALCchar* deviceSpecifier ) ;
FUNCTION: ALCboolean alcCloseDevice ( ALCdevice* deviceHandle ) ;

: alcCloseDevice* ( deviceHandle -- )
    alcCloseDevice drop ;

FUNCTION: ALCcontext* alcCreateContext ( ALCdevice* deviceHandle, ALCint* attrList ) ;
FUNCTION: ALCboolean alcMakeContextCurrent ( ALCcontext* context ) ;
FUNCTION: void alcProcessContext ( ALCcontext* context ) ;
FUNCTION: void alcSuspendContext ( ALCcontext* context ) ;
FUNCTION: void alcDestroyContext ( ALCcontext* context ) ;
FUNCTION: ALCcontext* alcGetCurrentContext ( ) ;
FUNCTION: ALCdevice* alcGetContextsDevice ( ALCcontext* context ) ;
FUNCTION: ALCboolean alcIsExtensionPresent ( ALCdevice* deviceHandle, ALCchar* extName ) ;
FUNCTION: void* alcGetProcAddress ( ALCdevice* deviceHandle, ALCchar* funcName ) ;
FUNCTION: ALCenum alcGetEnumValue ( ALCdevice* deviceHandle, ALCchar* enumName ) ;
FUNCTION: ALCenum alcGetError ( ALCdevice* deviceHandle ) ;
FUNCTION: ALCchar* alcGetString ( ALCdevice* deviceHandle, ALCenum token ) ;
FUNCTION: void alcGetIntegerv ( ALCdevice* deviceHandle, ALCenum token, ALCsizei size, ALCint* dest ) ;

FUNCTION: ALCdevice* alcCaptureOpenDevice ( ALCchar* deviceName, ALCuint freq, ALCenum fmt, ALCsizei bufsize ) ;
FUNCTION: ALCboolean alcCaptureCloseDevice ( ALCdevice* device ) ;
FUNCTION: void alcCaptureStart ( ALCdevice* device ) ;
FUNCTION: void alcCaptureStop ( ALCdevice* device ) ;
FUNCTION: void alcCaptureSamples ( ALCdevice* device, void* buf, ALCsizei samps ) ;

DESTRUCTOR: alcCloseDevice*
DESTRUCTOR: alcDestroyContext

: gen-sources ( size -- seq )
    dup <uint-array> [ alGenSources ] keep ;

: gen-buffers ( size -- seq )
    dup <uint-array> [ alGenBuffers ] keep ;

: gen-buffer ( -- buffer ) 1 gen-buffers first ;

: queue-buffers ( source buffers -- )
    [ length ] [ >uint-array ] bi alSourceQueueBuffers ;

: queue-buffer ( source buffer -- )
    1array queue-buffers ;

: set-source-param ( source param value -- )
    alSourcei ;

: get-source-param ( source param -- value )
    0 uint <ref> dup [ alGetSourcei ] dip uint deref ;

: set-buffer-param ( source param value -- )
    alBufferi ;

: get-buffer-param ( source param -- value )
    0 uint <ref> dup [ alGetBufferi ] dip uint deref ;

: source-play ( source -- ) alSourcePlay ;

: source-stop ( source -- ) alSourceStop ;

: source-playing? ( source -- bool )
    AL_SOURCE_STATE get-source-param AL_PLAYING = ;
