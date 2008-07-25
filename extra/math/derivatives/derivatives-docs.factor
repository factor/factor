USING: help.markup help.syntax ;

IN: math.derivatives

HELP: derivative ( x function -- m )
{ $values { "x" "the x-position on the function" } { "function" "a differentiable function" } }
{ $description "Finds the slope of the tangent line at the given x-position on the given function." } ;

{ derivative-func } related-words
