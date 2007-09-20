! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
IN: openal.other
USING: openal alien.c-types kernel alien alien.syntax shuffle combinators.lib ;

LIBRARY: alut

FUNCTION: void alutLoadWAVFile ( ALbyte* fileName, ALenum* format, void** data, ALsizei* size, ALsizei* frequency, ALboolean* looping ) ;

M: other-openal-impl load-wav-file ( filename -- format data size frequency )
  0 <int> f <void*> 0 <int> 0 <int>
  [ 0 <char> alutLoadWAVFile ] 4keep
  >r >r >r *int r> *void* r> *int r> *int ;
