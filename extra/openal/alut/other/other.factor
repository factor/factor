! Copyright (C) 2007 Chris Double.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.data alien.syntax combinators
kernel openal openal.alut.backend ;
IN: openal.alut.other

LIBRARY: alut

FUNCTION: void alutLoadWAVFile ( c-string fileName, ALenum* format, void** data, ALsizei* size, ALsizei* frequency, ALboolean* looping )

M: object load-wav-file ( filename -- format data size frequency )
    0 int <ref>
    f void* <ref>
    0 int <ref>
    0 int <ref>
    [ 0 char <ref> alutLoadWAVFile ] 4keep
    { [ int deref ] [ void* deref ] [ int deref ] [ int deref ] } spread ;
