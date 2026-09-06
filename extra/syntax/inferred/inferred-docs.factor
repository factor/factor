USING: help.markup help.syntax ;
IN: syntax.inferred

HELP: ?:
{ $syntax "?: name definition... ;" }
{ $description "Defines a word whose stack effect is inferred from its body. The body must have a statically inferable effect. Use an explicit declaration for recursive definitions or combinators with unknown quotation inputs." }
{ $examples
    { $example "USING: math prettyprint syntax.inferred ;"
        "IN: scratchpad"
        "?: add1 1 + ;"
        "4 add1 ." "5" }
}
{ $notes "Inference takes place before the new definition is installed. The word otherwise behaves like an ordinary definition, including dependency tracking and subsequent redefinition." } ;

ARTICLE: "syntax.inferred" "Inferred definitions"
"The " { $vocab-link "syntax.inferred" } " vocabulary provides an optional definition syntax which computes the stack effect from the body:"
{ $subsections POSTPONE: ?: } ;

ABOUT: "syntax.inferred"
