! Copyright (C) 2007, 2009 Slava Pestov, Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors classes.struct classes.tuple
classes.tuple.private combinators combinators.short-circuit
continuations generic kernel namespaces quotations sequences
stack-checker.backend stack-checker.dependencies
stack-checker.errors stack-checker.recursive-state
stack-checker.values stack-checker.visitor words ;

IN: stack-checker.transforms

: call-transformer ( stack quot -- newquot )
    '[ _ _ with-datastack [ length 1 assert= ] [ first ] bi ]
    [ error-continuation get current-word get transform-expansion-error ]
    recover ;

:: apply-literal-values-transform ( quot values stack rstate -- )
    rstate recursive-state [ stack quot call-transformer ] with-variable
    values [ length shorten-d ] [ #drop, ] bi
    rstate infer-quot ;

: literal-values? ( values -- ? ) [ literal-value? ] all? ;

: input-values? ( values -- ? )
    [ { [ literal-value? ] [ input-value? ] } 1|| ] all? ;

: (apply-transform) ( quot n -- )
    ensure-d {
        { [ dup literal-values? ] [
            dup empty? [ dup recursive-state get ] [
                [ ]
                [ [ literal value>> ] map ]
                [ first literal recursion>> ] tri
            ] if
            apply-literal-values-transform
        ] }
        { [ dup input-values? ] [ drop current-word get unknown-macro-input ] }
        [ drop current-word get bad-macro-input ]
    } cond ;

: apply-transform ( word -- )
    [ current-word set ]
    [ "transform-quot" word-prop ]
    [ "transform-n" word-prop ] tri
    (apply-transform) ;

: apply-macro ( word -- )
    [ current-word set ]
    [ "macro" word-prop ]
    [ "declared-effect" word-prop in>> length ] tri
    (apply-transform) ;

: define-transform ( word quot n -- )
    [ drop "transform-quot" set-word-prop ]
    [ nip "transform-n" set-word-prop ]
    3bi ;

! Combinators
\ cond [ cond>quot ] 1 define-transform

\ cond t "no-compile" set-word-prop

\ case [
    [
        [ no-case ]
    ] [
        dup [ callable? ] find dup
        [ [ head ] dip ] [ 2drop [ no-case ] ] if
        swap case>quot
    ] if-empty
] 1 define-transform

\ case t "no-compile" set-word-prop

\ cleave [ cleave>quot ] 1 define-transform

\ cleave t "no-compile" set-word-prop

\ 2cleave [ 2cleave>quot ] 1 define-transform

\ 2cleave t "no-compile" set-word-prop

\ 3cleave [ 3cleave>quot ] 1 define-transform

\ 3cleave t "no-compile" set-word-prop

\ 4cleave [ 4cleave>quot ] 1 define-transform

\ 4cleave t "no-compile" set-word-prop

\ spread [ deep-spread>quot ] 1 define-transform

\ spread t "no-compile" set-word-prop

\ 0&& [ '[ _ 0 n&& ] ] 1 define-transform

\ 0&& t "no-compile" set-word-prop

\ 1&& [ '[ _ 1 n&& ] ] 1 define-transform

\ 1&& t "no-compile" set-word-prop

\ 2&& [ '[ _ 2 n&& ] ] 1 define-transform

\ 2&& t "no-compile" set-word-prop

\ 3&& [ '[ _ 3 n&& ] ] 1 define-transform

\ 3&& t "no-compile" set-word-prop

\ 0|| [ '[ _ 0 n|| ] ] 1 define-transform

\ 0|| t "no-compile" set-word-prop

\ 1|| [ '[ _ 1 n|| ] ] 1 define-transform

\ 1|| t "no-compile" set-word-prop

\ 2|| [ '[ _ 2 n|| ] ] 1 define-transform

\ 2|| t "no-compile" set-word-prop

\ 3|| [ '[ _ 3 n|| ] ] 1 define-transform

\ 3|| t "no-compile" set-word-prop

: add-next-method-dependency ( method -- )
    [ "method-class" word-prop ]
    [ "method-generic" word-prop ] bi
    2dup next-method
    add-depends-on-next-method ;

\ (call-next-method) [
    [ add-next-method-dependency ]
    [ [ next-method-quot ] [ '[ _ no-next-method ] ] bi or ] bi
] 1 define-transform

\ (call-next-method) t "no-compile" set-word-prop

! Constructors
\ boa [
    {
        { [ dup struct-class? ] [
            dup dup struct-slots add-depends-on-struct-slots
            '[ _ <struct-boa> ] ] }
        { [ dup tuple-class? ] [
            dup tuple-layout
            [ add-depends-on-tuple-layout ]
            [ [ "boa-check" word-prop [ ] or ] dip ] 2bi
            '[ @ _ <tuple-boa> ]
            ] }
        [ \ boa time-bomb ]
    } cond
] 1 define-transform

\ boa t "no-compile" set-word-prop
