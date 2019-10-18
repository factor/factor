USING: help.markup help.syntax math math.functions ;
IN: math.derivatives

HELP: derivative ( x function -- m )
{ $values { "x" "a position on the function" } { "function" "a differentiable function" } { "m" number } }
{ $description
    "Approximates the slope of the tangent line by using Ridders' "
    "method of computing derivatives, from the chapter \"Accurate computation "
    "of F'(x) and F'(x)F''(x)\", from \"Advances in Engineering Software, Vol. 4, pp. 75-76 ."
}
{ $examples
    { $example
        "USING: math math.derivatives prettyprint ;"
        "4 [ sq ] derivative >integer ."
        "8"
    }
    { $notes
        "For applied scientists, you may play with the settings "
        "in the source file to achieve arbitrary accuracy. "
    }
} ;

HELP: (derivative)
{ $values
    { "x" "a position on the function" }
    { "func" "a differentiable function" }
    {
        "h" "distance between the points of the first secant line used for "
        "approximation of the tangent. This distance will be divided "
        "constantly, by " { $link con } ". See " { $link init-hh }
        " for the code which enforces this. H should be .001 to .5 -- too "
        "small can cause bad convergence. Also, h should be small enough "
        "to give the correct sgn(f'(x)). In other words, if you're expecting "
        "a positive derivative, make h small enough to give the same "
        "when plugged into the academic limit definition of a derivative. "
        "See " { $link update-hh } " for the code which performs this task."
    }
    {
        "err" "maximum tolerance of increase in error. For example, if this "
        "is set to 2.0, the program will terminate with its nearest answer "
        "when the error multiplies by 2. See " { $link check-safe } " for "
        "the enforcing code."
    }
    {   "ans" number }
    {   "error" number }
}
{ $description
    "Approximates the slope of the tangent line by using Ridders' "
    "method of computing derivatives, from the chapter \"Accurate computation "
    "of F'(x) and F'(x)F''(x)\", from \"Advances in Engineering Software, "
    "Vol. 4, pp. 75-76 ."
}
{ $examples
    { $example
        "USING: math math.derivatives prettyprint ;"
        "4 [ sq ] derivative >integer ."
        "8"
    }
    { $notes
        "For applied scientists, you may play with the settings "
        "in the source file to achieve arbitrary accuracy. "
    }
} ;

HELP: derivative-func
{ $values { "func" "a differentiable function" } { "der" "the derivative" } }
{ $description
    "Provides the derivative of the function. The implementation simply "
    "attaches the " { $link derivative } " word to the end of the function."
}
{ $examples
    { $example
        "USING: kernel math.derivatives math.functions math.trig prettyprint ;"
        "60 deg>rad [ sin ] derivative-func call 0.5 .001 ~ ."
        "t"
    }
    { $notes
        "Without a heavy algebraic system, derivatives must be "
        "approximated. With the current settings, there is a fair trade of "
        "speed and accuracy; the first 12 digits "
        "will always be correct with " { $link sin } " and " { $link cos }
        ". The following code performs a minumum and maximum error test."
        { $code
            "USING: kernel math math.functions math.trig sequences sequences.lib ;"
            "360"
            "["
            "           deg>rad"
            "            [ [ sin ] derivative-func call ]"
            "           ! Note: the derivative of sin is cos"
            "            [ cos ]"
            "       bi - abs"
            "] map minmax"
        }
    }
} ;

ARTICLE: "derivatives" "The Derivative Toolkit"
"A toolkit for computing the derivative of functions."
{ $subsections
    derivative
    derivative-func
    (derivative)
} ;

ABOUT: "derivatives"
