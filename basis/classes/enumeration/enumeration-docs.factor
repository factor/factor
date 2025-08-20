IN: classes.enumeration
USING: words kernel help.syntax help.markup math assocs strings sequences classes ;

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
        "USING: classes.enumeration prettyprint strings sequences ;\nENUMERATION: example-enum3 < string { example-elt1 \"a\" [ CHAR: a suffix ] } example-elt2 ;\n example-enum3.example-elt2 ."
        "\"aa\""
}
{ $see-also POSTPONE: ENUMERATION: "enums" } 
;

HELP: ENUMERATION:
{ $syntax "ENUMERATION: name elements ... ;" }
{ $description 
    "Defines a new enumeration class. Elements may be specified using " { $link "enumeration-element-syntax" } " or just by name" 
} 
{ $examples 
    { $example "IN: enumeration-demo" "USING: prettyprint classes.enumeration ;\nENUMERATION: example-enum example-elt1 example-elt2 ;\n example-enum.example-elt2 ." "2" }
    { $example "IN: enumeration-demo" "USING: prettyprint classes.enumeration ;\nENUMERATION: example-enum2 example-elt1 { example-elt2 5 } example-elt3 ;\n example-enum2.example-elt3 ." "6" }
    {
        $example 
        "IN: enumeration-demo" 
        "USING: prettyprint strings sequences classes.enumeration ;\nENUMERATION: example-enum3 < string { example-elt1 \"a\" [ CHAR: a suffix ] } example-elt2 ;\n example-enum3.example-elt2 ."
        "\"aa\""
    }
} 
{ $see-also "enums" } ;

HELP: define-enum-class
{ $values
    { "class" class } { "superclass" class } { "member-list" sequence }
}
{ 
    $description "Defines an enumeration class. This is the runtime equivalent of " 
    { $link POSTPONE: ENUMERATION: } ". The " { $snippet "member-list" } " input has a very similar form to " { $link "enumeration-element-syntax" } ". The only difference is that enum element names are represented as strings (or as a 1-length array containing the string if it would otherwise be alone), rather than words" 
} ;

HELP: enum-member-list
{ $values
    { "enumeration-class" object }
    { "member-list" object }
}
{ $description "Retrieves the \"member list\" of an enumeration. See " { $link define-enum-class } " for information about member lists." } ;

HELP: enumeration-class
{ $class-description "The class of enumeration class words." } ;

HELP: enumeration-member-word
{ $class-description "The class of words that are part of enums." } ;

HELP: incorrect-type-in-enum-value
{ $values
    { "expected-type" object } { "value" object } { "word" word }
}
{ $description "Throws an " { $link incorrect-type-in-enum-value } " error." }
{ $error-description "Thrown when one element of an enum isn't of the enum's base type. For example, if the enum extends " { $link fixnum } " but the value is of type " { $link string } } ;


ABOUT: "enums"
