! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: calendar kernel openal sequences threads ;
IN: openal.example

: play-hello ( -- )
    init-openal
    1 gen-sources
    first dup AL_BUFFER  alutCreateBufferHelloWorld set-source-param
    source-play
    1000 milliseconds sleep ;
  
: (play-file) ( source -- )
    100 milliseconds sleep
    dup source-playing? [ (play-file) ] [ drop ] if ;

: play-file ( filename -- )
    init-openal
    create-buffer-from-file 
    1 gen-sources
    first dup [ AL_BUFFER rot set-source-param ] dip
    dup source-play
    check-error
    (play-file) ;

: play-wav ( filename -- )
    init-openal
    create-buffer-from-wav 
    1 gen-sources
    first dup [ AL_BUFFER rot set-source-param ] dip
    dup source-play
    check-error
    (play-file) ;
