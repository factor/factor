! Copyright (C) 2010 Erik Charlebois.
! See http://factorcode.org/license.txt for BSD license.
USING: classes.parser classes.singleton classes.union kernel lexer
sequences ;
IN: opencl.syntax

SYNTAX: SINGLETONS-UNION:
    CREATE-CLASS ";" parse-tokens [ create-class-in [ define-singleton-class ] keep ] map define-union-class ;
