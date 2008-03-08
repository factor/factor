USING: help.markup help.syntax quotations kernel ;
IN: fry

HELP: ,
{ $description "Fry specifier. Inserts a literal value into the fried quotation." } ;

HELP: @
{ $description "Fry specifier. Splices a quotation into the fried quotation." } ;

HELP: _
{ $description "Fry specifier. Shifts all fry specifiers to the left down by one stack position." } ;

HELP: fry
{ $values { "quot" quotation } { "quot'" quotation } }
{ $description "Outputs a quotation that when called, fries " { $snippet "quot" } " by taking values from the stack and substituting them in." }
{ $notes "This word is used to implement " { $link POSTPONE: '[ } "; the following two lines are equivalent:"
    { $code "[ X ] fry call" "'[ X ]" }
} ;

HELP: '[
{ $syntax "code... ]" }
{ $description "Literal fried quotation. Expands into code which takes values from the stack and substituting them in." } ;

ARTICLE: "fry.examples" "Examples of fried quotations"
"Conceptually, " { $link fry } " is tricky however the general idea is easy to grasp once presented with examples."
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
"Occurrences of " { $link @ } " are simply syntax sugar for " { $snippet ", call" } ". The following three lines are equivalent:"
{ $code 
    "{ 10 20 30 } [ sq ] '[ @ . ] map"
    "{ 10 20 30 } [ sq ] [ . ] compose map"
    "{ 10 20 30 } [ sq . ] map"
}
"The " { $link , } " and " { $link @ } " specifiers may be freely mixed:"
{ $code
    "{ 8 13 14 27 } [ even? ] 5 [ @ dup , ? ] map"
    "{ 8 13 14 27 } [ even? ] 5 [ dup ] swap [ ? ] curry 3compose map"
    "{ 8 13 14 27 } [ even? dup 5 ? ] map"
}
"Occurrences of " { $link _ } " have the effect of enclosing all code to their left with " { $link >r } " and " { $link r> } ":"
{ $code 
    "{ 10 20 30 } 1 '[ , _ / ] map"
    "{ 10 20 30 } 1 [ swap / ] curry map"
    "{ 10 20 30 } [ 1 swap / ] map"
}
"For any quotation body " { $snippet "X" } ", the following two are equivalent:"
{ $code
    "[ >r X r> ]"
    "[ X _ ]"
}
"Here are some built-in combinators rewritten in terms of fried quotations:"
{ $table
    { { $link literalize } { $snippet ": literalize '[ , ] ;" } }
    { { $link slip } { $snippet ": slip '[ @ , ] call ;" } }
    { { $link dip } { $snippet ": dip '[ @ _ ] call ;" } }
    { { $link curry } { $snippet ": curry '[ , @ ] ;" } }
    { { $link with } { $snippet ": with swapd '[ , _ @ ] ;" } }
    { { $link compose } { $snippet ": compose '[ @ @ ] ;" } }
    { { $link 2apply } { $snippet ": 2apply tuck '[ , @ , @ ] call ;" } }
} ;

ARTICLE: "fry.philosophy" "Fried quotation philosophy"
"Fried quotations generalize quotation-building words such as " { $link curry } " and " { $link compose } "."
$nl
"There is a mapping from fried quotations to lexical closures as defined in the " { $vocab-link "locals" } " vocabulary. Namely, a fried quotation is equivalent to a ``let'' form where each local binding is only used once, and bindings are used in the same order in which they are defined. The following two lines are equivalent:"
{ $code
    "'[ 3 , + 4 , / ]"
    "[let | a [ ] b [ ] | [ 3 a + 4 b / ] ]"
}
"The " { $link _ } " fry specifier has no direct analogue in " { $vocab-link "locals" } ", however closure conversion together with the " { $link dip } " combinator achieve the same effect:"
{ $code
    "'[ , 2 + , * _ / ]"
    "[let | a [ ] b [ ] | [ [ a 2 + b * ] dip / ] ]"
} ;

ARTICLE: "fry.limitations" "Fried quotation limitations"
"As with " { $link "locals" } ", fried quotations cannot contain " { $link >r } " and " { $link r> } ". Unlike " { $link "locals" } ", using " { $link dip } " is not a suitable workaround since unlike closure conversion, fry conversion is not recursive, and so the quotation passed to " { $link dip } " cannot contain fry specifiers." ;

ARTICLE: "fry" "Fried quotations"
"A " { $emphasis "fried quotation" } " differs from a literal quotation in that when it is evaluated, instead of just pushing itself on the stack, it consumes zero or more stack values and inserts them into the quotation."
$nl
"Fried quotations are denoted with a special parsing word:"
{ $subsection POSTPONE: '[ }
"Fried quotations contain zero or more " { $emphasis "fry specifiers" } ":"
{ $subsection , }
{ $subsection @ }
{ $subsection _ }
"When a fried quotation is being evaluated, values are consumed from the stack and spliced into the quotation from right to left."
{ $subsection "fry.examples" }
{ $subsection "fry.philosophy" }
{ $subsection "fry.limitations" }
"Quotations can also be fried without using a parsing word:"
{ $subsection fry } ;

ABOUT: "fry"
