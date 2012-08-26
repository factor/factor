! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.data alien.strings
alien.syntax kernel layouts sequences system unix
environment io.encodings.utf8 unix.utilities vocabs
combinators alien.accessors unix.ffi ;
IN: environment.unix

HOOK: environ os ( -- void* )

M: unix environ ( -- void* ) &: environ ;

M: unix os-env ( key -- value ) getenv ;

M: unix set-os-env ( value key -- ) swap 1 setenv io-error ;

M: unix unset-os-env ( key -- ) unsetenv io-error ;

M: unix (os-envs) ( -- seq )
    environ void* deref utf8 alien>strings ;

: set-void* ( value alien -- ) 0 set-alien-cell ;

M: unix set-os-envs-pointer ( malloc -- ) environ set-void* ;

M: unix (set-os-envs) ( seq -- )
    utf8 strings>alien malloc-byte-array set-os-envs-pointer ;

os {
    { macosx [ "environment.unix.macosx" require ] }
    [ drop ]
} case
