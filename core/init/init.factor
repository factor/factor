! Copyright (C) 2004, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: continuations continuations.private kernel
kernel.private sequences assocs namespaces namespaces.private ;
IN: init

SYMBOL: startup-hooks
SYMBOL: shutdown-hooks

startup-hooks global [ drop V{ } clone ] cache drop
shutdown-hooks global [ drop V{ } clone ] cache drop

: do-hooks ( symbol -- )
    get [ nip call( -- ) ] assoc-each ;

: do-startup-hooks ( -- ) startup-hooks do-hooks ;

: do-shutdown-hooks ( -- ) shutdown-hooks do-hooks ;

: add-startup-hook ( quot name -- )
    startup-hooks get
    [ at [ drop ] [ call( -- ) ] if ]
    [ set-at ] 3bi ;

: add-shutdown-hook ( quot name -- )
    shutdown-hooks get set-at ;

: boot ( -- ) init-namespaces init-catchstack init-error-handler ;

: startup-quot ( -- quot ) OBJ-STARTUP-QUOT special-object ;

: set-startup-quot ( quot -- ) OBJ-STARTUP-QUOT set-special-object ;

: shutdown-quot ( -- quot ) OBJ-SHUTDOWN-QUOT special-object ;

: set-shutdown-quot ( quot -- ) OBJ-SHUTDOWN-QUOT set-special-object ;

[ do-shutdown-hooks ] set-shutdown-quot
