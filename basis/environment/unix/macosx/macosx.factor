! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax system environment.unix ;
IN: environment.unix.macosx

FUNCTION: void* _NSGetEnviron ( )

M: macosx environ _NSGetEnviron ;
