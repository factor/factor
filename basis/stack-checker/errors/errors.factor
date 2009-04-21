! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel generic sequences io words arrays summary effects
continuations assocs accessors namespaces compiler.errors
stack-checker.values stack-checker.recursive-state
source-files.errors compiler.errors ;
IN: stack-checker.errors

: pretty-word ( word -- word' )
    dup method-body? [ "method-generic" word-prop ] when ;

TUPLE: inference-error error type word ;

M: inference-error error-type type>> ;

: (inference-error) ( ... class type -- * )
    [ boa ] dip
    recursive-state get word>>
    \ inference-error boa rethrow ; inline

: inference-error ( ... class -- * )
    +compiler-error+ (inference-error) ; inline

: inference-warning ( ... class -- * )
    +compiler-warning+ (inference-error) ; inline

TUPLE: do-not-compile word ;

: do-not-compile ( word -- * ) \ do-not-compile inference-warning ;

TUPLE: literal-expected what ;

: literal-expected ( what -- * ) \ literal-expected inference-warning ;

M: object (literal) "literal value" literal-expected ;

TUPLE: unbalanced-branches-error branches quots ;

: unbalanced-branches-error ( branches quots -- * )
    \ unbalanced-branches-error inference-error ;

TUPLE: too-many->r ;

: too-many->r ( -- * ) \ too-many->r inference-error ;

TUPLE: too-many-r> ;

: too-many-r> ( -- * ) \ too-many-r> inference-error ;

TUPLE: missing-effect word ;

: missing-effect ( word -- * )
    pretty-word \ missing-effect inference-error ;

TUPLE: effect-error inferred declared ;

: effect-error ( inferred declared -- * )
    \ effect-error inference-error ;

TUPLE: recursive-quotation-error quot ;

: recursive-quotation-error ( word -- * )
    \ recursive-quotation-error inference-error ;

TUPLE: undeclared-recursion-error word ;

: undeclared-recursion-error ( word -- * )
    \ undeclared-recursion-error inference-error ;

TUPLE: diverging-recursion-error word ;

: diverging-recursion-error ( word -- * )
    \ diverging-recursion-error inference-error ;

TUPLE: unbalanced-recursion-error word height ;

: unbalanced-recursion-error ( word height -- * )
    \ unbalanced-recursion-error inference-error ;

TUPLE: inconsistent-recursive-call-error word ;

: inconsistent-recursive-call-error ( word -- * )
    \ inconsistent-recursive-call-error inference-error ;

TUPLE: unknown-primitive-error ;

: unknown-primitive-error ( -- * )
    \ unknown-primitive-error inference-warning ;

TUPLE: transform-expansion-error word error ;

: transform-expansion-error ( word error -- * )
    \ transform-expansion-error inference-error ;