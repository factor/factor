! Copyright (C) 2004, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: continuations continuations.private kernel
kernel.private sequences assocs namespaces namespaces.private
continuations continuations.private ;
IN: init

SYMBOL: init-hooks

init-hooks global [ drop V{ } clone ] cache drop

: do-init-hooks ( -- )
    init-hooks get [ nip call( -- ) ] assoc-each ;

: add-init-hook ( quot name -- )
    dup init-hooks get at [ over call( -- ) ] unless
    init-hooks get set-at ;

: boot ( -- ) init-namespaces init-catchstack init-error-handler ;

: boot-quot ( -- quot ) 20 getenv ;

: set-boot-quot ( quot -- ) 20 setenv ;
