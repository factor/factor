USING: arrays compiler.units definitions help.markup help.syntax
kernel lexer math namespaces quotations sequences source-files
strings vectors vocabs vocabs.parser words words.symbol ;
IN: parser

ARTICLE: "reading-ahead" "Reading ahead"
"Parsing words can consume input from the input stream. Words come in two flavors: words that throw upon finding end of file, and words that return " { $link f } " upon the same." $nl
"Parsing words that throw on end of file:"
{ $subsections
    scan-token
    scan-word-name
    scan-word
    scan-datum
    scan-number
    scan-object
}
"Parsing words that return " { $link f } " on end of file:"
{ $subsections
    ?scan-token
    ?scan-datum
}
"A simple example is the " { $link POSTPONE: \ } " word:"
{ $see POSTPONE: \ } ;

ARTICLE: "parsing-word-nest" "Nested structure"
"Recall that the parser loop calls parsing words with an accumulator vector on the stack. The parser loop can be invoked recursively with a new, empty accumulator; the result can then be added to the original accumulator. This is how parsing words for object literals are implemented; object literals can nest arbitrarily deep."
$nl
"A simple example is the parsing word that reads a quotation:"
{ $see POSTPONE: [ }
"This word uses a utility word which recursively invokes the parser, reading objects into a new accumulator until an occurrence of " { $link POSTPONE: ] } ":"
{ $subsections parse-literal }
"There is another, lower-level word for reading nested structure, which is also useful when called directly:"
{ $subsections parse-until }
"Words such as " { $link POSTPONE: ] } " use a declaration which causes them to throw an error when an unpaired occurrence is encountered:"
{ $subsections POSTPONE: delimiter }
{ $see-also POSTPONE: { POSTPONE: H{ POSTPONE: V{ POSTPONE: W{ POSTPONE: T{ POSTPONE: } } ;

ARTICLE: "defining-words" "Defining words"
"Defining words add definitions to the dictionary without modifying the parse tree. The simplest example is the " { $link POSTPONE: SYMBOL: } " word."
{ $see POSTPONE: SYMBOL: }
"The key factor in the definition of " { $link POSTPONE: SYMBOL: } " is " { $link scan-new } ", which reads a token from the input and creates a word with that name. This word is then passed to " { $link define-symbol } "."
{ $subsections
    scan-new
    scan-new-word
}
"Colon definitions are defined in a more elaborate way:"
{ $subsections POSTPONE: : }
"The " { $link POSTPONE: : } " word first calls " { $link scan-new } ", and then reads input until reaching " { $link POSTPONE: ; } " using a utility word:"
{ $subsections parse-definition }
"The " { $link POSTPONE: ; } " word is just a delimiter; an unpaired occurrence throws a parse error:"
{ $see POSTPONE: ; }
"There are additional parsing words whose syntax is delimited by " { $link POSTPONE: ; } ", and they are all implemented by calling " { $link parse-definition } " or " { $link parse-array-def } "." ;

ARTICLE: "parsing-tokens" "Parsing raw tokens"
"So far we have seen how to read individual tokens, or read a sequence of parsed objects until a delimiter. It is also possible to read raw tokens from the input and perform custom processing."
$nl
"One example is the " { $link POSTPONE: USING: } " parsing word."
{ $see POSTPONE: USING: }
"It reads a list of vocabularies terminated by " { $link POSTPONE: ; } ". However, the vocabulary names do not name words, except by coincidence; so " { $link parse-until } " cannot be used here. Instead, a set of lower-level combinators can be used:"
{ $subsections
    each-token
    map-tokens
    parse-tokens
} ;

ARTICLE: "parsing-words" "Parsing words"
"The Factor parser follows a simple recursive-descent design. The parser reads successive tokens from the input; if the token identifies a number or an ordinary word, it is added to an accumulator vector. Otherwise if the token identifies a parsing word, the parsing word is executed immediately."
$nl
"Parsing words are defined using the defining word:"
{ $subsections POSTPONE: SYNTAX: }
"Parsing words have uppercase names by convention. Here is the simplest possible parsing word; it prints a greeting at parse time:"
{ $code "SYNTAX: HELLO \"Hello world\" print ;" }
"Parsing words must not pop or push items from the stack; however, they are permitted to access the accumulator vector supplied by the parser at the top of the stack. That is, parsing words must have stack effect " { $snippet "( accum -- accum )" } ", where " { $snippet "accum" } " is the accumulator vector supplied by the parser."
$nl
"Parsing words can read input, add word definitions to the dictionary, and do anything an ordinary word can."
$nl
"Because of the stack restriction, parsing words cannot pass data to other words by leaving values on the stack; instead, use " { $link suffix! } " to add the data to the parse tree so that it can be evaluated later."
$nl
"Parsing words cannot be called from the same source file where they are defined, because new definitions are only compiled at the end of the source file. An attempt to use a parsing word in its own source file raises an error:"
{ $subsections staging-violation }
"Tools for implementing parsing words:"
{ $subsections
    "reading-ahead"
    "parsing-word-nest"
    "defining-words"
    "parsing-tokens"
    "word-search-parsing"
} ;

ARTICLE: "top-level-forms" "Top level forms"
"Any code outside of a definition is known as a " { $emphasis "top-level form" } "; top-level forms are run after the entire source file has been parsed, regardless of their position in the file."
$nl
"Top-level forms cannot access the parse-time manifest (" { $link "word-search-parsing" } "), nor do they run inside " { $link with-compilation-unit } "; as a result, meta-programming might require extra work in a top-level form compared with a parsing word."
$nl
"Also, top-level forms run in a new dynamic scope, so using " { $link set } " to store values is almost always wrong, since the values will be lost after the top-level form completes. To save values computed by a top-level form, either use " { $link set-global } " or define a new word with the value." ;

ARTICLE: "parser" "The parser"
"The Factor parser reads textual representations of objects and definitions, with all syntax determined by " { $link "parsing-words" } ". The parser is implemented in the " { $vocab-link "parser" } " vocabulary, with standard syntax in the " { $vocab-link "syntax" } " vocabulary. See " { $link "syntax" } " for a description of standard syntax."
$nl
"The parser cross-references " { $link "source-files" } " and " { $link "definitions" } ". This functionality is used for improved error checking, as well as tools such as " { $link "tools.crossref" } " and " { $link "editor" } "."
$nl
"The parser can be invoked reflectively, to run strings and source files."
{ $subsections
    "eval"
    run-file
    parse-file
}
"If Factor is run from the command line with a script file supplied as an argument, the script is run using " { $link run-file } ". See " { $link "command-line" } "."
$nl
"While " { $link run-file } " can be used interactively in the listener to load user code into the session, this should only be done for quick one-off scripts, and real programs should instead rely on the automatic " { $link "vocabs.loader" } "."
{ $see-also "parsing-words" "definitions" "definition-checking" } ;

ABOUT: "parser"

HELP: location
{ $values { "loc/f" "a " { $snippet "{ path line# }" } " pair or " { $link f } } }
{ $description "Outputs the current parser location. This value can be passed to " { $link set-where } " or " { $link remember-definition } "." } ;

HELP: save-location
{ $values { "definition" "a definition specifier" } }
{ $description "Saves the location of a definition and associates this definition with the current source file." } ;

HELP: bad-number
{ $error-description "Indicates the parser encountered an invalid numeric literal." } ;

HELP: create-word-in
{ $values { "str" "a word name" } { "word" "a new word" } }
{ $description "Creates a word in the current vocabulary. Until re-defined, the word throws an error when invoked." }
$parsing-note ;

HELP: scan-new
{ $values { "word" word } }
{ $description "Reads the next token from the parser input, and creates a word with that name in the current vocabulary." }
{ $errors "Throws an error if the end of the file is reached." }
$parsing-note ;

HELP: scan-new-word
{ $values { "word" word } }
{ $description "Reads the next token from the parser input, and creates a word with that name in the current vocabulary and resets the generic word properties of that word." }
{ $errors "Throws an error if the end of the file is reached." }
$parsing-note ;

HELP: no-word-error
{ $error-description "Thrown if the parser encounters a token which does not name a word in the current vocabulary search path. If any words with this name exist in vocabularies not part of the search path, a number of restarts will offer to add those vocabularies to the search path and use the chosen word." }
{ $notes "Apart from a missing " { $link POSTPONE: USE: } ", this error can also indicate an ordering issue. In Factor, words must be defined before they can be called. Mutual recursion can be implemented via " { $link POSTPONE: DEFER: } "." } ;

HELP: no-word
{ $values { "name" string } { "newword" word } }
{ $description "Throws a " { $link no-word-error } "." } ;

HELP: parse-word
{ $values { "string" string } { "word" word } }
{ $description "The vocabulary search path is searched for all words named by the " { $snippet "string" } ". If no words matches, an error is thrown, if one word matches, and it is already loaded, that word is returned. Otherwise throws a restartable error to let the user choose which word to use." }
{ $errors "Throws a " { $link no-word-error } " if the string doesn't name a word." }
{ $notes "This word is used to implement " { $link scan-word } "." } ;

HELP: parse-datum
{ $values { "string" string } { "word/number" { $or word number } } }
{ $description "If " { $snippet "string" } " is a valid number literal, it is converted to a number, otherwise the current vocabulary search path is searched for a word named by the string." }
{ $errors "Throws an error if the token does not name a word, and does not parse as a number." }
{ $notes "This word is used to implement " { $link ?scan-datum } " and " { $link scan-datum } "." } ;

HELP: scan-word
{ $values { "word" word } }
{ $description "Reads the next token from parser input. The vocabulary search path is searched for a word named by the token." }
{ $errors "Throws an error if the token does not name a word or end of file is reached." }
$parsing-note ;

{ scan-word parse-word } related-words

HELP: scan-word-name
{ $values { "string" string } }
{ $description "Reads the next token from parser input and makes sure it does not parse as a number." }
{ $errors "Throws an error if the scanned token is a number or upon finding end of file." }
$parsing-note ;

HELP: ?scan-datum
{ $values { "word/number/f" { $maybe word number } } }
{ $description "Reads the next token from parser input. If the token is found in the vocabulary search path, returns the word named by the token. If the token does not find a word, it is next converted to a number. If this conversion fails, too, this word returns " { $link f } "." }
$parsing-note ;

HELP: scan-datum
{ $values { "word/number" { $or word number } } }
{ $description "Reads the next token from parser input. If the token is found in the vocabulary search path, returns the word named be the token. If the token is not found in the vocabulary search path, it is converted to a number. If this conversion fails, an error is thrown." }
{ $errors "Throws an error if the token is not a number or end of file is reached." }
$parsing-note ;

HELP: scan-number
{ $values { "number" number } }
{ $description "Reads the next token from parser input. If the token is a number literal, it is converted to a number. Otherwise, it throws an error." }
{ $errors "Throws an error if the token is not a number or end of file is reached." }
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

{ parse-tokens each-token map-tokens parse-until (parse-until) } related-words

HELP: (parse-lines)
{ $values { "lexer" lexer } { "quot" "a new " { $link quotation } } }
{ $description "Parses Factor source code using a custom lexer. The vocabulary search path is taken from the current scope." }
{ $errors "Throws a " { $link lexer-error } " if the input is malformed." } ;

HELP: parse-lines
{ $values { "lines" { $sequence string } } { "quot" "a new " { $link quotation } } }
{ $description "Parses Factor source code which has been tokenized into lines. The vocabulary search path is taken from the current scope." }
{ $errors "Throws a " { $link lexer-error } " if the input is malformed." } ;

HELP: parse-literal
{ $values { "accum" vector } { "end" word } { "quot" { $quotation ( seq -- obj ) } } }
{ $description "Parses objects from parser input until " { $snippet "end" } ", applies the quotation to the resulting sequence, and adds the output value to the accumulator." }
{ $examples "This word is used to implement " { $link POSTPONE: [ } "." }
$parsing-note ;

HELP: parse-definition
{ $values { "quot" "a new " { $link quotation } } }
{ $description "Parses objects from parser input until " { $link POSTPONE: ; } " and outputs a quotation with the results." }
{ $examples "This word is used to implement " { $link POSTPONE: : } "." }
$parsing-note ;

HELP: parse-array-def
{ $values { "array" "a new " { $link array } } }
{ $description "Like " { $link parse-definition } ", except the parsed sequence is output as an array." }
$parsing-note ;

HELP: bootstrap-syntax
{ $var-description "Only set during bootstrap. Stores a copy of the " { $link vocab-words-assoc } " of the host's syntax vocabulary; this allows the host's parsing words to be used during bootstrap source parsing, not the target's." } ;

HELP: with-file-vocabs
{ $values { "quot" quotation } }
{ $description "Calls the quotation in a scope with an initial vocabulary search path consisting of just the " { $snippet "syntax" } " vocabulary." } ;

HELP: parse-fresh
{ $values { "lines" { $sequence string } } { "quot" quotation } }
{ $description "Parses Factor source code in a sequence of lines. The initial vocabulary search path is used (see " { $link with-file-vocabs } ")." }
{ $errors "Throws a parse error if the input is malformed." } ;

HELP: filter-moved
{ $values { "set1" set } { "set2" set } { "seq" { $sequence "definitions" } } }
{ $description "Removes all definitions from " { $snippet "set2" } " which are in " { $snippet "set1" } " or are no longer present in the " { $link current-source-file } "." } ;

HELP: forget-smudged
{ $description "Forgets removed definitions." } ;

HELP: finish-parsing
{ $values { "lines" "the lines of text just parsed" } { "quot" "the quotation just parsed" } }
{ $description "Records information to the " { $link current-source-file } "." }
{ $notes "This is one of the factors of " { $link parse-stream } "." } ;

HELP: parse-stream
{ $values { "stream" "an input stream" } { "name" "a file name for error reporting and cross-referencing" } { "quot" quotation } }
{ $description "Parses Factor source code read from the stream. The initial vocabulary search path is used." }
{ $errors "Throws an I/O error if there was an error reading from the stream. Throws a parse error if the input is malformed." } ;

HELP: parse-file
{ $values { "path" "a pathname string" } { "quot" quotation } }
{ $description "Parses the Factor source code stored in a file. The initial vocabulary search path is used." }
{ $errors "Throws an I/O error if there was an error reading from the file. Throws a parse error if the input is malformed." } ;

HELP: run-file
{ $values { "path" "a pathname string" } }
{ $description "Parses the Factor source code stored in a file and runs it. The initial vocabulary search path is used." }
{ $errors "Throws an error if loading the file fails, there input is malformed, or if a runtime error occurs while calling the parsed quotation." } ;

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
{ $notes "This feature is intended to help during development. To generate a " { $link POSTPONE: USING: } " form automatically, enable " { $link auto-use? } ", load the source file, and copy and paste the " { $link POSTPONE: USING: } " form printed by the parser back into the file, then disable " { $link auto-use? } ". See " { $link "word-search-errors" } "." } ;

HELP: use-first-word?
{ $values { "words" sequence } { "?" boolean } }
{ $description "Checks if the first word can be used automatically without first throwing a restartable " { $link no-word-error } } ;

HELP: scan-object
{ $values { "object" object } }
{ $description "Parses a literal representation of an object." }
$parsing-note ;
