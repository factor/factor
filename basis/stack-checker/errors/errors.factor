! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel generic sequences io words arrays summary effects
assocs accessors namespaces compiler.errors stack-checker.values
stack-checker.recursive-state ;
IN: stack-checker.errors

TUPLE: inference-error error type word ;

M: inference-error compiler-error-type type>> ;

: (inference-error) ( ... class type -- * )
    [ boa ] dip
    recursive-state get word>>
    \ inference-error boa throw ; inline

: inference-error ( ... class -- * )
    +error+ (inference-error) ; inline

: inference-warning ( ... class -- * )
    +warning+ (inference-error) ; inline

TUPLE: literal-expected ;

M: object (literal) \ literal-expected inference-warning ;

TUPLE: unbalanced-branches-error branches quots ;

: unbalanced-branches-error ( branches quots -- * )
    \ unbalanced-branches-error inference-error ;

TUPLE: too-many->r ;

TUPLE: too-many-r> ;

TUPLE: missing-effect word ;

TUPLE: effect-error word inferred declared ;

: effect-error ( word inferred declared -- * )
    \ effect-error inference-error ;

TUPLE: recursive-quotation-error quot ;

TUPLE: undeclared-recursion-error word ;

TUPLE: diverging-recursion-error word ;

TUPLE: unbalanced-recursion-error word height ;

TUPLE: inconsistent-recursive-call-error word ;

TUPLE: unknown-primitive-error ;
