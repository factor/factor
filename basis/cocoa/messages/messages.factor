! Copyright (C) 2006, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data alien.strings
arrays assocs classes.struct cocoa.runtime cocoa.types
combinators continuations core-graphics.types destructors
generalizations io io.encodings.utf8 kernel layouts libc make math
math.parser namespaces sequences sets specialized-arrays
splitting stack-checker strings words ;
QUALIFIED-WITH: alien.c-types c
IN: cocoa.messages

SPECIALIZED-ARRAY: void*

: make-sender ( signature function -- quot )
    [ over first , f , , second , f , \ alien-invoke , ] [ ] make ;

: sender-stub-name ( signature -- str )
    first2 [ name>> ] [
        [ name>> ] map "," join "(" ")" surround
    ] bi* append "( sender-stub:" " )" surround ;

: sender-stub ( signature function -- word )
    [ [ sender-stub-name f <word> dup ] keep ] dip
    over first large-struct? [ "_stret" append ] when
    make-sender dup infer define-declared ;

SYMBOL: message-senders
SYMBOL: super-message-senders

message-senders [ H{ } clone ] initialize
super-message-senders [ H{ } clone ] initialize

:: cache-stub ( signature function assoc -- )
    signature assoc [ function sender-stub ] cache drop ;

: cache-stubs ( signature -- )
    [ "objc_msgSendSuper" super-message-senders get cache-stub ]
    [ "objc_msgSend" message-senders get cache-stub ]
    bi ;

: <super> ( receiver -- super )
    [ ] [ object_getClass class_getSuperclass ] bi
    objc-super boa ;

TUPLE: selector-tuple name object ;

: selector-name ( name -- name' )
    CHAR: . over index [ 0 > [ "." split1 nip ] when ] when* ;

MEMO: <selector> ( name -- sel )
    selector-name f selector-tuple boa ;

: selector ( selector -- alien )
    dup object>> expired? [
        dup name>> sel_registerName
        [ >>object drop ] keep
    ] [
        object>>
    ] if ;

: lookup-selector ( name -- alien )
    <selector> selector ;

SYMBOL: objc-methods

objc-methods [ H{ } clone ] initialize

ERROR: no-objc-method name ;

: ?lookup-objc-method ( name -- signature/f )
    objc-methods get at ;

: lookup-objc-method ( name -- signature )
    [ ?lookup-objc-method ] [ no-objc-method ] ?unless ;

MEMO: make-prepare-send ( selector signature super? -- quot )
    [
        [ \ <super> , ] when swap <selector> , \ selector ,
    ] [ ] make swap second length 2 - '[ _ _ ndip ] ;

MACRO: (send) ( signature selector super? -- quot )
    swapd [ make-prepare-send ] 2keep
    super-message-senders message-senders ? get at suffix ;

: send ( receiver args... signature selector -- return... ) f (send) ; inline

: super-send ( receiver args... signature selector -- return... ) t (send) ; inline

! Runtime introspection
SYMBOL: class-init-hooks

class-init-hooks [ H{ } clone ] initialize

: (objc-class) ( name word -- class )
    2dup execute [ 2nip ] [
        over class-init-hooks get at [ call( -- ) ] when*
        2dup execute [ 2nip ] [
            drop "No such class: " prepend throw
        ] if*
    ] if* ; inline

: objc-class ( string -- class )
    \ objc_getClass (objc-class) ;

: objc-protocol ( string -- class )
    \ objc_getProtocol (objc-class) ;

: objc-meta-class ( string -- class )
    \ objc_getMetaClass (objc-class) ;

SYMBOL: objc>alien-types

H{
    { "c" c:char }
    { "i" c:int }
    { "s" c:short }
    { "C" c:uchar }
    { "I" c:uint }
    { "S" c:ushort }
    { "f" c:float }
    { "d" c:double }
    { "B" c:bool }
    { "v" c:void }
    { "*" c:void* }
    { "?" unknown_type }
    { "@" id }
    { "#" Class }
    { ":" SEL }
    { "(" c:void* }
}
cell {
    { 4 [ H{
        { "l" c:long }
        { "q" c:longlong }
        { "L" c:ulong }
        { "Q" c:ulonglong }
    } ] }
    { 8 [ H{
        { "l" long32 }
        { "q" long }
        { "L" ulong32 }
        { "Q" ulong }
    } ] }
} case
assoc-union objc>alien-types set-global

SYMBOL: objc>struct-types

H{
    { "_NSPoint" NSPoint }
    { "NSPoint"  NSPoint }
    { "CGPoint"  NSPoint }
    { "_NSRect"  NSRect  }
    { "NSRect"   NSRect  }
    { "CGRect"   NSRect  }
    { "_NSSize"  NSSize  }
    { "NSSize"   NSSize  }
    { "CGSize"   NSSize  }
    { "_NSRange" NSRange }
    { "NSRange"  NSRange }
} objc>struct-types set-global

! The transpose of the above map
SYMBOL: alien>objc-types

objc>alien-types get [ swap ] assoc-map
! A hack...
cell {
    { 4 [ H{
        { NSPoint    "{_NSPoint=ff}" }
        { NSRect     "{_NSRect={_NSPoint=ff}{_NSSize=ff}}" }
        { NSSize     "{_NSSize=ff}" }
        { NSRange    "{_NSRange=II}" }
        { NSInteger  "i" }
        { NSUInteger "I" }
        { CGFloat    "f" }
    } ] }
    { 8 [ H{
        { NSPoint    "{CGPoint=dd}" }
        { NSRect     "{CGRect={CGPoint=dd}{CGSize=dd}}" }
        { NSSize     "{CGSize=dd}" }
        { NSRange    "{_NSRange=QQ}" }
        { NSInteger  "q" }
        { NSUInteger "Q" }
        { CGFloat    "d" }
    } ] }
} case
assoc-union alien>objc-types set-global

: objc-struct-type ( i string -- ctype )
    [ CHAR: = ] 2keep index-from swap subseq
    objc>struct-types get at* [ drop void* ] unless ;

ERROR: no-objc-type name ;

: decode-type ( ch -- ctype )
    1string
    [ objc>alien-types get at ] [ no-objc-type ] ?unless ;

: (parse-objc-type) ( i string -- ctype )
    [ [ 1 + ] dip ] [ nth ] 2bi {
        { [ dup "rnNoORV" member? ] [ drop (parse-objc-type) ] }
        { [ dup CHAR: ^ = ] [ 3drop void* ] }
        { [ dup CHAR: { = ] [ drop objc-struct-type ] }
        { [ dup CHAR: [ = ] [ 3drop void* ] }
        [ 2nip decode-type ]
    } cond ;

: parse-objc-type ( string -- ctype ) 0 swap (parse-objc-type) ;

: method-arg-type ( method i -- type )
    method_copyArgumentType
    [ utf8 alien>string parse-objc-type ] keep
    (free) ;

: method-arg-types ( method -- args )
    dup method_getNumberOfArguments <iota>
    [ method-arg-type ] with map ;

: method-return-type ( method -- ctype )
    method_copyReturnType [ utf8 alien>string ] [ (free) ] bi ;

: method-return-type-parsed ( method -- ctype/f )
    method-return-type
    [ parse-objc-type ] [ 2drop f ] recover ;

: method-signature ( method -- signature )
    [ method-return-type-parsed ] [ method-arg-types ] bi 2array ;

: method-name ( method -- name )
    method_getName sel_getName ;

: warn-unknown-objc-method ( classname method-name method -- )
    '[
        _ write bl
        _ "`" dup surround write bl
        "has unknown method-return-type:" write bl
        _ method-return-type print
    ] with-output>error ;

:: register-objc-method ( classname method -- )
    method method-signature :> signature
    method method-name :> name
    classname "." name 3append :> fullname
    signature first [
        signature cache-stubs
        signature name objc-methods get set-at
        signature fullname objc-methods get set-at
    ] [
        classname name method warn-unknown-objc-method
    ] if ;

: method-collisions ( -- collisions )
    objc-methods get >alist
    [ first CHAR: . swap member? ] filter
    [ first "." split1 nip ] collect-by
    [ values members length 1 > ] filter-values ;

: method-count ( class -- c-direct-array )
    0 uint <ref> [ class_copyMethodList (free) ] keep uint deref ;

: each-method-in-class ( class quot: ( classname method -- ) -- )
    [
        [ class_getName ] keep
        0 uint <ref> [ class_copyMethodList ] keep uint deref
    ] dip over 0 = [ 4drop ] [
        [ void* <c-direct-array> ] dip
        [ with each ] [ drop (free) ] 2bi
    ] if ; inline

: register-objc-methods ( class -- )
    [ register-objc-method ] each-method-in-class ;

: class-exists? ( string -- class ) objc_getClass >boolean ;

: define-objc-class-word ( quot name -- )
    [ class-init-hooks get set-at ]
    [
        [ "cocoa.classes" create-word ] [ '[ _ objc-class ] ] bi
        ( -- class ) define-declared
    ] bi ;

: import-objc-class ( name quot -- )
    2dup swap define-objc-class-word
    over class-exists? [ drop ] [ call( -- ) ] if
    dup class-exists? [
        [ objc_getClass register-objc-methods ]
        [ objc_getMetaClass register-objc-methods ] bi
    ] [ drop ] if ;

: root-class ( class -- root )
    [ class_getSuperclass ] [ root-class ] ?when ;

: objc-class-names ( -- seq )
    [
        f 0 objc_getClassList
        [ Class heap-size * malloc &free ] keep
        dupd objc_getClassList void* <c-direct-array>
        [ class_getName ] { } map-as
    ] with-destructors ;
