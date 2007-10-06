! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.compiler
arrays assocs combinators compiler inference.transforms kernel
math namespaces parser prettyprint prettyprint.sections
quotations sequences strings words cocoa.runtime io macros
memoize ;
IN: cocoa.messages

: make-sender ( method function -- quot )
    [ over first , f , , second , \ alien-invoke , ] [ ] make ;

: sender-stub-name ( method function -- string )
    [ % "_" % unparse % ] "" make ;

: sender-stub ( method function -- word )
    [ sender-stub-name f <word> dup ] 2keep
    over first large-struct? [ "_stret" append ] when
    make-sender define-compound dup compile ;

SYMBOL: message-senders
SYMBOL: super-message-senders

message-senders global [ H{ } assoc-like ] change-at
super-message-senders global [ H{ } assoc-like ] change-at

: cache-stub ( method function hash -- )
    [
        over get [ 2drop ] [ over >r sender-stub r> set ] if
    ] bind ;

: cache-stubs ( method -- )
    dup
    "objc_msgSendSuper" super-message-senders get cache-stub
    "objc_msgSend" message-senders get cache-stub ;

: <super> ( receiver -- super )
    "objc-super" <c-object> [
        >r dup objc-object-isa objc-class-super-class r>
        set-objc-super-class
    ] keep
    [ set-objc-super-receiver ] keep ;

TUPLE: selector name object ;

: <selector> ( name -- sel ) f \ selector construct-boa ;

: selector ( selector -- alien )
    dup selector-object expired? [
        dup selector-name sel_registerName
        dup rot set-selector-object
    ] [
        selector-object
    ] if ;

SYMBOL: selectors

selectors global [ H{ } assoc-like ] change-at

: cache-selector ( string -- selector )
    selectors get-global [ <selector> ] cache ;

SYMBOL: objc-methods

objc-methods global [ H{ } assoc-like ] change-at

: lookup-method ( selector -- method )
    dup objc-methods get at
    [ ] [ "No such method: " swap append throw ] ?if ;

: make-dip ( quot n -- quot' )
    dup
    \ >r <repetition> >quotation -rot
    \ r> <repetition> >quotation 3append ;

MEMO: make-prepare-send ( selector method super? -- quot )
    [
        [ \ <super> , ] when
        swap cache-selector , \ selector ,
    ] [ ] make
    swap second length 2 - make-dip ;

MACRO: (send) ( selector super? -- quot )
    >r dup lookup-method r>
    [ make-prepare-send ] 2keep
    super-message-senders message-senders ? get at
    [ slip execute ] 2curry ;

: send ( args... receiver selector -- return... ) f (send) ; inline

\ send soft "break-after" set-word-prop

: super-send ( args... receiver selector -- return... ) t (send) ; inline

\ super-send soft "break-after" set-word-prop

! Runtime introspection
: (objc-class) ( string word -- class )
    dupd execute
    [ ] [ "No such class: " swap append throw ] ?if ; inline

: objc-class ( string -- class )
    \ objc_getClass (objc-class) ;

: objc-protocol ( string -- class )
    \ objc_getProtocol (objc-class) ;

: objc-meta-class ( string -- class )
    \ objc_getMetaClass (objc-class) ;

: method-arg-type ( method i -- type )
    f <void*> 0 <int> over
    >r method_getArgumentInfo drop
    r> *char* ;

SYMBOL: objc>alien-types

H{
    { "c" "char" }
    { "i" "int" }
    { "s" "short" }
    { "l" "long" }
    { "q" "longlong" }
    { "C" "uchar" }
    { "I" "uint" }
    { "S" "ushort" }
    { "L" "ulong" }
    { "Q" "ulonglong" }
    { "f" "float" }
    { "d" "double" }
    { "B" "bool" }
    { "v" "void" }
    { "*" "char*" }
    { "@" "id" }
    { "#" "id" }
    { ":" "SEL" }
} objc>alien-types set-global

! The transpose of the above map
SYMBOL: alien>objc-types

objc>alien-types get [ swap ] assoc-map
! A hack...
H{
    { "NSPoint" "{_NSPoint=ff}" }
    { "NSRect" "{_NSRect=ffff}" }
    { "NSSize" "{_NSSize=ff}" }
    { "NSRange" "{_NSRange=II}" }
} union alien>objc-types set-global

: objc-struct-type ( i string -- ctype )
    2dup CHAR: = -rot index* swap subseq
    dup c-types get key? [
        "Warning: no such C type: " write dup print
        drop "void*"
    ] unless ;

: (parse-objc-type) ( i string -- ctype )
    2dup nth >r >r 1+ r> r> {
        { [ dup "rnNoORV" member? ] [ drop (parse-objc-type) ] }
        { [ dup CHAR: ^ = ] [ 3drop "void*" ] }
        { [ dup CHAR: { = ] [ drop objc-struct-type ] }
        { [ dup CHAR: [ = ] [ 3drop "void*" ] }
        { [ t ] [ 2nip 1string objc>alien-types get at ] }
    } cond ;

: parse-objc-type ( string -- ctype ) 0 swap (parse-objc-type) ;

: method-arg-types ( method -- args )
    dup method_getNumberOfArguments
    [ method-arg-type parse-objc-type ] curry* map ;

: method-return-type ( method -- ctype )
    #! Undocumented hack! Apple does not support this feature!
    objc-method-types parse-objc-type ;

: register-objc-method ( method -- )
    dup method-return-type over method-arg-types 2array
    dup cache-stubs
    swap objc-method-name sel_getName
    objc-methods get set-at ;

: method-list@ ( ptr -- ptr )
    "objc-method-list" heap-size swap <displaced-alien> ;

: (register-objc-methods) ( objc-class iterator -- )
    2dup class_nextMethodList [
        dup objc-method-list-count swap method-list@ [
            objc-method-nth register-objc-method
        ] curry each (register-objc-methods)
    ] [
        2drop
    ] if* ;

: register-objc-methods ( class -- )
    f <void*> (register-objc-methods) ;

: class-exists? ( string -- class ) objc_getClass >boolean ;

: unless-defined ( class quot -- )
    >r class-exists? r> unless ; inline

: define-objc-class-word ( name quot -- )
    [
        over , , \ unless-defined , dup , \ objc-class ,
    ] [ ] make >r "cocoa.classes" create r> define-compound ;

: import-objc-class ( name quot -- )
    2dup unless-defined
    dupd define-objc-class-word
    dup objc-class register-objc-methods
    objc-meta-class register-objc-methods ;

: root-class ( class -- root )
    dup objc-class-super-class [ root-class ] [ ] ?if ;
