! (c)2009 Joe Groff bsd license
USING: arrays classes classes.singleton classes.tuple help.markup
help.syntax kernel multiline slots quotations ;
IN: variants

HELP: VARIANT:
{ $syntax <"
VARIANT: class-name
    singleton
    singleton
    tuple: { slot slot slot ... }
    .
    .
    .
    ; "> }
{ $description "Defines " { $snippet "class-name" } " as a union of the following " { $link singleton-class } " and " { $link tuple-class } " definitions. Each " { $snippet "singleton" } " word is defined as a " { $snippet "singleton-class" } ", and each " { $snippet "tuple" } " word is defined aas a " { $snippet "tuple-class" } " with the given set of " { $snippet "slot" } "s, using the same syntax for slot specifiers as " { $link POSTPONE: TUPLE: } ". Typed tuple slots are able to recursively reference the variant " { $snippet "class-name" } " being defined. For " { $snippet "tuple" } " types, a " { $link boa } " constructor word " { $snippet "<tuple>" } " is defined as well." }
{ $examples { $code <"
USING: kernel variants ;
IN: scratchpad

VARIANT: list
    nil
    cons: { { first object } { rest list } }
    ;
"> } } ;

HELP: match
{ $values { "branches" array } }
{ $description "Dispatches on the type of the value on the top of the stack. If the type is a " { $link singleton-class } ", the corresponding quotation is called with an empty stack. If the type is a " { $link tuple-class } ", the tuple slots are pushed onto the stack by order of arguments." }
{ $examples { $example <"
USING: kernel math prettyprint variants ;
IN: scratchpad

VARIANT: list
    nil
    cons: { { first object } { rest list } }
    ;

: list-length ( list -- length )
    {
        { nil [ 0 ] }
        { cons [ nip list-length 1 + ] }
    } match ;

1 2 3 4 nil <cons> <cons> <cons> <cons> list-length .
"> "4" } } ;

HELP: unboa
{ $values { "class" class } }
{ $description "Decomposes a tuple of type " { $snippet "class" } " into its component slot values by order of arguments. The inverse of " { $link boa } "." } ;

HELP: variant-class
{ $class-description "This class comprises class names that have been defined with " { $link POSTPONE: VARIANT: } ". When a " { $snippet "variant-class" } " is used as the type of a specialized " { $link tuple } " slot, the variant's first member type is used as the default " { $link initial-value } "." } ;

{ POSTPONE: VARIANT: variant-class match } related-words

ARTICLE: "variants" "Algebraic data types"
"The " { $vocab-link "variants" } " vocabulary provides syntax and combinators for defining and manipulating algebraic data types."
{ $subsection POSTPONE: VARIANT: }
{ $subsection variant-class }
{ $subsection match } ;

ABOUT: "variants"
