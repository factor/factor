! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs kernel accessors ;
IN: smalltalk.compiler.lexenv

! local-readers: assoc string => word
! local-writers: assoc string => word
! self: word or f for top-level forms
! class: class word or f for top-level forms
! method: generic word or f for top-level forms
TUPLE: lexenv local-readers local-writers self class method ;

: <lexenv> ( local-readers local-writers -- lexenv )
    f f f lexenv boa ; inline

CONSTANT: empty-lexenv T{ lexenv }

: lexenv-union ( lexenv1 lexenv2 -- lexenv )
    [ [ local-readers>> ] bi@ assoc-union ]
    [ [ local-writers>> ] bi@ assoc-union ] 2bi <lexenv> ;
