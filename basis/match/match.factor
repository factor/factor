! Copyright (C) 2006 Chris Double.
! See https://factorcode.org/license.txt for BSD license.
!
! Based on pattern matching code from Paul Graham's book 'On Lisp'.
USING: assocs classes classes.tuple combinators kernel lexer
make namespaces parser quotations sequences summary words ;
IN: match

SYMBOL: _

: define-match-var ( name -- )
    create-word-in
    dup t "match-var" set-word-prop
    dup [ get ] curry ( -- value ) define-declared ;

: define-match-vars ( seq -- )
    [ define-match-var ] each ;

SYNTAX: MATCH-VARS: ! vars ...
    ";" [ define-match-var ] each-token ;

PREDICATE: match-var < word "match-var" word-prop ;

: set-match-var ( value var -- ? )
    building get ?at [ = ] [ ,, t ] if ;

: (match) ( value1 value2 -- matched? )
    {
        { [ dup match-var? ] [ set-match-var ] }
        { [ over match-var? ] [ swap set-match-var ] }
        { [ 2dup = ] [ 2drop t ] }
        { [ 2dup [ _ eq? ] either? ] [ 2drop t ] }
        { [ 2dup [ sequence? ] both? ] [
            2dup [ length ] same? [
                [ (match) ] 2all?
            ] [ 2drop f ] if ] }
        { [ 2dup [ tuple? ] both? ] [
            2dup [ class-of ] same? [
                [ tuple-slots ] bi@ [ (match) ] 2all?
            ] [ 2drop f ] if ] }
        [ 2drop f ]
    } cond ;

: match ( value1 value2 -- bindings )
    [ (match) ] H{ } make and ;

ERROR: no-match-cond ;

M: no-match-cond summary drop "Fall-through in match-cond" ;

MACRO: match-cond ( assoc -- quot )
    <reversed>
    dup ?first callable? [ unclip ] [ [ no-match-cond ] ] if
    [
        first2
        [ [ dupd match ] curry ] dip
        [ with-variables ] curry rot
        [ [ or? ] 2dip if ] 2curry append
    ] reduce ;

GENERIC: replace-patterns ( object -- result )
M: object replace-patterns ;
M: match-var replace-patterns get ;
M: sequence replace-patterns [ replace-patterns ] map ;
M: tuple replace-patterns pack-tuple replace-patterns unpack-tuple ;

: match-replace ( object pattern1 pattern2 -- result )
    [ match [ "Pattern does not match" throw ] unless* ] dip swap
    [ replace-patterns ] with-variables ;

: ?rest ( seq -- tailseq/f )
    [ f ] [ rest ] if-empty ;

: (match-first) ( seq pattern-seq -- bindings leftover/f )
    2dup shorter? [
        2drop f f
    ] [
        2dup length head over match or?
        [ swap ?rest ] [ [ rest ] dip (match-first) ] if
    ] if ;

: match-first ( seq pattern-seq -- bindings )
    (match-first) drop ;

: (match-all) ( seq pattern-seq -- )
    [ (match-first) ] keep
    [ , [ swap (match-all) ] [ drop ] if* ] [ 2drop ] if* ;

: match-all ( seq pattern-seq -- bindings-seq )
    [ (match-all) ] { } make ;
