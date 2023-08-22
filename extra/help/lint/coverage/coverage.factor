USING: accessors arrays classes classes.error combinators
continuations english formatting generic help help.lint.checks
help.markup io io.streams.string io.styles kernel math
namespaces parser sequences sequences.deep sets sorting
splitting strings summary vocabs vocabs.parser words words.alias ;
FROM: namespaces => set ;
IN: help.lint.coverage

TUPLE: word-help-coverage
    { word-name word initial: POSTPONE: f }
    { omitted-sections sequence initial: { } }
    { empty-examples? boolean initial: f }
    { 100%-coverage? boolean initial: f } ;

<PRIVATE
ERROR: unloaded-vocab spec ;

M: unloaded-vocab summary
    drop "Not a loaded vocabulary" ;

CONSTANT: ignored-words {
    $low-level-note
    $prettyprinting-note
    $values-x/y
    $parsing-note
    $io-error
    $shuffle
    $nl
}

: (word-help) ( word -- content )
    [ "help" word-prop ] [ word-help* ] ?unless ;

GENERIC: write-object* ( object -- )
M: string write-object* write ;
M: pair write-object* first2 write-object ;

: write-object-seq ( object-seq -- )
    [ dup array? [
            dup ?first array? [
                [ write-object* ] each
            ] [ write-object* ] if
        ] [ write ] if
    ] each ; inline

: (assemble-word-metadata) ( vec word -- vec )
    [
        [ "[" ] dip vocabulary>> dup lookup-vocab 2array "] "
            3array over push-all
    ] [
        [ name>> ] keep 2array ": "
        2array over push-all
    ] bi ; inline

: (assemble-empty-examples) ( vec coverage -- vec )
    empty-examples?>> [ "empty " \ $examples [ name>> ] keep 2array "; "
        3array over push-all
    ] when ;

: (assemble-omitted-sections) ( vec coverage -- vec )
    omitted-sections>> [
        length "section" ?pluralize ": " append
    ] [
        [ [ name>> ] keep 2array ] map "and" comma-list
    ] bi
    [ "needs help " ] 2dip
    3array over push-all ;

: (assemble-full-coverage) ( vec coverage -- vec )
    drop "full help coverage" over push ;

: (present-coverage) ( coverage-report -- )
    [ V{ } clone ] dip
    [ word-name>> (assemble-word-metadata) ] keep
    dup 100%-coverage?>>
    [ (assemble-full-coverage) ] [
        [ (assemble-empty-examples) ]
        [ (assemble-omitted-sections) ] bi
    ] if "\n" over push write-object-seq ;

M: word-help-coverage summary
    [ (present-coverage) ] with-string-writer ; inline

: find-word ( name -- word/f )
    dup words-named dup length {
        { 0 [ 2drop f ] }
        { 1 [ first nip ] }
        [ drop <ambiguous-use-error> throw-restarts ]
    } case ;

: sorted-loaded-child-vocabs ( prefix -- assoc )
    loaded-child-vocab-names sort ; inline

: filter-private ( seq -- no-private )
    [ ".private" ?tail nip ] reject ; inline

: ?remove-$values ( word spec -- spec )
    \ $values over member? [
        swap "declared-effect" word-prop [
            [ in>> ] [ out>> ] bi append [
                \ $values swap remove
            ] [ drop ] if-empty
    ] when* ] [ nip ] if ;

: should-define ( word -- spec )
    dup {
        ! predicates have generated docs
        { [ dup predicate? ]   [ drop { } ] }
        { [ dup primitive? ]   [ drop { $description } ] }
        ! aliases should describe why they exist but ideally $values should be
        ! automatically inherited from the aliased word's docs
        { [ dup alias? ]       [ drop { $values $description } ] }
        { [ dup error-class? ] [ drop { $values $description $error-description } ] }
        { [ dup class? ]       [ drop { $class-description } ] }
        { [ dup generic? ]     [ drop { $values $contract $examples } ] }
        { [ dup word? ]        [ drop { $values $description $examples } ] }
    } cond ?remove-$values ;

: word-defines-sections ( word -- seq )
    (word-help) [ ignored-words member? ] reject [ ?first ] map ;

! only words that need examples, need to have them nonempty
! not defining examples is not the same as an empty { $examples }
: empty-examples? ( word -- ? )
    (word-help) \ $examples swap elements [ f ] [ first rest empty? ] if-empty ;

: missing-sections ( word -- missing )
    [ should-define ] [ word-defines-sections ] bi diff ;

GENERIC: loaded-vocab? ( vocab-spec -- ? )
M: string loaded-vocab? lookup-vocab >boolean ;
M: vocab loaded-vocab? source-loaded?>> +done+ = ;
PRIVATE>

GENERIC: <word-help-coverage> ( word -- coverage )
M: word <word-help-coverage>
    dup [ missing-sections ] [ empty-examples? ] bi
    2dup [ empty? ] both? word-help-coverage boa ; inline

M: string <word-help-coverage>
    find-word <word-help-coverage> ; inline

: <vocab-help-coverage> ( vocab-spec -- coverage )
    dup loaded-vocab? [
        [ auto-use? off vocab-words sort [ <word-help-coverage> ] map ] with-scope
    ] [
        unloaded-vocab
    ] if ;

: <prefix-help-coverage> ( prefix private? -- coverage )
    over loaded-vocab? [
            [ auto-use? off group-articles vocab-articles set
            [ sorted-loaded-child-vocabs ] dip not
            [ filter-private ] when
            [ <vocab-help-coverage> ] map flatten
        ] with-scope
    ] [
        drop unloaded-vocab
    ] if ;

GENERIC: help-coverage. ( coverage -- )
M: sequence help-coverage.
    [
        [ help-coverage. ] each
    ] [
        [ [ 100%-coverage?>> ] count ] [ length ] bi /f
        100 *
        "\n%3.1f%% of words have complete documentation\n"
        printf
    ] bi ; recursive

M: word-help-coverage help-coverage.
    (present-coverage) ;

: word-help-coverage. ( word-spec -- ) <word-help-coverage> help-coverage. ;
: vocab-help-coverage. ( vocab-spec -- ) <vocab-help-coverage> help-coverage. ;
: prefix-help-coverage. ( prefix-spec private? -- ) <prefix-help-coverage> help-coverage. ;
