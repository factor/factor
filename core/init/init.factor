! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: continuations continuations.private kernel
kernel.private sequences assocs namespaces namespaces.private ;
IN: init

SYMBOL: startup-hooks

startup-hooks global [ drop V{ } clone ] cache drop

: do-startup-hooks ( -- )
    startup-hooks get [ nip call ] assoc-each ;

: add-startup-hook ( quot name -- )
    over call startup-hooks get set-at ;

: boot ( -- ) init-namespaces init-error-handler ;

: boot-quot ( -- quot ) 8 getenv ;

: set-boot-quot ( quot -- ) 8 setenv ;
