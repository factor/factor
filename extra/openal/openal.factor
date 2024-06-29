! Copyright (C) 2007 Chris Double.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.data alien.destructors
alien.libraries alien.syntax arrays combinators kernel sequences
specialized-arrays system ;
FROM: alien.c-types => char double float int short uchar uint
ushort void ;
SPECIALIZED-ARRAY: uint
IN: openal

<< "openal" {
        { [ os windows? ]  [ "OpenAL32.dll" ] }
        { [ os macos? ] [
            "/System/Library/Frameworks/OpenAL.framework/OpenAL"
        ] }
        { [ os unix?  ]  [ "libopenal.so" ] }
    } cond cdecl add-library >>

<< os unix? [ "openal" deploy-library ] unless >>

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
CONSTANT: AL_SOURCE_RELATIVE 0x202
CONSTANT: AL_CONE_INNER_ANGLE 0x1001
CONSTANT: AL_CONE_OUTER_ANGLE 0x1002
CONSTANT: AL_PITCH 0x1003
CONSTANT: AL_POSITION 0x1004
CONSTANT: AL_DIRECTION 0x1005
CONSTANT: AL_VELOCITY 0x1006
CONSTANT: AL_LOOPING 0x1007
CONSTANT: AL_BUFFER 0x1009
CONSTANT: AL_GAIN 0x100A
CONSTANT: AL_MIN_GAIN 0x100D
CONSTANT: AL_MAX_GAIN 0x100E
CONSTANT: AL_ORIENTATION 0x100F
CONSTANT: AL_CHANNEL_MASK 0x3000
CONSTANT: AL_SOURCE_STATE 0x1010
CONSTANT: AL_INITIAL 0x1011
CONSTANT: AL_PLAYING 0x1012
CONSTANT: AL_PAUSED 0x1013
CONSTANT: AL_STOPPED 0x1014
CONSTANT: AL_BUFFERS_QUEUED 0x1015
CONSTANT: AL_BUFFERS_PROCESSED 0x1016
CONSTANT: AL_SEC_OFFSET 0x1024
CONSTANT: AL_SAMPLE_OFFSET 0x1025
CONSTANT: AL_BYTE_OFFSET 0x1026
CONSTANT: AL_SOURCE_TYPE 0x1027
CONSTANT: AL_STATIC 0x1028
CONSTANT: AL_STREAMING 0x1029
CONSTANT: AL_UNDETERMINED 0x1030
CONSTANT: AL_FORMAT_MONO8 0x1100
CONSTANT: AL_FORMAT_MONO16 0x1101
CONSTANT: AL_FORMAT_STEREO8 0x1102
CONSTANT: AL_FORMAT_STEREO16 0x1103
CONSTANT: AL_REFERENCE_DISTANCE 0x1020
CONSTANT: AL_ROLLOFF_FACTOR 0x1021
CONSTANT: AL_CONE_OUTER_GAIN 0x1022
CONSTANT: AL_MAX_DISTANCE 0x1023
CONSTANT: AL_FREQUENCY 0x2001
CONSTANT: AL_BITS 0x2002
CONSTANT: AL_CHANNELS 0x2003
CONSTANT: AL_SIZE 0x2004
CONSTANT: AL_UNUSED 0x2010
CONSTANT: AL_PENDING 0x2011
CONSTANT: AL_PROCESSED 0x2012
CONSTANT: AL_NO_ERROR AL_FALSE
CONSTANT: AL_INVALID_NAME 0xA001
CONSTANT: AL_ILLEGAL_ENUM 0xA002
CONSTANT: AL_INVALID_ENUM 0xA002
CONSTANT: AL_INVALID_VALUE 0xA003
CONSTANT: AL_ILLEGAL_COMMAND 0xA004
CONSTANT: AL_INVALID_OPERATION 0xA004
CONSTANT: AL_OUT_OF_MEMORY 0xA005
CONSTANT: AL_VENDOR 0xB001
CONSTANT: AL_VERSION 0xB002
CONSTANT: AL_RENDERER 0xB003
CONSTANT: AL_EXTENSIONS 0xB004
CONSTANT: AL_DOPPLER_FACTOR 0xC000
CONSTANT: AL_DOPPLER_VELOCITY 0xC001
CONSTANT: AL_SPEED_OF_SOUND 0xC003
CONSTANT: AL_DISTANCE_MODEL 0xD000
CONSTANT: AL_INVERSE_DISTANCE 0xD001
CONSTANT: AL_INVERSE_DISTANCE_CLAMPED 0xD002
CONSTANT: AL_LINEAR_DISTANCE 0xD003
CONSTANT: AL_LINEAR_DISTANCE_CLAMPED 0xD004
CONSTANT: AL_EXPONENT_DISTANCE 0xD005
CONSTANT: AL_EXPONENT_DISTANCE_CLAMPED 0xD006

FUNCTION: void alEnable ( ALenum capability )
FUNCTION: void alDisable ( ALenum capability )
FUNCTION: ALboolean alIsEnabled ( ALenum capability )
FUNCTION: ALchar* alGetString ( ALenum param )
FUNCTION: void alGetBooleanv ( ALenum param, ALboolean* data )
FUNCTION: void alGetIntegerv ( ALenum param, ALint* data )
FUNCTION: void alGetFloatv ( ALenum param, ALfloat* data )
FUNCTION: void alGetDoublev ( ALenum param, ALdouble* data )
FUNCTION: ALboolean alGetBoolean ( ALenum param )
FUNCTION: ALint alGetInteger ( ALenum param )
FUNCTION: ALfloat alGetFloat ( ALenum param )
FUNCTION: ALdouble alGetDouble ( ALenum param )
FUNCTION: ALenum alGetError ( )
FUNCTION: ALboolean alIsExtensionPresent ( ALchar* extname )
FUNCTION: void* alGetProcAddress ( ALchar* fname )
FUNCTION: ALenum alGetEnumValue ( ALchar* ename )
FUNCTION: void alListenerf ( ALenum param, ALfloat value )
FUNCTION: void alListener3f ( ALenum param, ALfloat value1, ALfloat value2, ALfloat value3 )
FUNCTION: void alListenerfv ( ALenum param, ALfloat* values )
FUNCTION: void alListeneri ( ALenum param, ALint value )
FUNCTION: void alListener3i ( ALenum param, ALint value1, ALint value2, ALint value3 )
FUNCTION: void alListeneriv ( ALenum param, ALint* values )
FUNCTION: void alGetListenerf ( ALenum param, ALfloat* value )
FUNCTION: void alGetListener3f ( ALenum param, ALfloat* value1, ALfloat* value2, ALfloat* value3 )
FUNCTION: void alGetListenerfv ( ALenum param, ALfloat* values )
FUNCTION: void alGetListeneri ( ALenum param, ALint* value )
FUNCTION: void alGetListener3i ( ALenum param, ALint* value1, ALint* value2, ALint* value3 )
FUNCTION: void alGetListeneriv ( ALenum param, ALint* values )
FUNCTION: void alGenSources ( ALsizei n, ALuint* sources )
FUNCTION: void alDeleteSources ( ALsizei n, ALuint* sources )
FUNCTION: ALboolean alIsSource ( ALuint sid )
FUNCTION: void alSourcef ( ALuint sid, ALenum param, ALfloat value )
FUNCTION: void alSource3f ( ALuint sid, ALenum param, ALfloat value1, ALfloat value2, ALfloat value3 )
FUNCTION: void alSourcefv ( ALuint sid, ALenum param, ALfloat* values )
FUNCTION: void alSourcei ( ALuint sid, ALenum param, ALint value )
FUNCTION: void alSource3i ( ALuint sid, ALenum param, ALint value1, ALint value2, ALint value3 )
FUNCTION: void alSourceiv ( ALuint sid, ALenum param, ALint* values )
FUNCTION: void alGetSourcef ( ALuint sid, ALenum param, ALfloat* value )
FUNCTION: void alGetSource3f ( ALuint sid, ALenum param, ALfloat* value1, ALfloat* value2, ALfloat* value3 )
FUNCTION: void alGetSourcefv ( ALuint sid, ALenum param, ALfloat* values )
FUNCTION: void alGetSourcei ( ALuint sid,  ALenum param, ALint* value )
FUNCTION: void alGetSource3i ( ALuint sid, ALenum param, ALint* value1, ALint* value2, ALint* value3 )
FUNCTION: void alGetSourceiv ( ALuint sid,  ALenum param, ALint* values )
FUNCTION: void alSourcePlayv ( ALsizei ns, ALuint* sids )
FUNCTION: void alSourceStopv ( ALsizei ns, ALuint* sids )
FUNCTION: void alSourceRewindv ( ALsizei ns, ALuint* sids )
FUNCTION: void alSourcePausev ( ALsizei ns, ALuint* sids )
FUNCTION: void alSourcePlay ( ALuint sid )
FUNCTION: void alSourceStop ( ALuint sid )
FUNCTION: void alSourceRewind ( ALuint sid )
FUNCTION: void alSourcePause ( ALuint sid )
FUNCTION: void alSourceQueueBuffers ( ALuint sid, ALsizei numEntries, ALuint* bids )
FUNCTION: void alSourceUnqueueBuffers ( ALuint sid, ALsizei numEntries, ALuint* bids )
FUNCTION: void alGenBuffers ( ALsizei n, ALuint* buffers )
FUNCTION: void alDeleteBuffers ( ALsizei n, ALuint* buffers )
FUNCTION: ALboolean alIsBuffer ( ALuint bid )
FUNCTION: void alBufferData ( ALuint bid, ALenum format, void* data, ALsizei size, ALsizei freq )
FUNCTION: void alBufferf ( ALuint bid, ALenum param, ALfloat value )
FUNCTION: void alBuffer3f ( ALuint bid, ALenum param, ALfloat value1, ALfloat value2, ALfloat value3 )
FUNCTION: void alBufferfv ( ALuint bid, ALenum param, ALfloat* values )
FUNCTION: void alBufferi ( ALuint bid, ALenum param, ALint value )
FUNCTION: void alBuffer3i ( ALuint bid, ALenum param, ALint value1, ALint value2, ALint value3 )
FUNCTION: void alBufferiv ( ALuint bid, ALenum param, ALint* values )
FUNCTION: void alGetBufferf ( ALuint bid, ALenum param, ALfloat* value )
FUNCTION: void alGetBuffer3f ( ALuint bid, ALenum param, ALfloat* value1, ALfloat* value2, ALfloat* value3 )
FUNCTION: void alGetBufferfv ( ALuint bid, ALenum param, ALfloat* values )
FUNCTION: void alGetBufferi ( ALuint bid, ALenum param, ALint* value )
FUNCTION: void alGetBuffer3i ( ALuint bid, ALenum param, ALint* value1, ALint* value2, ALint* value3 )
FUNCTION: void alGetBufferiv ( ALuint bid, ALenum param, ALint* values )
FUNCTION: void alDopplerFactor ( ALfloat value )
FUNCTION: void alDopplerVelocity ( ALfloat value )
FUNCTION: void alSpeedOfSound ( ALfloat value )
FUNCTION: void alDistanceModel ( ALenum distanceModel )

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
CONSTANT: ALC_FREQUENCY                            0x1007
CONSTANT: ALC_REFRESH                              0x1008
CONSTANT: ALC_SYNC                                 0x1009
CONSTANT: ALC_MONO_SOURCES                         0x1010
CONSTANT: ALC_STEREO_SOURCES                       0x1011

CONSTANT: ALC_NO_ERROR                             0

CONSTANT: ALC_INVALID_DEVICE                       0xA001
CONSTANT: ALC_INVALID_CONTEXT                      0xA002
CONSTANT: ALC_INVALID_ENUM                         0xA003
CONSTANT: ALC_INVALID_VALUE                        0xA004
CONSTANT: ALC_OUT_OF_MEMORY                        0xA005

CONSTANT: ALC_DEFAULT_DEVICE_SPECIFIER             0x1004
CONSTANT: ALC_DEVICE_SPECIFIER                     0x1005
CONSTANT: ALC_EXTENSIONS                           0x1006

CONSTANT: ALC_MAJOR_VERSION                        0x1000
CONSTANT: ALC_MINOR_VERSION                        0x1001

CONSTANT: ALC_ATTRIBUTES_SIZE                      0x1002
CONSTANT: ALC_ALL_ATTRIBUTES                       0x1003
CONSTANT: ALC_DEFAULT_ALL_DEVICES_SPECIFIER        0x1012
CONSTANT: ALC_ALL_DEVICES_SPECIFIER                0x1013
CONSTANT: ALC_CAPTURE_DEVICE_SPECIFIER             0x310
CONSTANT: ALC_CAPTURE_DEFAULT_DEVICE_SPECIFIER     0x311
CONSTANT: ALC_CAPTURE_SAMPLES                      0x312

FUNCTION: ALCdevice* alcOpenDevice ( ALCchar* deviceSpecifier )
FUNCTION: ALCboolean alcCloseDevice ( ALCdevice* deviceHandle )

: alcCloseDevice* ( deviceHandle -- )
    alcCloseDevice drop ;

FUNCTION: ALCcontext* alcCreateContext ( ALCdevice* deviceHandle, ALCint* attrList )
FUNCTION: ALCboolean alcMakeContextCurrent ( ALCcontext* context )
FUNCTION: void alcProcessContext ( ALCcontext* context )
FUNCTION: void alcSuspendContext ( ALCcontext* context )
FUNCTION: void alcDestroyContext ( ALCcontext* context )
FUNCTION: ALCcontext* alcGetCurrentContext ( )
FUNCTION: ALCdevice* alcGetContextsDevice ( ALCcontext* context )
FUNCTION: ALCboolean alcIsExtensionPresent ( ALCdevice* deviceHandle, ALCchar* extName )
FUNCTION: void* alcGetProcAddress ( ALCdevice* deviceHandle, ALCchar* funcName )
FUNCTION: ALCenum alcGetEnumValue ( ALCdevice* deviceHandle, ALCchar* enumName )
FUNCTION: ALCenum alcGetError ( ALCdevice* deviceHandle )
FUNCTION: ALCchar* alcGetString ( ALCdevice* deviceHandle, ALCenum token )
FUNCTION: void alcGetIntegerv ( ALCdevice* deviceHandle, ALCenum token, ALCsizei size, ALCint* dest )

FUNCTION: ALCdevice* alcCaptureOpenDevice ( ALCchar* deviceName, ALCuint freq, ALCenum fmt, ALCsizei bufsize )
FUNCTION: ALCboolean alcCaptureCloseDevice ( ALCdevice* device )
FUNCTION: void alcCaptureStart ( ALCdevice* device )
FUNCTION: void alcCaptureStop ( ALCdevice* device )
FUNCTION: void alcCaptureSamples ( ALCdevice* device, void* buf, ALCsizei samps )

DESTRUCTOR: alcCloseDevice*
DESTRUCTOR: alcDestroyContext

: gen-sources ( size -- seq )
    dup uint <c-array> [ alGenSources ] keep ;

: gen-buffers ( size -- seq )
    dup uint <c-array> [ alGenBuffers ] keep ;

: gen-buffer ( -- buffer ) 1 gen-buffers first ;

: queue-buffers ( source buffers -- )
    [ length ] [ uint >c-array ] bi alSourceQueueBuffers ;

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
