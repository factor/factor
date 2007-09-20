! Copyright (C) 2007 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: continuations kernel namespaces sequences vectors ;
IN: destructors

SYMBOL: destructors
SYMBOL: errored?
TUPLE: destructor obj quot always? ;

<PRIVATE

: filter-destructors ( -- )
    errored? get [
        destructors [ [ destructor-always? ] subset ] change
    ] unless ;

PRIVATE>

: add-destructor ( obj quot always? -- )
    \ destructor construct-boa destructors [ ?push ] change ;

: call-destructors ( -- )
    destructors get [
        dup destructor-obj swap destructor-quot call
    ] each ;

: with-destructors ( quot -- )
    [
        [ call ] [ errored? on ] recover
        filter-destructors call-destructors
        errored? get [ rethrow ] when
    ] with-scope ; inline



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

