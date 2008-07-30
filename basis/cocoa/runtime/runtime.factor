! Copyright (C) 2006, 2007 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax ;
IN: cocoa.runtime

TYPEDEF: void* SEL

TYPEDEF: void* id

FUNCTION: char* sel_getName ( SEL aSelector ) ;

FUNCTION: bool sel_isMapped ( SEL aSelector ) ;

FUNCTION: SEL sel_registerName ( char* str ) ;

C-STRUCT: objc-super
    { "id" "receiver" }
    { "void*" "class" } ;

: CLS_CLASS        HEX: 1   ;
: CLS_META         HEX: 2   ;
: CLS_INITIALIZED  HEX: 4   ;
: CLS_POSING       HEX: 8   ;
: CLS_MAPPED       HEX: 10  ;
: CLS_FLUSH_CACHE  HEX: 20  ;
: CLS_GROW_CACHE   HEX: 40  ;
: CLS_NEED_BIND    HEX: 80  ;
: CLS_METHOD_ARRAY HEX: 100 ;

C-STRUCT: objc-class
    { "void*" "isa" }
    { "void*" "super-class" }
    { "char*" "name" }
    { "long" "version" }
    { "long" "info" }
    { "long" "instance-size" }
    { "void*" "ivars" }
    { "void*" "methodLists" }
    { "void*" "cache" }
    { "void*" "protocols" } ;

C-STRUCT: objc-object
    { "objc-class*" "isa" } ;

FUNCTION: int objc_getClassList ( void* buffer, int bufferLen ) ;

FUNCTION: objc-class* objc_getClass ( char* class ) ;

FUNCTION: objc-class* objc_getMetaClass ( char* class ) ;

FUNCTION: objc-class* objc_getProtocol ( char* class ) ;

FUNCTION: void objc_addClass ( objc-class* class ) ;

FUNCTION: id class_createInstance ( objc-class* class, uint additionalByteCount ) ;

FUNCTION: id class_createInstanceFromZone ( objc-class* class, uint additionalByteCount, void* zone ) ;

C-STRUCT: objc-method
    { "SEL" "name" }
    { "char*" "types" }
    { "void*" "imp" } ;

FUNCTION: objc-method* class_getInstanceMethod ( objc-class* class, SEL selector ) ;

FUNCTION: objc-method* class_getClassMethod ( objc-class* class, SEL selector ) ;

C-STRUCT: objc-method-list
    { "void*" "obsolete" }
    { "int" "count" } ;

FUNCTION: objc-method-list* class_nextMethodList ( objc-class* class, void** iterator ) ;

FUNCTION: void class_addMethods ( objc-class* class, objc-method-list* methodList ) ;

FUNCTION: void class_removeMethods ( objc-class* class, objc-method-list* methodList ) ;

FUNCTION: uint method_getNumberOfArguments ( objc-method* method ) ;

FUNCTION: uint method_getSizeOfArguments ( objc-method* method ) ;

FUNCTION: uint method_getArgumentInfo ( objc-method* method, int argIndex, char** type, int* offset ) ;

C-STRUCT: objc-protocol-list
    { "void*" "next" }
    { "int" "count" }
    { "objc-class*" "class" } ;
