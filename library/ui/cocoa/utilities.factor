! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: objc
USING: alien arrays errors hashtables kernel math
namespaces parser sequences strings words ;

TUPLE: selector name object ;

C: selector ( name -- sel ) [ set-selector-name ] keep ;

: selector ( selector -- alien )
    dup selector-object expired? [
        dup selector-name sel_registerName
        dup rot set-selector-object
    ] [
        selector-object
    ] if ;

: objc-classes ( -- seq )
    f 0 objc_getClassList
    [ "void*" <c-array> dup ] keep objc_getClassList
    [ swap void*-nth objc-class-name ] map-with ;

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

: objc-method-info ( method -- { return name args } )
    [ method-return-type ] keep
    [ objc-method-name sel_getName ] keep
    method-arg-types 3array ;

: method-list@ ( ptr -- ptr )
    "objc-method-list" c-size swap <displaced-alien> ;

: method-list>seq ( method-list -- seq )
    dup method-list@ swap objc-method-list-count
    [ swap objc-method-nth objc-method-info ] map-with ;

: (objc-methods) ( objc-class iterator -- )
    2dup class_nextMethodList
    [ method-list>seq % (objc-methods) ] [ 2drop ] if* ;

: objc-methods ( class -- seq )
    [ f <void*> (objc-methods) ] { } make ;

: (objc-class) ( string word -- class )
    dupd execute
    [ ] [ "No such class: " swap append throw ] ?if ; inline

: objc-class ( string -- class )
    \ objc_getClass (objc-class) ;

: objc-meta-class ( string -- class )
    \ objc_getMetaClass (objc-class) ;

: class-exists? ( string -- class )
    objc_getClass >boolean ;

: instance-methods ( classname -- seq )
    objc-class objc-methods ;

: class-methods ( classname -- seq )
    objc-meta-class objc-methods ;

: <super> ( receiver class -- super )
    "objc-super" <c-object>
    [ set-objc-super-class ] keep
    [ set-objc-super-receiver ] keep ;

: SUPER-> \ SUPER-> on ; inline

: ?super ( obj -- class )
    objc-object-isa \ SUPER-> [ f ] change
    [ objc-class-super-class ] when ; inline

: selector-quot ( string -- )
    [
        [ dup ?super <super> ] % <selector> , \ selector ,
    ] [ ] make ;

: make-objc-invoke
    [
        >r over length 2 - make-dip % r> call \ alien-invoke ,
    ] [ ] make ;

: make-objc-send ( returns args selector -- )
    selector-quot
    [ swap , [ f "objc_msgSendSuper" ] % , ] make-objc-invoke ;

: make-objc-send-stret ( returns args selector -- )
    >r swap [ <c-object> dup ] curry 1 make-dip r>
    selector-quot append [
        "void" ,
        [ f "objc_msgSendSuper_stret" ] %
        { "void*" } swap append ,
    ] make-objc-invoke ;

: make-objc-method ( returns args selector -- )
    pick c-struct?
    [ make-objc-send-stret ] [ make-objc-send ] if ;

: import-objc-method ( returns types selector -- )
    [ make-objc-method "[" ] keep "]" append3 create-in
    swap define-compound ;

: import-objc-methods ( seq -- )
    [ first3 swap import-objc-method ] each ;

: unless-defined ( class quot -- )
    >r class-exists? r> unless ; inline

: define-objc-class-word ( name quot -- )
    [
        over , , \ unless-defined , dup , \ objc-class ,
    ] [ ] make >r create-in r> define-compound ;

: import-objc-class ( name quot -- )
    #! The quotation is prepended to the class word. It should
    #! "regenerate" the class as appropriate (by loading a
    #! framework or defining the class in some manner).
    2dup unless-defined [
        "objc-" pick append in set
        dupd define-objc-class-word
        dup instance-methods import-objc-methods
        class-methods import-objc-methods
    ] with-scope ;

: root-class ( class -- class )
    dup objc-class-super-class [ root-class ] [ ] ?if ;
