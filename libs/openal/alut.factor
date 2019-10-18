! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
IN: openal
USING: kernel alien ;

: load-alut-library ( -- )
  "alut" {
    { [ win32? ]  [ "alut.dll" ] }
    { [ macosx? ] [ "/System/Library/Frameworks/OpenAL.framework/OpenAL" ] }
    { [ unix?  ]  [ "libalut.so" ] }
  } cond "cdecl" add-library ;

load-alut-library

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