! Copyright (C) 2007 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: continuations io.backend libc kernel namespaces
sequences system vectors ;
IN: destructors

SYMBOL: destructors

TUPLE: destructor obj always? destroyed? ;

: <destructor> ( obj always? -- newobj )
    {
        set-destructor-obj
        set-destructor-always?
    } destructor construct ;

: push-destructor ( obj -- )
    destructors [ ?push ] change ;

GENERIC: (destruct) ( obj -- )

: destruct ( obj -- )
    dup destructor-destroyed? [
        drop
    ] [
        [ (destruct) t ] keep set-destructor-destroyed?
    ] if ;

: destruct-always ( destructor -- )
    dup destructor-always? [
        destruct
    ] [
        drop
    ] if ;

: with-destructors ( quot -- )
    [
        [ call ]
        [ destructors get [ destruct-always ] each ]
        [ destructors get [ destruct ] each ] cleanup
    ] with-scope ; inline



TUPLE: memory-destructor ;

: <memory-destructor> ( obj ? -- newobj )
    <destructor> memory-destructor construct-delegate ;

TUPLE: handle-destructor ;

: <handle-destructor> ( obj ? -- newobj )
    <destructor> handle-destructor construct-delegate ;

TUPLE: socket-destructor ;

: <socket-destructor> ( obj ? -- newobj )
    <destructor> socket-destructor construct-delegate ;

M: memory-destructor (destruct) ( obj -- )
    destructor-obj free ;

HOOK: (handle-destructor) io-backend ( obj -- )
HOOK: (socket-destructor) io-backend ( obj -- )

M: handle-destructor (destruct) ( obj -- ) (handle-destructor) ;
M: socket-destructor (destruct) ( obj -- ) (socket-destructor) ;

: free-always ( alien -- )
    t <memory-destructor> push-destructor ;

: free-later ( alien -- )
    f <memory-destructor> push-destructor ;

: close-always ( handle -- )
    t <handle-destructor> push-destructor ;

: close-later ( handle -- )
    f <handle-destructor> push-destructor ;

: close-socket-always ( handle -- )
    t <socket-destructor> push-destructor ;

: close-socket-later ( handle -- )
    f <socket-destructor> push-destructor ;

USE-IF: windows? destructors.windows
USE-IF: unix? destructors.unix



! : add-destructor ( word quot -- )
    ! >quotation
    ! "slot-destructor" set-word-prop ;

! MACRO: destruct ( class -- )
    ! "slots" word-prop
    ! [ slot-spec-reader "slot-destructor" word-prop ] subset
    ! [
        ! [
            ! slot-spec-reader [ 1quotation ] keep
            ! "slot-destructor" word-prop [ when* ] curry compose
            ! [ keep f swap ] curry
        ! ] keep slot-spec-writer 1quotation compose
        ! dupd curry
    ! ] map concat nip ;

! : DTOR: scan-word parse-definition add-destructor ; parsing

! : free-destructor ( word -- )
    ! [ free ] add-destructor ;

! : stream-destructor ( word -- )
    ! [ stream-close ] add-destructor ;


! TUPLE: foo a b c ;
! C: <foo> foo

! DTOR: foo-a "lol, a destructor" print drop ;
! DTOR: foo-b "lol, b destructor" print drop ;

! TUPLE: stuff mem stream ;
! : <stuff>
    ! 100 malloc
    ! "license.txt" resource-path <file-reader>
    ! \ stuff construct-boa ;

! DTOR: stuff-mem free-destructor ;
! DTOR: stuff-stream stream-destructor ;

