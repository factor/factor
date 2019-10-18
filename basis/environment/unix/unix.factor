! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.accessors alien.c-types alien.data alien.strings
alien.syntax environment io.encodings.utf8 kernel libc system unix.ffi
unix.utilities vocabs ;
IN: environment.unix

HOOK: environ os ( -- void* )

M: unix environ ( -- void* ) &: environ ;

M: unix os-env ( key -- value ) getenv ;

M: unix set-os-env ( value key -- )
    over [
        swap 1 setenv io-error
    ] [
        nip unset-os-env
    ] if ;

M: unix unset-os-env ( key -- ) unsetenv io-error ;

M: unix (os-envs) ( -- seq )
    environ void* deref native-string-encoding alien>strings ;

: set-void* ( value alien -- ) 0 set-alien-cell ;

M: unix set-os-envs-pointer ( malloc -- ) environ set-void* ;

M: unix (set-os-envs) ( seq -- )
    utf8 strings>alien malloc-byte-array set-os-envs-pointer ;

os macosx? [ "environment.unix.macosx" require ] when
