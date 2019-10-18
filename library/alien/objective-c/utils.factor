! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: objective-c
USING: alien arrays kernel lists namespaces parser sequences
words ;

TUPLE: selector name object ;

C: selector ( name -- sel ) [ set-selector-name ] keep ;

: selector-valid? ( selector -- ? )
    selector-object dup [ expired? not ] when ;

: selector ( selector -- alien )
    dup selector-valid? [
        selector-object
    ] [
        dup selector-name sel_registerName
        dup rot set-selector-object
    ] if ;

: objc-classes ( -- seq )
    f 0 objc_getClassList
    [ "void*" <c-array> dup ] keep objc_getClassList
    [ swap void*-nth objc-class-name ] map-with ;

: method-list>seq ( method-list -- seq )
    dup objc-method-list-elements swap objc-method-list-count [
        swap objc-method-nth objc-method-name sel_getName
    ] map-with ;

: (objc-methods) ( objc-class iterator -- )
    2dup class_nextMethodList [
        method-list>seq % (objc-methods)
    ] [
        2drop
    ] if* ;

: objc-methods ( class -- seq )
    [ objc_getClass f <void*> (objc-methods) ] { } make ;

: make-dip ( quot n -- quot )
    dup \ >r <array> -rot \ r> <array> append3 ;

: make-msg-send ( returns args selector -- )
    <selector> [ selector ] curry over length make-dip [
        %
        swap ,
        [ f "objc_msgSend" ] % 
        [ "id" "SEL" ] swap append ,
        \ alien-invoke ,
    ] [ ] make ;

: define-msg-send ( returns types selector -- )
    [ make-msg-send "[" ] keep "]" append3 create-in
    swap define-compound ;

: msg-send-args ( args -- types selector )
    dup length 1 =
    [ first { } ] [ unpair >r concat r> ] if swap ;
