USING: help.markup help.syntax kernel sequences words
math strings vectors quotations generic effects classes
vocabs.loader definitions io vocabs source-files
quotations namespaces compiler.units assocs lexer
words.symbol words.alias words.constant vocabs.parser ;
IN: parser

ARTICLE: "reading-ahead" "Reading ahead"
"Parsing words can consume input:"
{ $subsection scan }
{ $subsection scan-word }
"For example, the " { $link POSTPONE: HEX: } " word uses this feature to read hexadecimal literals:"
{ $see POSTPONE: HEX: }
"It is defined in terms of a lower-level word that takes the numerical base on the data stack, but reads the number from the parser and then adds it to the parse tree:"
{ $see parse-base }
"Another simple example is the " { $link POSTPONE: \ } " word:"
{ $see POSTPONE: \ } ;

ARTICLE: "parsing-word-nest" "Nested structure"
"Recall that the parser loop calls parsing words with an accumulator vector on the stack. The parser loop can be invoked recursively with a new, empty accumulator; the result can then be added to the original accumulator. This is how parsing words for object literals are implemented; object literals can nest arbitrarily deep."
$nl
"A simple example is the parsing word that reads a quotation:"
{ $see POSTPONE: [ }
"This word uses a utility word which recursively invokes the parser, reading objects into a new accumulator until an occurrence of " { $link POSTPONE: ] } ":"
{ $subsection parse-literal }
"There is another, lower-level word for reading nested structure, which is also useful when called directly:"
{ $subsection parse-until }
"Words such as " { $link POSTPONE: ] } " use a declaration which causes them to throw an error when an unpaired occurrence is encountered:"
{ $subsection POSTPONE: delimiter }
{ $see-also POSTPONE: { POSTPONE: H{ POSTPONE: V{ POSTPONE: W{ POSTPONE: T{ POSTPONE: } } ;

ARTICLE: "defining-words" "Defining words"
"Defining words add definitions to the dictionary without modifying the parse tree. The simplest example is the " { $link POSTPONE: SYMBOL: } " word."
{ $see POSTPONE: SYMBOL: }
"The key factor in the definition of " { $link POSTPONE: SYMBOL: } " is " { $link CREATE } ", which reads a token from the input and creates a word with that name. This word is then passed to " { $link define-symbol } "."
{ $subsection CREATE }
{ $subsection CREATE-WORD }
"Colon definitions are defined in a more elaborate way:"
{ $subsection POSTPONE: : }
"The " { $link POSTPONE: : } " word first calls " { $link CREATE } ", and then reads input until reaching " { $link POSTPONE: ; } " using a utility word:"
{ $subsection parse-definition }
"The " { $link POSTPONE: ; } " word is just a delimiter; an unpaired occurrence throws a parse error:"
{ $see POSTPONE: ; }
"There are additional parsing words whose syntax is delimited by " { $link POSTPONE: ; } ", and they are all implemented by calling " { $link parse-definition } "." ;

ARTICLE: "parsing-tokens" "Parsing raw tokens"
"So far we have seen how to read individual tokens, or read a sequence of parsed objects until a delimiter. It is also possible to read raw tokens from the input and perform custom processing."
$nl
"One example is the " { $link POSTPONE: USING: } " parsing word."
{ $see POSTPONE: USING: } 
"It reads a list of vocabularies terminated by " { $link POSTPONE: ; } ". However, the vocabulary names do not name words, except by coincidence; so " { $link parse-until } " cannot be used here. Instead, a lower-level word is called:"
{ $subsection parse-tokens } ;

ARTICLE: "parsing-words" "Parsing words"
"The Factor parser follows a simple recursive-descent design. The parser reads successive tokens from the input; if the token identifies a number or an ordinary word, it is added to an accumulator vector. Otherwise if the token identifies a parsing word, the parsing word is executed immediately."
$nl
"Parsing words are defined using the a defining word:"
{ $subsection POSTPONE: SYNTAX: }
"Parsing words have uppercase names by convention. Here is the simplest possible parsing word; it prints a greeting at parse time:"
{ $code "SYNTAX: HELLO \"Hello world\" print ;" }
"Parsing words must not pop or push items from the stack; however, they are permitted to access the accumulator vector supplied by the parser at the top of the stack. That is, parsing words must have stack effect " { $snippet "( accum -- accum )" } ", where " { $snippet "accum" } " is the accumulator vector supplied by the parser."
$nl
"Parsing words can read input, add word definitions to the dictionary, and do anything an ordinary word can."
$nl
"Because of the stack restriction, parsing words cannot pass data to other words by leaving values on the stack; instead, use " { $link parsed } " to add the data to the parse tree so that it can be evaluated later."
$nl
"Parsing words cannot be called from the same source file where they are defined, because new definitions are only compiled at the end of the source file. An attempt to use a parsing word in its own source file raises an error:"
{ $subsection staging-violation }
"Tools for implementing parsing words:"
{ $subsection "reading-ahead" }
{ $subsection "parsing-word-nest" }
{ $subsection "defining-words" }
{ $subsection "parsing-tokens" } ;

ARTICLE: "parser-files" "Parsing source files"
"The parser can run source files:"
{ $subsection run-file }
{ $subsection parse-file }
"The parser cross-references source files and definitions. This allows it to keep track of removed definitions, and prevent forward references and accidental redefinitions."
$nl
"While the above words are useful for one-off experiments, real programs should be written to use the vocabulary system instead; see " { $link "vocabs.loader" } "."
{ $see-also "source-files" } ;

ARTICLE: "top-level-forms" "Top level forms"
"Any code outside of a definition is known as a " { $emphasis "top-level form" } "; top-level forms are run after the entire source file has been parsed, regardless of their position in the file."
$nl
"Top-level forms do not have access to the " { $link in } " and " { $link use } " variables that were set at parse time, nor do they run inside " { $link with-compilation-unit } "; so meta-programming might require extra work in a top-level form compared with a parsing word."
$nl
"Also, top-level forms run in a new dynamic scope, so using " { $link set } " to store values is almost always wrong, since the values will be lost after the top-level form completes. To save values computed by a top-level form, either use " { $link set-global } " or define a new word with the value." ;

ARTICLE: "parser" "The parser"
"This parser is a general facility for reading textual representations of objects and definitions. The parser is implemented in the " { $vocab-link "parser" } " and " { $vocab-link "syntax" } " vocabularies."
$nl
"This section concerns itself with usage and extension of the parser. Standard syntax is described in " { $link "syntax" } "."
{ $subsection "parser-files" }
"The parser can be extended."
{ $subsection "parser-lexer" }
"The parser can be invoked reflectively;"
{ $subsection parse-stream }
{ $see-also "parsing-words" "definitions" "definition-checking" } ;

ABOUT: "parser"

HELP: location
{ $values { "loc" "a " { $snippet "{ path line# }" } " pair" } }
{ $description "Outputs the current parser location. This value can be passed to " { $link set-where } " or " { $link remember-definition } "." } ;

HELP: save-location
{ $values { "definition" "a definition specifier" } }
{ $description "Saves the location of a definition and associates this definition with the current source file." } ;

HELP: parser-notes
{ $var-description "A boolean controlling whether the parser will print various notes. Switched on by default. If a source file is being run for its effect on " { $link output-stream } ", this variable should be switched off, to prevent parser notes from polluting the output." } ;

HELP: parser-notes?
{ $values { "?" "a boolean" } }
{ $description "Tests if the parser will print various notes and warnings. To disable parser notes, either set " { $link parser-notes } " to " { $link f } ", or pass the " { $snippet "-quiet" } " command line switch." } ;

HELP: bad-number
{ $error-description "Indicates the parser encountered an invalid numeric literal." } ;

HELP: use
{ $var-description "A variable holding the current vocabulary search path as a sequence of assocs." } ;

{ use in use+ (use+) set-use set-in POSTPONE: USING: POSTPONE: USE: with-file-vocabs with-interactive-vocabs } related-words

HELP: in
{ $var-description "A variable holding the name of the current vocabulary for new definitions." } ;

HELP: current-vocab
{ $values { "str" "a vocabulary" } }
{ $description "Returns the vocabulary stored in the " { $link in } " symbol. Throws an error if the current vocabulary is " { $link f } "." } ;

HELP: (use+)
{ $values { "vocab" "an assoc mapping strings to words" } }
{ $description "Adds an assoc at the front of the search path." }
$parsing-note ;

HELP: use+
{ $values { "vocab" string } }
{ $description "Adds a new vocabulary at the front of the search path after loading it if necessary. Subsequent word lookups by the parser will search this vocabulary first." }
$parsing-note
{ $errors "Throws an error if the vocabulary does not exist." } ;

HELP: set-use
{ $values { "seq" "a sequence of strings" } }
{ $description "Sets the vocabulary search path. Later vocabularies take precedence." }
{ $errors "Throws an error if one of the vocabularies does not exist." }
$parsing-note ;

HELP: add-use
{ $values { "seq" "a sequence of strings" } }
{ $description "Adds multiple vocabularies to the search path, with later vocabularies taking precedence." }
{ $errors "Throws an error if one of the vocabularies does not exist." }
$parsing-note ;

HELP: set-in
{ $values { "name" string } }
{ $description "Sets the current vocabulary where new words will be defined, creating the vocabulary first if it does not exist." }
$parsing-note ;

HELP: create-in
{ $values { "str" "a word name" } { "word" "a new word" } }
{ $description "Creates a word in the current vocabulary. Until re-defined, the word throws an error when invoked." }
$parsing-note ;

HELP: CREATE
{ $values { "word" word } }
{ $description "Reads the next token from the line currently being parsed, and creates a word with that name in the current vocabulary." }
{ $errors "Throws an error if the end of the line is reached." }
$parsing-note ;

HELP: no-word-error
{ $error-description "Thrown if the parser encounters a token which does not name a word in the current vocabulary search path. If any words with this name exist in vocabularies not part of the search path, a number of restarts will offer to add those vocabularies to the search path and use the chosen word." }
{ $notes "Apart from a missing " { $link POSTPONE: USE: } ", this error can also indicate an ordering issue. In Factor, words must be defined before they can be called. Mutual recursion can be implemented via " { $link POSTPONE: DEFER: } "." } ;

HELP: no-word
{ $values { "name" string } { "newword" word } }
{ $description "Throws a " { $link no-word-error } "." } ;

HELP: search
{ $values { "str" string } { "word/f" "a word or " { $link f } } }
{ $description "Searches for a word by name in the current vocabulary search path. If no such word could be found, outputs " { $link f } "." }
$parsing-note ;

HELP: scan-word
{ $values { "word/number/f" "a word, number or " { $link f } } }
{ $description "Reads the next token from parser input. If the token is a valid number literal, it is converted to a number, otherwise the dictionary is searched for a word named by the token. Outputs " { $link f } " if the end of the input has been reached." }
{ $errors "Throws an error if the token does not name a word, and does not parse as a number." }
$parsing-note ;

HELP: parse-step
{ $values { "accum" vector } { "end" word } { "?" "a boolean" } }
{ $description "Parses a token. If the token is a number or an ordinary word, it is added to the accumulator. If it is a parsing word, calls the parsing word with the accumulator on the stack. Outputs " { $link f } " if " { $snippet "end" } " is encountered, " { $link t } " otherwise." }
$parsing-note ;

HELP: (parse-until)
{ $values { "accum" vector } { "end" word } }
{ $description "Parses objects from parser input until " { $snippet "end" } " is encountered, adding them to the accumulator." }
$parsing-note ;

HELP: parse-until
{ $values { "end" word } { "vec" "a new vector" } }
{ $description "Parses objects from parser input until " { $snippet "end" } ". Outputs a new vector with the results." }
{ $examples "This word is used to implement " { $link POSTPONE: ARTICLE: } "." }
$parsing-note ;

{ parse-tokens (parse-until) parse-until } related-words

HELP: parsed
{ $values { "accum" vector } { "obj" object } }
{ $description "Convenience word for parsing words. It behaves exactly the same as " { $link push } ", except the accumulator remains on the stack." }
$parsing-note ;

HELP: (parse-lines)
{ $values { "lexer" lexer } { "quot" "a new " { $link quotation } } }
{ $description "Parses Factor source code using a custom lexer. The vocabulary search path is taken from the current scope." }
{ $errors "Throws a " { $link lexer-error } " if the input is malformed." } ;

HELP: parse-lines
{ $values { "lines" "a sequence of strings" } { "quot" "a new " { $link quotation } } }
{ $description "Parses Factor source code which has been tokenized into lines. The vocabulary search path is taken from the current scope." }
{ $errors "Throws a " { $link lexer-error } " if the input is malformed." } ;

HELP: parse-base
{ $values { "base" "an integer between 2 and 36" } { "parsed" integer } }
{ $description "Reads an integer in a specific numerical base from the parser input." }
$parsing-note ;

HELP: parse-literal
{ $values { "accum" vector } { "end" word } { "quot" { $quotation "( seq -- obj )" } } }
{ $description "Parses objects from parser input until " { $snippet "end" } ", applies the quotation to the resulting sequence, and adds the output value to the accumulator." }
{ $examples "This word is used to implement " { $link POSTPONE: [ } "." }
$parsing-note ;

HELP: parse-definition
{ $values { "quot" "a new " { $link quotation } } }
{ $description "Parses objects from parser input until " { $link POSTPONE: ; } " and outputs a quotation with the results." }
{ $examples "This word is used to implement " { $link POSTPONE: : } "." }
$parsing-note ;

HELP: bootstrap-syntax
{ $var-description "Only set during bootstrap. Stores a copy of the " { $link vocab-words } " of the host's syntax vocabulary; this allows the host's parsing words to be used during bootstrap source parsing, not the target's." } ;

HELP: with-file-vocabs
{ $values { "quot" quotation } }
{ $description "Calls the quotation in a scope with the initial the vocabulary search path for parsing a file. This consists of just the " { $snippet "syntax" } " vocabulary." } ;

HELP: parse-fresh
{ $values { "lines" "a sequence of strings" } { "quot" quotation } }
{ $description "Parses Factor source code in a sequence of lines. The initial vocabulary search path is used (see " { $link with-file-vocabs } ")." }
{ $errors "Throws a parse error if the input is malformed." } ;

HELP: filter-moved
{ $values { "assoc1" assoc } { "assoc2" assoc } { "seq" "an seqence of definitions" } }
{ $description "Removes all definitions from " { $snippet "assoc2" } " which are in " { $snippet "assoc1" } " or are are no longer present in the current " { $link file } "." } ;

HELP: forget-smudged
{ $description "Forgets removed definitions and prints a warning message if any of them are still referenced from other source files." } ;

HELP: finish-parsing
{ $values { "lines" "the lines of text just parsed" } { "quot" "the quotation just parsed" } }
{ $description "Records information to the current " { $link file } "." }
{ $notes "This is one of the factors of " { $link parse-stream } "." } ;

HELP: parse-stream
{ $values { "stream" "an input stream" } { "name" "a file name for error reporting and cross-referencing" } { "quot" quotation } }
{ $description "Parses Factor source code read from the stream. The initial vocabulary search path is used." }
{ $errors "Throws an I/O error if there was an error reading from the stream. Throws a parse error if the input is malformed." } ;

HELP: parse-file
{ $values { "file" "a pathname string" } { "quot" quotation } }
{ $description "Parses the Factor source code stored in a file. The initial vocabulary search path is used." }
{ $errors "Throws an I/O error if there was an error reading from the file. Throws a parse error if the input is malformed." } ;

HELP: run-file
{ $values { "file" "a pathname string" } }
{ $description "Parses the Factor source code stored in a file and runs it. The initial vocabulary search path is used." }
{ $errors "Throws an error if loading the file fails, there input is malformed, or if a runtime error occurs while calling the parsed quotation." }  ;

HELP: ?run-file
{ $values { "path" "a pathname string" } }
{ $description "If the file exists, runs it with " { $link run-file } ", otherwise does nothing." } ;

HELP: staging-violation
{ $values { "word" word } }
{ $description "Throws a " { $link staging-violation } " error." }
{ $error-description "Thrown by the parser if a parsing word is used in the same compilation unit as where it was defined; see " { $link "compilation-units" } "." }
{ $notes "One possible workaround is to use the " { $link POSTPONE: << } " word to execute code at parse time. However, executing words defined in the same source file at parse time is still prohibited." } ;

HELP: auto-use?
{ $var-description "If set to a true value, the behavior of the parser when encountering an unknown word name is changed. If only one loaded vocabulary has a word with this name, instead of throwing an error, the parser adds the vocabulary to the search path and prints a parse note. Off by default." }
{ $notes "This feature is intended to help during development. To generate a " { $link POSTPONE: USING: } " form automatically, enable " { $link auto-use? } ", load the source file, and copy and paste the " { $link POSTPONE: USING: } " form printed by the parser back into the file, then disable " { $link auto-use? } ". See " { $link "vocabulary-search-errors" } "." } ;
