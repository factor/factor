IN: classes.enumeration
USING: help.syntax help.markup math assocs ;

ARTICLE: "enums" "Enumeration classes"
"An enumeration is a class that contains constants. The values stored in these constants (" { $link fixnum } "s by default) are instances of the class."
{ $subsections
    POSTPONE: ENUMERATION:
    define-enum-class
    "enumeration-element-syntax"
}
"The set of all enumerations is itself a class"
{ $subsections enumeration-class enumeration-class? }

{ $notes
    "Enumerations should not be confused with values of the similarly named " { $link enumerated } " class"
}
;

ARTICLE: "enumeration-element-syntax" "Enumeration element syntax"
"Enumeration elements are typically specified by their name, as in"
{ $code "ENUMERATION: example first-elt second-elt ;" }
"but they can also be specified using an array. The second element of this array is the value assigned to the enum element, and is used as the counter that subsiquent elements increment from"
{ $example "USE: prettyprint" "ENUMERATION: example first-elt { second-elt 10 } third-elt ;\nexample.first-elt example.second-elt example.third-elt .s" "0\n10\n11" }
"The third element of the array, if present, must be a quotation. It defines how subsiquent increments are handled. By default, incrementation means that 1 is added to the counter to get the value of the next element. This quotation changes that definition."
{ $example "USE: prettyprint math" "ENUMERATION: example first-elt second-elt { third-elt 3 [ 2 * ] } fourth-elt fifth-elt ;\nexample.third-elt example.fourth-elt example.fifth-elt .s" "3\n6\n12" }
"Despite their name, enumeration values do not just have to be numbers, although if these values don't support math operations, you'll need to define a custom incrementation quotation and starting value."
{
        $example 
        "IN: enumeration-demo" 
        "USING: prettyprint strings sequences ;\nENUMERATION: example-enum3 < string { example-elt1 \"a\" [ CHAR: a suffix ] } example-elt2 ;\n example-enum3.example-elt2 ."
        "\"aa\""
}
{ $see-also POSTPONE: ENUMERATION: "enums" } 
;

ABOUT: "enums"
