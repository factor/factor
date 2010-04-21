! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries alien.syntax
classes.struct combinators io.encodings.utf16n
io.encodings.utf8 kernel system ;
IN: javascriptcore.ffi

<<
"javascriptcore" {
    { [ os macosx? ] [
        "/System/Library/Frameworks/JavaScriptCore.framework/Versions/Current/JavaScriptCore" cdecl add-library
    ] }
    ! { [ os winnt? ]  [ "javascriptcore.dll" ] }
    ! { [ os unix? ]  [ "libsqlite3.so" ] }
    [ drop ]
} cond
>>

LIBRARY: javascriptcore

TYPEDEF: void* JSContextGroupRef
TYPEDEF: void* JSContextRef
TYPEDEF: void* JSGlobalContextRef
TYPEDEF: void* JSStringRef
TYPEDEF: void* JSClassRef
TYPEDEF: void* JSPropertyNameArrayRef
TYPEDEF: void* JSPropertyNameAccumulatorRef
TYPEDEF: void* JSValueRef
TYPEDEF: void* JSObjectRef
TYPEDEF: void* JSObjectInitializeCallback
TYPEDEF: void* JSObjectFinalizeCallback
TYPEDEF: void* JSObjectHasPropertyCallback
TYPEDEF: void* JSObjectGetPropertyCallback
TYPEDEF: void* JSObjectSetPropertyCallback
TYPEDEF: void* JSObjectDeletePropertyCallback
TYPEDEF: void* JSObjectGetPropertyNamesCallback
TYPEDEF: void* JSObjectCallAsFunctionCallback
TYPEDEF: void* JSObjectCallAsConstructorCallback
TYPEDEF: void* JSObjectHasInstanceCallback
TYPEDEF: void* JSObjectConvertToTypeCallback
TYPEDEF: uint unsigned
TYPEDEF: ushort JSChar

C-ENUM: JSPropertyAttributes
    { kJSPropertyAttributeNone       0 }
    { kJSPropertyAttributeReadOnly   2 }
    { kJSPropertyAttributeDontEnum   4 }
    { kJSPropertyAttributeDontDelete 8 } ;

C-ENUM: JSClassAttributes
    { kJSClassAttributeNone 0 }
    { kJSClassAttributeNoAutomaticPrototype 2 } ;

C-ENUM: JSType
    kJSTypeUndefined,
    kJSTypeNull,
    kJSTypeBoolean,
    kJSTypeNumber,
    kJSTypeString,
    kJSTypeObject ;

STRUCT: JSStaticValue
    { name c-string }
    { getProperty JSObjectGetPropertyCallback }
    { setProperty JSObjectSetPropertyCallback }
    { attributes JSPropertyAttributes } ;

STRUCT: JSStaticFunction
    { name c-string }
    { callAsFunction JSObjectCallAsFunctionCallback } ;

STRUCT: JSClassDefinition
    { version int }
    { attributes JSClassAttributes }
    { className c-string }
    { parentClass JSClassRef }
    { staticValues JSStaticValue* }
    { staticFunctions JSStaticFunction* }
    { initialize JSObjectInitializeCallback }
    { finalize JSObjectFinalizeCallback }
    { hasProperty JSObjectHasPropertyCallback }
    { getProperty JSObjectGetPropertyCallback }
    { setProperty JSObjectSetPropertyCallback }
    { deleteProperty JSObjectDeletePropertyCallback }
    { getPropertyNames JSObjectGetPropertyNamesCallback }
    { callAsFunction JSObjectCallAsFunctionCallback }
    { callAsConstructor JSObjectCallAsConstructorCallback }
    { hasInstance JSObjectHasInstanceCallback }
    { convertToType JSObjectConvertToTypeCallback } ;

ALIAS: kJSClassDefinitionEmpty JSClassDefinition

FUNCTION: JSValueRef JSEvaluateScript (
    JSContextRef ctx,
    JSStringRef script,
    JSObjectRef thisObject,
    JSStringRef sourceURL,
    int startingLineNumber,
    JSValueRef* exception ) ;

FUNCTION: bool JSCheckScriptSyntax (
    JSContextRef ctx,
    JSStringRef script,
    JSStringRef sourceURL,
    int startingLineNumber,
    JSValueRef* exception ) ;

FUNCTION: void JSGarbageCollect
    ( JSContextRef ctx ) ;

FUNCTION: JSContextGroupRef JSContextGroupCreate
    ( ) ;

FUNCTION: JSContextGroupRef JSContextGroupRetain
    ( JSContextGroupRef group ) ;

FUNCTION: void JSContextGroupRelease
    ( JSContextGroupRef group ) ;

FUNCTION: JSGlobalContextRef JSGlobalContextCreate
    ( JSClassRef globalObjectClass ) ; 

FUNCTION: JSGlobalContextRef JSGlobalContextCreateInGroup (
    JSContextGroupRef group,
    JSClassRef globalObjectClass ) ;

FUNCTION: JSGlobalContextRef JSGlobalContextRetain
    ( JSGlobalContextRef ctx ) ;

FUNCTION: void JSGlobalContextRelease
    ( JSGlobalContextRef ctx ) ;

FUNCTION: JSObjectRef JSContextGetGlobalObject
    ( JSContextRef ctx ) ;

FUNCTION: JSContextGroupRef JSContextGetGroup
    ( JSContextRef ctx ) ;

FUNCTION: JSClassRef JSClassCreate
    ( JSClassDefinition* definition ) ;

FUNCTION: JSClassRef JSClassRetain
    ( JSClassRef jsClass ) ;

FUNCTION: void JSClassRelease
    ( JSClassRef jsClass ) ;

FUNCTION: JSObjectRef JSObjectMake
    ( JSContextRef ctx,
      JSClassRef jsClass, void* data ) ;

FUNCTION: JSObjectRef JSObjectMakeFunctionWithCallback ( JSContextRef ctx, JSStringRef name, JSObjectCallAsFunctionCallback callAsFunction ) ;

FUNCTION: JSObjectRef JSObjectMakeConstructor ( JSContextRef ctx, JSClassRef jsClass, JSObjectCallAsConstructorCallback callAsConstructor ) ;

FUNCTION: JSObjectRef JSObjectMakeArray ( JSContextRef ctx, size_t argumentCount, JSValueRef arguments[], JSValueRef* exception ) ;

FUNCTION: JSObjectRef JSObjectMakeDate ( JSContextRef ctx, size_t argumentCount, JSValueRef arguments[], JSValueRef* exception ) ;

FUNCTION: JSObjectRef JSObjectMakeError ( JSContextRef ctx, size_t argumentCount, JSValueRef arguments[], JSValueRef* exception ) ;

FUNCTION: JSObjectRef JSObjectMakeRegExp ( JSContextRef ctx, size_t argumentCount, JSValueRef arguments[], JSValueRef* exception ) ;

FUNCTION: JSObjectRef JSObjectMakeFunction ( JSContextRef ctx, JSStringRef name, unsigned parameterCount, JSStringRef parameterNames[], JSStringRef body, JSStringRef sourceURL, int startingLineNumber, JSValueRef* exception ) ;

FUNCTION: JSValueRef JSObjectGetPrototype ( JSContextRef ctx, JSObjectRef object ) ;

FUNCTION: void JSObjectSetPrototype ( JSContextRef ctx, JSObjectRef object, JSValueRef value ) ;

FUNCTION: bool JSObjectHasProperty ( JSContextRef ctx, JSObjectRef object, JSStringRef propertyName ) ;

FUNCTION: JSValueRef JSObjectGetProperty ( JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef* exception ) ;

FUNCTION: void JSObjectSetProperty ( JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef value, JSPropertyAttributes attributes, JSValueRef* exception ) ;

FUNCTION: bool JSObjectDeleteProperty ( JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef* exception ) ;

FUNCTION: JSValueRef JSObjectGetPropertyAtIndex ( JSContextRef ctx, JSObjectRef object, unsigned propertyIndex, JSValueRef* exception ) ;

FUNCTION: void JSObjectSetPropertyAtIndex ( JSContextRef ctx, JSObjectRef object, unsigned propertyIndex, JSValueRef value, JSValueRef* exception ) ;

FUNCTION: void* JSObjectGetPrivate ( JSObjectRef object ) ;

FUNCTION: bool JSObjectSetPrivate ( JSObjectRef object, void* data ) ;

FUNCTION: bool JSObjectIsFunction ( JSContextRef ctx, JSObjectRef object ) ;

FUNCTION: JSValueRef JSObjectCallAsFunction ( JSContextRef ctx, JSObjectRef object, JSObjectRef thisObject, size_t argumentCount, JSValueRef arguments[], JSValueRef* exception ) ;

FUNCTION: bool JSObjectIsConstructor ( JSContextRef ctx, JSObjectRef object ) ;

FUNCTION: JSObjectRef JSObjectCallAsConstructor ( JSContextRef ctx, JSObjectRef object, size_t argumentCount, JSValueRef arguments[], JSValueRef* exception ) ;

FUNCTION: JSPropertyNameArrayRef JSObjectCopyPropertyNames ( JSContextRef ctx, JSObjectRef object ) ;

FUNCTION: JSPropertyNameArrayRef JSPropertyNameArrayRetain ( JSPropertyNameArrayRef array ) ;

FUNCTION: void JSPropertyNameArrayRelease ( JSPropertyNameArrayRef array ) ;

FUNCTION: size_t JSPropertyNameArrayGetCount ( JSPropertyNameArrayRef array ) ;

FUNCTION: JSStringRef JSPropertyNameArrayGetNameAtIndex ( JSPropertyNameArrayRef array, size_t index ) ;

FUNCTION: void JSPropertyNameAccumulatorAddName ( JSPropertyNameAccumulatorRef accumulator, JSStringRef propertyName ) ;

FUNCTION: JSStringRef JSStringCreateWithCharacters ( JSChar* chars, size_t numChars ) ;

FUNCTION: JSStringRef JSStringCreateWithUTF8CString ( c-string string ) ;

FUNCTION: JSStringRef JSStringRetain ( JSStringRef string ) ;

FUNCTION: void JSStringRelease ( JSStringRef string ) ;

FUNCTION: size_t JSStringGetLength ( JSStringRef string ) ;

FUNCTION: JSChar* JSStringGetCharactersPtr ( JSStringRef string ) ;

FUNCTION: size_t JSStringGetMaximumUTF8CStringSize ( JSStringRef string ) ;

FUNCTION: size_t JSStringGetUTF8CString ( JSStringRef string, char* buffer, size_t bufferSize ) ;

FUNCTION: bool JSStringIsEqual ( JSStringRef a, JSStringRef b ) ;

FUNCTION: bool JSStringIsEqualToUTF8CString ( JSStringRef a, char* b ) ;

FUNCTION: JSType JSValueGetType ( JSContextRef ctx, JSValueRef value ) ;

FUNCTION: bool JSValueIsUndefined ( JSContextRef ctx, JSValueRef value ) ;

FUNCTION: bool JSValueIsNull ( JSContextRef ctx, JSValueRef value ) ;

FUNCTION: bool JSValueIsBoolean ( JSContextRef ctx, JSValueRef value ) ;

FUNCTION: bool JSValueIsNumber ( JSContextRef ctx, JSValueRef value ) ;

FUNCTION: bool JSValueIsString ( JSContextRef ctx, JSValueRef value ) ;

FUNCTION: bool JSValueIsObject ( JSContextRef ctx, JSValueRef value ) ;

FUNCTION: bool JSValueIsObjectOfClass ( JSContextRef ctx, JSValueRef value, JSClassRef jsClass ) ;

FUNCTION: bool JSValueIsEqual ( JSContextRef ctx, JSValueRef a, JSValueRef b, JSValueRef* exception ) ;

FUNCTION: bool JSValueIsStrictEqual ( JSContextRef ctx, JSValueRef a, JSValueRef b ) ;

FUNCTION: bool JSValueIsInstanceOfConstructor ( JSContextRef ctx, JSValueRef value, JSObjectRef constructor, JSValueRef* exception ) ;

FUNCTION: JSValueRef JSValueMakeUndefined ( JSContextRef ctx ) ;

FUNCTION: JSValueRef JSValueMakeNull ( JSContextRef ctx ) ;

FUNCTION: JSValueRef JSValueMakeBoolean ( JSContextRef ctx, bool boolean ) ;

FUNCTION: JSValueRef JSValueMakeNumber ( JSContextRef ctx, double number ) ;

FUNCTION: JSValueRef JSValueMakeString ( JSContextRef ctx, JSStringRef string ) ;

FUNCTION: bool JSValueToBoolean ( JSContextRef ctx, JSValueRef value ) ;

FUNCTION: double JSValueToNumber ( JSContextRef ctx, JSValueRef value, JSValueRef* exception ) ;

FUNCTION: JSStringRef JSValueToStringCopy ( JSContextRef ctx, JSValueRef value, JSValueRef* exception ) ;

FUNCTION: JSObjectRef JSValueToObject ( JSContextRef ctx, JSValueRef value, JSValueRef* exception ) ;

FUNCTION: void JSValueProtect ( JSContextRef ctx, JSValueRef value ) ;

FUNCTION: void JSValueUnprotect ( JSContextRef ctx, JSValueRef value ) ;

