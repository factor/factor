! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: compiler.units io.encodings.utf8 io.files
smalltalk.compiler smalltalk.parser ;
IN: smalltalk.eval

: eval-smalltalk ( string -- result )
    [ parse-smalltalk compile-smalltalk ] with-compilation-unit
    call( -- result ) ;

: eval-smalltalk-file ( path -- result )
    utf8 file-contents eval-smalltalk ;
