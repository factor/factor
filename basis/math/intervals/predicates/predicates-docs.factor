USING: classes compiler.units help.markup help.syntax math math.intervals ;
IN: math.intervals.predicates

HELP: INTERVAL-PREDICATE:
{ $syntax "INTERVAL-PREDICATE: class < superclass interval... ;" }
{ $values
  { "class" "a new class word to define" }
  { "superclass" "an existing superclass, which should be derived from " { $link real } "." }
  { "interval" "code that must result in a valid " { $link interval }
    ", i.e. have the stack effect " { $snippet "( -- int )" } }
}
{ $description
  "Defines a predicate class deriving from " { $snippet "superclass" } ", with the predicate being a test if an object is an instance of the predicate's superclass as well as if is contained in the specified interval."
}

{ $examples
  { $code "USING: math.intervals math.interval-predicates ;" "INTERVAL-PREDICATE: positive < integer 0 (a,inf] ;" }
}
{ $notes
    "In addition to defining a predicate for the class, this also sets the word property " { $snippet "\"declared-interval\"" }
    ", which allows the optimizing compiler to make additional assumptions about the numerical range of a number which has been declared a type of the defined class."
}
{ $see-also "predicates" "math-intervals" "word-props" }
;

HELP: define-interval-predicate-class
{ $values { "class" class } { "superclass" class } { "interval" interval } }
{ $description "Defines an interval predicate class.  This is the run time equivalent of " { $link POSTPONE: INTERVAL-PREDICATE: } }
{ $notes "This word must be called from inside " { $link with-compilation-unit } "." }
{ $side-effects "class" } ;

{ define-interval-predicate-class POSTPONE: INTERVAL-PREDICATE: } related-words
