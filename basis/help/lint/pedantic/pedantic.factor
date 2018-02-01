USING: accessors classes combinators.short-circuit eval
formatting fry help help.lint help.lint.checks help.markup
kernel namespaces parser prettyprint sequences sorting splitting
strings summary vocabs words ;
IN: help.lint.pedantic

ERROR: ordinary-word-missing-section missing-section word-name ;
ERROR: empty-examples word-name ;

M: empty-examples summary
    word-name>> "Word '%s' has defined empty $examples section" sprintf ;

M: ordinary-word-missing-section summary
    [ word-name>> ] [ missing-section>> ] bi
    "Word '%s' should define %s help section" sprintf ;

<PRIVATE

: elements-by ( element elt-type -- seq )
    swap elements ;

: checked-ordinary-word? ( word -- ? )
    {
        [ word-help \ $predicate elements-by empty? ]
        [ class? not ]
    } 1&& ;

: check-ordinary-word-sections ( word -- )
    [ word-help ] keep '[
        [ elements-by ] keep swap
        [ name>> _ ordinary-word-missing-section ]
        [ 2drop ] if-empty
    ]
    { [ \ $values ] [ \ $description ] [ \ $examples ] }
    [ prepose ] with map
    [ call( x -- ) ] with each ;

: missing-examples? ( word -- ? )
    word-help \ $examples elements-by empty? ;

: check-ordinary-word-examples ( word -- )
    [ missing-examples? ] keep '[ _ empty-examples ] when ;
PRIVATE>

GENERIC: word-pedant ( word -- )
M: word word-pedant
    dup checked-ordinary-word? [
        [ check-ordinary-word-sections ] [ check-ordinary-word-examples ] bi
    ] [ drop ] if ; inline

M: string word-pedant
    "\\ " prepend eval( -- word ) word-pedant ; inline

: vocab-pedant ( vocab-spec -- )
    [ auto-use? off vocab-words natural-sort [ word-pedant ] each ] with-scope ;

: prefix-pedant ( prefix private? -- )
    [
        auto-use? off group-articles vocab-articles set
        [ loaded-child-vocab-names natural-sort ] dip not
        [ [ ".private" ?tail nip not ] filter ] when
        [ vocab-pedant ] each
    ] with-scope ;
