! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
IN: jni
USING: kernel alien ;

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

FUNCTION: jint JNI_GetDefaultJavaVMInitArgs ( jdk-init-args* args ) ;
FUNCTION: jint JNI_CreateJavaVM ( void** pvm, void** penv, void* args ) ;

: <jdk-init-args> ( -- jdk-init-args )
  "jdk-init-args" <c-object>  HEX: 00010004 over set-jdk-init-args-version ;

: jni1 ( -- init-args int )
  <jdk-init-args> dup JNI_GetDefaultJavaVMInitArgs ;

: jni2 ( -- vm env int )
  f <void*> f <void*> [
    jni1 drop JNI_CreateJavaVM
  ] 2keep rot ;

: (destroy-java-vm) 
  "int" { "void*" } "cdecl" alien-indirect ;

: destroy-java-vm ( javavm -- int )
  0 swap void*-nth dup JavaVM-functions JNIInvokeInterface-DestroyJavaVM (destroy-java-vm) ;
