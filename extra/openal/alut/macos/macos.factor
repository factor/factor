! Copyright (C) 2007 Chris Double.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data alien.syntax audio audio.loader
kernel locals math namespaces openal openal.alut.backend system ;
IN: openal.alut.macos

SYMBOL: native-alut-context

:: init-native-openal ( -- )
    f alcOpenDevice :> device
    device [
        device f alcCreateContext :> context
        context [
            context alcMakeContextCurrent zero? [
                context alcDestroyContext
                device alcCloseDevice drop
                "Cannot make the OpenAL context current" throw
            ] when
            context native-alut-context set-global
        ] [
            device alcCloseDevice drop
            "Cannot create an OpenAL context" throw
        ] if
    ] [ "Cannot open an OpenAL device" throw ] if ;

:: exit-native-openal ( -- )
    native-alut-context get-global :> context
    context [
        context alcGetContextsDevice :> device
        alcGetCurrentContext context = [ f alcMakeContextCurrent drop ] when
        context alcDestroyContext
        device alcCloseDevice drop
        f native-alut-context set-global
    ] when ;

:: create-native-buffer ( filename -- buffer )
    filename read-audio :> audio
    gen-buffer :> buffer
    buffer audio openal-format audio data>> audio size>> audio sample-rate>>
    alBufferData
    buffer ;

LIBRARY: alut

M: macos init-alut init-native-openal ;
M: macos exit-alut exit-native-openal ;
M: macos load-alut-buffer create-native-buffer ;
M: macos load-wav-buffer create-native-buffer ;

FUNCTION: void alutLoadWAVFile ( c-string fileName, ALenum* format, void** data, ALsizei* size, ALsizei* frequency )

M: macos load-wav-file ( path -- format data size frequency )
    0 int <ref> f void* <ref> 0 int <ref> 0 int <ref>
    [ alutLoadWAVFile ] 4keep
    [ [ [ int deref ] dip void* deref ] dip int deref ] dip int deref ;
