USING: help.markup help.syntax words ;
IN: tools.annotations

ARTICLE: "tools.annotations" "Word annotations"
"The word annotation feature modifies word definitions to add debugging code. You can restore the old definition by calling " { $link reset } " on the word in question."
$nl
"Printing messages when a word is called or returns:"
{ $subsections
    watch
    watch-vars
    POSTPONE: <WATCH
}
"Timing words:"
{ $subsections
    reset-word-timing
    add-timing
    word-timing.
}
"All of the above words are implemented using a single combinator which applies a quotation to a word definition to yield a new definition:"
{ $subsections annotate }
{ $warning
    "Certain internal words, such as words in the " { $vocab-link "math" } ", " { $vocab-link "sequences" } " and UI vocabularies, cannot be annotated, since the annotated code may end up recursively invoking the word in question. This may crash or hang Factor. It is safest to only define annotations on your own words."
} ;

ABOUT: "tools.annotations"

HELP: annotate
{ $values { "word" word } { "quot" { $quotation ( old-def -- new-def ) } } }
{ $description "Changes a word definition to the result of applying a quotation to the old definition." }
{ $notes "This word is used to implement " { $link watch } "." } ;

HELP: watch
{ $values { "word" word } }
{ $description "Annotates a word definition to print the data stack on entry and exit." } ;

{ watch watch-vars reset } related-words

HELP: <WATCH
{ $syntax "<WATCH ... WATCH>" }
{ $description "Allows wrapping a block of code and record stack values entering and exiting the block of code." } ;

HELP: reset
{ $values
    { "word" word } }
{ $description "Resets any annotations on a word." }
{ $notes "This word will remove a " { $link watch } "." } ;

HELP: watch-vars
{ $values
    { "word" word } { "vars" "a sequence of symbols" } }
{ $description "Annotates a word definition to print the " { $snippet "vars" } " upon entering the word. This word is useful for debugging." } ;

HELP: add-timing
{ $values { "word" word } }
{ $description "Adds timing code to a word, which records its total running time, including that of words it calls, on every invocation." }
{ $see-also "timing" "tools.profiler.sampling" } ;

HELP: reset-word-timing
{ $description "Resets the word timing table." } ;

HELP: word-timing.
{ $description "Prints the word timing table." } ;

HELP: cannot-annotate-twice
{ $error-description "Thrown when attempting to annotate a word that's already been annotated. If a word already has an annotation such as a watch or a breakpoint, you must first " { $link reset } " the word before adding another annotation." } ;
