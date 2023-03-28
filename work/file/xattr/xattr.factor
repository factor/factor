! File: xattr.factor
! Version: 0.1
! DRI: Dave Carlton
! Description: Another fine Factor file!
! Copyright (C) 2017 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.strings assocs classes.tuple file.xattr.lib
 fry io io.encodings io.encodings.utf8 io.files io.launcher
 io.pathnames io.streams.c kernel kernel.private libc locals
 make math math.parser namespaces prettyprint sequences
extensions splitting strings threads unix.ffi uuid words
    ;
IN: file.xattr

TUPLE: xattr name value ;
C: <xattr> xattr 

: nameRead ( xattr -- name )   name>> ;

: quoted-value ( xattr -- value )
    value>> soft-quote ;

: (value) ( xattr -- value )
    value>> dup number?
    [ number>string ]
    [ unparse ]
    if
    ;

: valueRead ( xattr -- value )
    (value) soft-quote
    ;

SYMBOL: XATTRERROR

FROM: alien.strings => string>alien ;
FROM: file.xattr.lib => getxattr setxattr ; 
:: xattrStore ( xattr path -- )
    xattr value>>  number? 
    [ path  xattr name>>  xattr value>> number>string utf8 string>alien  ]
    [ path  xattr name>>  xattr value>> utf8 string>alien ]
    if yield  setxattr
    XATTRERROR set ;

:: path>xattrs ( path -- {xattr} )
    path xattr-values 
    keys [ path over  yield  getxattr <xattr> ] map
    ;
    
