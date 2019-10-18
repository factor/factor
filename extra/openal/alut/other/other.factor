! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax combinators generalizations
kernel openal openal.alut.backend ;
IN: openal.alut.other

LIBRARY: alut

FUNCTION: void alutLoadWAVFile ( c-string fileName, ALenum* format, void** data, ALsizei* size, ALsizei* frequency, ALboolean* looping ) ;

M: object load-wav-file ( filename -- format data size frequency )
    0 <int> f <void*> 0 <int> 0 <int>
    [ 0 <char> alutLoadWAVFile ] 4 nkeep
    { [ *int ] [ *void* ] [ *int ] [ *int ] } spread ;
