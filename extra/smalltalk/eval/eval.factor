! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.files io.encodings.utf8
compiler.units smalltalk.parser smalltalk.compiler
smalltalk.library ;
IN: smalltalk.eval

: eval-smalltalk ( string -- result )
    [ parse-smalltalk compile-smalltalk ] with-compilation-unit
    call( -- result ) ;

: eval-smalltalk-file ( path -- result )
    utf8 file-contents eval-smalltalk ;
