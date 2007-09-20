! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
IN: openal.example
USING: openal kernel alien threads sequences ;

: play-hello ( -- )
  init-openal
  1 gen-sources
  first dup AL_BUFFER  alutCreateBufferHelloWorld set-source-param
  source-play
  1000 sleep ;
  
: (play-file) ( source -- )
  100 sleep
  dup source-playing? [ (play-file) ] [ drop ] if ;

: play-file ( filename -- )
  init-openal
  create-buffer-from-file 
  1 gen-sources
  first dup >r AL_BUFFER rot set-source-param r>
  dup source-play
  check-error
  (play-file) ;

: play-wav ( filename -- )
  init-openal
  create-buffer-from-wav 
  1 gen-sources
  first dup >r AL_BUFFER rot set-source-param r>
  dup source-play
  check-error
  (play-file) ;