! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.accessors alien.c-types alien.data alien.strings
alien.syntax alien.utilities environment io.encodings.utf8
kernel libc system unix.ffi vocabs ;
IN: environment.unix

HOOK: environ os ( -- void* )

M: unix environ &: environ ;

M: unix os-env getenv ;

M: unix set-os-env
    over [
        swap 1 setenv io-error
    ] [
        nip unset-os-env
    ] if ;

M: unix unset-os-env unsetenv io-error ;

M: unix (os-envs)
    environ void* deref native-string-encoding alien>strings ;

: set-void* ( value alien -- ) 0 set-alien-cell ;

M: unix set-os-envs-pointer environ set-void* ;

M: unix (set-os-envs)
    utf8 strings>alien malloc-byte-array set-os-envs-pointer ;

os macosx? [ "environment.unix.macosx" require ] when
