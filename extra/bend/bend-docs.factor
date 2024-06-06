! Copyright (C) 2024 Keldan Chapman.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel ;
IN: bend

HELP: fold
{ $values
    { "obj" object }
    { "branches" "a sequence of type/quotation pairs, with an optional quotation at the end" }
    { "value" "The result of the fold" }
}
{ $description "Unpacks the slots of a tuple, recursively calling " { $link fold } " on slots with a type matching the original object (Except for slots typed with " { $link object } "). Then calls the branch according to object type, to produce a value." } ;

HELP: BEND[
{ $syntax "BEND[ code ... fork ... code ]" }
{ $description "Calls the quotation in a context where the word " { $code "fork" } " can be used to recursively call this quotation again." }
;

ARTICLE: "bend" "Bend"
"The " { $vocab-link "bend" } " vocabulary is an experimental Factor port of some interesting features found in the bend language (" { $url "https://github.com/HigherOrderCO/bend" } ")."
$nl
"The " { $link POSTPONE: BEND[ } " word can help create recursive datastructures, while " { $link fold } " consumes them in a convenient way."
$nl
"Examples:"
$nl
{ $code
"USING: bend kernel math variants ;"
"IN: bend-example"
""
"VARIANT: tree"
"    leaf: { value }"
"    branch: { { left tree } { right tree } }"
"    ;"
""
""
": make-tree ( depth -- tree )"
"    0 BEND[ swap"
"        [ <leaf> ]"
"        [ 1 - swap 2 * [ fork ] [ 1 + fork ] 2bi <branch> ]"
"        if-zero"
"    ] ;"
""
""
": sum-tree ( tree -- sum )"
"    {"
"        { leaf [ ] }"
"        { branch [ + ] }"
"    } fold ;" }
$nl ;

ABOUT: "bend"