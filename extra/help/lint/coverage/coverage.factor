USING: accessors arrays classes classes.error combinators
combinators.short-circuit continuations english eval formatting
fry generic help help.lint help.lint.checks help.markup io
kernel math namespaces parser prettyprint sequences sets sorting
splitting strings summary vocabs words ;
FROM: namespaces => set ;
IN: help.lint.coverage

TUPLE: word-help-coverage
    { word-name word initial: POSTPONE: f }
    { omitted-sections sequence initial: { } }
    { empty-examples? boolean initial: f }
    { 100%-coverage? boolean initial: f } ;

<PRIVATE
! <<
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
! >>

DEFER: ?pluralize

M: word-help-coverage summary
    [ word-name>> [ vocabulary>> ] [ name>> ] bi "[%s] %s: " sprintf ] keep
    dup 100%-coverage?>>
    [ drop "full help coverage" append ]
    [
        [ empty-examples?>> "defined empty { $examples }, " "" ? ]
        [ omitted-sections>> dup [
                length "section" ?pluralize
            ] dip
            [ name>> ] map ", " join
        ] bi
        "%sshould define help %s %s" sprintf append
    ] if ; inline

: sorted-loaded-child-vocabs ( prefix -- assoc )
    loaded-child-vocab-names natural-sort ; inline

: resolve-name-in ( name namespaces -- word )
    "syntax" swap remove " " join
    "USING: " " ; \\ " surround
    prepend eval( -- word ) ;

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

GENERIC: print-coverage ( coverage-seq -- )
M: sequence print-coverage
    [
        [ print-coverage ] each
    ] [
        [ [ 100%-coverage?>> ] count ] [ length ] bi /f
        100 *
        "\n%3.1f%% of words have complete documentation\n"
        printf
    ] bi ;

M: word-help-coverage print-coverage
    summary print ;

GENERIC: <word-help-coverage> ( word -- coverage )
M: word <word-help-coverage>
    dup
    [ missing-sections ]
    [ empty-examples? ] bi
    2dup 2array { { } f } =
    word-help-coverage boa ; inline

M: string <word-help-coverage>
    loaded-vocab-names resolve-name-in <word-help-coverage> ; inline

: <vocab-help-coverage> ( vocab-spec -- coverage )
    [ auto-use? off vocab-words natural-sort [ <word-help-coverage> ] map ] with-scope ;

: <prefix-help-coverage> ( prefix private? -- coverage )
    [
        auto-use? off group-articles vocab-articles set
        [ sorted-loaded-child-vocabs ] dip not
        [ filter-private ] when
        [ <vocab-help-coverage> ] map
    ] with-scope ;
