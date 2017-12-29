! (c)2009 Joe Groff, Doug Coleman. see BSD license
USING: accessors combinators.short-circuit kernel lexer
namespaces sequences tools.crossref words ;
FROM: functors2 => new-word \INLINE-FUNCTOR: ;
IN: annotations

<<

: (parse-annotation) ( accum -- accum )
    lexer get [ line-text>> suffix! ] [ next-line ] bi ;

: (non-annotation-usage) ( word -- usages )
    smart-usage
    [ { [ word? ] [ vocabulary>> "annotations" = ] } 1&& not ]
    filter ;

INLINE-FUNCTOR: annotation ( name: new-word -- ) [[
    USING: annotations kernel sequences tools.crossref ;

    : (${name}) ( str -- ) drop ; inline

    SYNTAX: !${name} (parse-annotation) \ (${name}) suffix! ;

    : ${name}s ( -- usages )
        \ (${name}) (non-annotation-usage) ;

    : ${name}s. ( -- )
        ${name}s sorted-definitions. ;
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
