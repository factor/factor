! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
IN: jni
USING: kernel alien arrays sequences ;

LIBRARY: jvm

TYPEDEF: int jint
TYPEDEF: uchar jboolean
TYPEDEF: void* JNIEnv

BEGIN-STRUCT: jdk-init-args
	FIELD: jint version
	FIELD: void* properties
	FIELD: jint check-source
	FIELD: jint native-stack-size
	FIELD: jint java-stack-size
	FIELD: jint min-heap-size
	FIELD: jint max-heap-size
	FIELD: jint verify-mode
	FIELD: char* classpath
	FIELD: void* vprintf
	FIELD: void* exit
	FIELD: void* abort
	FIELD: jint enable-class-gc
	FIELD: jint enable-verbose-gc
	FIELD: jint disable-async-gc
	FIELD: jint verbose
	FIELD: jboolean debugging
	FIELD: jint debug-port
END-STRUCT

BEGIN-STRUCT: JNIInvokeInterface
	FIELD: void* reserved0
	FIELD: void* reserved1
	FIELD: void* reserved2
	FIELD: void* DestroyJavaVM
	FIELD: void* AttachCurrentThread
	FIELD: void* DetachCurrentThread
	FIELD: void* GetEnv
	FIELD: void* AttachCurrentThreadAsDaemon
END-STRUCT

BEGIN-STRUCT: JavaVM
	FIELD: JNIInvokeInterface* functions
END-STRUCT

BEGIN-STRUCT: JNINativeInterface
	FIELD: void* reserved0
	FIELD: void* reserved1
	FIELD: void* reserved2
	FIELD: void* reserved3
	FIELD: void* GetVersion
	FIELD: void* DefineClass
	FIELD: void* FindClass
	FIELD: void* FromReflectedMethod
	FIELD: void* FromReflectedField
	FIELD: void* ToReflectedMethod
	FIELD: void* GetSuperclass
	FIELD: void* IsAssignableFrom
	FIELD: void* ToReflectedField
        FIELD: void* Throw
        FIELD: void* ThrowNew
        FIELD: void* ExceptionOccurred
        FIELD: void* ExceptionDescribe
        FIELD: void* ExceptionClear
        FIELD: void* FatalError
        FIELD: void* PushLocalFrame
        FIELD: void* PopLocalFrame
        FIELD: void* NewGlobalRef
        FIELD: void* DeleteGlobalRef
        FIELD: void* DeleteLocalRef
        FIELD: void* IsSameObject
        FIELD: void* NewLocalRef
        FIELD: void* EnsureLocalCapacity
        FIELD: void* AllocObject
        FIELD: void* NewObject
        FIELD: void* NewObjectV
        FIELD: void* NewObjectA
        FIELD: void* GetObjectClass
        FIELD: void* IsInstanceOf
        FIELD: void* GetMethodID
        FIELD: void* CallObjectMethod
        FIELD: void* CallObjectMethodV
        FIELD: void* CallObjectMethodA
        FIELD: void* CallBooleanMethod
        FIELD: void* CallBooleanMethodV
        FIELD: void* CallBooleanMethodA
        FIELD: void* CallByteMethod
        FIELD: void* CallByteMethodV
        FIELD: void* CallByteMethodA
        FIELD: void* CallCharMethod
        FIELD: void* CallCharMethodV
        FIELD: void* CallCharMethodA
        FIELD: void* CallShortMethod
        FIELD: void* CallShortMethodV
        FIELD: void* CallShortMethodA
        FIELD: void* CallIntMethod
        FIELD: void* CallIntMethodV
        FIELD: void* CallIntMethodA
        FIELD: void* CallLongMethod
        FIELD: void* CallLongMethodV
        FIELD: void* CallLongMethodA
        FIELD: void* CallFloatMethod
        FIELD: void* CallFloatMethodV
        FIELD: void* CallFloatMethodA
        FIELD: void* CallDoubleMethod
        FIELD: void* CallDoubleMethodV
        FIELD: void* CallDoubleMethodA
        FIELD: void* CallVoidMethod
        FIELD: void* CallVoidMethodV
        FIELD: void* CallVoidMethodA
        FIELD: void* CallNonvirtualObjectMethod
        FIELD: void* CallNonvirtualObjectMethodV
        FIELD: void* CallNonvirtualObjectMethodA
        FIELD: void* CallNonvirtualBooleanMethod
        FIELD: void* CallNonvirtualBooleanMethodV
        FIELD: void* CallNonvirtualBooleanMethodA
        FIELD: void* CallNonvirtualByteMethod
        FIELD: void* CallNonvirtualByteMethodV
        FIELD: void* CallNonvirtualByteMethodA
        FIELD: void* CallNonvirtualCharMethod
        FIELD: void* CallNonvirtualCharMethodV
        FIELD: void* CallNonvirtualCharMethodA
        FIELD: void* CallNonvirtualShortMethod
        FIELD: void* CallNonvirtualShortMethodV
        FIELD: void* CallNonvirtualShortMethodA
        FIELD: void* CallNonvirtualIntMethod
        FIELD: void* CallNonvirtualIntMethodV
        FIELD: void* CallNonvirtualIntMethodA
        FIELD: void* CallNonvirtualLongMethod
        FIELD: void* CallNonvirtualLongMethodV
        FIELD: void* CallNonvirtualLongMethodA
        FIELD: void* CallNonvirtualFloatMethod
        FIELD: void* CallNonvirtualFloatMethodV
        FIELD: void* CallNonvirtualFloatMethodA
        FIELD: void* CallNonvirtualDoubleMethod
        FIELD: void* CallNonvirtualDoubleMethodV
        FIELD: void* CallNonvirtualDoubleMethodA
        FIELD: void* CallNonvirtualVoidMethod
        FIELD: void* CallNonvirtualVoidMethodV
        FIELD: void* CallNonvirtualVoidMethodA
        FIELD: void* GetFieldID
        FIELD: void* GetObjectField
        FIELD: void* GetBooleanField
        FIELD: void* GetByteField
        FIELD: void* GetCharField
        FIELD: void* GetShortField
        FIELD: void* GetIntField
        FIELD: void* GetLongField
        FIELD: void* GetFloatField
        FIELD: void* GetDoubleField
        FIELD: void* SetObjectField
        FIELD: void* SetBooleanField
        FIELD: void* SetByteField
        FIELD: void* SetCharField
        FIELD: void* SetShortField
        FIELD: void* SetIntField
        FIELD: void* SetLongField
        FIELD: void* SetFloatField
        FIELD: void* SetDoubleField
        FIELD: void* GetStaticMethodID
        FIELD: void* CallStaticObjectMethod
        FIELD: void* CallStaticObjectMethodV
        FIELD: void* CallStaticObjectMethodA
        FIELD: void* CallStaticBooleanMethod
        FIELD: void* CallStaticBooleanMethodV
        FIELD: void* CallStaticBooleanMethodA
        FIELD: void* CallStaticByteMethod
        FIELD: void* CallStaticByteMethodV
        FIELD: void* CallStaticByteMethodA
        FIELD: void* CallStaticCharMethod
        FIELD: void* CallStaticCharMethodV
        FIELD: void* CallStaticCharMethodA
        FIELD: void* CallStaticShortMethod
        FIELD: void* CallStaticShortMethodV
        FIELD: void* CallStaticShortMethodA
        FIELD: void* CallStaticIntMethod
        FIELD: void* CallStaticIntMethodV
        FIELD: void* CallStaticIntMethodA
        FIELD: void* CallStaticLongMethod
        FIELD: void* CallStaticLongMethodV
        FIELD: void* CallStaticLongMethodA
        FIELD: void* CallStaticFloatMethod
        FIELD: void* CallStaticFloatMethodV
        FIELD: void* CallStaticFloatMethodA
        FIELD: void* CallStaticDoubleMethod
        FIELD: void* CallStaticDoubleMethodV
        FIELD: void* CallStaticDoubleMethodA
        FIELD: void* CallStaticVoidMethod
        FIELD: void* CallStaticVoidMethodV
        FIELD: void* CallStaticVoidMethodA
        FIELD: void* GetStaticFieldID
        FIELD: void* GetStaticObjectField
        FIELD: void* GetStaticBooleanField
        FIELD: void* GetStaticByteField
        FIELD: void* GetStaticCharField
        FIELD: void* GetStaticShortField
        FIELD: void* GetStaticIntField
        FIELD: void* GetStaticLongField
        FIELD: void* GetStaticFloatField
        FIELD: void* GetStaticDoubleField
        FIELD: void* SetStaticObjectField
        FIELD: void* SetStaticBooleanField
        FIELD: void* SetStaticByteField
        FIELD: void* SetStaticCharField
        FIELD: void* SetStaticShortField
        FIELD: void* SetStaticIntField
        FIELD: void* SetStaticLongField
        FIELD: void* SetStaticFloatField
        FIELD: void* SetStaticDoubleField
        FIELD: void* NewString
        FIELD: void* GetStringLength
        FIELD: void* GetStringChars
        FIELD: void* ReleaseStringChars
        FIELD: void* NewStringUTF
        FIELD: void* GetStringUTFLength
        FIELD: void* GetStringUTFChars
        FIELD: void* ReleaseStringUTFChars
        FIELD: void* GetArrayLength
        FIELD: void* NewObjectArray
        FIELD: void* GetObjectArrayElement
        FIELD: void* SetObjectArrayElement
        FIELD: void* NewBooleanArray
        FIELD: void* NewByteArray
        FIELD: void* NewCharArray
        FIELD: void* NewShortArray
        FIELD: void* NewIntArray
        FIELD: void* NewLongArray
        FIELD: void* NewFloatArray
        FIELD: void* NewDoubleArray
        FIELD: void* GetBooleanArrayElements
        FIELD: void* GetByteArrayElements
        FIELD: void* GetCharArrayElements
        FIELD: void* GetShortArrayElements
        FIELD: void* GetIntArrayElements
        FIELD: void* GetLongArrayElements
        FIELD: void* GetFloatArrayElements
        FIELD: void* GetDoubleArrayElements
        FIELD: void* ReleaseBooleanArrayElements
        FIELD: void* ReleaseByteArrayElements
        FIELD: void* ReleaseCharArrayElements
        FIELD: void* ReleaseShortArrayElements
        FIELD: void* ReleaseIntArrayElements
        FIELD: void* ReleaseLongArrayElements
        FIELD: void* ReleaseFloatArrayElements
        FIELD: void* ReleaseDoubleArrayElements
        FIELD: void* GetBooleanArrayRegion
        FIELD: void* GetByteArrayRegion
        FIELD: void* GetCharArrayRegion
        FIELD: void* GetShortArrayRegion
        FIELD: void* GetIntArrayRegion
        FIELD: void* GetLongArrayRegion
        FIELD: void* GetFloatArrayRegion
        FIELD: void* GetDoubleArrayRegion
        FIELD: void* SetBooleanArrayRegion
        FIELD: void* SetByteArrayRegion
        FIELD: void* SetCharArrayRegion
        FIELD: void* SetShortArrayRegion
        FIELD: void* SetIntArrayRegion
        FIELD: void* SetLongArrayRegion
        FIELD: void* SetFloatArrayRegion
        FIELD: void* SetDoubleArrayRegion
        FIELD: void* RegisterNatives
        FIELD: void* UnregisterNatives
        FIELD: void* MonitorEnter
        FIELD: void* MonitorExit
        FIELD: void* GetJavaVM
        FIELD: void* GetStringRegion
        FIELD: void* GetStringUTFRegion
        FIELD: void* GetPrimitiveArrayCritical
        FIELD: void* ReleasePrimitiveArrayCritical
        FIELD: void* GetStringCritical
        FIELD: void* ReleaseStringCritical
        FIELD: void* NewWeakGlobalRef
        FIELD: void* DeleteWeakGlobalRef
        FIELD: void* ExceptionCheck
        FIELD: void* NewDirectByteBuffer
        FIELD: void* GetDirectBufferAddress
        FIELD: void* GetDirectBufferCapacity
END-STRUCT

BEGIN-STRUCT: JNIEnv
	FIELD: JNINativeInterface* functions
END-STRUCT

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
