! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
IN: jni
USING: kernel jni-internals namespaces ;

! High level interface for JNI to be added here...

: test0 ( -- )
  jni2 drop nip "env" set ;

: test1 ( -- system )
  "java/lang/System" "env" get find-class ;

: test2 ( system -- system.out )
  dup "out" "Ljava/io/PrintStream;" "env" get get-static-field-id 
  "env" get get-static-object-field ;

: test3 ( int system.out -- )
  "java/io/PrintStream" "env" get find-class ! jstr out class
  "println" "(I)V" "env" get get-method-id ! jstr out id
  rot "env" get call1 ;
  