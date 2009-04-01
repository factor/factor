! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: compiler.units smalltalk.parser smalltalk.compiler ;
IN: smalltalk.eval

: eval-smalltalk ( string -- result )
    [ parse-smalltalk compile-smalltalk ] with-compilation-unit
    call( -- result ) ;