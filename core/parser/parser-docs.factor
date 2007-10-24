USING: help.markup help.syntax kernel sequences words
math strings vectors quotations generic effects classes
vocabs.loader definitions io vocabs source-files
quotations namespaces ;
IN: parser

ARTICLE: "vocabulary-search-shadow" "Shadowing word names"
"If adding a vocabulary to the search path results in a word in another vocabulary becoming inaccessible due to the new vocabulary defining a word with the same name, a message is printed to the " { $link stdio } " stream. Except when debugging suspected name clashes, these messages can be ignored."
$nl
"Here is an example where shadowing occurs:"
{ $code
    "IN: foe"
    "USING: sequences io ;"
    ""
    ": append"
    "    \"foe::append calls sequences::append\" print  append ;"
    ""
    "IN: fee"
    ""
    ": append"
    "    \"fee::append calls fee::append\" print  append ;"
    ""
    "IN: fox"
    "USE: foe"
    ""
    ": append"
    "    \"fox::append calls foe::append\" print  append ;"
    ""
    "\"1234\" \"5678\" append print"
    ""
    "USE: fox"
    "\"1234\" \"5678\" append print"
}
"When placed in a source file and run, the above code produces the following output:"
{ $code
    "foe::append calls sequences::append"
    "12345678"
    "fee::append calls foe::append"
    "foe::append calls sequences::append"
    "12345678"
} ;

ARTICLE: "vocabulary-search-errors" "Word lookup errors"
"If the parser cannot not find a word in the current vocabulary search path, it attempts to look for the word in all loaded vocabularies. Then, one of three things happen:"
{ $list
    { "If there are no words having this name at all, an error is thrown and parsing stops." }
    { "If there is exactly one vocabulary having a word with this name, the vocabulary is automatically added to the search path. This behavior is intended for interactive use and exploratory programming only, and production code should contain full " { $link POSTPONE: USING: } " declarations." }
    { "If there is more than one vocabulary which contains a word with this name, a restartable error is thrown, with a restart for each vocabulary in question. The restarts add the vocabulary to the search path and continue parsing." }
}
"When writing a new vocabulary, one approach is to ignore " { $link POSTPONE: USING: } " declarations altogether, then to load the vocabulary and observe any parser notes and restarts and use this information to write the correct " { $link POSTPONE: USING: } " declaration." ;

ARTICLE: "vocabulary-search" "Vocabulary search"
"When the parser reads a token, it attempts to look up a word named by that token. The lookup is performed by searching each vocabulary in the search path, in order."
$nl
"For a source file the vocabulary search path starts off with two vocabularies:"
{ $code "syntax\nscratchpad" }
"The " { $vocab-link "syntax" } " vocabulary consists of a set of parsing words for reading Factor data and defining new words. The " { $vocab-link "scratchpad" } " vocabulary is the default vocabulary for new word definitions."
$nl
"At the interactive listener, the default search path contains many more vocabularies. Details on the default search path and parser invocation are found in " { $link "parser" } "."
$nl
"Three parsing words deal with the vocabulary search path:"
{ $subsection POSTPONE: USE: }
{ $subsection POSTPONE: USING: }
{ $subsection POSTPONE: IN: }
"Private words can be defined; note that this is just a convention and they can be called from other vocabularies anyway:"
{ $subsection POSTPONE: <PRIVATE }
{ $subsection POSTPONE: PRIVATE> }
{ $subsection "vocabulary-search-errors" }
{ $subsection "vocabulary-search-shadow" }
{ $see-also "words" } ;

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
"Colon definitions are defined in a more elaborate way:"
{ $subsection POSTPONE: : }
"The " { $link POSTPONE: : } " word first calls " { $link CREATE } ", and then reads input until reaching " { $link POSTPONE: ; } " using a utility word:"
{ $subsection parse-definition }
"The " { $link POSTPONE: ; } " word is just a delimiter; an unpaired occurrence throws a parse error:"
{ $see POSTPONE: ; }
"There are additional parsing words whose syntax is delimited by  " { $link POSTPONE: ; } ", and they are all implemented by calling " { $link parse-definition } "." ;

ARTICLE: "parsing-tokens" "Parsing raw tokens"
"So far we have seen how to read individual tokens, or read a sequence of parsed objects until a delimiter. It is also possible to read raw tokens from the input and perform custom processing."
$nl
"One example is the " { $link POSTPONE: USING: } " parsing word."
{ $see POSTPONE: USING: } 
"It reads a list of vocabularies terminated by " { $link POSTPONE: ; } ". However, the vocabulary names do not name words, except by coincidence; so " { $link parse-until } " cannot be used here. Instead, a lower-level word is called:"
{ $subsection parse-tokens } ;

ARTICLE: "parsing-words" "Parsing words"
"The Factor parser is follows a simple recursive-descent design. The parser reads successive tokens from the input; if the token identifies a number or an ordinary word, it is added to an accumulator vector. Otherwise if the token identifies a parsing word, the parsing word is executed immediately."
$nl
"Parsing words are marked by suffixing the definition with a " { $link POSTPONE: parsing } " declaration. Here is the simplest possible parsing word; it prints a greeting at parse time:"
{ $code ": hello \"Hello world\" print ; parsing" }
"Parsing words must have stack effect " { $snippet "( accum -- accum )" } ", where " { $snippet "accum" } " is the accumulator vector supplied by the parser. Parsing words can read input, add word definitions to the dictionary, and do anything an ordinary word can."
$nl
"Tools for implementing parsing words:"
{ $subsection "reading-ahead" }
{ $subsection "parsing-word-nest" }
{ $subsection "defining-words" }
{ $subsection "parsing-tokens" } ;

ARTICLE: "parser-lexer" "The lexer"
"Two variables that encapsulate internal parser state:"
{ $subsection file }
{ $subsection lexer }
"Creating a default lexer:"
{ $subsection <lexer> }
"A word to test of the end of input has been reached:"
{ $subsection still-parsing? }
"A word to get the text of the current line:"
{ $subsection line-text }
"A word to advance the lexer to the next line:"
{ $subsection next-line }
"Two generic words to override the lexer's token boundary detection:"
{ $subsection skip-blank }
{ $subsection skip-word }
"A utility used when parsing string literals:"
{ $subsection parse-string }
"The parser can be invoked with a custom lexer:"
{ $subsection (parse-lines) }
{ $subsection with-parser } ;

ARTICLE: "parser-files" "Parsing source files"
"The parser can run source files:"
{ $subsection run-file }
{ $subsection parse-file }
{ $subsection bootstrap-file }
"The parser cross-references source files and definitions. This allows it to keep track of removed definitions, and prevent forward references and accidental redefinitions."
$nl
"When a source file is reloaded, the parser compares the previous list of definitions with the current list; any definitions which are no longer present in the file are removed by a call to " { $link forget } ". A warning message is printed if any other definitions still depend on the removed definitions."
$nl
"The parser also catches forward references when reloading source files. This is best illustrated with an example. Suppose we load a source file " { $snippet "a.factor" } ":"
{ $code
    "USING: io sequences ;"
    "IN: a"
    ": hello \"Hello\" ;"
    ": world \"world\" ;"
    ": hello-world hello " " world 3append print ;"
}
"The definitions for " { $snippet "hello" } ", " { $snippet "world" } ", and " { $snippet "hello-world" } " are in the dictionary."
$nl
"Now, after some heavily editing and refactoring, the file looks like this:"
{ $code
    "USING: namespaces ;"
    "IN: a"
    ": hello \"Hello\" % ;"
    ": hello-world [ hello " " % world ] \"\" make ;"
    ": world \"world\" % ;"
}
"Note that the developer has made a mistake, placing the definition of " { $snippet "world" } " " { $emphasis "after" } " its usage in " { $snippet "hello-world" } "."
$nl
"If the parser did not have special checks for this case, then the modified source file would still load, because when the definition of " { $snippet "hello-world" } " on line 4 is being parsed, the " { $snippet "world" } " word is already present in the dictionary from an earlier run. The developer would then not discover this mistake until attempting to load the source file into a fresh image."
$nl
"Since this is undesirable, the parser explicitly raises an error if a source file refers to a word which is in the dictionary, but defined after it is used."
{ $subsection forward-error }
"If a source file raises a " { $link forward-error } " when loaded into a development image, then it would have raised a " { $link no-word } " error when loaded into a fresh image."
$nl
"The parser also catches duplicate definitions. If an artifact is defined twice in the same source file, the earlier definition will never be accessible, and this is almost always a mistake, perhaps due to a bad choice of word names, or a copy and paste error. The parser raises an error in this case."
{ $subsection redefine-error }
{ $see-also "source-files" } ;

ARTICLE: "parser-usage" "Reflective parser usage"
"The parser can be called on a string:"
{ $subsection eval }
{ $subsection parse }
{ $subsection parse-fresh }
"The parser can also parse from a stream:"
{ $subsection parse-stream } ;

ARTICLE: "parser" "The parser"
"This parser is a general facility for reading textual representations of objects and definitions. The parser is implemented in the " { $vocab-link "parser" } " and " { $vocab-link "syntax" } " vocabularies."
$nl
"This section concerns itself with usage and extension of the parser. Standard syntax is described in " { $link "syntax" } "."
{ $subsection "vocabulary-search" }
{ $subsection "parser-files" }
{ $subsection "parser-usage" }
"The parser can be extended."
{ $subsection "parsing-words" }
{ $subsection "parser-lexer" } ;

ABOUT: "parser"

: $parsing-note
    drop
    "This word should only be called from parsing words."
    $notes ;

HELP: lexer
{ $var-description "Stores the current " { $link lexer } " instance." }
{ $class-description "An object for tokenizing parser input. It has the following slots:"
    { $list
        { { $link lexer-text } " - the lines being parsed; an array of strings" }
        { { $link lexer-line } " - the line number being parsed; unlike most indices this is 1-based for friendlier error reporting and integration with text editors" }
        { { $link lexer-column } " - the current column position, zero-based" }
    }
"Custom lexing can be implemented by delegating a tuple to an instance of this class and implementing the " { $link skip-word } " and " { $link skip-blank } " generic words." } ;

HELP: <lexer>
{ $values { "text" "a sequence of strings" } { "lexer" lexer } }
{ $description "Creates a new lexer for tokenizing the given sequence of lines." } ;

HELP: location
{ $values { "loc" "a " { $snippet "{ path line# }" } " pair" } }
{ $description "Outputs the current parser location. This value can be passed to " { $link set-where } " or " { $link (save-location) } "." } ;

HELP: redefine-error
{ $values { "definition" "a definition specifier" } }
{ $description "Throws a " { $link redefine-error } "." }
{ $error-description "Indicates that a single source file contains two definitions for the same artifact, one of which shadows the other. This is an error since it indicates a likely mistake, such as two words accidentally named the same by the developer; the error is restartable." } ;

HELP: redefinition?
{ $values { "definition" "a definition specifier" } { "?" "a boolean" } }
{ $description "Tests if this definition is already present in the current source file." }
$parsing-note ;

HELP: (save-location)
{ $values { "definition" "a definition specifier" } { "loc" "a " { $snippet "{ path line# }" } " pair" } }
{ $description "Saves the location of a definition and associates this definition with the current source file."
$nl
"This is the book-keeping required to detect " { $link redefine-error } " and " { $link forward-error } "." } ;

HELP: save-location
{ $values { "definition" "a definition specifier" } }
{ $description "Saves the location of a definition and associates this definition with the current source file."
$nl
"This is the book-keeping required to detect " { $link redefine-error } " and " { $link forward-error } "." } ;

HELP: parser-notes
{ $var-description "A boolean controlling whether the parser will print various notes and warnings. Switched on by default. If a source file is being run for its effect on the " { $link stdio } " stream, this variable should be switched off, to prevent parser notes from polluting the output." } ;

HELP: parser-notes?
{ $values { "?" "a boolean" } }
{ $description "Tests if the parser will print various notes and warnings. To disable parser notes, either set " { $link parser-notes } " to " { $link f } ", or pass the " { $snippet "-quiet" } " command line switch." } ;

HELP: next-line
{ $values { "lexer" lexer } }
{ $description "Advances the lexer to the next input line, discarding the remainder of the current line." } ;

HELP: file
{ $var-description "Stores the " { $link source-file } " being parsed. The " { $link source-file-path } " of this object comes from the input parameter to " { $link parse-stream } "." } ;

HELP: old-definitions
{ $var-description "Stores an assoc where the keys form the set of definitions which were defined by " { $link file } " the most recent time it was loaded." } ;

HELP: new-definitions
{ $var-description "Stores an assoc where the keys form the set of definitions which were defined so far by the current parsing of " { $link file } "." } ;

HELP: parse-error
{ $error-description "Thrown when the parser encounters invalid input. A parse error wraps an underlying error and holds the file being parsed, line number, and column number." } ;

HELP: <parse-error>
{ $values { "msg" "an error" } { "error" parse-error } }
{ $description "Creates a new " { $link parse-error } ", filling in the location information from the current " { $link lexer } "." } ;

HELP: line-text
{ $values { "lexer" lexer } { "str" string } }
{ $description "Outputs the text of the line being parsed." } ;

HELP: skip
{ $values { "i" "a starting index" } { "seq" "a sequence" } { "quot" "a quotation with stack effect " { $snippet "( elt -- ? )" } } { "n" integer } }
{ $description "Variant of " { $link find* } " that outputs the length of the sequence instead of " { $link f } " if no elements satisfy the predicate." } ;

HELP: change-column
{ $values { "lexer" lexer } { "quot" "a quotation with stack effect " { $snippet "( col line -- newcol )" } } }
{ $description "Applies a quotation to the current column and line text to produce a new column, and moves the lexer position." } ;

HELP: skip-blank
{ $values { "lexer" lexer } }
{ $contract "Skips whitespace characters." }
{ $notes "Custom lexers can implement this generic word." } ;

HELP: skip-word
{ $values { "lexer" lexer } }
{ $contract
    "Skips until the end of the current token."
    $nl
    "The default implementation treats a single " { $snippet "\"" } " as a word by itself; otherwise it searches forward until a whitespace character or the end of the line."
}
{ $notes "Custom lexers can implement this generic word." } ;

HELP: still-parsing-line?
{ $values { "lexer" lexer } { "?" "a boolean" } }
{ $description "Outputs " { $link f } " if the end of the current line has been reached, " { $link t } " otherwise." } ;

HELP: parse-token
{ $values { "lexer" lexer } { "str/f" "a " { $link string } " or " { $link f } } }
{ $description "Reads the next token from the lexer. Tokens are delimited by whitespace, with the exception that " { $snippet "\"" } " is treated like a single token even when not followed by whitespace." } ;

HELP: scan
{ $values { "str/f" "a " { $link string } " or " { $link f } } }
{ $description "Reads the next token from the lexer. See " { $link parse-token } " for details." }
$parsing-note ;

HELP: bad-escape
{ $error-description "Indicates the parser encountered an invalid escape code following a backslash (" { $snippet "\\" } ") in a string literal. See " { $link "escape" } " for a list of valid escape codes." } ;

HELP: bad-number
{ $error-description "Indicates the parser encountered an invalid numeric literal." } ;

HELP: escape
{ $values { "escape" "a single-character escape" } { "ch" "a character" } }
{ $description "Converts from a single-character escape code and the corresponding character." }
{ $examples { $example "CHAR: n escape CHAR: \\n = ." "t" } } ;

HELP: next-escape
{ $values { "m" "an index into " { $snippet "str" } } { "str" string } { "n" "an index into " { $snippet "str" } } { "ch" "a character" } }
{ $description "Helper word for " { $link parse-string } " which parses an escape sequence starting at the " { $snippet "m" } "th index of " { $snippet "str" } "." }
{ $errors "Throws a " { $link bad-escape } " if the string contains an invalid escape sequence." } ;

HELP: next-char
{ $values { "m" "an index into " { $snippet "str" } } { "str" string } { "n" "an index into " { $snippet "str" } } { "ch" "a character" } }
{ $description "Helper word for " { $link parse-string } " which parses a character starting at the " { $snippet "m" } "th index of " { $snippet "str" } "." } ;

HELP: parse-string
{ $values { "str" "a new " { $link string } } }
{ $description "Parses the line until a quote (\"), interpreting escape codes along the way." }
{ $errors "Throws an " { $link bad-escape } " if the string contains an invalid escape sequence." }
$parsing-note ;

HELP: still-parsing?
{ $values { "lexer" lexer } { "?" "a boolean" } }
{ $description "Outputs " { $link f } " if end of input has been reached, " { $link t } " otherwise." } ;

HELP: use
{ $var-description "A variable holding the current vocabulary search path as a sequence of assocs." } ;

{ use in use+ (use+) set-use set-in POSTPONE: USING: POSTPONE: USE: file-vocabs } related-words

HELP: in
{ $var-description "A variable holding the name of the current vocabulary for new definitions." } ;

HELP: shadow-warnings
{ $values { "vocab" "an assoc mapping strings to words" } { "vocabs" "a sequence of assocs" } }
{ $description "Tests if any keys in " { $snippet "vocab" } " shadow keys in the elements of " { $snippet "vocabs" } ", and if so, prints a warning message. These warning messages can be disabled by setting " { $link parser-notes } " to " { $link f } "." } ;

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
{ $values { "string" "a word name" } { "word" "a new word" } }
{ $description "Creates a word in the current vocabulary. Until re-defined, the word throws an error when invoked." }
$parsing-note ;

HELP: parse-tokens
{ $values { "end" string } { "seq" "a new sequence of strings" } }
{ $description "Reads a sequence of tokens until the first occurrence of " { $snippet "end" } ". The tokens remain as strings and are not processed in any way." }
{ $examples "This word is used to implement " { $link POSTPONE: USING: } "." }
$parsing-note ;

HELP: CREATE
{ $values { "word" word } }
{ $description "Reads the next token from the line currently being parsed, and creates a word with that name in the current vocabulary." }
{ $errors "Throws an error if the end of the line is reached." }
$parsing-note ;

HELP: no-word
{ $values { "name" string } { "newword" word } }
{ $description "Throws a " { $link no-word } " error." }
{ $error-description "Thrown if the parser encounters a token which does not name a word in the current vocabulary search path. If any words with this name exist in vocabularies not part of the search path, a number of restarts will offer to add those vocabularies to the search path and use the chosen word." }
{ $notes "Apart from a missing " { $link POSTPONE: USE: } ", this error can also indicate an ordering issue. In Factor, words must be defined before they can be called. Mutual recursion can be implemented via " { $link POSTPONE: DEFER: } "." } ;

HELP: search
{ $values { "str" string } { "word" word } }
{ $description "Searches for a word by name in the current vocabulary search path. If no such word could be found, throws a " { $link no-word } " error. If the search path does not contain a word with this name but other vocabularies do, the error will have restarts offering to add vocabularies to the search path." }
$parsing-note ;

HELP: forward-error
{ $values { "word" word } } 
{ $description "Throws a " { $link forward-error } "." }
{ $description "Indicates a word is being referenced prior to the location of its most recent definition. This can only happen if a source file is loaded, and subsequently edited such that two dependent definitions are reversed." } ;

HELP: scan-word
{ $values { "word/number/f" "a word, number or " { $link f } } }
{ $description "Reads the next token from parser input. If the token is a valid number literal, it is converted to a number, otherwise the dictionary is searched for a word named by the token. Outputs " { $link f } " if the end of the input has been reached." }
{ $errors "Throws an error if the token does not name a word, and does not parse as a number." }
$parsing-note ;

HELP: unexpected
{ $values { "want" "a " { $link word } " or " { $link f } } { "got" word } }
{ $description "Throws an " { $link unexpected } " error." }
{ $error-description "Thrown by the parser if an unmatched closing delimiter is encountered." }
{ $examples
    "Parsing the following snippet will throw this error:"
    { $code "[ 1 2 3 }" }
} ;

HELP: unexpected-eof
{ $values { "word" "a " { $link word } } }
{ $description "Throws an " { $link unexpected } " error indicating the parser was looking for an occurrence of " { $snippet "word" } " but encountered end of file." } ;

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

HELP: with-parser
{ $values { "lexer" lexer } { "quot" "a quotation with stack effect " { $snippet "( -- accum )" } } { "newquot" "a new " { $link quotation } } }
{ $description "Sets up the parser and calls the quotation. The quotation can make use of parsing words such as " { $link scan } " and " { $link parse-until } ". It must yield a sequence, which is converted to a quotation and output. Any errors thrown by the quotation are wrapped in parse errors." } ;

HELP: (parse-lines)
{ $values { "lexer" lexer } { "quot" "a new " { $link quotation } } }
{ $description "Parses Factor source code using a custom lexer. The vocabulary search path is taken from the current scope." }
{ $errors "Throws a " { $link parse-error } " if the input is malformed." } ;

HELP: parse-lines
{ $values { "lines" "a sequence of strings" } { "quot" "a new " { $link quotation } } }
{ $description "Parses Factor source code which has been tokenized into lines. The vocabulary search path is taken from the current scope." }
{ $errors "Throws a " { $link parse-error } " if the input is malformed." } ;

HELP: lexer-factory
{ $var-description "A variable holding a quotation with stack effect " { $snippet "( lines -- lexer )" } ". This quotation is called by the parser to create " { $link lexer } " instances. This variable can be rebound to a quotation which outputs a custom tuple delegating to " { $link lexer } " to customize syntax." } ;

HELP: parse-effect
{ $values { "effect" "an instance of " { $link effect } } }
{ $description "Parses a stack effect from the current input line." }
{ $examples "This word is used by " { $link POSTPONE: ( } " to parse stack effect declarations." }
$parsing-note ;

HELP: parse-base
{ $values { "base" "an integer between 2 and 36" } { "parsed" integer } }
{ $description "Reads an integer in a specific numerical base from the parser input." }
$parsing-note ;

HELP: parse-literal
{ $values { "accum" vector } { "end" word } { "quot" "a quotation with stack effect " { $snippet "( seq -- obj )" } } }
{ $description "Parses objects from parser input until " { $snippet "end" } ", applies the quotation to the resulting sequence, and adds the output value to the accumulator." }
{ $examples "This word is used to implement " { $link POSTPONE: C{ } "." }
$parsing-note ;

HELP: parse-definition
{ $values { "quot" "a new " { $link quotation } } }
{ $description "Parses objects from parser input until " { $link POSTPONE: ; } " and outputs a quotation with the results." }
{ $examples "This word is used to implement " { $link POSTPONE: : } "." }
$parsing-note ;

HELP: bootstrap-syntax
{ $var-description "Only set during bootstrap. Stores a copy of the " { $link vocab-words } " of the host's syntax vocabulary; this allows the host's parsing words to be used during bootstrap source parsing, not the target's." } ;

HELP: file-vocabs
{ $description "Installs the initial the vocabulary search path for parsing a file. This consists of the " { $snippet "syntax" } " vocabulary together with the " { $snippet "scratchpad" } " vocabulary." } ;

HELP: parse
{ $values { "str" string } { "quot" quotation } }
{ $description "Parses Factor source code from a string. The current vocabulary search path is used." }
{ $errors "Throws a parse error if the input is malformed." } ;

HELP: parse-fresh
{ $values { "lines" "a sequence of strings" } { "quot" quotation } }
{ $description "Parses Factor source code in a sequence of lines. The initial vocabulary search path is used (see " { $link file-vocabs } ")." }
{ $errors "Throws a parse error if the input is malformed." } ;

HELP: eval
{ $values { "str" string } }
{ $description "Parses Factor source code from a string, and calls the resulting quotation. The current vocabulary search path is used." }
{ $errors "Throws an error if the input is malformed, or if the quotation throws an error." } ;

HELP: parse-hook
{ $var-description "A quotation called by " { $link parse-stream } " after parsing the input stream. The default value recompiles new word definitions; see " { $link "recompile" } " for details." } ;

{ parse-hook no-parse-hook } related-words

HELP: no-parse-hook
{ $values { "quot" "a quotation" } }
{ $description "Runs the quotation in a new dynamic scope where " { $link parse-hook } " is set to " { $link f } ", then calls the outer " { $link parse-hook } " after the quotation returns. This has the effect of postponing any recompilation to the end of a quotation." } ;

HELP: start-parsing
{ $values { "stream" "an input stream" } { "name" "a pathname string" } }
{ $description "Prepares to parse a source file by reading the entire contents of the stream and setting some variables. The pathname identifies the stream for cross-referencing purposes." }
{ $errors "Throws an I/O error if there was an error reading from the stream." }
{ $notes "This is one of the factors of " { $link parse-stream } "." } ;

HELP: outside-usages
{ $values { "seq" "a sequence of definitions" } { "usages" "an association list mapping definitions to sequences of definitions" } }
{ $description "Outputs an association list mapping elements of " { $snippet "seq" } " to lists of usages which exclude the definitions in " { $snippet "seq" } " themselves." } ;

HELP: filter-moved
{ $values { "assoc" "an assoc where the keys are definitions" } { "newassoc" "an assoc where the keys are definitions" } }
{ $description "Removes all definitions from the assoc which are no longer present in the current " { $link file } "." } ;

HELP: smudged-usage
{ $values { "usages" "a sequence of definitions which reference removed definitions" } { "referenced" "a sequence of definitions removed from this source file which are still referenced elsewhere" } { "removed" "a sequence of definitions removed from this source file" } }
{ $description "Collects information about changed word definitioins after parsing." } ;

HELP: forget-smudged
{ $description "Forgets removed definitions and prints a warning message if any of them are still referenced from other source files." } ;

HELP: record-definitions
{ $values { "file" source-file } }
{ $description "Records that all " { $link new-definitions } " were defined in " { $snippet "file" } "." } ;

HELP: finish-parsing
{ $values { "quot" "the quotation just parsed" } }
{ $description "Records information to the current " { $link file } " and prints warnings about any removed definitions which are still in use." }
{ $notes "This is one of the factors of " { $link parse-stream } "." } ;

HELP: undo-parsing
{ $description "Records information to the current " { $link file } " after an incomplete parse which ended with an error." } ;

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

HELP: reload
{ $values { "defspec" "a definition specifier" } }
{ $description "Reloads the source file containing the definition." }
{ $examples
    "Reloading a word definition:"
    { $code "\\ foo reload" }
    "A word's documentation:"
    { $code "\\ foo >link reload" }
    "A method definition:"
    { $code "{ editor draw-gadget* } reload" }
    "A help article:"
    { $code "\"handbook\" >link reload" }
} ;

HELP: bootstrap-file
{ $values { "path" "a pathname string" } }
{ $description "If bootstrapping, parses the source file and adds its top level form to the quotation being constructed with " { $link make } "; the bootstrap code uses this to build up a boot quotation to be run on image startup. If not bootstrapping, just runs the file normally." } ;

HELP: ?bootstrap-file
{ $values { "path" "a pathname string" } }
{ $description "If the file exists, loads it with " { $link bootstrap-file } ", otherwise does nothing." } ;

HELP: eval>string
{ $values { "str" string } { "output" string } }
{ $description "Evaluates the Factor code in " { $snippet "str" } " with the " { $link stdio } " stream rebound to a string output stream, then outputs the resulting string." } ;
