! File: xattr.factor
! Version: 0.1
! DRI: Dave Carlton
! Description: Another fine Factor file!
! Copyright (C) 2017 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.strings assocs classes.tuple file.xattr.lib
 fry io io.encodings io.encodings.utf8 io.files io.launcher
 io.streams.c kernel kernel.private libc locals make
 math math.parser namespaces prettyprint sequences splitting
 strings threads unix.ffi uuid words  ;
IN: file.xattr

TUPLE: xattr name value ;
C: <xattr> xattr 

: nameRead ( xattr -- name )   name>> ;

: soft-quote ( string -- string' )
    "\"" dup surround ;
: hard-quote ( string -- string' )
    "'" dup surround ;

: escape-string-by ( str table -- escaped )
    ! Convert $, (, ), ' and " to shell escapes
    [ '[ [ _ at ] [ % ] [ , ] ?if ] each ] "" make ;

CONSTANT: PATH_ESCAPE_CHARS H{
       { CHAR: \s "\\ "  }
       { CHAR: \n "?"    }
       { CHAR: (  "\\("  }
       { CHAR: )  "\\)"  }
       { CHAR: &  "\\&"  }
       { CHAR: $  "\\$"  }
       { CHAR: ;  "\\;"  }
       { CHAR: "  "\""   }      ! for editor's sake "
       { CHAR: '  "\\'"  } 
       { CHAR: `  "\\`"  }
       }
       
: escape-string ( str -- str' )
    [ dup
      [ PATH_ESCAPE_CHARS at ] [ nip ] [ drop 1string ] ?if
    ] { } map-as
    "" join ; 

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
    
