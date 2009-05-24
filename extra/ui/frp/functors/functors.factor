USING: fry functors generalizations kernel macros peg peg-lexer
sequences ;
IN: ui.frp.functors

FUNCTOR: fmaps ( W P -- )
W        IS ${W}
<p>      IS <${P}>
w-n      DEFINES ${W}-n-${P}
w-2      DEFINES 2${W}-${P}
w-3      DEFINES 3${W}-${P}
w-4      DEFINES 4${W}-${P}
WHERE
MACRO: w-n ( int -- quot ) dup '[ [ _ narray <p> ] dip [ _ firstn ] prepend W ] ;
: w-2 ( a b quot -- mapped ) 2 w-n ; inline
: w-3 ( a b c quot -- mapped ) 3 w-n ; inline
: w-4 ( a b c d quot -- mapped ) 4 w-n ; inline
;FUNCTOR

ON-BNF: FMAPS:
tokenizer = <foreign factor>
token = !("FOR"|";").
middle = "FOR" => [[ drop ignore ]]
endexpr = ";" => [[ drop ignore ]]
expr = token* middle token* endexpr => [[ first2 combos [ first2 fmaps ] each ignore ]]
;ON-BNF