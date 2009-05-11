USING: help.markup help.syntax math sequences ;
IN: math.polynomials

ARTICLE: "polynomials" "Polynomials"
"A polynomial is a vector with the highest powers on the right:"
{ $code "{ 1 1 0 1 } -> 1 + x + x^3" "{ } -> 0" }
"Numerous words are defined to help with polynomial arithmetic:"
{ $subsection p= }
{ $subsection p+ }
{ $subsection p- }
{ $subsection p* }
{ $subsection p-sq }
{ $subsection powers }
{ $subsection n*p }
{ $subsection p/mod }
{ $subsection pgcd }
{ $subsection polyval }
{ $subsection pdiff }
{ $subsection pextend-conv }
{ $subsection ptrim }
{ $subsection 2ptrim } ;

ABOUT: "polynomials"

HELP: powers
{ $values { "n" integer } { "x" number } { "seq" sequence } }
{ $description "Output a sequence having " { $snippet "n" } " elements in the format: " { $snippet "{ 1 x x^2 x^3 ... }" } "." }
{ $examples { $example "USING: math.polynomials prettyprint ;" "4 2 powers ." "{ 1 2 4 8 }" } } ;

HELP: p=
{ $values { "p" "a polynomial" } { "q" "a polynomial" } { "?" "a boolean" } }
{ $description "Tests if two polynomials are equal." }
{ $examples { $example "USING: math.polynomials prettyprint ;" "{ 0 1 } { 0 1 0 } p= ." "t" } } ;

HELP: ptrim
{ $values { "p" "a polynomial" } { "p" "a polynomial" } }
{ $description "Trims excess zeros from a polynomial." }
{ $examples { $example "USING: math.polynomials prettyprint ;" "{ 0 1 0 0 } ptrim ." "{ 0 1 }" } } ;

HELP: 2ptrim
{ $values { "p" "a polynomial" } { "q" "a polynomial" } { "p" "a polynomial" } { "q" "a polynomial" } }
{ $description "Trims excess zeros from two polynomials." }
{ $examples { $example "USING: kernel math.polynomials prettyprint ;" "{ 0 1 0 0 } { 1 0 0 } 2ptrim [ . ] bi@" "{ 0 1 }\n{ 1 }" } } ;

HELP: p+
{ $values { "p" "a polynomial" } { "q" "a polynomial" } { "r" "a polynomial" } }
{ $description "Adds " { $snippet "p" } " and " { $snippet "q" } " component-wise." }
{ $examples { $example "USING: math.polynomials prettyprint ;" "{ 1 0 1 } { 0 1 } p+ ." "{ 1 1 1 }" } } ;

HELP: p-
{ $values { "p" "a polynomial" } { "q" "a polynomial" } { "r" "a polynomial" } }
{ $description "Subtracts " { $snippet "q" } " from " { $snippet "p" } " component-wise." }
{ $examples { $example "USING: math.polynomials prettyprint ;" "{ 1 1 1 } { 0 1 } p- ." "{ 1 0 1 }" } } ;

HELP: n*p
{ $values { "n" number } { "p" "a polynomial" } { "n*p" "a polynomial" } }
{ $description "Multiplies each element of " { $snippet "p" } " by " { $snippet "n" } "." }
{ $examples { $example "USING: math.polynomials prettyprint ;" "4 { 3 0 1 } n*p ." "{ 12 0 4 }" } } ;

HELP: pextend-conv
{ $values { "p" "a polynomial" } { "q" "a polynomial" } { "p" "a polynomial" } { "q" "a polynomial" } }
{ $description "Convulution, extending to " { $snippet "p_m + q_n - 1" } "." }
{ $examples { $example "USING: kernel math.polynomials prettyprint ;" "{ 1 0 1 } { 0 1 } pextend-conv [ . ] bi@" "V{ 1 0 1 0 }\nV{ 0 1 0 0 }" } } ;

HELP: p*
{ $values { "p" "a polynomial" } { "q" "a polynomial" } { "r" "a polynomial" } }
{ $description "Multiplies two polynomials." }
{ $examples { $example "USING: math.polynomials prettyprint ;" "{ 1 2 3 0 0 0 } { 1 2 0 0 } p* ." "{ 1 4 7 6 0 0 0 0 0 }" } } ;

HELP: p-sq
{ $values { "p" "a polynomial" } { "p^2" "a polynomial" } }
{ $description "Squares a polynomial." }
{ $examples { $example "USING: math.polynomials prettyprint ;" "{ 1 2 0 } p-sq ." "{ 1 4 4 0 0 }" } } ;

HELP: p/mod
{ $values { "p" "a polynomial" } { "q" "a polynomial" } { "z" "a polynomial" } { "w" "a polynomial" } }
{ $description "Computes to quotient " { $snippet "z" } " and remainder " { $snippet "w" } " of dividing " { $snippet "p" } " by " { $snippet "q" } "." }
{ $examples { $example "USING: kernel math.polynomials prettyprint ;" "{ 1 1 1 1 } { 3 1 } p/mod [ . ] bi@" "V{ 7 -2 1 }\nV{ -20 0 0 }" } } ;

HELP: pgcd
{ $values { "p" "a polynomial" } { "q" "a polynomial" } { "a" "a polynomial" } { "d" "a polynomial" } }
{ $description "Computes the greatest common divisor " { $snippet "d" } " of " { $snippet "p" } " and " { $snippet "q" } ", and another value " { $snippet "a" } " satisfying:" { $code "a*q = d mod p" } }
{ $notes "GCD in the case of polynomials is a monic polynomial of the highest possible degree that divides into both " { $snippet "p" } " and " { $snippet "q" } "." }
{ $examples
    { $example "USING: kernel math.polynomials prettyprint ;"
               "{ 1 1 1 1 } { 1 1 } pgcd [ . ] bi@"
               "{ 0 0 }\n{ 1 1 }"
    }
} ;

HELP: pdiff
{ $values { "p" "a polynomial" } { "p'" "a polynomial" } }
{ $description "Finds the derivative of " { $snippet "p" } "." } ;

HELP: polyval
{ $values { "x" number } { "p" "a polynomial" } { "p[x]" number } }
{ $description "Evaluate " { $snippet "p" } " with the input " { $snippet "x" } "." }
{ $examples { $example "USING: math.polynomials prettyprint ;" "2 { 1 0 1 } polyval ." "5" } } ;

HELP: polyval*
{ $values { "p" "a literal polynomial" } }
{ $description "Macro version of " { $link polyval } ". Evaluates the literal polynomial " { $snippet "p" } " at the value off the top of the stack." }
{ $examples { $example "USING: math.polynomials prettyprint ;" "2 { 1 0 1 } polyval* ." "5" } } ;

{ polyval polyval* } related-words
