! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
IN: openal.macosx
USING: alien.c-types kernel alien alien.syntax shuffle
combinators.lib openal.backend namespaces ;

TUPLE: macosx-openal-backend ;
LIBRARY: alut

T{ macosx-openal-backend } openal-backend set-global

FUNCTION: void alutLoadWAVFile ( ALbyte* fileName, ALenum* format, void** data, ALsizei* size, ALsizei* frequency ) ;

M: macosx-openal-backend load-wav-file ( path -- format data size frequency )
  0 <int> f <void*> 0 <int> 0 <int>
  [ alutLoadWAVFile ] 4keep
  >r >r >r *int r> *void* r> *int r> *int ;
