! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
IN: openal
USING: kernel alien alien-contrib namespaces threads errors
sequences shuffle ;

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
  dup <uint-array> 2dup alGenSources swap uint-array>array ;

: gen-buffers ( size -- seq )
  dup <uint-array> 2dup alGenBuffers swap uint-array>array ;

: gen-buffer ( -- buffer ) 1 gen-buffers first ;

: create-buffer-from-file ( filename -- buffer )
  alutCreateBufferFromFile dup AL_NONE = [
    "create-buffer-from-file failed" throw
  ] when ;

: create-buffer-from-wav ( filename -- buffer )
  gen-buffer dup rot load-wav-file
  [ alBufferData ] 4keep alutUnloadWAV ;

: set-source-param ( source param value -- )
  alSourcei ;

: get-source-param ( source param -- value )
  0 <uint> dup >r alGetSourcei r> *uint ;

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