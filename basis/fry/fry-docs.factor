USING: help.markup help.syntax quotations kernel ;
IN: fry

HELP: ,
{ $description "Fry specifier. Inserts a literal value into the fried quotation." } ;

HELP: @
{ $description "Fry specifier. Splices a quotation into the fried quotation." } ;

HELP: fry
{ $values { "quot" quotation } { "quot'" quotation } }
{ $description "Outputs a quotation that when called, fries " { $snippet "quot" } " by taking values from the stack and substituting them in." }
{ $notes "This word is used to implement " { $link POSTPONE: '[ } "; the following two lines are equivalent:"
    { $code "[ X ] fry call" "'[ X ]" }
} ;

HELP: '[
{ $syntax "code... ]" }
{ $description "Literal fried quotation. Expands into code which takes values from the stack and substitutes them in place of the fry specifiers " { $link , } " and " { $link @ } "." }
{ $examples "See " { $link "fry.examples" } "." } ;

ARTICLE: "fry.examples" "Examples of fried quotations"
"The easiest way to understand fried quotations is to look at some examples."
$nl
"If a quotation does not contain any fry specifiers, then " { $link POSTPONE: '[ } " behaves just like " { $link POSTPONE: [ } ":"
{ $code "{ 10 20 30 } '[ . ] each" }
"Occurrences of " { $link , } " on the left map directly to " { $link curry } ". That is, the following three lines are equivalent:"
{ $code 
    "{ 10 20 30 } 5 '[ , + ] map"
    "{ 10 20 30 } 5 [ + ] curry map"
    "{ 10 20 30 } [ 5 + ] map"
}
"Occurrences of " { $link , } " in the middle of a quotation map to more complex quotation composition patterns. The following three lines are equivalent:"
{ $code 
    "{ 10 20 30 } 5 '[ 3 , / ] map"
    "{ 10 20 30 } 5 [ 3 ] swap [ / ] curry compose map"
    "{ 10 20 30 } [ 3 5 / ] map"
}
"Occurrences of " { $link @ } " are simply syntax sugar for " { $snippet ", call" } ". The following four lines are equivalent:"
{ $code 
    "{ 10 20 30 } [ sq ] '[ @ . ] each"
    "{ 10 20 30 } [ sq ] [ call . ] curry each"
    "{ 10 20 30 } [ sq ] [ . ] compose each"
    "{ 10 20 30 } [ sq . ] each"
}
"The " { $link , } " and " { $link @ } " specifiers may be freely mixed:"
{ $code
    "{ 8 13 14 27 } [ even? ] 5 '[ @ dup , ? ] map"
    "{ 8 13 14 27 } [ even? ] 5 [ dup ] swap [ ? ] curry 3compose map"
    "{ 8 13 14 27 } [ even? dup 5 ? ] map"
}
"Here are some built-in combinators rewritten in terms of fried quotations:"
{ $table
    { { $link literalize } { $snippet ": literalize '[ , ] ;" } }
    { { $link slip } { $snippet ": slip '[ @ , ] call ;" } }
    { { $link curry } { $snippet ": curry '[ , @ ] ;" } }
    { { $link compose } { $snippet ": compose '[ @ @ ] ;" } }
    { { $link bi@ } { $snippet ": bi@ tuck '[ , @ , @ ] call ;" } }
} ;

ARTICLE: "fry.philosophy" "Fried quotation philosophy"
"Fried quotations generalize quotation-building words such as " { $link curry } " and " { $link compose } ". They can clean up code with lots of currying and composition, particularly when quotations are nested:"
{ $code
    "'[ [ , key? ] all? ] filter"
    "[ [ key? ] curry all? ] curry filter"
}
"There is a mapping from fried quotations to lexical closures as defined in the " { $vocab-link "locals" } " vocabulary. Namely, a fried quotation is equivalent to a ``let'' form where each local binding is only used once, and bindings are used in the same order in which they are defined. The following two lines are equivalent:"
{ $code
    "'[ 3 , + 4 , / ]"
    "[let | a [ ] b [ ] | [ 3 a + 4 b / ] ]"
} ;

ARTICLE: "fry.limitations" "Fried quotation limitations"
"As with " { $vocab-link "locals" } ", fried quotations cannot contain " { $link >r } " and " { $link r> } ". This is not a real limitation in practice, since " { $link dip } " can be used instead." ;

ARTICLE: "fry" "Fried quotations"
"A " { $emphasis "fried quotation" } " differs from a literal quotation in that when it is evaluated, instead of just pushing itself on the stack, it consumes zero or more stack values and inserts them into the quotation."
$nl
"Fried quotations are denoted with a special parsing word:"
{ $subsection POSTPONE: '[ }
"Fried quotations contain zero or more " { $emphasis "fry specifiers" } ":"
{ $subsection , }
{ $subsection @ }
"When a fried quotation is being evaluated, values are consumed from the stack and spliced into the quotation from right to left."
{ $subsection "fry.examples" }
{ $subsection "fry.philosophy" }
{ $subsection "fry.limitations" }
"Quotations can also be fried without using a parsing word:"
{ $subsection fry } ;

ABOUT: "fry"
