IN: objc
USING: alien arrays errors hashtables inference kernel math
namespaces parser sequences strings words ;

: make-alien-invoke [ ] make \ alien-invoke add ; inline

: make-sender ( method function -- quot )
    [ over first , f , , second , ] make-alien-invoke ;

: make-sender-stret ( method function -- quot )
    [
        [ "void" f ] %
        "_stret" append ,
        { "void*" } swap second append ,
    ] make-alien-invoke ;

: sender-stub ( method function -- word )
    over first c-struct?
    [ make-sender-stret ] [ make-sender ] if
    define-temp ;

SYMBOL: msg-senders
H{ } clone msg-senders set-global

SYMBOL: super-msg-senders
H{ } clone super-msg-senders set-global

: (cache-stub) ( method function hash -- word )
    [
        over second get dup [
            2nip
        ] [
            drop over >r sender-stub dup r> second set
        ] if
    ] bind ;

: cache-stub ( method super? -- word )
    [ "objc_msgSendSuper" "objc_msgSend" ? ] keep
    super-msg-senders msg-senders ? get
    (cache-stub) ;

: <super> ( receiver -- super )
    "objc-super" <c-object> [
        >r dup objc-object-isa objc-class-super-class r>
        set-objc-super-class
    ] keep
    [ set-objc-super-receiver ] keep ;

: make-stret-quot ( returns -- quot )
    [ <c-object> dup ] curry 1 make-dip ;

TUPLE: selector name object ;

C: selector ( name -- sel ) [ set-selector-name ] keep ;

: selector ( selector -- alien )
    dup selector-object expired? [
        dup selector-name sel_registerName
        dup rot set-selector-object
    ] [
        selector-object
    ] if ;

SYMBOL: selectors

H{ } clone selectors set-global

: cache-selector selectors get-global [ <selector> ] cache ;

SYMBOL: objc-methods
H{ } clone objc-methods set-global

: lookup-method ( selector -- method )
    dup objc-methods get hash
    [ ] [ "No such method: " swap append throw ] ?if ;

: (make-prepare-send) ( selector method -- quot )
    [
        [ \ <super> , ] when
        dup first c-struct? [ make-stret-quot % ] [ drop ] if
        cache-selector , \ selector ,
    ] [ ] make ;

: make-prepare-send ( selector method super? -- quot )
    over second length 2 - >r (make-prepare-send) r> make-dip ;

: make-objc-send ( selector super? -- quot )
    >r dup lookup-method r> 2dup cache-stub >r
    make-prepare-send r> add ;

: infer-send ( super? -- )
    pop-literal rot make-objc-send infer-quot-value ;

: compile-send-error
    "Objective C message sends must be compiled" throw ;

: send ( ... selector -- ... ) compile-send-error ;

\ send [ f infer-send ] "infer" set-word-prop

: -> scan parsed \ send parsed ; parsing

: super-send ( ... selector -- ... ) compile-send-error ;

\ super-send [ t infer-send ] "infer" set-word-prop

: SUPER-> scan parsed \ super-send parsed ; parsing

! Runtime introspection
: (objc-class) ( string word -- class )
    dupd execute
    [ ] [ "No such class: " swap append throw ] ?if ; inline

: objc-class ( string -- class )
    \ objc_getClass (objc-class) ;

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

objc>alien-types get hash>alist [ reverse ] map alist>hash
! A hack...
H{
    { "NSPoint" "{_NSPoint=ff}" }
    { "NSRect" "{_NSRect=ffff}" }
    { "NSSize" "{_NSSize=ff}" }
} hash-union alien>objc-types set-global

: objc-struct-type ( i string -- ctype )
    2dup CHAR: = -rot index* swap subseq ;

: (parse-objc-type) ( i string -- ctype )
    2dup nth >r >r 1+ r> r> {
        { [ dup "rnNoORV" member? ] [ drop (parse-objc-type) ] }
        { [ dup CHAR: ^ = ] [ 3drop "void*" ] }
        { [ dup CHAR: { = ] [ drop objc-struct-type ] }
        { [ dup CHAR: [ = ] [ 3drop "void*" ] }
        { [ t ] [ 2nip ch>string objc>alien-types get hash ] }
    } cond ;

: parse-objc-type ( string -- ctype ) 0 swap (parse-objc-type) ;

: method-arg-types ( method -- args )
    dup method_getNumberOfArguments
    [ method-arg-type parse-objc-type ] map-with ;

: method-return-type ( method -- ctype )
    #! Undocumented hack! Apple does not support this feature!
    objc-method-types parse-objc-type ;

: register-objc-method ( method -- )
    dup method-return-type over method-arg-types 2array
    swap objc-method-name sel_getName
    objc-methods get set-hash ;

: method-list@ ( ptr -- ptr )
    "objc-method-list" c-size swap <displaced-alien> ;

: (register-objc-methods) ( objc-class iterator -- )
    2dup class_nextMethodList [
        dup method-list@ swap objc-method-list-count [
            swap objc-method-nth register-objc-method
        ] each-with (register-objc-methods)
    ] [
        2drop
    ] if* ;

: register-objc-methods ( class -- seq )
    f <void*> (register-objc-methods) ;

: class-exists? ( string -- class ) objc_getClass >boolean ;

: unless-defined ( class quot -- )
    >r class-exists? r> unless ; inline

: define-objc-class-word ( name quot -- )
    [
        over , , \ unless-defined , dup , \ objc-class ,
    ] [ ] make >r "objc-classes" create r> define-compound ;

: import-objc-class ( name quot -- )
    #! The quotation is prepended to the class word. It should
    #! "regenerate" the class as appropriate (by loading a
    #! framework or defining the class in some manner).
    2dup unless-defined
    dupd define-objc-class-word
    dup objc-class register-objc-methods
    objc-meta-class register-objc-methods ;

: root-class ( class -- class )
    dup objc-class-super-class [ root-class ] [ ] ?if ;
