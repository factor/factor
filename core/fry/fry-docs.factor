USING: help.markup help.syntax quotations kernel ;
IN: fry

HELP: _
{ $description "Fry specifier. Inserts a literal value into the fried quotation." }
{ $examples "See " { $link "fry.examples" } "." } ;

HELP: @
{ $description "Fry specifier. Splices a quotation into the fried quotation." }
{ $examples "See " { $link "fry.examples" } "." } ;

HELP: fry
{ $values { "object" object } { "quot" quotation } }
{ $description "Outputs a quotation that when called, fries " { $snippet "object" } " by taking values from the stack and substituting them in." }
{ $notes "This word is used to implement " { $link POSTPONE: '[ } "; the following two lines are equivalent:"
    { $code "[ X ] fry call" "'[ X ]" }
}
{ $examples "See " { $link "fry.examples" } "." } ;

HELP: '[
{ $syntax "'[ code... ]" }
{ $description "Literal fried quotation. Expands into code which takes values from the stack and substitutes them in place of the fry specifiers " { $link POSTPONE: _ } " and " { $link POSTPONE: @ } "." }
{ $examples "See " { $link "fry.examples" } "." } ;

HELP: >r/r>-in-fry-error
{ $error-description "Thrown by " { $link POSTPONE: '[ } " if the fried quotation contains calls to retain stack manipulation primitives." } ;

ARTICLE: "fry.examples" "Examples of fried quotations"
"The easiest way to understand fried quotations is to look at some examples."
$nl
"If a quotation does not contain any fry specifiers, then " { $link POSTPONE: '[ } " behaves just like " { $link POSTPONE: [ } ":"
{ $code "{ 10 20 30 } '[ . ] each" }
"Occurrences of " { $link POSTPONE: _ } " on the left map directly to " { $link curry } ". That is, the following three lines are equivalent:"
{ $code
    "{ 10 20 30 } 5 '[ _ + ] map"
    "{ 10 20 30 } 5 [ + ] curry map"
    "{ 10 20 30 } [ 5 + ] map"
}
"Occurrences of " { $link POSTPONE: _ } " in the middle of a quotation map to more complex quotation composition patterns. The following three lines are equivalent:"
{ $code
    "{ 10 20 30 } 5 '[ 3 _ / ] map"
    "{ 10 20 30 } 5 [ 3 ] swap [ / ] curry compose map"
    "{ 10 20 30 } [ 3 5 / ] map"
}
"Occurrences of " { $link POSTPONE: @ } " are simply syntax sugar for " { $snippet "_ call" } ". The following four lines are equivalent:"
{ $code
    "{ 10 20 30 } [ sq ] '[ @ . ] each"
    "{ 10 20 30 } [ sq ] [ call . ] curry each"
    "{ 10 20 30 } [ sq ] [ . ] compose each"
    "{ 10 20 30 } [ sq . ] each"
}
"The " { $link POSTPONE: _ } " and " { $link POSTPONE: @ } " specifiers may be freely mixed, and the result is considerably more concise and readable than the version using " { $link curry } " and " { $link compose } " directly:"
{ $code
    "{ 8 13 14 27 } [ even? ] 5 '[ @ dup _ ? ] map"
    "{ 8 13 14 27 } [ even? ] 5 [ dup ] swap [ ? ] curry compose compose map"
    "{ 8 13 14 27 } [ even? dup 5 ? ] map"
}
"The following is a no-op:"
{ $code "'[ @ ]" }
"Here are some built-in combinators rewritten in terms of fried quotations:"
{ $table
    { { $link literalize } { $snippet ": literalize '[ _ ] ;" } }
    { { $link curry } { $snippet ": curry '[ _ @ ] ;" } }
    { { $link compose } { $snippet ": compose '[ @ @ ] ;" } }
} ;

ARTICLE: "fry.philosophy" "Fried quotation philosophy"
"Fried quotations generalize quotation-building words such as " { $link curry } " and " { $link compose } ". They can clean up code with lots of currying and composition, particularly when quotations are nested:"
{ $code
    "'[ [ _ key? ] all? ] filter"
    "[ [ key? ] curry all? ] curry filter"
}
"There is a mapping from fried quotations to lexical closures as defined in the " { $vocab-link "locals" } " vocabulary. Namely, a fried quotation is equivalent to a " { $snippet "[| | ]" } " form where each local binding is only used once, and bindings are used in the same order in which they are defined. The following two lines are equivalent:"
{ $code
    "'[ 3 _ + 4 _ / ]"
    "[| a b | 3 a + 4 b / ]"
} ;

ARTICLE: "fry" "Fried quotations"
"The " { $vocab-link "fry" } " vocabulary implements " { $emphasis "fried quotation" } ". Conceptually, fried quotations are quotations with \"holes\" (more formally, " { $emphasis "fry specifiers" } "), and the holes are filled in when the fried quotation is pushed on the stack."
$nl
"Fried quotations are started by a special parsing word:"
{ $subsections POSTPONE: '[ }
"There are two types of fry specifiers; the first can hold a value, and the second \"splices\" a quotation, as if it were inserted without surrounding brackets:"
{ $subsections
    POSTPONE: _
    POSTPONE: @
}
"The holes are filled in with the top of stack going in the rightmost hole, the second item on the stack going in the second hole from the right, and so on."
{ $subsections
    "fry.examples"
    "fry.philosophy"
}
"Fry is implemented as a parsing word which reads a quotation and scans for occurrences of " { $link POSTPONE: _ } " and " { $link POSTPONE: @ } "; these words are not actually executed, and doing so raises an error (this can happen if they're accidentally used outside of a fry)."
$nl
"Fried quotations can also be constructed without using a parsing word; this is useful when meta-programming:"
{ $subsections fry }
"Fried quotations are an abstraction on top of the " { $link "compositional-combinators" } "; their use is encouraged over the combinators, because often the fry form is shorter and clearer than the combinator form." ;

ABOUT: "fry"
