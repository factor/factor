USING: help.markup help.syntax ;

IN: math.derivatives

HELP: derivative ( x function -- m )
{ $values { "x" "a position on the function" } { "function" "a differentiable function" } }
{ $description
    "Approximates the slope of the tangent line by using Ridders' "
    "method of computing derivatives, from the chapter \"Accurate computation "
    "of F'(x) and F'(x)F''(x)\", from \"Advances in Engineering Software, Vol. 4, pp. 75-76 ."
}
{ $examples
    { $example
        "USING: math.derivatives prettyprint ;"
        "[ sq ] 4 derivative ."
        "8"
    }
    { $notes
        "For applied scientists, you may play with the settings "
        "in the source file to achieve arbitrary accuracy. "
    }
} ;

HELP: derivative-func ( function -- der )
{ $values { "func" "a differentiable function" } { "der" "the derivative" } }
{ $description
    "Provides the derivative of the function. The implementation simply "
    "attaches the " { $link derivative } " word to the end of the function."
}
{ $examples
    { $example
        "USING: math.derivatives prettyprint ;"
        "[ sq ] derivative-func ."
        "[ [ sq ] derivative ]"
    }
} ;

ARTICLE: "derivatives" "The Derivative Toolkit"
"A toolkit for computing the derivative of functions."
{ $subsection derivative }
{ $subsection derivative-func } ;
ABOUT: "derivatives"
