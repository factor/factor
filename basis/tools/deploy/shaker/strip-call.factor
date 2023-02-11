! Copyright (C) 2009 Slava Pestov
! See https://factorcode.org/license.txt for BSD license.
USING: combinators.private kernel ;
IN: combinators

: call-effect ( word effect -- ) call-effect-unsafe ;

: execute-effect ( word effect -- ) execute-effect-unsafe ;

IN: compiler.tree.propagation.call-effect

: call-effect-unsafe? ( quot effect -- ? ) 2drop t ; inline

: execute-effect-unsafe? ( word effect -- ? ) 2drop t ; inline
