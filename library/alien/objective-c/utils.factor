! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: objc
USING: alien arrays hashtables kernel lists math namespaces
parser sequences words ;

TUPLE: selector name object ;

C: selector ( name -- sel ) [ set-selector-name ] keep ;

: selector ( selector -- alien )
    dup selector-object dup expired? not and [
        selector-object
    ] [
        dup selector-name sel_registerName
        dup rot set-selector-object
    ] if ;

: objc-classes ( -- seq )
    f 0 objc_getClassList
    [ "void*" <c-array> dup ] keep objc_getClassList
    [ swap void*-nth objc-class-name ] map-with ;

: method-arg-type ( method i -- type )
    f <void*> 0 <int> over
    >r method_getArgumentInfo drop
    r> *char* ;

: objc-primitive-type ( char -- ctype )
    H{
        { CHAR: c "char" }
        { CHAR: i "int" }
        { CHAR: s "short" }
        { CHAR: l "long" }
        { CHAR: q "longlong" }
        { CHAR: C "uchar" }
        { CHAR: I "uint" }
        { CHAR: S "ushort" }
        { CHAR: L "ulong" }
        { CHAR: Q "ulonglong" }
        { CHAR: f "float" }
        { CHAR: d "double" }
        { CHAR: B "bool" }
        { CHAR: v "void" }
        { CHAR: * "char*" }
        { CHAR: @ "id" }
        { CHAR: # "id" }
        { CHAR: : "SEL" }
    } hash ;

: objc-struct-type ( i string -- ctype )
    2dup CHAR: = -rot index* swap subseq ;

: (parse-objc-type) ( i string -- ctype )
    2dup nth >r >r 1+ r> r> {
        { [ dup CHAR: ^ = ] [ 3drop "void*" ] }
        { [ dup CHAR: { = ] [ drop objc-struct-type ] }
        { [ dup CHAR: [ = ] [ 3drop "void*" ] }
        { [ t ] [ 2nip objc-primitive-type ] }
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

: method-list>seq ( method-list -- seq )
    dup objc-method-list-elements swap objc-method-list-count [
        swap objc-method-nth objc-method-info
    ] map-with ;

: (objc-methods) ( objc-class iterator -- )
    2dup class_nextMethodList
    [ method-list>seq % (objc-methods) ] [ 2drop ] if* ;

: objc-methods ( class -- seq )
    [ f <void*> (objc-methods) ] { } make ;

: instance-methods ( classname -- seq )
    objc_getClass objc-methods ;

: class-methods ( classname -- seq )
    objc_getMetaClass objc-methods ;

: make-dip ( quot n -- quot )
    dup \ >r <array> -rot \ r> <array> append3 ;

: make-objc-method ( returns args selector -- )
    <selector> [ selector ] curry over length 2 - make-dip [
        %
        swap ,
        [ f "objc_msgSend" ] % ,
        \ alien-invoke ,
    ] [ ] make ;

: define-objc-method ( returns types selector -- )
    [ make-objc-method "[" ] keep "]" append3 create-in
    swap define-compound ;

: define-objc-methods ( seq -- )
    [ first3 swap define-objc-method ] each ;

: define-objc-class-word ( name -- )
    create-in over [ objc_getClass ] curry define-compound ;

: define-objc-class ( name -- )
    [
        "objc-" over append in set
        dup define-objc-class-word
        dup instance-methods define-objc-methods
        class-methods define-objc-methods
    ] with-scope ;
