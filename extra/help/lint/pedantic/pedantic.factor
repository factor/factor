USING: accessors arrays classes combinators
combinators.short-circuit continuations english eval formatting
fry help help.lint help.lint.checks help.markup kernel
namespaces parser prettyprint sequences sets sorting splitting
strings summary vocabs words ;
FROM: namespaces => set ;
IN: help.lint.pedantic

ERROR: missing-sections
    { word-name word initial: POSTPONE: f }
    { missing-sections sequence initial: { } } ;
ERROR: empty-examples { word-name initial: POSTPONE: f } ;

<PRIVATE
DEFER: ?pluralize

M: empty-examples summary
    word-name>> "Word '%s' has defined empty $examples section" sprintf ;

M: missing-sections summary
    [ word-name>> ] [
        missing-sections>> dup [
            length "section" ?pluralize
        ] dip
        [ name>> ] map ", " join
    ] bi
    "Word '%s' should define help %s: %s" sprintf ;

: sorted-loaded-child-vocabs ( prefix -- assoc )
    loaded-child-vocab-names natural-sort ; inline

: filter-private ( seq -- no-private )
    [ ".private" ?tail nip not ] filter ; inline

: ?pluralize ( n singular -- singular/plural )
    count-of-things " " split1 nip ;

: should-define ( word -- spec )
    {
        { [ dup predicate? ] [ drop { } ] } ! predicate?s have generated docs
        { [ dup error? ] [ drop { $values $description $error-description } ] }
        { [ dup class? ] [ drop { $class-description } ] }
        { [ dup word? ]  [ drop { $values $description $examples } ] }
        [ drop no-cond ]
    } cond ;

: word-defines-sections ( word -- seq )
    word-help [ first ] map ;

: missing-examples? ( word -- ? )
    word-help \ $examples swap elements empty? ;

: check-examples ( word -- )
    [ missing-examples? ] keep '[ _ empty-examples ] when ;

: check-sections ( word -- )
    [ ] [ should-define ] [ word-defines-sections ] tri
    diff [ drop ] [ missing-sections ] if-empty ;
PRIVATE>

GENERIC: word-pedant ( word -- )
M: word word-pedant
    {
        { [ dup predicate? ] [ drop ] }
        { [ dup error? ] [ check-sections ] }
        { [ dup word? ] [ [ check-sections ] [ check-examples ] bi ] }
        [ drop no-cond ]
    } cond ; inline

M: string word-pedant
    "\\ " prepend eval( -- word ) word-pedant ; inline

: vocab-pedant ( vocab-spec -- )
    [ auto-use? off vocab-words natural-sort [ word-pedant ] each ] with-scope ;

: prefix-pedant ( prefix private? -- )
    [
        auto-use? off group-articles vocab-articles set
        [ sorted-loaded-child-vocabs ] dip not
        [ filter-private ] when
        [ vocab-pedant ] each
    ] with-scope ;
