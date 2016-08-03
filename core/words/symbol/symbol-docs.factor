USING: help.syntax help.markup words.symbol words compiler.units ;
IN: words.symbol

HELP: symbol
{ $class-description "The class of symbols created by " { $link POSTPONE: SYMBOL: } "." } ;

HELP: define-symbol
{ $values { "word" word } }
{ $description "Defines the word to push itself on the stack when executed. This is the run time equivalent of " { $link POSTPONE: SYMBOL: } "." }
{ $notes "This word must be called from inside " { $link with-compilation-unit } "." }
{ $side-effects "word" } ;

ARTICLE: "words.symbol" "Symbols"
"A symbol pushes itself on the stack when executed. By convention, symbols are used as variable names (" { $link "namespaces" } ")."
{ $subsections
    symbol
    symbol?
}
"Defining symbols at parse time:"
{ $subsections
    POSTPONE: SYMBOL:
    POSTPONE: SYMBOLS:
}
"Defining symbols at run time:"
{ $subsections define-symbol }
"Symbols are just compound definitions in disguise. The following two lines are equivalent:"
{ $code
    "SYMBOL: foo"
    ": foo ( -- value ) \\ foo ;"
} ;

ABOUT: "words.symbol"
