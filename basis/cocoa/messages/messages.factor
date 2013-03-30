! Copyright (C) 2006, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data alien.strings
arrays assocs classes.struct continuations combinators compiler
core-graphics.types stack-checker kernel math namespaces make
quotations sequences strings words cocoa.runtime cocoa.types io
macros memoize io.encodings.utf8 effects layouts libc lexer init
core-foundation fry generalizations specialized-arrays locals ;
QUALIFIED-WITH: alien.c-types c
IN: cocoa.messages

SPECIALIZED-ARRAY: void*

: make-sender ( signature function -- quot )
    [ over first , f , , second , \ alien-invoke , ] [ ] make ;

: sender-stub ( name signature function -- word )
    [ "( sender-stub:" ")" surround f <word> dup ] 2dip
    over first large-struct? [ "_stret" append ] when
    make-sender dup infer define-declared ;

SYMBOL: message-senders
SYMBOL: super-message-senders

message-senders [ H{ } clone ] initialize
super-message-senders [ H{ } clone ] initialize

:: cache-stub ( name signature function assoc -- )
    signature assoc [ [ name ] dip function sender-stub ] cache drop ;

: cache-stubs ( name signature -- )
    [ "objc_msgSendSuper" super-message-senders get cache-stub ]
    [ "objc_msgSend" message-senders get cache-stub ]
    2bi ;

: <super> ( receiver -- super )
    [ ] [ object_getClass class_getSuperclass ] bi
    objc-super <struct-boa> ;

TUPLE: selector-tuple name object ;

MEMO: <selector> ( name -- sel ) f \ selector-tuple boa ;

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

: ?lookup-method ( selector -- method/f )
    objc-methods get at ;

: lookup-method ( selector -- method )
    dup ?lookup-method [ ] [ no-objc-method ] ?if ;

: lookup-sender ( name -- method )
    lookup-method message-senders get at ;

MEMO: make-prepare-send ( selector method super? -- quot )
    [
        [ \ <super> , ] when swap <selector> , \ selector ,
    ] [ ] make
    swap second length 2 - '[ _ _ ndip ] ;

MACRO: (send) ( selector super? -- quot )
    [ dup lookup-method ] dip
    [ make-prepare-send ] 2keep
    super-message-senders message-senders ? get at
    1quotation append ;

: send ( receiver args... selector -- return... ) f (send) ; inline

: super-send ( receiver args... selector -- return... ) t (send) ; inline

! Runtime introspection
SYMBOL: class-init-hooks

class-init-hooks [ H{ } clone ] initialize

: (objc-class) ( name word -- class )
    2dup execute dup [ 2nip ] [
        drop over class-init-hooks get at [ call( -- ) ] when*
        2dup execute dup [ 2nip ] [
            2drop "No such class: " prepend throw
        ] if
    ] if ; inline

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
    1string dup objc>alien-types get at
    [ ] [ no-objc-type ] ?if ;

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
    dup method_getNumberOfArguments iota
    [ method-arg-type ] with map ;

: method-return-type ( method -- ctype )
    method_copyReturnType
    [ utf8 alien>string parse-objc-type ] keep
    (free) ;

: method-name ( method -- name )
    method_getName sel_getName ;

: register-objc-method ( method -- )
    [ method-name ]
    [ [ method-return-type ] [ method-arg-types ] bi 2array ] bi
    [ cache-stubs ] [ swap objc-methods get set-at ] 2bi ;

: each-method-in-class ( class quot -- )
    [ { uint } [ class_copyMethodList ] with-out-parameters ] dip
    over 0 = [ 3drop ] [
        [ void* <c-direct-array> ] dip
        [ each ] [ drop (free) ] 2bi
    ] if ; inline

: register-objc-methods ( class -- )
    [ register-objc-method ] each-method-in-class ;

: class-exists? ( string -- class ) objc_getClass >boolean ;

: define-objc-class-word ( quot name -- )
    [ class-init-hooks get set-at ]
    [
        [ "cocoa.classes" create ] [ '[ _ objc-class ] ] bi
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
    dup class_getSuperclass [ root-class ] [ ] ?if ;
