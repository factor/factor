
USING: kernel quotations help.syntax help.markup ;

IN: combinators.cleave

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

ARTICLE: "cleave-combinators" "Cleave Combinators"

{ $subsection bi  }
{ $subsection tri }

{ $notes
  "From the Merriam-Webster Dictionary: "
  $nl
  { $strong "cleave" }
  { $list
    { $emphasis "To divide by or as if by a cutting blow" }
    { $emphasis "To separate into distinct parts and especially into "
                "groups having divergent views" } }
  $nl
  "The Joy programming language has a " { $emphasis "cleave" } " combinator." }

;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

HELP: bi

  { $values { "x" object }
            { "p" quotation }
            { "q" quotation }
          
            { "p(x)" "p applied to x" }
            { "q(x)" "q applied to x" } } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

HELP: tri

  { $values { "x" object }
            { "p" quotation }
            { "q" quotation }
            { "r" quotation }
          
            { "p(x)" "p applied to x" }
            { "q(x)" "q applied to x" }
            { "r(x)" "r applied to x" } } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

ARTICLE: "spread-combinators" "Spread Combinators"

{ $subsection bi* }
{ $subsection tri* } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

HELP: bi*

  { $values { "x" object }
            { "y" object }
            { "p" quotation }
            { "q" quotation }
          
            { "p(x)" "p applied to x" }
            { "q(y)" "q applied to y" } } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

HELP: tri*

  { $values { "x" object }
            { "y" object }
            { "z" object }
            { "p" quotation }
            { "q" quotation }
            { "r" quotation }
          
            { "p(x)" "p applied to x" }
            { "q(y)" "q applied to y" }
            { "r(z)" "r applied to z" } } ;
