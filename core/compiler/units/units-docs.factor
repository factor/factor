USING: help.markup help.syntax words math source-files
parser quotations definitions ;
IN: compiler.units

ARTICLE: "compilation-units" "Compilation units"
"A " { $emphasis "compilation unit" } " scopes a group of related definitions. They are compiled and entered into the system in one atomic operation."
$nl
"Words defined in a compilation unit may not be called until the compilation unit is finished. The parser detects this case for parsing words and throws a " { $link staging-violation } "; calling any other word from within its own compilation unit throws an " { $link undefined } " error."
$nl
"The parser groups all definitions in a source file into one compilation unit, and parsing words do not need to concern themselves with compilation units. However, if definitions are being created at run time, a compilation unit must be created explicitly:"
{ $subsection with-compilation-unit }
"Compiling a set of words:"
{ $subsection compile }
"Words called to associate a definition with a compilation unit and a source file location:"
{ $subsection remember-definition }
{ $subsection remember-class }
"Forward reference checking (see " { $link "definition-checking" } "):"
{ $subsection forward-reference? }
"A hook to be called at the end of the compilation unit. If the optimizing compiler is loaded, this compiles new words with the " { $link "compiler" } ":"
{ $subsection recompile }
"Low-level compiler interface exported by the Factor VM:"
{ $subsection modify-code-heap } ;

ABOUT: "compilation-units"

HELP: redefine-error
{ $values { "definition" "a definition specifier" } }
{ $description "Throws a " { $link redefine-error } "." }
{ $error-description "Indicates that a single source file contains two definitions for the same artifact, one of which shadows the other. This is an error since it indicates a likely mistake, such as two words accidentally named the same by the developer; the error is restartable." } ;

HELP: remember-definition
{ $values { "definition" "a definition specifier" } { "loc" "a " { $snippet "{ path line# }" } " pair" } }
{ $description "Saves the location of a definition and associates this definition with the current source file." } ;

HELP: old-definitions
{ $var-description "Stores an assoc where the keys form the set of definitions which were defined by " { $link file } " the most recent time it was loaded." } ;

HELP: new-definitions
{ $var-description "Stores an assoc where the keys form the set of definitions which were defined so far by the current parsing of " { $link file } "." } ;

HELP: with-compilation-unit
{ $values { "quot" quotation } }
{ $description "Calls a quotation in a new compilation unit. The quotation can define new words and classes, as well as forget words. When the quotation returns, any changed words are recompiled, and changes are applied atomically." }
{ $notes "Compilation units may be nested."
$nl
"The parser wraps every source file in a compilation unit, so parsing words may define new words without having to perform extra work; to define new words at any other time, you must wrap your defining code with this combinator."
$nl
"Since compilation is relatively expensive, you should try to batch up as many definitions into one compilation unit as possible." } ;

HELP: recompile
{ $values { "words" "a sequence of words" } { "alist" "an association list mapping words to compiled definitions" } }
{ $contract "Internal word which compiles words. Called at the end of " { $link with-compilation-unit } "." } ;

HELP: no-compilation-unit
{ $values { "word" word } }
{ $description "Throws a " { $link no-compilation-unit } " error." }
{ $error-description "Thrown when an attempt is made to define a word outside of a " { $link with-compilation-unit } " combinator." } ;

HELP: modify-code-heap ( alist -- )
{ $values { "alist" "an alist" } }
{ $description "Stores compiled code definitions in the code heap. The alist maps words to the following:"
{ $list
    { "a quotation - in this case, the quotation is compiled with the non-optimizing compiler and the word will call the quotation when executed." }
    { { $snippet "{ code labels rel words literals }" } " - in this case, a code heap block is allocated with the given data and the word will call the code block when executed." }
} }
{ $notes "This word is called at the end of " { $link with-compilation-unit } "." } ;

HELP: compile
{ $values { "words" "a sequence of words" } }
{ $description "Compiles a set of words." } ;
