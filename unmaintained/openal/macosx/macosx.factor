! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types kernel alien alien.syntax shuffle
combinators.lib openal.backend namespaces system ;
IN: openal.macosx

LIBRARY: alut

FUNCTION: void alutLoadWAVFile ( ALbyte* fileName, ALenum* format, void** data, ALsizei* size, ALsizei* frequency ) ;

M: macosx load-wav-file ( path -- format data size frequency )
    0 <int> f <void*> 0 <int> 0 <int>
    [ alutLoadWAVFile ] 4keep
    [ [ [ *int ] dip *void* ] dip *int ] dip *int ;
