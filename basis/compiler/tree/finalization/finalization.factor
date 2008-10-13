! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel arrays accessors sequences sequences.private words
fry namespaces make math math.private math.order memoize
classes.builtin classes.tuple.private classes.algebra
slots.private combinators layouts byte-arrays alien.accessors
compiler.intrinsics
compiler.tree
compiler.tree.combinators
compiler.tree.propagation.info
compiler.tree.late-optimizations ;
IN: compiler.tree.finalization

! This is a late-stage optimization.
! See the comment in compiler.tree.late-optimizations.

! This pass runs after propagation, so that it can expand
! built-in type predicates and memory allocation; these cannot
! be expanded before propagation since we need to see 'fixnum?'
! instead of 'tag 0 eq?' and so on, for semantic reasoning.
! We also delete empty stack shuffles and copies to facilitate
! tail call optimization in the code generator.

GENERIC: finalize* ( node -- nodes )

: finalize ( nodes -- nodes' ) [ finalize* ] map-nodes ;

: splice-final ( quot -- nodes ) splice-quot finalize ;

M: #copy finalize* drop f ;

M: #shuffle finalize*
    dup shuffle-effect
    [ in>> ] [ out>> ] bi sequence=
    [ drop f ] when ;

: builtin-predicate? ( #call -- ? )
    word>> "predicating" word-prop builtin-class? ;

MEMO: builtin-predicate-expansion ( word -- nodes )
    def>> splice-final ;

: expand-builtin-predicate ( #call -- nodes )
    word>> builtin-predicate-expansion ;

: expand-tuple-boa? ( #call -- ? )
    dup word>> \ <tuple-boa> eq? [
        last-literal tuple-layout?
    ] [ drop f ] if ;

MEMO: (tuple-boa-expansion) ( n -- nodes )
    [
        [ '[ _ (tuple) ] % ]
        [
            [ 2 + ] map <reversed>
            [ '[ [ _ set-slot ] keep ] % ] each
        ] bi
    ] [ ] make '[ _ dip ] splice-final ;

: tuple-boa-expansion ( layout -- quot )
    #! No memoization here since otherwise we'd hang on to
    #! tuple layout objects.
    size>> (tuple-boa-expansion)
    [ over 1 set-slot ] splice-final append ;

: expand-tuple-boa ( #call -- node )
    last-literal tuple-boa-expansion ;

MEMO: <array>-expansion ( n -- quot )
    [
        [ swap (array) ] %
        [ '[ _ over 1 set-slot ] % ]
        [ [ '[ 2dup _ swap set-array-nth ] % ] each ] bi
        \ nip ,
    ] [ ] make splice-final ;

: expand-<array>? ( #call -- ? )
    dup word>> \ <array> eq? [
        first-literal dup integer?
        [ 0 8 between? ] [ drop f ] if
    ] [ drop f ] if ;

: expand-<array> ( #call -- node )
    first-literal <array>-expansion ;

: bytes>cells ( m -- n ) cell align cell /i ;

MEMO: <byte-array>-expansion ( n -- quot )
    [
        [ (byte-array) ] %
        [ '[ _ over 1 set-slot ] % ]
        [
            bytes>cells [
                cell *
                '[ 0 over _ set-alien-unsigned-cell ] %
            ] each
        ] bi
    ] [ ] make splice-final ;

: expand-<byte-array>? ( #call -- ? )
    dup word>> \ <byte-array> eq? [
        first-literal dup integer?
        [ 0 32 between? ] [ drop f ] if
    ] [ drop f ] if ;

: expand-<byte-array> ( #call -- nodes )
    first-literal <byte-array>-expansion ;

MEMO: <ratio>-expansion ( -- quot )
    [ (ratio) [ 2 set-slot ] keep [ 1 set-slot ] keep ] splice-final ;

: expand-<ratio> ( #call -- nodes )
    drop <ratio>-expansion ;

MEMO: <complex>-expansion ( -- quot )
    [ (complex) [ 2 set-slot ] keep [ 1 set-slot ] keep ] splice-final ;

: expand-<complex> ( #call -- nodes )
    drop <complex>-expansion ;

MEMO: <wrapper>-expansion ( -- quot )
    [ (wrapper) [ 1 set-slot ] keep ] splice-final ;

: expand-<wrapper> ( #call -- nodes )
    drop <wrapper>-expansion ;

MEMO: slot-expansion ( tag -- nodes )
    '[ _ (slot) ] splice-final ;

: value-tag ( node value -- n )
    node-value-info class>> class-tag ;

: expand-slot ( #call -- nodes )
    dup dup in-d>> first value-tag [ slot-expansion ] [ ] ?if ;

MEMO: set-slot-expansion ( write-barrier? tag# -- nodes )
    [ '[ [ _ (set-slot) ] [ drop (write-barrier) ] 2bi ] ]
    [ '[ _ (set-slot) ] ]
    bi ? splice-final ;

: expand-set-slot ( #call -- nodes )
    dup dup in-d>> second value-tag [
        [ dup in-d>> first node-value-info class>> immediate class<= not ] dip
        set-slot-expansion
    ] when* ;

M: #call finalize*
    {
        { [ dup builtin-predicate? ] [ expand-builtin-predicate ] }
        { [ dup expand-tuple-boa? ] [ expand-tuple-boa ] }
        { [ dup expand-<array>? ] [ expand-<array> ] }
        { [ dup expand-<byte-array>? ] [ expand-<byte-array> ] }
        [
            dup word>> {
                { \ <ratio> [ expand-<ratio> ] }
                { \ <complex> [ expand-<complex> ] }
                { \ <wrapper> [ expand-<wrapper> ] }
                { \ set-slot [ expand-set-slot ] }
                { \ slot [ expand-slot ] }
                [ drop ]
            } case
        ]
    } cond ;

M: node finalize* ;
