! Copyright (C) 2007, 2010 Slava Pestov, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel hashtables sequences sequences.private arrays
words namespaces make parser effects.parser math assocs effects
definitions quotations summary accessors fry hashtables.identity ;
IN: memoize

<PRIVATE

! We can't use n*quot, narray and firstn from generalizations because
! they're macros, and macros use memoize!
: (n*quot) ( n quot -- quotquot )
    <repetition> [ ] concat-as ;

: [nsequence] ( length exemplar -- quot )
    [ [ [ 1 - ] keep ] dip '[ _ _ _ new-sequence ] ]
    [ drop [ [ set-nth-unsafe ] 2keep [ 1 - ] dip ] (n*quot) ] 2bi
    [ nip ] 3append ;

: [firstn] ( length -- quot )
    [ 0 swap ] swap
    [ [ nth-unsafe ] 2keep [ 1 + ] dip ] (n*quot)
    [ 2drop ] 3append ;

: packer ( seq -- quot )
    length dup 4 <=
    [ { [ f ] [ ] [ 2array ] [ 3array ] [ 4array ] } nth ]
    [ { } [nsequence] ] if ;

: unpacker ( seq -- quot )
    length dup 4 <=
    [ { [ drop ] [ ] [ first2-unsafe ] [ first3-unsafe ] [ first4-unsafe ] } nth ]
    [ [firstn] ] if ;

: pack/unpack ( quot effect -- newquot )
    [ in>> packer ] [ out>> unpacker ] bi surround ;

: unpack/pack ( quot effect -- newquot )
    [ in>> unpacker ] [ out>> packer ] bi surround ;

: make-memoizer ( table quot effect -- quot )
    [ unpack/pack '[ _ _ cache ] ] keep
    pack/unpack ;

PRIVATE>

: (define-memoized) ( word quot effect hashtable -- )
    [ [ drop "memo-quot" set-word-prop ] ] dip
    '[ 2drop _ "memoize" set-word-prop ]
    [ [ [ dup "memoize" word-prop ] 2dip make-memoizer ] keep define-declared ]
    3tri ;

: define-memoized ( word quot effect -- )
    H{ } clone (define-memoized) ;

: define-identity-memoized ( word quot effect -- )
    IH{ } clone (define-memoized) ;

SYNTAX: MEMO: (:) define-memoized ;

SYNTAX: IDENTITY-MEMO: (:) define-identity-memoized ;

PREDICATE: memoized < word "memoize" word-prop ;

M: memoized definer drop \ MEMO: \ ; ;

M: memoized definition "memo-quot" word-prop ;

M: memoized reset-word
    [ call-next-method ]
    [ { "memoize" "memo-quot" } reset-props ]
    bi ;

: memoize-quot ( quot effect -- memo-quot )
    [ H{ } clone ] 2dip make-memoizer ;

: reset-memoized ( word -- )
    "memoize" word-prop clear-assoc ;

: invalidate-memoized ( inputs... word -- )
    [ stack-effect in>> packer call ] [ "memoize" word-prop delete-at ] bi ;

\ invalidate-memoized t "no-compile" set-word-prop
