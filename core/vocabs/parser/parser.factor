! Copyright (C) 2007, 2010 Daniel Ehrenberg, Bruno Deferrari,
! Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators compiler.units
continuations hash-sets hashtables kernel math namespaces
parser.notes sequences sets sorting splitting vectors vocabs
words ;
IN: vocabs.parser

ERROR: no-word-error name ;

: word-restarts ( possibilities -- restarts )
    sort [
        [ vocabulary>> "Use the " " vocabulary" surround ] keep
    ] { } map>assoc ;

: word-restarts-with-defer ( name possibilities -- restarts )
    word-restarts
    "Defer word in current vocabulary" rot 2array
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

PRIVATE>

: qualified-vocabs ( -- qualified-vocabs )
    manifest get qualified-vocabs>> ;

: set-current-vocab ( name -- )
    create-vocab
    [ manifest get current-vocab<< ]
    [ qualified-vocabs push ] bi ;

: with-current-vocab ( name quot -- )
    manifest get clone manifest [
        [ set-current-vocab ] dip call
    ] with-variable ; inline

TUPLE: no-current-vocab-error ;

: no-current-vocab ( -- vocab )
    no-current-vocab-error boa
    { { "Define words in scratchpad vocabulary" "scratchpad" } }
    throw-restarts dup set-current-vocab ;

: current-vocab ( -- vocab )
    manifest get current-vocab>> [ no-current-vocab ] unless* ;

ERROR: unbalanced-private-declaration vocab ;

: begin-private ( -- )
    current-vocab name>> ".private" ?tail
    [ unbalanced-private-declaration ]
    [ ".private" append set-current-vocab ] if ;

: end-private ( -- )
    current-vocab name>> ".private" ?tail
    [ set-current-vocab ]
    [ unbalanced-private-declaration ] if ;

: using-vocab? ( vocab -- ? )
    vocab-name manifest get search-vocab-names>> in? ;

: use-vocab ( vocab -- )
    dup using-vocab? [
        vocab-name "Already using “" "” vocabulary" surround note.
    ] [
        manifest get
        [ [ ?load-vocab ] dip search-vocabs>> push ]
        [ [ vocab-name ] dip search-vocab-names>> adjoin ]
        2bi
    ] if ;

: auto-use-vocab ( vocab -- )
    [ use-vocab ] [ manifest get auto-used>> push ] bi ;

: auto-used? ( -- ? )
    manifest get auto-used>> length 0 > ;

: unuse-vocab ( vocab -- )
    dup using-vocab? [
        manifest get
        [ [ load-vocab ] dip search-vocabs>> remove-eq! drop ]
        [ [ vocab-name ] dip search-vocab-names>> delete ]
        [
            [ vocab-name ] dip qualified-vocabs>> [
                dup extra-words? [ 2drop f ] [
                    dup vocab? [ vocab>> ] unless vocab-name =
                ] if
            ] with reject! drop
        ] 2tri
    ] [ drop ] if ;

TUPLE: qualified vocab prefix words ;

: <qualified> ( vocab prefix -- qualified )
    (from) qualified-words qualified boa ;

: add-qualified ( vocab prefix -- )
    <qualified> qualified-vocabs push ;

TUPLE: from vocab names words ;

: <from> ( vocab words -- from )
    (from) extract-words from boa ;

: add-words-from ( vocab words -- )
    <from> qualified-vocabs push ;

TUPLE: exclude vocab names words ;

: <exclude> ( vocab words -- from )
    (from) excluding-words exclude boa ;

: add-words-excluding ( vocab words -- )
    <exclude> qualified-vocabs push ;

TUPLE: rename word vocab words ;

: <rename> ( word vocab new-name -- rename )
    [
        2dup load-vocab words>> dupd at
        or* [ swap no-word-in-vocab ] unless
    ] dip associate rename boa ;

: add-renamed-word ( word vocab new-name -- )
    <rename> qualified-vocabs push ;

: use-words ( words -- )
    <extra-words> qualified-vocabs push ;

: unuse-words ( words -- )
    <extra-words> qualified-vocabs remove! drop ;

DEFER: with-words

<PRIVATE

: ?restart-with-words ( words error -- * )
    dup condition? [
        [ error>> ]
        [ restarts>> rethrow-restarts ]
        [ continuation>> '[ _ _ continue-with ] with-words ] tri
    ] [ nip rethrow ] if ;

PRIVATE>

: with-words ( words quot -- )
    [ over '[ _ use-words @ _ unuse-words ] ]
    [ drop dup '[ _ unuse-words _ swap ?restart-with-words ] ]
    2bi recover ; inline

TUPLE: ambiguous-use-error name words ;

: <ambiguous-use-error> ( name words -- error restarts )
    [ ambiguous-use-error boa ] [ word-restarts ] bi ;

<PRIVATE

: (lookup-word) ( words name vocab -- words )
    words>> (lookup) [ suffix! ] when* ; inline

: (vocab-search) ( name assocs -- words )
    [ V{ } clone ] 2dip [ (lookup-word) ] with each ;

: (vocab-search-qualified) ( words name assocs -- words )
    [ ":" split1 swap ] dip pick [
        [ name>> = ] with find nip [ (lookup-word) ] with when*
    ] [
        3drop
    ] if ;

: (vocab-search-full) ( name assocs -- words )
    [ (vocab-search) ] [ (vocab-search-qualified) ] 2bi ;

: vocab-search ( name manifest -- word/f )
    dupd search-vocabs>> (vocab-search-full) dup length {
        { 0 [ 2drop f ] }
        { 1 [ first nip ] }
        [
            drop <ambiguous-use-error> throw-restarts
            dup [ vocabulary>> ] [ name>> 1array ] bi add-words-from
        ]
    } case ;

: qualified-search ( name manifest -- word/f )
    qualified-vocabs>> (vocab-search) ?last ;

PRIVATE>

: search-manifest ( name manifest -- word/f )
    2dup qualified-search [ 2nip ] [ vocab-search ] if* ;

: search ( name -- word/f )
    manifest get search-manifest ;

<PRIVATE

GENERIC: update ( search-path-elt -- valid? )

: trim-forgotten ( qualified-vocab -- valid? )
    [ [ nip "forgotten" word-prop ] assoc-reject ] change-words
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

: update-current-vocab ( manifest -- manifest )
    [ dup [ name>> lookup-vocab ] when ] change-current-vocab ; inline

: compute-search-vocabs ( manifest -- search-vocab-names search-vocabs )
    search-vocab-names>> members dup length <vector> [
        [ push ] curry [ when* ] curry
        [ lookup-vocab dup ] prepose filter fast-set
    ] keep ; inline

: update-search-vocabs ( manifest -- manifest )
    dup compute-search-vocabs
    [ >>search-vocab-names ] [ >>search-vocabs ] bi* ; inline

: update-qualified-vocabs ( manifest -- manifest )
    dup qualified-vocabs>> [ update ] filter! drop ; inline

: update-manifest ( manifest -- manifest )
    update-current-vocab
    update-search-vocabs
    update-qualified-vocabs ; inline

M: manifest definitions-changed
    nip update-manifest drop ;

PRIVATE>

SYMBOL: print-use-hook

print-use-hook [ [ ] ] initialize

: (with-manifest) ( quot manifest -- )
    manifest [
        [ call ] [
            [ manifest get add-definition-observer call ]
            [ manifest get remove-definition-observer ]
            finally
        ] if-bootstrapping
    ] with-variable ; inline

: with-manifest ( quot -- )
    <manifest> (with-manifest) ; inline

: with-current-manifest ( quot -- )
    manifest get (with-manifest) ; inline
