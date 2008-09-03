! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel arrays accessors sequences sequences.private words
fry namespaces math math.order memoize classes.builtin
classes.tuple.private slots.private combinators layouts
byte-arrays alien.accessors
compiler.intrinsics
compiler.tree
compiler.tree.builder
compiler.tree.normalization
compiler.tree.propagation
compiler.tree.propagation.info
compiler.tree.cleanup
compiler.tree.def-use
compiler.tree.dead-code
compiler.tree.combinators ;
IN: compiler.tree.finalization

! This pass runs after propagation, so that it can expand
! built-in type predicates and memory allocation; these cannot
! be expanded before propagation since we need to see 'fixnum?'
! instead of 'tag 0 eq?' and so on, for semantic reasoning.
! We also delete empty stack shuffles and copies to facilitate
! tail call optimization in the code generator. After this pass
! runs, stack flow information is no longer accurate, since we
! punt in 'splice-quot' and don't update everything that we
! should; this simplifies the code, improves performance, and we
! don't need the stack flow information after this pass anyway.

GENERIC: finalize* ( node -- nodes )

M: #copy finalize* drop f ;

M: #shuffle finalize*
    dup shuffle-effect
    [ in>> ] [ out>> ] bi sequence=
    [ drop f ] when ;

: splice-quot ( quot -- nodes )
    [
        build-tree
        normalize
        propagate
        cleanup
        compute-def-use
        remove-dead-code
        but-last
    ] with-scope ;

: builtin-predicate? ( #call -- ? )
    word>> "predicating" word-prop builtin-class? ;

MEMO: builtin-predicate-expansion ( word -- nodes )
    def>> splice-quot ;

: expand-builtin-predicate ( #call -- nodes )
    word>> builtin-predicate-expansion ;

: first-literal ( #call -- obj ) node-input-infos first literal>> ;

: last-literal ( #call -- obj ) node-input-infos peek literal>> ;

: expand-tuple-boa? ( #call -- ? )
    dup word>> \ <tuple-boa> eq? [
        last-literal tuple-layout?
    ] [ drop f ] if ;

MEMO: (tuple-boa-expansion) ( n -- quot )
    [
       [ 2 + ] map <reversed>
        [ '[ [ , set-slot ] keep ] % ] each
    ] [ ] make ;

: tuple-boa-expansion ( layout -- quot )
    #! No memoization here since otherwise we'd hang on to
    #! tuple layout objects.
    size>> (tuple-boa-expansion) \ (tuple) prefix splice-quot ;

: expand-tuple-boa ( #call -- node )
    last-literal tuple-boa-expansion ;

MEMO: <array>-expansion ( n -- quot )
    [
        [ swap (array) ] %
        [ \ 2dup , , [ swap set-array-nth ] % ] each
        \ nip ,
    ] [ ] make splice-quot ;

: expand-<array>? ( #call -- ? )
    dup word>> \ <array> eq? [
        first-literal dup integer?
        [ 0 32 between? ] [ drop f ] if
    ] [ drop f ] if ;

: expand-<array> ( #call -- node )
    first-literal <array>-expansion ;

: bytes>cells ( m -- n ) cell align cell /i ;

MEMO: <byte-array>-expansion ( n -- quot )
    [
        [ (byte-array) ] %
        bytes>cells [ cell * ] map
        [ [ 0 over ] % , [ set-alien-unsigned-cell ] % ] each
    ] [ ] make splice-quot ;

: expand-<byte-array>? ( #call -- ? )
    dup word>> \ <byte-array> eq? [
        first-literal dup integer?
        [ 0 128 between? ] [ drop f ] if
    ] [ drop f ] if ;

: expand-<byte-array> ( #call -- nodes )
    first-literal <byte-array>-expansion ;

M: #call finalize*
    {
        { [ dup builtin-predicate? ] [ expand-builtin-predicate ] }
        { [ dup expand-tuple-boa? ] [ expand-tuple-boa ] }
        { [ dup expand-<array>? ] [ expand-<array> ] }
        { [ dup expand-<byte-array>? ] [ expand-<byte-array> ] }
        [ ]
    } cond ;

M: node finalize* ;

: finalize ( nodes -- nodes' ) [ finalize* ] map-nodes ;
