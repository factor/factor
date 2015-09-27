USING: help.syntax help.markup classes layouts ;
IN: classes.builtin

ARTICLE: "builtin-classes" "Built-in classes"
"Every object is an instance of exactly one canonical " { $emphasis "built-in class" } " which defines its layout in memory and basic behavior."
$nl
"The set of built-in classes is a class:"
{ $subsections
    builtin-class
    builtin-class?
}
"See " { $link "class-index" } " for a list of built-in classes." ;

HELP: builtin-class
{ $class-description "The class of built-in classes." }
{ $examples
    "The class of arrays is a built-in class:"
    { $example "USING: arrays classes.builtin prettyprint ;" "array builtin-class? ." "t" }
    "However, an instance of the array class is not a built-in class; it is not even a class:"
    { $example "USING: classes.builtin prettyprint ;" "{ 1 2 3 } builtin-class? ." "f" }
} ;

HELP: builtins
{ $var-description "Vector mapping type numbers to builtin class words." } ;

HELP: type>class
{ $values { "n" "a non-negative integer" } { "class" class } }
{ $description "Outputs a builtin class whose instances are precisely those having a given pointer tag." }
{ $notes "The parameter " { $snippet "n" } " must be between 0 and the return value of " { $link num-types } "." } ;
