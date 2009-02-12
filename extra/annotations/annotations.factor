! (c)2009 Joe Groff, Doug Coleman. see BSD license
USING: accessors combinators.short-circuit definitions functors
kernel lexer namespaces parser prettyprint sequences words ;
IN: annotations

<<

: (parse-annotation) ( accum -- accum )
    lexer get [ line-text>> parsed ] [ next-line ] bi ;

: (non-annotation-usage) ( word -- usages )
    smart-usage
    [ { [ word? ] [ vocabulary>> "annotations" = not ] } 1&& ]
    filter ;

FUNCTOR: define-annotation ( NAME -- )

(NAME) DEFINES (${NAME})
!NAME  DEFINES !${NAME}
NAMEs  DEFINES ${NAME}s
NAMEs. DEFINES ${NAME}s.

WHERE

: (NAME) ( str -- ) drop ; inline
: !NAME (parse-annotation) \ (NAME) parsed ; parsing

: NAMEs ( -- usages )
    \ (NAME) (non-annotation-usage) ;
: NAMEs. ( -- )
    NAMEs sorted-definitions. ;

;FUNCTOR

{
    "XXX" "TODO" "FIXME" "BUG" "REVIEW" "LICENSE"
    "AUTHOR" "BROKEN" "HACK" "LOL" "NOTE"
} [ define-annotation ] each

>>

