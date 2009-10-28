! Copyright (C) 2007, 2009 Daniel Ehrenberg, Bruno Deferrari,
! Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs hashtables kernel namespaces sequences
sets strings vocabs sorting accessors arrays compiler.units
combinators vectors splitting continuations math
parser.notes ;
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
{ search-vocab-names hashtable }
{ search-vocabs vector }
{ qualified-vocabs vector }
{ extra-words vector }
{ auto-used vector } ;

: <manifest> ( -- manifest )
    manifest new
        H{ } clone >>search-vocab-names
        V{ } clone >>search-vocabs
        V{ } clone >>qualified-vocabs
        V{ } clone >>extra-words
        V{ } clone >>auto-used ;

M: manifest clone
    call-next-method
        [ clone ] change-search-vocab-names
        [ clone ] change-search-vocabs
        [ clone ] change-qualified-vocabs
        [ clone ] change-extra-words
        [ clone ] change-auto-used ;

TUPLE: extra-words words ;

M: extra-words equal?
    over extra-words? [ [ words>> ] bi@ eq? ] [ 2drop f ] if ;

C: <extra-words> extra-words

: clear-manifest ( -- )
    manifest get
    [ search-vocab-names>> clear-assoc ]
    [ search-vocabs>> delete-all ]
    [ qualified-vocabs>> delete-all ]
    tri ;

ERROR: no-word-in-vocab word vocab ;

<PRIVATE

: (add-qualified) ( qualified -- )
    manifest get qualified-vocabs>> push ;

: (from) ( vocab words -- vocab words words' vocab )
    2dup swap load-vocab ;

: extract-words ( seq vocab -- assoc' )
    [ words>> extract-keys dup ] [ name>> ] bi
    [ swap [ 2drop ] [ no-word-in-vocab ] if ] curry assoc-each ;

: (lookup) ( name assoc -- word/f )
    at dup forward-reference? [ drop f ] when ;

: (use-words) ( assoc -- extra-words seq )
    <extra-words> manifest get qualified-vocabs>> ;

PRIVATE>

: set-current-vocab ( name -- )
    create-vocab
    [ manifest get (>>current-vocab) ]
    [ words>> <extra-words> (add-qualified) ] bi ;

: with-current-vocab ( name quot -- )
    manifest get clone manifest [
        [ set-current-vocab ] dip call
    ] with-variable ; inline

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

: using-vocab? ( vocab -- ? )
    vocab-name manifest get search-vocab-names>> key? ;

: use-vocab ( vocab -- )
    dup using-vocab?
    [ vocab-name "Already using ``" "'' vocabulary" surround note. ] [
        manifest get
        [ [ load-vocab ] dip search-vocabs>> push ]
        [ [ vocab-name ] dip search-vocab-names>> conjoin ]
        2bi
    ] if ;

: auto-use-vocab ( vocab -- )
    [ use-vocab ] [ manifest get auto-used>> push ] bi ;

: auto-used? ( -- ? ) manifest get auto-used>> length 0 > ;

: unuse-vocab ( vocab -- )
    dup using-vocab? [
        manifest get
        [ [ load-vocab ] dip search-vocabs>> delq ]
        [ [ vocab-name ] dip search-vocab-names>> delete-at ]
        2bi
    ] [ drop ] if ;

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
    (from) [ nip words>> ] [ extract-words ] 2bi assoc-diff exclude boa ;

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
