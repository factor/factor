! File: ffi.factor
! Version: 0.1
! DRI: Dave Carlton
! Description: Another fine Factor file!
! Copyright (C) 2017 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.

USING: alien alien.c-types alien.libraries alien.syntax combinators
unix.types system ;

IN: xattr.ffi

<<
"libxattr" {
        { [ os macosx? ] [ "/usr/lib/libSystem.dylib" ] }
        { [ os linux? ]  [ "/lib/x86_64-linux-gnu/libattr.a" ] }
} cond
cdecl add-library >>

! "libsystemB" "/usr/lib/libSystemB.dylib" cdecl add-library

LIBRARY: libsystem

FUNCTION-ALIAS: (getxattr)
ssize_t getxattr ( c-string path, c-string  name, void* value, size_t size, u_int32_t position, int optionals )

FUNCTION-ALIAS: (fgetxattr)
ssize_t fgetxattr ( int fd, c-string name, void* value, size_t size, u_int32_t position, int options ) 

FUNCTION-ALIAS: (setxattr)
int setxattr ( c-string path, c-string name, void* value, size_t size, u_int32_t position, int options ) 

FUNCTION-ALIAS: (fsetxattr)
int fsetxattr ( int fd, c-string name, void* value, size_t size, u_int32_t position, int options ) 

FUNCTION-ALIAS: (removexattr)
int removexattr ( c-string path, c-string name, int options ) 

FUNCTION-ALIAS: (fremovexattr)
int fremovexattr ( int fd, c-string name, int options ) 

FUNCTION-ALIAS: (listxattr)
ssize_t listxattr  (  c-string path, c-string namebuff, size_t size, int options  ) 
 
FUNCTION-ALIAS: (flistxattr)
ssize_t flistxattr ( int fd, c-string namebuff, size_t size, int options ) 

