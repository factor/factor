IN: objective-c
USING: alien arrays compiler kernel lists namespaces parser
sequences words ;

TYPEDEF: void* SEL

TYPEDEF: void* id

FUNCTION: char* sel_getName ( SEL aSelector ) ;

FUNCTION: bool sel_isMapped ( SEL aSelector ) ;

FUNCTION: SEL sel_registerName ( char* str ) ;

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

BEGIN-STRUCT: objc-class
   FIELD: void* isa
   FIELD: void* super-class
   FIELD: char* name
   FIELD: long version
   FIELD: long info
   FIELD: long instance-size
   FIELD: void* ivars
   FIELD: void* methodLists
   FIELD: void* cache
   FIELD: void* protocols
END-STRUCT

FUNCTION: int objc_getClassList ( void* buffer, int bufferLen ) ; compiled

: objc-classes ( -- seq )
    f 0 objc_getClassList
    [ "void*" <c-array> dup ] keep objc_getClassList
    [ swap void*-nth objc-class-name ] map-with ;

FUNCTION: objc-class* objc_getClass ( char* class ) ;

FUNCTION: objc-class* objc_getMetaClass ( char* class ) ;

FUNCTION: id class_createInstance ( objc-class* class, uint additionalByteCount ) ;

FUNCTION: id class_createInstanceFromZone ( objc-class* class, uint additionalByteCount, void* zone ) ;

BEGIN-STRUCT: objc-method
    FIELD: SEL name
    FIELD: char* types
    FIELD: void* imp
END-STRUCT

FUNCTION: objc-method* class_getInstanceMethod ( objc-class* class, SEL selector ) ;

FUNCTION: objc-method* class_getClassMethod ( objc-class* class, SEL selector ) ;

BEGIN-STRUCT: objc-method-list
    FIELD: void* obsolete
    FIELD: int count
    FIELD: objc-method elements
END-STRUCT

FUNCTION: objc-method-list* class_nextMethodList ( objc-class* class, void** iterator ) ;

FUNCTION: void class_addMethods ( objc-class* class, objc-method-list* methodList ) ;

FUNCTION: void class_removeMethods ( objc-class* class, objc-method-list* methodList ) ;

FUNCTION: uint method_getNumberOfArguments ( objc-method* method ) ;

FUNCTION: uint method_getSizeOfArguments ( objc-method* method ) ;

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

: OBJC-CLASS:
    #! Syntax: name
    CREATE dup word-name
    [ objc_getClass ] curry define-compound ; parsing

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

: OBJC-MESSAGE:
    scan string-mode on
    [ string-mode off msg-send-args define-msg-send ] f ;
    parsing

"objective-c" words [ try-compile ] each
