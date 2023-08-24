! Copyright (C) 2018 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays help.markup help.syntax kernel ;
IN: boolean-expr

ABOUT: "boolean-expr"

ARTICLE: "boolean-expr" "Boolean expressions"
"The " { $vocab-link "boolean-expr" } " vocab demonstrates the use of Unicode symbols in source files and multi-method dispatch."
;

HELP: dnf
{ $values
    { "expr" □ }
    { "dnf" array }
}
{ $description "Convert the " { $snippet "expr" } " to Disjunctive Normal Form (DNF), i.e. an array of subexpressions, each not containing disjunctions. See " { $url "https://en.wikipedia.org/wiki/Disjunctive_normal_form" } "." }
{ $examples
    { $example "USING: boolean-expr prettyprint ;"
        "X Y Z ⋀ ⋀ dnf ."
        "{ { X Y Z } }"
    }
    { $example "USING: boolean-expr prettyprint ;"
        "X Y Z ⋁ ⋁ dnf ."
        "{ { X } { Y } { Z } }"
    }
} ;

HELP: expr.
{ $values
    { "expr" □ }
}
{ $description "Print the expression followed by newline." }
{ $examples
    { $example "USING: boolean-expr ;"
        "X Y ⋁ X ¬ Y ⋀ ⋀ op."
        "((X ⋀ (¬X ⋀ Y)) ⋁ (Y ⋀ (¬X ⋀ Y)))"
    }
} ;

HELP: op.
{ $values
    { "expr" □ }
}
{ $description "Print the expression." }
{ $examples
    { $example "USING: boolean-expr ;"
        "X Y ⋁ X ¬ Y ⋀ ⋀ op."
        "((X ⋀ (¬X ⋀ Y)) ⋁ (Y ⋀ (¬X ⋀ Y)))"
    }
} ;

{ expr. op. } related-words

HELP: satisfiable?
{ $values
    { "expr" □ }
    { "?" boolean }
}
{ $description "Return " { $link t } " if the " { $snippet "expr" } " can be true." }
{ $examples
    { $example "USING: boolean-expr prettyprint ;"
        "⊤ satisfiable? ."
        "t"
    }
    { $example "USING: boolean-expr prettyprint ;"
        "⊥ satisfiable? ."
        "f"
    }
    { $example "USING: boolean-expr prettyprint ;"
        "X X ¬ ⋀ satisfiable? ."
        "f"
    }
    { $example "USING: boolean-expr prettyprint ;"
        "X Y ⋁ X ¬ Y ¬ ⋀ ⋀ satisfiable? ."
        "f"
    }
    { $example "USING: boolean-expr prettyprint ;"
        "X Y ⋁ X ¬ Y ⋀ ⋀ satisfiable? ."
        "t"
    }
} ;

HELP: ¬
{ $class-description "Logical negation (NOT)." $nl
    { $snippet "¬(¬A) " { $link ≣ } " A" } "."
} ;

HELP: →
{ $values
    { "x" □ } { "y" □ }
    { "expr" □ }
}
{ $description "Material implication (if..then)." $nl
    { $snippet "x→y" } " " { $link ≣ } " " { $link ¬ } "x" { $link ⋁ } "y"
} ;

HELP: ≣
{ $values
    { "x" □ } { "y" □ }
    { "expr" □ }
}
{ $description "Material equivalence (if and only if)." $nl
    { $snippet "(x≣y) ≣ ((x" } { $link ⋀ } { $snippet "y) " }
    { $link ⋁ } { $snippet " (" } { $link ¬ } { $snippet "x" } { $link ⋀ } { $link ¬ } { $snippet "y))" }
} ;

HELP: ⊕
{ $values
    { "x" □ } { "y" □ }
    { "expr" □ }
}
{ $description "Exclusive disjunction (XOR)." } ;

HELP: ⊤
{ $class-description "Logical tautology. This statement is unconditionally true." } ;

HELP: ⊥
{ $class-description "Logical contradiction. This statement is unconditionally false." } ;

HELP: ⋀
{ $class-description "Logical conjunction (AND)." } ;

HELP: ⋁
{ $class-description "Logical disjunction (OR)." } ;

HELP: □
{ $class-description "A union class of all classes defined in this vocab. In methods signatures it stands for \"any variable or expression\"." } ;
