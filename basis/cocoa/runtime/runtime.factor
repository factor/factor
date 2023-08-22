! Copyright (C) 2006, 2007 Slava Pestov
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax classes.struct core-foundation ;
IN: cocoa.runtime

TYPEDEF: void* SEL

TYPEDEF: void* id

FUNCTION: c-string sel_getName ( SEL aSelector )

FUNCTION: char sel_isMapped ( SEL aSelector )

FUNCTION: SEL sel_registerName ( c-string str )

TYPEDEF: void* Class
TYPEDEF: void* Method
TYPEDEF: void* Protocol
TYPEDEF: void* Ivar

STRUCT: objc-super
    { receiver id }
    { class Class } ;

CONSTANT: CLS_CLASS        0x1
CONSTANT: CLS_META         0x2
CONSTANT: CLS_INITIALIZED  0x4
CONSTANT: CLS_POSING       0x8
CONSTANT: CLS_MAPPED       0x10
CONSTANT: CLS_FLUSH_CACHE  0x20
CONSTANT: CLS_GROW_CACHE   0x40
CONSTANT: CLS_NEED_BIND    0x80
CONSTANT: CLS_METHOD_ARRAY 0x100

FUNCTION: int objc_getClassList ( void* buffer, int bufferLen )

FUNCTION: Class objc_getClass ( c-string class )

FUNCTION: Class objc_getMetaClass ( c-string class )

FUNCTION: Protocol objc_getProtocol ( c-string class )

FUNCTION: Class objc_allocateClassPair ( Class superclass, c-string name, size_t extraBytes )
FUNCTION: void objc_registerClassPair ( Class cls )

FUNCTION: void* objc_getAssociatedObject ( void* obj, c-string key )

FUNCTION: id class_createInstance ( Class class, uint additionalByteCount )

FUNCTION: id class_createInstanceFromZone ( Class class, uint additionalByteCount, void* zone )

FUNCTION: Method class_getInstanceMethod ( Class class, SEL selector )

FUNCTION: Method class_getClassMethod ( Class class, SEL selector )

FUNCTION: Method* class_copyMethodList ( Class class, uint* outCount )

FUNCTION: Class class_getSuperclass ( Class cls )

FUNCTION: c-string class_getName ( Class cls )

FUNCTION: Boolean class_isMetaClass ( Class cls )

FUNCTION: Method class_getInstanceVariable ( Class class, c-string str )

FUNCTION: Method class_getClassVariable ( Class class, c-string str )

FUNCTION: uint8_t* class_getIvarLayout ( Class class )

FUNCTION: char class_addMethod ( Class class, SEL name, void* imp, void* types )

FUNCTION: char class_addProtocol ( Class class, Protocol protocol )

FUNCTION: uint method_getNumberOfArguments ( Method method )

FUNCTION: void* method_copyReturnType ( Method method )

FUNCTION: void* method_copyArgumentType ( Method method, uint index )

FUNCTION: void* method_getTypeEncoding ( Method method )

FUNCTION: SEL method_getName ( Method method )

FUNCTION: void* method_setImplementation ( Method method, void* imp )
FUNCTION: void* method_getImplementation ( Method method )

FUNCTION: Class object_getClass ( id object )

FUNCTION: void* object_getIvar ( Class class, Ivar ivar )

