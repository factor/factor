IN: make
USING: help.markup help.syntax quotations sequences math.parser
kernel ;

ARTICLE: "make-philosophy" "Make philosophy"
{ $heading "When to use make" }
"Make is useful for complex sequence construction which is hard to express with sequence combinators and various combinations of utility words."
$nl
"For example, this example uses " { $link make } " and reads better than a version using utility words:"
{ $code "[ [ left>> , ] [ \"+\" % center>> % \"-\" % ] [ right , ] tri ] { } make" }
"compare the above to"
{ $code "[ center>> \"+\" \"-\" surround ] [ left>> prefix ] [ right suffix ] tri" }
"The first one has a similar shape to the eventual output array. The second one has an arbitrary structure and uses three different utilities. Furthermore, the second version also constructs two redundant intermediate sequences, and for longer sequences, this extra copying will outweigh any overhead " { $link make } " has due to its use of a dynamic variable to store the sequence being built."
$nl
"On the other hand, using " { $link make } " instead of a single call to " { $link surround } " is overkill. The below headings summarize the most important cases where other idioms are more appropriate than " { $link make } "."
{ $heading "Make versus combinators" }
"Sometimes, usages of " { $link make } " are better expressed with " { $link "sequences-combinators" } ". For example, instead of calling a combinator with a quotation which executes " { $link , } " exactly once on each iteration, often a combinator encapsulating that specific idiom exists and can be used."
$nl
"For example,"
{ $code "[ [ 42 * , ] each ] { } make" }
"is equivalent to"
{ $code "[ 42 * ] map" }
"and"
{ $code "[ [ reverse % ] each ] \"\" make" }
"is equivalent to"
{ $code "[ reverse ] map concat" }
{ $heading "Utilities for simple make patterns" }
"Sometimes, an existing word already implements a specific " { $link make } " usage. For example, " { $link prefix } " is equivalent to the following, with the added caveat that the below example always outputs an array:"
{ $code "[ , % ] { } make" }
"The existing utility words can in some cases express intent better than a bunch of " { $link , } " and " { $link % } "."
{ $heading "Constructing quotations" }
"Simple quotation construction can often be accomplished using " { $link "fry" } " and " { $link "compositional-combinators" } "."
$nl
"For example,"
{ $code "[ 2 , , \\ + , ] [ ] make" }
"is better expressed as"
{ $code "'[ 2 _ + ]" } ;

ARTICLE: "namespaces-make" "Making sequences with variables"
"The " { $vocab-link "make" } " vocabulary implements a facility for constructing sequences by holding an collector sequence in a variable. Storing the collector sequence in a variable rather than the stack may allow code to be written with less stack manipulation."
$nl
"Sequence construction is wrapped in a combinator:"
{ $subsections make }
"Inside the quotation passed to " { $link make } ", several words accumulate values:"
{ $subsections
    ,
    %
    #
}
"The collector sequence can be accessed directly from inside a " { $link make } ":"
{ $subsections building }
{ $example
  "USING: make math.parser ;"
  "[ \"Language #\" % CHAR: \\s , 5 # ] \"\" make print"
  "Language # 5"
}
{ $subsections "make-philosophy" } ;

ABOUT: "namespaces-make"

HELP: building
{ $var-description "Temporary mutable growable sequence holding elements accumulated so far by " { $link make } "." } ;

HELP: make
{ $values { "quot" quotation } { "exemplar" sequence } { "seq" "a new sequence" } }
{ $description "Calls the quotation in a new " { $emphasis "dynamic scope" } ". The quotation and any words it calls can execute the " { $link , } " and " { $link % } " words to accumulate elements. When the quotation returns, all accumulated elements are collected into a sequence with the same type as " { $snippet "exemplar" } "." }
{ $examples { $example "USING: make prettyprint ;" "[ 1 , 2 , 3 , ] { } make ." "{ 1 2 3 }" } } ;

HELP: ,
{ $values { "elt" object } }
{ $description "Adds an element to the end of the sequence being constructed by " { $link make } "." } ;

HELP: %
{ $values { "seq" sequence } }
{ $description "Appends a sequence to the end of the sequence being constructed by " { $link make } "." } ;
