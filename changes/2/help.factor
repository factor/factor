USING: accessors arrays assocs classes combinators effects
generic help.markup help.topics kernel make namespaces
prettyprint sequences words words.symbol ;
IN: help

M: word article-title
    dup [ parsing-word? ] [ symbol? ] bi or [ name>> ] [ unparse ] if ;

<PRIVATE

: (word-help) ( word -- element )
    [
        {
            [ \ $vocabulary swap 2array , ]
            [ \ $graph swap 2array , ]
            [ word-help % ]
            [ dup global at [ get-global \ $value swap 2array , ] [ drop ] if ]
            [ \ $definition swap 2array , ]
            [ \ $related swap 2array , ]
        } cleave
    ] { } make ;

PRIVATE>

M: generic article-content (word-help) ;

M: class article-content (word-help) ;

M: word word-help*
    stack-effect [ in>> ] [ out>> ] bi [
        [
            dup pair? [
                first2 dup effect? [ \ $quotation swap 2array ] when
            ] [
                object
            ] if [ effect>string ] dip
        ] { } map>assoc
    ] bi@ [ \ $inputs prefix ] dip \ $outputs prefix 2array ;
