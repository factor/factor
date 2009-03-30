! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs kernel accessors ;
IN: smalltalk.compiler.lexenv

TUPLE: lexenv local-readers local-writers ;

C: <lexenv> lexenv

CONSTANT: empty-lexenv T{ lexenv }

: lexenv-union ( lexenv1 lexenv2 -- lexenv )
    [ [ local-readers>> ] bi@ assoc-union ]
    [ [ local-writers>> ] bi@ assoc-union ] 2bi <lexenv> ;
