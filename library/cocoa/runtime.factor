! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: objc

TYPEDEF: void* SEL

TYPEDEF: void* id

FUNCTION: char* sel_getName ( SEL aSelector ) ;

FUNCTION: bool sel_isMapped ( SEL aSelector ) ;

FUNCTION: SEL sel_registerName ( char* str ) ;

: CLS_CLASS        HEX: 1   ;
: CLS_META         HEX: 2   ;
: CLS_INITIALIZED  HEX: 4   ;
: CLS_POSING       HEX: 8   ;
: CLS_MAPPED       HEX: 10  ;
: CLS_FLUSH_CACHE  HEX: 20  ;
: CLS_GROW_CACHE   HEX: 40  ;
: CLS_NEED_BIND    HEX: 80  ;
: CLS_METHOD_ARRAY HEX: 100 ;

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

BEGIN-STRUCT: objc-object
    FIELD: objc-class* isa
END-STRUCT

FUNCTION: int objc_getClassList ( void* buffer, int bufferLen ) ;

FUNCTION: objc-class* objc_getClass ( char* class ) ;

FUNCTION: objc-class* objc_getMetaClass ( char* class ) ;

FUNCTION: void objc_addClass ( objc-class* class ) ;

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

FUNCTION: uint method_getArgumentInfo ( objc-method* method, int argIndex, char** type, int* offset ) ;
