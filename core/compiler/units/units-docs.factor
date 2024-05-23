USING: classes.tuple.private compiler.units.private definitions
help.markup help.syntax kernel kernel.private parser quotations
sequences source-files stack-checker.errors words ;
IN: compiler.units

ARTICLE: "compilation-units-internals" "Compilation units internals"
"These words do not need to be called directly, and only serve to support the implementation."
$nl
"Compiling a set of words:"
{ $subsections compile }
"Words called to associate a definition with a compilation unit and a source file location:"
{ $subsections
    remember-definition
    remember-class
}
"Forward reference checking (see " { $link "definition-checking" } "):"
{ $subsections forward-reference? }
"A hook to be called at the end of the compilation unit. If the optimizing compiler is loaded, this compiles new words with the " { $link "compiler" } ":"
{ $subsections recompile }
"Low-level compiler interface exported by the Factor VM:"
{ $subsections modify-code-heap }
"Variables maintaining state within a compilation unit."
{ $subsections
  changed-definitions
  maybe-changed
  outdated-generics
  outdated-tuples
} ;

ARTICLE: "compilation-units" "Compilation units"
"A " { $emphasis "compilation unit" } " scopes a group of related definitions. They are compiled and entered into the system in one atomic operation."
$nl
"When a source file is being parsed, all definitions are part of a single compilation unit, unless the " { $link POSTPONE: << } " parsing word is used to create nested compilation units."
$nl
"Words defined in a compilation unit may not be called until the compilation unit is finished. The parser detects this case for parsing words and throws a " { $link staging-violation } ". Similarly, an attempt to use a macro from a word defined in the same compilation unit will throw a " { $link transform-expansion-error } ". Calling any other word from within its own compilation unit throws an " { $link undefined } " error."
$nl
"This means that parsing words and macros generally cannot be used in the same source file as they are defined. There are two means of getting around this:"
{ $list
    { "The simplest way is to split off the parsing words and macros into sub-vocabularies; perhaps suffixed by " { $snippet ".syntax" } " and " { $snippet ".macros" } "." }
    { "Alternatively, nested compilation units can be created using " { $link "syntax-immediate" } "." }
}
"Parsing words which create new definitions at parse time will implicitly add them to the compilation unit of the current source file."
$nl
"Code which creates new definitions at run time will need to explicitly create a compilation unit with a combinator. There is an additional combinator used by the parser to implement " { $link "syntax-immediate" } "."
{ $subsections with-compilation-unit with-nested-compilation-unit }
"Additional topics:"
{ $subsections "compilation-units-internals" } ;

ABOUT: "compilation-units"

HELP: bump-effect-counter?
{ $values { "?" boolean } }
{ $description "Whether the " { $link REDEFINITION-COUNTER } " should be increased." } ;

HELP: new-definitions
{ $var-description "Stores a pair of sets where the members form the set of definitions which were defined so far by the current parsing of " { $link current-source-file } "." } ;

HELP: forgotten-definitions
{ $var-description "All definitions (words and vocabs) that have been forgotten in the current compilation unit." } ;

HELP: old-definitions
{ $var-description "Stores a pair of sets where the members form the set of definitions which were defined by " { $link current-source-file } " the most recent time it was loaded." } ;

HELP: redefine-error
{ $values { "definition" "a definition specifier" } }
{ $description "Throws a " { $link redefine-error } "." }
{ $error-description "Indicates that a single source file contains two definitions for the same artifact, one of which shadows the other. This is an error since it indicates a likely mistake, such as two words accidentally named the same by the developer; the error is restartable." } ;

HELP: remember-definition
{ $values { "definition" "a definition specifier" } { "loc" "a " { $snippet "{ path line# }" } " pair" } }
{ $description "Saves the location of a definition and associates this definition with the current source file." } ;

HELP: with-compilation-unit
{ $values { "quot" quotation } }
{ $description "Calls a quotation in a new compilation unit. The quotation can define new words and classes, as well as forget words. When the quotation returns, any changed words are recompiled, and changes are applied atomically." }
{ $notes "Calls to " { $link with-compilation-unit } " may be nested."
$nl
"The parser wraps every source file in a compilation unit, so parsing words may define new words without having to perform extra work; to define new words at any other time, you must wrap your defining code with this combinator."
$nl
"Since compilation is relatively expensive, you should try to batch up as many definitions into one compilation unit as possible." } ;

HELP: with-nested-compilation-unit
{ $values { "quot" quotation } }
{ $description "Calls a quotation in a new compilation unit. The only difference between this word and " { $link with-compilation-unit } " is that variables used by the parser to associate definitions with source files are not rebound." }
{ $notes "This word is used by " { $link "syntax-immediate" } " to ensure that definitions in nested blocks are correctly recorded. User code should not depend on parser internals in such a way that calling this combinator is required." } ;

HELP: recompile
{ $values { "words" { $sequence word } } { "alist" "an association list mapping words to compiled definitions" } }
{ $contract "Internal word which compiles words. Called at the end of " { $link with-compilation-unit } "." } ;

HELP: to-recompile
{ $values { "words" sequence } }
{ $description "Sequence of words that will be recompiled by the compilation unit. The non-optimizing compiler only recompiles words whose definitions has changed. But the optimizing compiler, which can perform optimizations such as inlining, recompiles words that depends on the changed words." } ;

HELP: no-compilation-unit
{ $values { "word" word } }
{ $description "Throws a " { $link no-compilation-unit } " error." }
{ $error-description "Thrown when an attempt is made to define a word outside of a " { $link with-compilation-unit } " combinator." } ;

HELP: modify-code-heap
{ $values { "alist" "an association list with words as keys" } { "update-existing?" boolean } { "reset-pics?" boolean } }
{ $description "Lowest-level primitive for defining words. Associates words with code blocks in the code heap."
$nl
"The alist maps words to one of the following:"
{ $list
    { "a quotation - in this case, the quotation is compiled with the non-optimizing compiler and the word will call the quotation when executed." }
    { "a 6-element array " { $snippet "{ parameters literals relocation labels code stack-frame-size }" } " - in this case, a code heap block is allocated with the given data and the word will call the code block when executed. This is used by the optimizing compiler." }
}
"If any of the redefined words may already be referenced by other words in the code heap, from outside of the compilation unit, then a scan of the code heap must be performed to update all word call sites. Passing " { $link t } " as the " { $snippet "update-existing?" } " parameter enables this code path."
$nl
"If classes, methods or generic words were redefined, then inline cache call sites need to be updated as well. Passing " { $link t } " as the " { $snippet "reset-pics?" } " parameter enables this code path."
}
{ $examples
  "Manually creating a word using the non-optimizing compiler:"
  { $example
    "USING: compiler.units io ;"
    "IN: scratchpad"
    ": foo ( -- ) ;"
    "{ { foo [ \"hello!\" print ] } } t t modify-code-heap foo"
    "hello!"
  }
}
{ $notes "This word is called at the end of " { $link with-compilation-unit } "." } ;

HELP: compile
{ $values { "words" { $sequence word } } }
{ $description "Compiles a set of words." } ;
