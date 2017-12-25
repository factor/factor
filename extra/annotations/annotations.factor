! (c)2009 Joe Groff, Doug Coleman. see BSD license
USING: accessors combinators.short-circuit kernel lexer
namespaces sequences tools.crossref words ;
FROM: functors2 => new-word \SAME-FUNCTOR: ;
IN: annotations

<<

: (parse-annotation) ( accum -- accum )
    lexer get [ line-text>> suffix! ] [ next-line ] bi ;

: (non-annotation-usage) ( word -- usages )
    smart-usage
    [ { [ word? ] [ vocabulary>> "annotations" = ] } 1&& not ]
    filter ;

SAME-FUNCTOR: annotation ( NAME: new-word -- ) [[

USING: annotations kernel sequences tools.crossref ;

: (${NAME}) ( str -- ) drop ; inline

SYNTAX: !${NAME} (parse-annotation) \ (${NAME}) suffix! ;

: ${NAME}s ( -- usages )
    \ (${NAME}) (non-annotation-usage) ;

: ${NAME}s. ( -- )
    ${NAME}s sorted-definitions. ;

]]

SYNTAX: \ANNOTATIONS: ";" [ define-annotation ] each-token ;
>>

! SYMBOLS: XXX TODO FIXME BUG REVIEW LICENSE
    ! AUTHOR BROKEN HACK LOL NOTE ;

! CONSTANT: annotation-tags {
    ! XXX TODO FIXME BUG REVIEW LICENSE
    ! AUTHOR BROKEN HACK LOL NOTE
! }

ANNOTATIONS: XXX TODO FIXME BUG REVIEW LICENSE AUTHOR BROKEN HACK LOL NOTE ;
