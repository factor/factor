USING: accessors arrays classes classes.error combinators
combinators.short-circuit continuations english eval formatting
fry fuel.help.private generic help help.lint help.lint.checks help.markup io
io.streams.string io.styles kernel math namespaces parser
prettyprint sequences sequences.deep sets sorting splitting strings summary
vocabs words ;
FROM: namespaces => set ;
IN: help.lint.coverage

TUPLE: word-help-coverage
    { word-name word initial: POSTPONE: f }
    { omitted-sections sequence initial: { } }
    { empty-examples? boolean initial: f }
    { 100%-coverage? boolean initial: f } ;

<PRIVATE

CONSTANT: ignored-words {
    $low-level-note
    $prettyprinting-note
    $values-x/y
    $parsing-note
    $io-error
    $shuffle
    $complex-shuffle
    $nl
}

DEFER: ?pluralize

: write-object-seq ( object-seq -- )
    [
        dup array? [
            dup ?first array?
            [ dup length '[
                    swap first2 write-object
                    _ 1 - abs = not [ " " write ] when
                ] each-index
            ] [ first2 write-object ] if
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
        [ [ name>> ] keep 2array ] map
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

: sorted-loaded-child-vocabs ( prefix -- assoc )
    loaded-child-vocab-names natural-sort ; inline

: filter-private ( seq -- no-private )
    [ ".private" ?tail nip not ] filter ; inline

: ?pluralize ( n singular -- singular/plural )
    count-of-things " " split1 nip ;

: should-define ( word -- spec )
    {
        { [ dup predicate? ]    [ drop { } ] } ! predicate?s have generated docs
        { [ dup error-class? ]  [ drop { $values $description $error-description } ] }
        { [ dup class? ]        [ drop { $class-description } ] }
        { [ dup generic? ]      [ drop { $values $contract $examples } ] }
        { [ dup word? ]         [ drop { $values $description $examples } ] }
        [ drop no-cond ]
    } cond ;

: word-defines-sections ( word -- seq )
    word-help [ ignored-words member? not ] filter [ ?first ] map ;

! only words that need examples, need to have them nonempty
! not defining examples is not the same as an empty { $examples }
: empty-examples? ( word -- ? )
    word-help \ $examples swap elements [ f ] [ first rest empty? ] if-empty ;

: missing-sections ( word -- missing )
    [ should-define ] [ word-defines-sections ] bi diff ;
PRIVATE>

GENERIC: <word-help-coverage> ( word -- coverage )
M: word <word-help-coverage>
    dup [ missing-sections ] [ empty-examples? ] bi
    2dup 2array { { } f } =
    word-help-coverage boa ; inline

M: string <word-help-coverage>
    find-word <word-help-coverage> ; inline

: <vocab-help-coverage> ( vocab-spec -- coverage )
    [ auto-use? off vocab-words natural-sort [ <word-help-coverage> ] map ] with-scope ;

: <prefix-help-coverage> ( prefix private? -- coverage )
    [
        auto-use? off group-articles vocab-articles set
        [ sorted-loaded-child-vocabs ] dip not
        [ filter-private ] when
        [ <vocab-help-coverage> ] map flatten
    ] with-scope ;

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
