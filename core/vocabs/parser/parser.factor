! Copyright (C) 2007, 2009 Daniel Ehrenberg, Bruno Deferrari,
! Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs hashtables kernel namespaces sequences
sets strings vocabs sorting accessors arrays compiler.units
combinators vectors splitting continuations math ;
IN: vocabs.parser

ERROR: no-word-error name ;

TUPLE: manifest
current-vocab
{ search-vocabs vector }
{ qualified-vocabs vector }
{ extra-words vector }
{ auto-used vector } ;

: <manifest> ( -- manifest )
    manifest new
        V{ } clone >>search-vocabs
        V{ } clone >>qualified-vocabs
        V{ } clone >>extra-words
        V{ } clone >>auto-used ;

M: manifest clone
    call-next-method
        [ clone ] change-search-vocabs
        [ clone ] change-qualified-vocabs
        [ clone ] change-extra-words
        [ clone ] change-auto-used ;

TUPLE: extra-words words ;

M: extra-words equal?
    over extra-words? [ [ words>> ] bi@ eq? ] [ 2drop f ] if ;

C: <extra-words> extra-words

<PRIVATE

: clear-manifest ( -- )
    manifest get
    [ search-vocabs>> delete-all ]
    [ qualified-vocabs>> delete-all ]
    bi ;

: (use-vocab) ( vocab -- vocab seq )
    load-vocab manifest get search-vocabs>> ;

: (add-qualified) ( qualified -- )
    manifest get qualified-vocabs>> push ;

: (from) ( vocab words -- vocab words words' assoc )
    2dup swap load-vocab words>> ;

: extract-words ( seq assoc -- assoc' )
    extract-keys dup [ [ drop ] [ no-word-error ] if ] assoc-each ;

: (lookup) ( name assoc -- word/f )
    at dup forward-reference? [ drop f ] when ;

: (use-words) ( assoc -- extra-words seq )
    <extra-words> manifest get qualified-vocabs>> ;

PRIVATE>

: set-current-vocab ( name -- )
    create-vocab
    [ manifest get (>>current-vocab) ]
    [ words>> <extra-words> (add-qualified) ] bi ;

TUPLE: no-current-vocab ;

: no-current-vocab ( -- vocab )
    \ no-current-vocab boa
    { { "Define words in scratchpad vocabulary" "scratchpad" } }
    throw-restarts dup set-current-vocab ;

: current-vocab ( -- vocab )
    manifest get current-vocab>> [ no-current-vocab ] unless* ;

: begin-private ( -- )
    manifest get current-vocab>> vocab-name ".private" ?tail
    [ drop ] [ ".private" append set-current-vocab ] if ;

: end-private ( -- )
    manifest get current-vocab>> vocab-name ".private" ?tail
    [ set-current-vocab ] [ drop ] if ;

: use-vocab ( vocab -- ) (use-vocab) push ;

: auto-use-vocab ( vocab -- )
    [ use-vocab ] [ manifest get auto-used>> push ] bi ;

: auto-used? ( -- ? ) manifest get auto-used>> length 0 > ;

: unuse-vocab ( vocab -- ) (use-vocab) delq ;

: only-use-vocabs ( vocabs -- )
    clear-manifest
    [ vocab ] V{ } map-as sift
    manifest get search-vocabs>> push-all ;

TUPLE: qualified vocab prefix words ;

: <qualified> ( vocab prefix -- qualified )
    2dup
    [ load-vocab words>> ] [ CHAR: : suffix ] bi*
    [ swap [ prepend ] dip ] curry assoc-map
    qualified boa ;

: add-qualified ( vocab prefix -- )
    <qualified> (add-qualified) ;

TUPLE: from vocab names words ;

: <from> ( vocab words -- from )
    (from) extract-words from boa ;

: add-words-from ( vocab words -- )
    <from> (add-qualified) ;

TUPLE: exclude vocab names words ;

: <exclude> ( vocab words -- from )
    (from) [ nip ] [ extract-words ] 2bi assoc-diff exclude boa ;

: add-words-excluding ( vocab words -- )
    <exclude> (add-qualified) ;

TUPLE: rename word vocab words ;

: <rename> ( word vocab new-name -- rename )
    [ 2dup load-vocab words>> dupd at [ ] [ no-word-error ] ?if ] dip
    associate rename boa ;

: add-renamed-word ( word vocab new-name -- )
    <rename> (add-qualified) ;

: use-words ( assoc -- ) (use-words) push ;

: unuse-words ( assoc -- ) (use-words) delete ;

ERROR: ambiguous-use-error words ;

<PRIVATE

: (vocab-search) ( name assocs -- words n )
    [ words>> (lookup) ] with map
    sift dup length ;

: vocab-search ( name manifest -- word/f )
    search-vocabs>>
    (vocab-search) {
        { 0 [ drop f ] }
        { 1 [ first ] }
        [ drop ambiguous-use-error ]
    } case ;

: qualified-search ( name manifest -- word/f )
    qualified-vocabs>>
    (vocab-search) 0 = [ drop f ] [ peek ] if ;

PRIVATE>

: search-manifest ( name manifest -- word/f )
    2dup qualified-search dup [ 2nip ] [ drop vocab-search ] if ;

: search ( name -- word/f )
    manifest get search-manifest ;

: word-restarts ( name possibilities -- restarts )
    natural-sort
    [ [ vocabulary>> "Use the " " vocabulary" surround ] keep ] { } map>assoc
    swap "Defer word in current vocabulary" swap 2array
    suffix ;

: <no-word-error> ( name possibilities -- error restarts )
    [ drop \ no-word-error boa ] [ word-restarts ] 2bi ;
