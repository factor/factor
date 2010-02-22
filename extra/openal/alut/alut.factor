! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors arrays alien system combinators
alien.syntax namespaces alien.c-types sequences vocabs.loader
shuffle openal openal.alut.backend alien.libraries generalizations
specialized-arrays alien.destructors ;
FROM: alien.c-types => float short ;
SPECIALIZED-ARRAY: uint
IN: openal.alut

<< "alut" {
        { [ os windows? ]  [ "alut.dll" ] }
        { [ os macosx? ] [
            "/System/Library/Frameworks/OpenAL.framework/OpenAL"
        ] }
        { [ os unix?  ]  [ "libalut.so" ] }
    } cond "cdecl" add-library >>

<< os macosx? [ "alut" deploy-library ] unless >>

LIBRARY: alut

CONSTANT: ALUT_API_MAJOR_VERSION 1
CONSTANT: ALUT_API_MINOR_VERSION 1
CONSTANT: ALUT_ERROR_NO_ERROR 0
CONSTANT: ALUT_ERROR_OUT_OF_MEMORY HEX: 200
CONSTANT: ALUT_ERROR_INVALID_ENUM HEX: 201
CONSTANT: ALUT_ERROR_INVALID_VALUE HEX: 202
CONSTANT: ALUT_ERROR_INVALID_OPERATION HEX: 203
CONSTANT: ALUT_ERROR_NO_CURRENT_CONTEXT HEX: 204
CONSTANT: ALUT_ERROR_AL_ERROR_ON_ENTRY HEX: 205
CONSTANT: ALUT_ERROR_ALC_ERROR_ON_ENTRY HEX: 206
CONSTANT: ALUT_ERROR_OPEN_DEVICE HEX: 207
CONSTANT: ALUT_ERROR_CLOSE_DEVICE HEX: 208
CONSTANT: ALUT_ERROR_CREATE_CONTEXT HEX: 209
CONSTANT: ALUT_ERROR_MAKE_CONTEXT_CURRENT HEX: 20A
CONSTANT: ALUT_ERROR_DESTRY_CONTEXT HEX: 20B
CONSTANT: ALUT_ERROR_GEN_BUFFERS HEX: 20C
CONSTANT: ALUT_ERROR_BUFFER_DATA HEX: 20D
CONSTANT: ALUT_ERROR_IO_ERROR HEX: 20E
CONSTANT: ALUT_ERROR_UNSUPPORTED_FILE_TYPE HEX: 20F
CONSTANT: ALUT_ERROR_UNSUPPORTED_FILE_SUBTYPE HEX: 210
CONSTANT: ALUT_ERROR_CORRUPT_OR_TRUNCATED_DATA HEX: 211
CONSTANT: ALUT_WAVEFORM_SINE HEX: 100
CONSTANT: ALUT_WAVEFORM_SQUARE HEX: 101
CONSTANT: ALUT_WAVEFORM_SAWTOOTH HEX: 102
CONSTANT: ALUT_WAVEFORM_WHITENOISE HEX: 103
CONSTANT: ALUT_WAVEFORM_IMPULSE HEX: 104
CONSTANT: ALUT_LOADER_BUFFER HEX: 300
CONSTANT: ALUT_LOADER_MEMORY HEX: 301

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
        f f alutInit 0 = [ "Could not initialize OpenAL" throw ] when
        1337 <alien> init set-global
    ] when ;

: exit-openal ( -- )
    init get-global expired? [
        alutExit 0 = [ "Could not close OpenAL" throw ] when
        f init set-global
    ] unless ;

: create-buffer-from-file ( filename -- buffer )
    alutCreateBufferFromFile dup AL_NONE = [
        "create-buffer-from-file failed" throw
    ] when ;

os macosx? "openal.alut.macosx" "openal.alut.other" ? require

: create-buffer-from-wav ( filename -- buffer )
    gen-buffer dup rot load-wav-file
    [ alBufferData ] 4 nkeep alutUnloadWAV ;

: check-error ( -- )
    alGetError dup ALUT_ERROR_NO_ERROR = [
        drop
    ] [
        alGetString throw
    ] if ;

