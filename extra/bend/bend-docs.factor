! Copyright (C) 2024 Keldan Chapman.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax effects kernel quotations ;
IN: bend

HELP: fold
{ $values
    { "obj" object }
    { "branches" "a sequence of type/quotation pairs, with an optional quotation at the end" }
    { "value" "The result of the fold" }
}
{ $description "Unpacks the slots of a tuple, recursively calling " { $link fold } " on slots with a type matching the original object (Except for slots typed with " { $link object } "). Then calls the branch according to object type, to produce a value." } ;

HELP: bend(
{ $syntax "bend( inputs -- outputs )" }
{ $description "Calls " { $link bend } " with the specified effect." }
{ $notes
    "This parsing word is just a slightly nicer syntax for " { $link bend } ". The following are equivalent:"
    { $code
        "bend( inputs -- outputs )"
        "( inputs -- outputs ) bend"
    }
} ;

HELP: bend
{ $values
    { "quot" quotation } { "effect" effect }
}
{ $description "Calls a quotation with the declared effect. Inside the quotation " { $link fork } " can be used to recursively call the quotation." }
{ $examples {
    { $example "USING: bend kernel math prettyprint ;" "6 [ 1 - dup 0 > [ dup fork + ] when ] ( x -- x ) bend ." "15" }
} } ;

HELP: fork
{ $description "A token used inside " { $link bend } " to recursively call the target quotation." } ;


ARTICLE: "bend" "Bend"
"The " { $vocab-link "bend" } " vocabulary is an experimental Factor port of some interesting features found in the bend language (" { $url "https://github.com/HigherOrderCO/bend" } ")."
$nl
"The " { $link bend } " word can help create recursive datastructures, while " { $link fold } " consumes them in a convenient way."
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
"    0 [ swap"
"        [ <leaf> ]"
"        [ 1 - swap 2 * [ fork ] [ 1 + fork ] 2bi <branch> ]"
"        if-zero"
"    ] bend( depth val -- tree ) ;"
""
""
": sum-tree ( tree -- sum )"
"    {"
"        { leaf [ ] }"
"        { branch [ + ] }"
"    } fold ;" }
$nl ;

ABOUT: "bend"