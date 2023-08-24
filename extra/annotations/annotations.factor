! (c)2009 Joe Groff, Doug Coleman. see BSD license
USING: accessors combinators.short-circuit functors kernel lexer
namespaces sequences tools.crossref words ;
IN: annotations

<<

: (parse-annotation) ( accum -- accum )
    lexer get [ line-text>> suffix! ] [ next-line ] bi ;

: (non-annotation-usage) ( word -- usages )
    smart-usage
    [ { [ word? ] [ vocabulary>> "annotations" = ] } 1&& not ]
    filter ;

<FUNCTOR: define-annotation ( NAME -- )

(NAME) DEFINES (${NAME})
!NAME  DEFINES !${NAME}
NAMEs  DEFINES ${NAME}s
NAMEs. DEFINES ${NAME}s.

WHERE

: (NAME) ( str -- ) drop ; inline
SYNTAX: !NAME (parse-annotation) \ (NAME) suffix! ;

: NAMEs ( -- usages )
    \ (NAME) (non-annotation-usage) ;
: NAMEs. ( -- )
    NAMEs sorted-definitions. ;

;FUNCTOR>

CONSTANT: annotation-tags {
    "XXX" "TODO" "FIXME" "BUG" "REVIEW" "LICENSE"
    "AUTHOR" "BROKEN" "HACK" "LOL" "NOTE"
}

annotation-tags [ define-annotation ] each

>>
