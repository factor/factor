! Copyright (C) 2007, 2010 Daniel Ehrenberg, Bruno Deferrari,
! Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators compiler.units
continuations hash-sets hashtables kernel math namespaces
parser.notes sequences sets sorting splitting vectors vocabs
words ;
IN: vocabs.parser

ERROR: no-word-error name ;

: word-restarts ( possibilities -- restarts )
    natural-sort
    [ [ vocabulary>> "Use the " " vocabulary" surround ] keep ] { } map>assoc ;

: word-restarts-with-defer ( name possibilities -- restarts )
    word-restarts
    swap "Defer word in current vocabulary" swap 2array
    suffix ;

: <no-word-error> ( name possibilities -- error restarts )
    [ drop \ no-word-error boa ] [ word-restarts-with-defer ] 2bi ;

TUPLE: manifest
current-vocab
{ search-vocab-names hash-set }
{ search-vocabs vector }
{ qualified-vocabs vector }
{ auto-used vector } ;

: <manifest> ( -- manifest )
    manifest new
        HS{ } clone >>search-vocab-names
        V{ } clone >>search-vocabs
        V{ } clone >>qualified-vocabs
        V{ } clone >>auto-used ;

M: manifest clone
    call-next-method
        [ clone ] change-search-vocab-names
        [ clone ] change-search-vocabs
        [ clone ] change-qualified-vocabs
        [ clone ] change-auto-used ;

TUPLE: extra-words words ;

M: extra-words equal?
    over extra-words? [ [ words>> ] bi@ eq? ] [ 2drop f ] if ;

C: <extra-words> extra-words

ERROR: no-word-in-vocab word vocab ;

<PRIVATE

: (add-qualified) ( qualified -- )
    manifest get qualified-vocabs>> push ;

: (from) ( vocab words -- vocab words words' vocab )
    2dup swap load-vocab ;

: extract-words ( seq vocab -- assoc )
    [ words>> extract-keys dup ] [ name>> ] bi
    [ swap [ 2drop ] [ no-word-in-vocab ] if ] curry assoc-each ;

: excluding-words ( seq vocab -- assoc )
    [ nip words>> ] [ extract-words ] 2bi assoc-diff ;

: qualified-words ( prefix vocab -- assoc )
    words>> swap [ swap [ swap ":" glue ] dip ] curry assoc-map ;

: (lookup) ( name assoc -- word/f )
    at* [ dup forward-reference? [ drop f ] when ] when ;

: (use-words) ( assoc -- extra-words seq )
    <extra-words> manifest get qualified-vocabs>> ;

PRIVATE>

: set-current-vocab ( name -- )
    create-vocab
    [ manifest get current-vocab<< ] [ (add-qualified) ] bi ;

: with-current-vocab ( name quot -- )
    manifest get clone manifest [
        [ set-current-vocab ] dip call
    ] with-variable ; inline

TUPLE: no-current-vocab-error ;

: no-current-vocab ( -- vocab )
    \ no-current-vocab-error boa
    { { "Define words in scratchpad vocabulary" "scratchpad" } }
    throw-restarts dup set-current-vocab ;

: current-vocab ( -- vocab )
    manifest get current-vocab>> [ no-current-vocab ] unless* ;

: begin-private ( -- )
    current-vocab name>> ".private" ?tail
    [ drop ] [ ".private" append set-current-vocab ] if ;

: end-private ( -- )
    current-vocab name>> ".private" ?tail
    [ set-current-vocab ] [ drop ] if ;

: using-vocab? ( vocab -- ? )
    vocab-name manifest get search-vocab-names>> in? ;

: use-vocab ( vocab -- )
    dup using-vocab?
    [ vocab-name "Already using ``" "'' vocabulary" surround note. ] [
        manifest get
        [ [ load-vocab ] dip search-vocabs>> push ]
        [ [ vocab-name ] dip search-vocab-names>> adjoin ]
        2bi
    ] if ;

: auto-use-vocab ( vocab -- )
    [ use-vocab ] [ manifest get auto-used>> push ] bi ;

: auto-used? ( -- ? ) manifest get auto-used>> length 0 > ;

: unuse-vocab ( vocab -- )
    dup using-vocab? [
        manifest get
        [ [ load-vocab ] dip search-vocabs>> remove-eq! drop ]
        [ [ vocab-name ] dip search-vocab-names>> delete ]
        2bi
    ] [ drop ] if ;

TUPLE: qualified vocab prefix words ;

: <qualified> ( vocab prefix -- qualified )
    (from) qualified-words qualified boa ;

: add-qualified ( vocab prefix -- )
    <qualified> (add-qualified) ;

TUPLE: from vocab names words ;

: <from> ( vocab words -- from )
    (from) extract-words from boa ;

: add-words-from ( vocab words -- )
    <from> (add-qualified) ;

TUPLE: exclude vocab names words ;

: <exclude> ( vocab words -- from )
    (from) excluding-words exclude boa ;

: add-words-excluding ( vocab words -- )
    <exclude> (add-qualified) ;

TUPLE: rename word vocab words ;

: <rename> ( word vocab new-name -- rename )
    [ 2dup load-vocab words>> dupd at [ ] [ swap no-word-in-vocab ] ?if ] dip
    associate rename boa ;

: add-renamed-word ( word vocab new-name -- )
    <rename> (add-qualified) ;

: use-words ( assoc -- ) (use-words) push ;

: unuse-words ( assoc -- ) (use-words) remove! drop ;

TUPLE: ambiguous-use-error words ;

: <ambiguous-use-error> ( words -- error restarts )
    [ \ ambiguous-use-error boa ] [ word-restarts ] bi ;

<PRIVATE

: (vocab-search) ( name assocs -- words n )
    [ words>> (lookup) ] with map
    sift dup length ;

: vocab-search ( name manifest -- word/f )
    search-vocabs>>
    (vocab-search) {
        { 0 [ drop f ] }
        { 1 [ first ] }
        [
            drop <ambiguous-use-error> throw-restarts
            dup [ vocabulary>> ] [ name>> 1array ] bi add-words-from
        ]
    } case ;

: qualified-search ( name manifest -- word/f )
    qualified-vocabs>>
    (vocab-search) 0 = [ drop f ] [ last ] if ;

PRIVATE>

: search-manifest ( name manifest -- word/f )
    2dup qualified-search dup [ 2nip ] [ drop vocab-search ] if ;

: search ( name -- word/f )
    manifest get search-manifest ;

<PRIVATE

GENERIC: update ( search-path-elt -- valid? )

: trim-forgotten ( qualified-vocab -- valid? )
    [ [ nip "forgotten" word-prop not ] assoc-filter ] change-words
    words>> assoc-empty? not ;

M: from update trim-forgotten ;
M: rename update trim-forgotten ;
M: extra-words update trim-forgotten ;
M: exclude update trim-forgotten ;

M: qualified update
    dup vocab>> lookup-vocab [
        dup [ prefix>> ] [ vocab>> load-vocab ] bi qualified-words
        >>words
    ] [ drop f ] if ;

M: vocab update dup name>> lookup-vocab eq? ;

: update-manifest ( manifest -- )
    [ dup [ name>> lookup-vocab ] when ] change-current-vocab
    [ members [ lookup-vocab ] filter dup fast-set ] change-search-vocab-names
    swap [ lookup-vocab ] V{ } map-as >>search-vocabs
    qualified-vocabs>> [ update ] filter! drop ;

M: manifest definitions-changed
    nip update-manifest ;

PRIVATE>

: with-manifest ( quot -- )
    <manifest> manifest [
        [ call ] [
            [ manifest get add-definition-observer call ]
            [ manifest get remove-definition-observer ]
            [ ]
            cleanup
        ] if-bootstrapping
    ] with-variable ; inline
