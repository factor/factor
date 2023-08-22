! Copyright (C) 2007 Chris Double.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries alien.syntax
combinators kernel namespaces openal openal.alut.backend
specialized-arrays system vocabs ;
SPECIALIZED-ARRAY: uint
FROM: alien.c-types => float short ;
IN: openal.alut

<< "alut" {
        { [ os windows? ]  [ "alut.dll" ] }
        { [ os macosx? ] [ "libalut.dylib" ] }
        { [ os unix?  ]  [ "libalut.so" ] }
    } cond cdecl add-library >>

<< os macosx? [ "alut" deploy-library ] unless >>

LIBRARY: alut

CONSTANT: ALUT_API_MAJOR_VERSION 1
CONSTANT: ALUT_API_MINOR_VERSION 1
CONSTANT: ALUT_ERROR_NO_ERROR 0
CONSTANT: ALUT_ERROR_OUT_OF_MEMORY 0x200
CONSTANT: ALUT_ERROR_INVALID_ENUM 0x201
CONSTANT: ALUT_ERROR_INVALID_VALUE 0x202
CONSTANT: ALUT_ERROR_INVALID_OPERATION 0x203
CONSTANT: ALUT_ERROR_NO_CURRENT_CONTEXT 0x204
CONSTANT: ALUT_ERROR_AL_ERROR_ON_ENTRY 0x205
CONSTANT: ALUT_ERROR_ALC_ERROR_ON_ENTRY 0x206
CONSTANT: ALUT_ERROR_OPEN_DEVICE 0x207
CONSTANT: ALUT_ERROR_CLOSE_DEVICE 0x208
CONSTANT: ALUT_ERROR_CREATE_CONTEXT 0x209
CONSTANT: ALUT_ERROR_MAKE_CONTEXT_CURRENT 0x20A
CONSTANT: ALUT_ERROR_DESTRY_CONTEXT 0x20B
CONSTANT: ALUT_ERROR_GEN_BUFFERS 0x20C
CONSTANT: ALUT_ERROR_BUFFER_DATA 0x20D
CONSTANT: ALUT_ERROR_IO_ERROR 0x20E
CONSTANT: ALUT_ERROR_UNSUPPORTED_FILE_TYPE 0x20F
CONSTANT: ALUT_ERROR_UNSUPPORTED_FILE_SUBTYPE 0x210
CONSTANT: ALUT_ERROR_CORRUPT_OR_TRUNCATED_DATA 0x211
CONSTANT: ALUT_WAVEFORM_SINE 0x100
CONSTANT: ALUT_WAVEFORM_SQUARE 0x101
CONSTANT: ALUT_WAVEFORM_SAWTOOTH 0x102
CONSTANT: ALUT_WAVEFORM_WHITENOISE 0x103
CONSTANT: ALUT_WAVEFORM_IMPULSE 0x104
CONSTANT: ALUT_LOADER_BUFFER 0x300
CONSTANT: ALUT_LOADER_MEMORY 0x301

FUNCTION: ALboolean alutInit ( int* argcp, c-string* argv )
FUNCTION: ALboolean alutInitWithoutContext ( int* argcp, c-string* argv )
FUNCTION: ALboolean alutExit ( )
FUNCTION: ALenum alutGetError ( )
FUNCTION: c-string alutGetErrorString ( ALenum error )
FUNCTION: ALuint alutCreateBufferFromFile ( c-string fileName )
FUNCTION: ALuint alutCreateBufferFromFileImage ( void* data, ALsizei length )
FUNCTION: ALuint alutCreateBufferHelloWorld ( )
FUNCTION: ALuint alutCreateBufferWaveform ( ALenum waveshape, ALfloat frequency, ALfloat phase, ALfloat duration )
FUNCTION: void* alutLoadMemoryFromFile ( c-string fileName, ALenum* format, ALsizei* size, ALfloat* frequency )
FUNCTION: void* alutLoadMemoryFromFileImage ( void* data, ALsizei length, ALenum* format, ALsizei* size, ALfloat* frequency )
FUNCTION: void* alutLoadMemoryHelloWorld ( ALenum* format, ALsizei* size, ALfloat* frequency )
FUNCTION: void* alutLoadMemoryWaveform ( ALenum waveshape, ALfloat frequency, ALfloat phase, ALfloat duration, ALenum* format, ALsizei* size, ALfloat* freq )
FUNCTION: c-string alutGetMIMETypes ( ALenum loader )
FUNCTION: ALint alutGetMajorVersion ( )
FUNCTION: ALint alutGetMinorVersion ( )
FUNCTION: ALboolean alutSleep ( ALfloat duration )

FUNCTION: void alutUnloadWAV ( ALenum format, void* data, ALsizei size, ALsizei frequency )

SYMBOL: init

: throw-alut-error ( -- )
    alutGetError alutGetErrorString throw ;

: init-openal ( -- )
    init get-global expired? [
        f f alutInit 0 = [ throw-alut-error ] when
        1337 <alien> init set-global
    ] when ;

: exit-openal ( -- )
    init get-global expired? [
        alutExit 0 = [ throw-alut-error ] when
        f init set-global
    ] unless ;

: create-buffer-from-file ( filename -- buffer )
    alutCreateBufferFromFile dup AL_NONE = [
        throw-alut-error
    ] when ;

os macosx? "openal.alut.macosx" "openal.alut.other" ? require

: create-buffer-from-wav ( filename -- buffer )
    gen-buffer dup rot load-wav-file
    [ alBufferData ] 4keep alutUnloadWAV ;

: check-error ( -- )
    alGetError dup ALUT_ERROR_NO_ERROR = [
        drop
    ] [
        alGetString throw
    ] if ;
