! Copyright (C) 2006, 2007 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax classes.struct ;
IN: cocoa.runtime

TYPEDEF: void* SEL

TYPEDEF: void* id

FUNCTION: char* sel_getName ( SEL aSelector ) ;

FUNCTION: char sel_isMapped ( SEL aSelector ) ;

FUNCTION: SEL sel_registerName ( char* str ) ;

TYPEDEF: void* Class
TYPEDEF: void* Method
TYPEDEF: void* Protocol

STRUCT: objc-super
    { receiver id }
    { class Class } ;

CONSTANT: CLS_CLASS        HEX: 1
CONSTANT: CLS_META         HEX: 2
CONSTANT: CLS_INITIALIZED  HEX: 4
CONSTANT: CLS_POSING       HEX: 8
CONSTANT: CLS_MAPPED       HEX: 10
CONSTANT: CLS_FLUSH_CACHE  HEX: 20
CONSTANT: CLS_GROW_CACHE   HEX: 40
CONSTANT: CLS_NEED_BIND    HEX: 80
CONSTANT: CLS_METHOD_ARRAY HEX: 100

FUNCTION: int objc_getClassList ( void* buffer, int bufferLen ) ;

FUNCTION: Class objc_getClass ( char* class ) ;

FUNCTION: Class objc_getMetaClass ( char* class ) ;

FUNCTION: Protocol objc_getProtocol ( char* class ) ;

FUNCTION: Class objc_allocateClassPair ( Class superclass, char* name, size_t extraBytes ) ;
FUNCTION: void objc_registerClassPair ( Class cls ) ;

FUNCTION: id class_createInstance ( Class class, uint additionalByteCount ) ;

FUNCTION: id class_createInstanceFromZone ( Class class, uint additionalByteCount, void* zone ) ;

FUNCTION: Method class_getInstanceMethod ( Class class, SEL selector ) ;

FUNCTION: Method class_getClassMethod ( Class class, SEL selector ) ;

FUNCTION: Method* class_copyMethodList ( Class class, uint* outCount ) ;

FUNCTION: Class class_getSuperclass ( Class cls ) ;

FUNCTION: char* class_getName ( Class cls ) ;

FUNCTION: char class_addMethod ( Class class, SEL name, void* imp, void* types ) ;

FUNCTION: char class_addProtocol ( Class class, Protocol protocol ) ;

FUNCTION: uint method_getNumberOfArguments ( Method method ) ;

FUNCTION: uint method_getSizeOfArguments ( Method method ) ;

FUNCTION: uint method_getArgumentInfo ( Method method, int argIndex, char** type, int* offset ) ;

FUNCTION: void* method_copyReturnType ( Method method ) ;

FUNCTION: void* method_copyArgumentType ( Method method, uint index ) ;

FUNCTION: void* method_getTypeEncoding ( Method method ) ;

FUNCTION: SEL method_getName ( Method method ) ;

FUNCTION: void* method_setImplementation ( Method method, void* imp ) ; 
FUNCTION: void* method_getImplementation ( Method method ) ; 

FUNCTION: Class object_getClass ( id object ) ;
