! File: lib.factor
! Version: 0.1
! DRI: Dave Carlton
! Description: Another fine Factor file!
! Copyright (C) 2017 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.

USING: alien alien.c-types alien.strings continuations
file.xattr.ffi io.backend io.encodings.utf8 kernel libc locals
math sequences xattr.ffi extensions syntax.terse ;
IN: file.xattr.lib

CONSTANT: TEST "/Users/davec/test"
CONSTANT: TESTKEY1 "net.polymicro.checksum.fnv1-32"
CONSTANT: TESTKEY2 "net.polymicro.sha"

! ssize_t getxattr ( c-string path, c-string  name, void* value, size_t size, u_int32_t position, int optionals )
:: getxattr ( path key -- value )
    f :> value!
    path normalize-path :> apath!
    apath key f 0 0 0 (getxattr) :> size!
    size  0 over =  swap -1 =  or not [
        apath key
        size malloc :> xvalue
        xvalue size  0 0 (getxattr) drop
        xvalue utf8 alien>string value!
        xvalue free
    ] when
    value ;
    
! ssize_t fgetxattr ( int fd, c-string name, void *value, size_t size, u_int32_t position, int options ) 
:: fgetxattr ( fd key -- size )
    f :> value!
    fd key f 0 0 0 (fgetxattr) :> size!
    size [
        size malloc :> xvalue
        fd key xvalue size 0 0 (fgetxattr) drop
        xvalue utf8 alien>string value!
        xvalue free
    ] when
    value ;
    
! int setxattr ( c-string path, c-string name, void *value, size_t size, u_int32_t position, int options )
: setxattr ( path key value -- result )
    [ normalize-path ] 2dip  dup length  0 0 (setxattr) ;

! int fsetxattr ( int fd, c-string name, void *value, size_t size, u_int32_t position, int options ) 
! int removexattr ( c-string path, c-string name, int options ) 
! int fremovexattr ( int fd, c-string name, int options )

! Probably should walk the ptr and collect the bytes
:: xattr-strings ( len alien -- strings )
    alien :> ptr!
    0 :> slength!
    len alien <displaced-alien> alien-address :> end
    { } :> seq!
    [ ptr alien-address end < ] 
    [ ptr utf8 alien>string :> newstring
      newstring length :> slength
      seq newstring suffix  seq!
      slength 1+ ptr <displaced-alien> ptr!
    ] while
    seq ;
      
! ssize_t listxattr  (  c-string path, c-string namebuff, size_t size, int options  )
:: listxattr ( path -- xattrs )
    path normalize-path :> npath
    npath f 0 0 (listxattr) :> size
    size -1 =
    [ f ] 
    [ size malloc :> buf
      buf -1 =
      [ f ]
      [ npath buf size 0 (listxattr)  buf xattr-strings ]
      if
    ] if
    ;

:: xattr-values ( path -- {{key:value}} )
    path listxattr :> keys
    keys [ path over getxattr  { } 2sequence  ] map
    ;

! ssize_t flistxattr ( int fd, c-string namebuff, size_t size, int options ) 

