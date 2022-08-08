! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.data alien.syntax kernel openal
openal.alut.backend system ;
IN: openal.alut.macosx

LIBRARY: alut

FUNCTION: void alutLoadWAVFile ( c-string fileName, ALenum* format, void** data, ALsizei* size, ALsizei* frequency )

M: macosx load-wav-file ( path -- format data size frequency )
    0 int <ref> f void* <ref> 0 int <ref> 0 int <ref>
    [ alutLoadWAVFile ] 4keep
    [ [ [ int deref ] dip void* deref ] dip int deref ] dip int deref ;
