! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
IN: jni-internals
USING: kernel alien arrays sequences ;

LIBRARY: jvm

TYPEDEF: int jint
TYPEDEF: uchar jboolean
TYPEDEF: void* JNIEnv

C-STRUCT: jdk-init-args
	{ "jint" "version" }
	{ "void*" "properties" }
	{ "jint" "check-source" }
	{ "jint" "native-stack-size" }
	{ "jint" "java-stack-size" }
	{ "jint" "min-heap-size" }
	{ "jint" "max-heap-size" }
	{ "jint" "verify-mode" }
	{ "char*" "classpath" }
	{ "void*" "vprintf" }
	{ "void*" "exit" }
	{ "void*" "abort" }
	{ "jint" "enable-class-gc" }
	{ "jint" "enable-verbose-gc" }
	{ "jint" "disable-async-gc" }
	{ "jint" "verbose" }
	{ "jboolean" "debugging" }
	{ "jint" "debug-port" } ;

C-STRUCT: JNIInvokeInterface
	{ "void*" "reserved0" }
	{ "void*" "reserved1" }
	{ "void*" "reserved2" }
	{ "void*" "DestroyJavaVM" }
	{ "void*" "AttachCurrentThread" }
	{ "void*" "DetachCurrentThread" }
	{ "void*" "GetEnv" }
	{ "void*" "AttachCurrentThreadAsDaemon" } ;

C-STRUCT: JavaVM
	{ "JNIInvokeInterface*" "functions" } ;

C-STRUCT: JNINativeInterface
    { "void*" "reserved0" }
    { "void*" "reserved1" }
    { "void*" "reserved2" }
    { "void*" "reserved3" }
    { "void*" "GetVersion" }
    { "void*" "DefineClass" }
    { "void*" "FindClass" }
    { "void*" "FromReflectedMethod" }
    { "void*" "FromReflectedField" }
    { "void*" "ToReflectedMethod" }
    { "void*" "GetSuperclass" }
    { "void*" "IsAssignableFrom" }
    { "void*" "ToReflectedField" }
    { "void*" "Throw" }
    { "void*" "ThrowNew" }
    { "void*" "ExceptionOccurred" }
    { "void*" "ExceptionDescribe" }
    { "void*" "ExceptionClear" }
    { "void*" "FatalError" }
    { "void*" "PushLocalFrame" }
    { "void*" "PopLocalFrame" }
    { "void*" "NewGlobalRef" }
    { "void*" "DeleteGlobalRef" }
    { "void*" "DeleteLocalRef" }
    { "void*" "IsSameObject" }
    { "void*" "NewLocalRef" }
    { "void*" "EnsureLocalCapacity" }
    { "void*" "AllocObject" }
    { "void*" "NewObject" }
    { "void*" "NewObjectV" }
    { "void*" "NewObjectA" }
    { "void*" "GetObjectClass" }
    { "void*" "IsInstanceOf" }
    { "void*" "GetMethodID" }
    { "void*" "CallObjectMethod" }
    { "void*" "CallObjectMethodV" }
    { "void*" "CallObjectMethodA" }
    { "void*" "CallBooleanMethod" }
    { "void*" "CallBooleanMethodV" }
    { "void*" "CallBooleanMethodA" }
    { "void*" "CallByteMethod" }
    { "void*" "CallByteMethodV" }
    { "void*" "CallByteMethodA" }
    { "void*" "CallCharMethod" }
    { "void*" "CallCharMethodV" }
    { "void*" "CallCharMethodA" }
    { "void*" "CallShortMethod" }
    { "void*" "CallShortMethodV" }
    { "void*" "CallShortMethodA" }
    { "void*" "CallIntMethod" }
    { "void*" "CallIntMethodV" }
    { "void*" "CallIntMethodA" }
    { "void*" "CallLongMethod" }
    { "void*" "CallLongMethodV" }
    { "void*" "CallLongMethodA" }
    { "void*" "CallFloatMethod" }
    { "void*" "CallFloatMethodV" }
    { "void*" "CallFloatMethodA" }
    { "void*" "CallDoubleMethod" }
    { "void*" "CallDoubleMethodV" }
    { "void*" "CallDoubleMethodA" }
    { "void*" "CallVoidMethod" }
    { "void*" "CallVoidMethodV" }
    { "void*" "CallVoidMethodA" }
    { "void*" "CallNonvirtualObjectMethod" }
    { "void*" "CallNonvirtualObjectMethodV" }
    { "void*" "CallNonvirtualObjectMethodA" }
    { "void*" "CallNonvirtualBooleanMethod" }
    { "void*" "CallNonvirtualBooleanMethodV" }
    { "void*" "CallNonvirtualBooleanMethodA" }
    { "void*" "CallNonvirtualByteMethod" }
    { "void*" "CallNonvirtualByteMethodV" }
    { "void*" "CallNonvirtualByteMethodA" }
    { "void*" "CallNonvirtualCharMethod" }
    { "void*" "CallNonvirtualCharMethodV" }
    { "void*" "CallNonvirtualCharMethodA" }
    { "void*" "CallNonvirtualShortMethod" }
    { "void*" "CallNonvirtualShortMethodV" }
    { "void*" "CallNonvirtualShortMethodA" }
    { "void*" "CallNonvirtualIntMethod" }
    { "void*" "CallNonvirtualIntMethodV" }
    { "void*" "CallNonvirtualIntMethodA" }
    { "void*" "CallNonvirtualLongMethod" }
    { "void*" "CallNonvirtualLongMethodV" }
    { "void*" "CallNonvirtualLongMethodA" }
    { "void*" "CallNonvirtualFloatMethod" }
    { "void*" "CallNonvirtualFloatMethodV" }
    { "void*" "CallNonvirtualFloatMethodA" }
    { "void*" "CallNonvirtualDoubleMethod" }
    { "void*" "CallNonvirtualDoubleMethodV" }
    { "void*" "CallNonvirtualDoubleMethodA" }
    { "void*" "CallNonvirtualVoidMethod" }
    { "void*" "CallNonvirtualVoidMethodV" }
    { "void*" "CallNonvirtualVoidMethodA" }
    { "void*" "GetFieldID" }
    { "void*" "GetObjectField" }
    { "void*" "GetBooleanField" }
    { "void*" "GetByteField" }
    { "void*" "GetCharField" }
    { "void*" "GetShortField" }
    { "void*" "GetIntField" }
    { "void*" "GetLongField" }
    { "void*" "GetFloatField" }
    { "void*" "GetDoubleField" }
    { "void*" "SetObjectField" }
    { "void*" "SetBooleanField" }
    { "void*" "SetByteField" }
    { "void*" "SetCharField" }
    { "void*" "SetShortField" }
    { "void*" "SetIntField" }
    { "void*" "SetLongField" }
    { "void*" "SetFloatField" }
    { "void*" "SetDoubleField" }
    { "void*" "GetStaticMethodID" }
    { "void*" "CallStaticObjectMethod" }
    { "void*" "CallStaticObjectMethodV" }
    { "void*" "CallStaticObjectMethodA" }
    { "void*" "CallStaticBooleanMethod" }
    { "void*" "CallStaticBooleanMethodV" }
    { "void*" "CallStaticBooleanMethodA" }
    { "void*" "CallStaticByteMethod" }
    { "void*" "CallStaticByteMethodV" }
    { "void*" "CallStaticByteMethodA" }
    { "void*" "CallStaticCharMethod" }
    { "void*" "CallStaticCharMethodV" }
    { "void*" "CallStaticCharMethodA" }
    { "void*" "CallStaticShortMethod" }
    { "void*" "CallStaticShortMethodV" }
    { "void*" "CallStaticShortMethodA" }
    { "void*" "CallStaticIntMethod" }
    { "void*" "CallStaticIntMethodV" }
    { "void*" "CallStaticIntMethodA" }
    { "void*" "CallStaticLongMethod" }
    { "void*" "CallStaticLongMethodV" }
    { "void*" "CallStaticLongMethodA" }
    { "void*" "CallStaticFloatMethod" }
    { "void*" "CallStaticFloatMethodV" }
    { "void*" "CallStaticFloatMethodA" }
    { "void*" "CallStaticDoubleMethod" }
    { "void*" "CallStaticDoubleMethodV" }
    { "void*" "CallStaticDoubleMethodA" }
    { "void*" "CallStaticVoidMethod" }
    { "void*" "CallStaticVoidMethodV" }
    { "void*" "CallStaticVoidMethodA" }
    { "void*" "GetStaticFieldID" }
    { "void*" "GetStaticObjectField" }
    { "void*" "GetStaticBooleanField" }
    { "void*" "GetStaticByteField" }
    { "void*" "GetStaticCharField" }
    { "void*" "GetStaticShortField" }
    { "void*" "GetStaticIntField" }
    { "void*" "GetStaticLongField" }
    { "void*" "GetStaticFloatField" }
    { "void*" "GetStaticDoubleField" }
    { "void*" "SetStaticObjectField" }
    { "void*" "SetStaticBooleanField" }
    { "void*" "SetStaticByteField" }
    { "void*" "SetStaticCharField" }
    { "void*" "SetStaticShortField" }
    { "void*" "SetStaticIntField" }
    { "void*" "SetStaticLongField" }
    { "void*" "SetStaticFloatField" }
    { "void*" "SetStaticDoubleField" }
    { "void*" "NewString" }
    { "void*" "GetStringLength" }
    { "void*" "GetStringChars" }
    { "void*" "ReleaseStringChars" }
    { "void*" "NewStringUTF" }
    { "void*" "GetStringUTFLength" }
    { "void*" "GetStringUTFChars" }
    { "void*" "ReleaseStringUTFChars" }
    { "void*" "GetArrayLength" }
    { "void*" "NewObjectArray" }
    { "void*" "GetObjectArrayElement" }
    { "void*" "SetObjectArrayElement" }
    { "void*" "NewBooleanArray" }
    { "void*" "NewByteArray" }
    { "void*" "NewCharArray" }
    { "void*" "NewShortArray" }
    { "void*" "NewIntArray" }
    { "void*" "NewLongArray" }
    { "void*" "NewFloatArray" }
    { "void*" "NewDoubleArray" }
    { "void*" "GetBooleanArrayElements" }
    { "void*" "GetByteArrayElements" }
    { "void*" "GetCharArrayElements" }
    { "void*" "GetShortArrayElements" }
    { "void*" "GetIntArrayElements" }
    { "void*" "GetLongArrayElements" }
    { "void*" "GetFloatArrayElements" }
    { "void*" "GetDoubleArrayElements" }
    { "void*" "ReleaseBooleanArrayElements" }
    { "void*" "ReleaseByteArrayElements" }
    { "void*" "ReleaseCharArrayElements" }
    { "void*" "ReleaseShortArrayElements" }
    { "void*" "ReleaseIntArrayElements" }
    { "void*" "ReleaseLongArrayElements" }
    { "void*" "ReleaseFloatArrayElements" }
    { "void*" "ReleaseDoubleArrayElements" }
    { "void*" "GetBooleanArrayRegion" }
    { "void*" "GetByteArrayRegion" }
    { "void*" "GetCharArrayRegion" }
    { "void*" "GetShortArrayRegion" }
    { "void*" "GetIntArrayRegion" }
    { "void*" "GetLongArrayRegion" }
    { "void*" "GetFloatArrayRegion" }
    { "void*" "GetDoubleArrayRegion" }
    { "void*" "SetBooleanArrayRegion" }
    { "void*" "SetByteArrayRegion" }
    { "void*" "SetCharArrayRegion" }
    { "void*" "SetShortArrayRegion" }
    { "void*" "SetIntArrayRegion" }
    { "void*" "SetLongArrayRegion" }
    { "void*" "SetFloatArrayRegion" }
    { "void*" "SetDoubleArrayRegion" }
    { "void*" "RegisterNatives" }
    { "void*" "UnregisterNatives" }
    { "void*" "MonitorEnter" }
    { "void*" "MonitorExit" }
    { "void*" "GetJavaVM" }
    { "void*" "GetStringRegion" }
    { "void*" "GetStringUTFRegion" }
    { "void*" "GetPrimitiveArrayCritical" }
    { "void*" "ReleasePrimitiveArrayCritical" }
    { "void*" "GetStringCritical" }
    { "void*" "ReleaseStringCritical" }
    { "void*" "NewWeakGlobalRef" }
    { "void*" "DeleteWeakGlobalRef" }
    { "void*" "ExceptionCheck" }
    { "void*" "NewDirectByteBuffer" }
    { "void*" "GetDirectBufferAddress" }
    { "void*" "GetDirectBufferCapacity" } ;

C-STRUCT: JNIEnv
	{ "JNINativeInterface*" "functions" } ;

FUNCTION: jint JNI_GetDefaultJavaVMInitArgs ( jdk-init-args* args ) ;
FUNCTION: jint JNI_CreateJavaVM ( void** pvm, void** penv, void* args ) ;

: <jdk-init-args> ( -- jdk-init-args )
  "jdk-init-args" <c-object>  HEX: 00010004 over set-jdk-init-args-version ;

: jni1 ( -- init-args int )
  <jdk-init-args> dup JNI_GetDefaultJavaVMInitArgs ;

: jni2 ( -- vm env int )
  f <void*> f <void*> [
    jni1 drop JNI_CreateJavaVM
  ] 2keep rot dup 0 = [
    >r >r 0 swap void*-nth r> 0 swap void*-nth r> 
  ] when ;

: (destroy-java-vm) 
  "int" { "void*" } "cdecl" alien-indirect ;

: (attach-current-thread) 
  "int" { "void*" "void*" "void*" } "cdecl" alien-indirect ;

: (detach-current-thread) 
  "int" { "void*" } "cdecl" alien-indirect ;

: (get-env) 
  "int" { "void*" "void*" "int" } "cdecl" alien-indirect ;

: (attach-current-thread-as-daemon) 
  "int" { "void*" "void*" "void*" } "cdecl" alien-indirect ;

: destroy-java-vm ( javavm -- int )
  dup JavaVM-functions JNIInvokeInterface-DestroyJavaVM (destroy-java-vm) ;

: (get-version) 
  "jint" { "JNIEnv*" } "cdecl" alien-indirect ;

: get-version ( jnienv -- int )
  dup JNIEnv-functions JNINativeInterface-GetVersion (get-version) ;
  
: (find-class) 
  "void*" { "JNINativeInterface*" "char*" } "cdecl" alien-indirect ;

: find-class ( name jnienv -- int )
  dup swapd JNIEnv-functions JNINativeInterface-FindClass (find-class) ;

: (get-static-field-id) 
  "void*" { "JNINativeInterface*" "void*" "char*" "char*" } "cdecl" alien-indirect ;

: get-static-field-id ( class name sig jnienv -- int )
  dup >r >r 3array r> swap first3 r> JNIEnv-functions JNINativeInterface-GetStaticFieldID (get-static-field-id) ;

: (get-static-object-field) 
  "void*" { "JNINativeInterface*" "void*" "void*" } "cdecl" alien-indirect ;

: get-static-object-field ( class id jnienv -- int )
  dup >r >r 2array r> swap first2 r> JNIEnv-functions JNINativeInterface-GetStaticObjectField (get-static-object-field) ;

: (get-method-id) 
  "void*" { "JNINativeInterface*" "void*" "char*" "char*" } "cdecl" alien-indirect ;

: get-method-id ( class name sig jnienv -- int )
  dup >r >r 3array r> swap first3 r> JNIEnv-functions JNINativeInterface-GetMethodID (get-method-id) ;

: (new-string) 
  "void*" { "JNINativeInterface*" "char*" "int" } "cdecl" alien-indirect ;

: new-string ( str jnienv -- str )
  dup >r >r dup length 2array r> swap first2 r> JNIEnv-functions JNINativeInterface-NewString (new-string) ;

: (call1) 
  "void" { "JNINativeInterface*" "void*" "void*" "int" } "cdecl" alien-indirect ;

: call1 ( obj method-id jstr jnienv -- )
  dup >r >r 3array r> swap first3 r> JNIEnv-functions JNINativeInterface-CallObjectMethod (call1) ;

