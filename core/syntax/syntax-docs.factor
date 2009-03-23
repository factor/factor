USING: generic help.syntax help.markup kernel math parser words
effects classes generic.standard classes.tuple generic.math
generic.standard arrays io.pathnames vocabs.loader io sequences
assocs words.symbol words.alias words.constant ;
IN: syntax

ARTICLE: "parser-algorithm" "Parser algorithm"
"At the most abstract level, Factor syntax consists of whitespace-separated tokens. The parser tokenizes the input on whitespace boundaries. The parser is case-sensitive and whitespace between tokens is significant, so the following three expressions tokenize differently:"
{ $code "2X+\n2 X +\n2 x +" }
"As the parser reads tokens it makes a distinction between numbers, ordinary words, and parsing words. Tokens are appended to the parse tree, the top level of which is a quotation returned by the original parser invocation. Nested levels of the parse tree are created by parsing words."
$nl
"The parser iterates through the input text, checking each character in turn. Here is the parser algorithm in more detail -- some of the concepts therein will be defined shortly:"
{ $list
    { "If the current character is a double-quote (\"), the " { $link POSTPONE: " } " parsing word is executed, causing a string to be read." }
    {
        "Otherwise, the next token is taken from the input. The parser searches for a word named by the token in the currently used set of vocabularies. If the word is found, one of the following two actions is taken:"
        { $list
            "If the word is an ordinary word, it is appended to the parse tree."
            "If the word is a parsing word, it is executed."
        }
    }
    "Otherwise if the token does not represent a known word, the parser attempts to parse it as a number. If the token is a number, the number object is added to the parse tree. Otherwise, an error is raised and parsing halts."
}
"Parsing words play a key role in parsing; while ordinary words and numbers are simply added to the parse tree, parsing words execute in the context of the parser, and can do their own parsing and create nested data structures in the parse tree. Parsing words are also able to define new words."
$nl
"While parsing words supporting arbitrary syntax can be defined, the default set is found in the " { $vocab-link "syntax" } " vocabulary and provides the basis for all further syntactic interaction with Factor." ;

ARTICLE: "syntax-comments" "Comments"
{ $subsection POSTPONE: ! }
{ $subsection POSTPONE: #! } ;

ARTICLE: "syntax-immediate" "Parse time evaluation"
"Code can be evaluated at parse time. This is a rarely-used feature; one use-case is " { $link "loading-libs" } ", where you want to execute some code before the words in a source file are compiled."
{ $subsection POSTPONE: << }
{ $subsection POSTPONE: >> } ;

ARTICLE: "syntax-integers" "Integer syntax"
"The printed representation of an integer consists of a sequence of digits, optionally prefixed by a sign."
{ $code
    "123456"
    "-10"
    "2432902008176640000"
}
"Integers are entered in base 10 unless prefixed with a base change parsing word."
{ $subsection POSTPONE: BIN: }
{ $subsection POSTPONE: OCT: }
{ $subsection POSTPONE: HEX: }
"More information on integers can be found in " { $link "integers" } "." ;

ARTICLE: "syntax-ratios" "Ratio syntax"
"The printed representation of a ratio is a pair of integers separated by a slash (/), prefixed by an optional whole number part followed by a plus (+). No intermediate whitespace is permitted. Here are some examples:"
{ $code
    "75/33"
    "1/10"
    "-5/-6"
    "1+1/3"
    "-10+1/7"
}
"More information on ratios can be found in " { $link "rationals" } ;

ARTICLE: "syntax-floats" "Float syntax"
"Floating point literals must contain a decimal point, and may contain an exponent:"
{ $code
    "10.5"
    "-3.1456"
    "7.e13"
    "1.0e-5"
}
"More information on floats can be found in " { $link "floats" } "." ;

ARTICLE: "syntax-complex-numbers" "Complex number syntax"
"A complex number is given by two components, a “real” part and “imaginary” part. The components must either be integers, ratios or floats."
{ $code
    "C{ 1/2 1/3 }   ! the complex number 1/2+1/3i"
    "C{ 0 1 }       ! the imaginary unit"
}
{ $subsection POSTPONE: C{ }
"More information on complex numbers can be found in " { $link "complex-numbers" } "." ;

ARTICLE: "syntax-numbers" "Number syntax"
"If a vocabulary lookup of a token fails, the parser attempts to parse it as a number."
{ $subsection "syntax-integers" }
{ $subsection "syntax-ratios" }
{ $subsection "syntax-floats" }
{ $subsection "syntax-complex-numbers" } ;

ARTICLE: "syntax-words" "Word syntax"
"A word occurring inside a quotation is executed when the quotation is called. Sometimes a word needs to be pushed on the data stack instead. The canonical use-case for this is passing the word to the " { $link execute } " combinator, or alternatively, reflectively accessing word properties (" { $link "word-props" } ")."
{ $subsection POSTPONE: \ }
{ $subsection POSTPONE: POSTPONE: }
"The implementation of the " { $link POSTPONE: \ } " word is discussed in detail in " { $link "reading-ahead" } ". Words are documented in " { $link "words" } "." ;

ARTICLE: "escape" "Character escape codes"
{ $table
    { "Escape code" "Meaning" }
    { { $snippet "\\\\" } { $snippet "\\" } }
    { { $snippet "\\s" } "a space" }
    { { $snippet "\\t" } "a tab" }
    { { $snippet "\\n" } "a newline" }
    { { $snippet "\\r" } "a carriage return" }
    { { $snippet "\\0" } "a null byte (ASCII 0)" }
    { { $snippet "\\e" } "escape (ASCII 27)" }
    { { $snippet "\\\"" } { $snippet "\"" } }
    { { $snippet "\\u" { $emphasis "xxxxxx" } } { "The Unicode code point with hexadecimal number " { $snippet { $emphasis "xxxxxx" } } } }
    { { $snippet "\\u{" { $emphasis "name" } "}" } { "The Unicode code point named " { $snippet { $emphasis "name" } } } }
} ;

ARTICLE: "syntax-strings" "Character and string syntax"
"Factor has no distinct character type, however Unicode character value integers can be read by specifying a literal character, or an escaped representation thereof."
{ $subsection POSTPONE: CHAR: }
{ $subsection POSTPONE: " }
{ $subsection "escape" }
"Strings are documented in " { $link "strings" } "." ;

ARTICLE: "syntax-sbufs" "String buffer syntax"
{ $subsection POSTPONE: SBUF" }
"String buffers are documented in " { $link "sbufs" } "." ;

ARTICLE: "syntax-arrays" "Array syntax"
{ $subsection POSTPONE: { }
{ $subsection POSTPONE: } }
"Arrays are documented in " { $link "arrays" } "." ;

ARTICLE: "syntax-vectors" "Vector syntax"
{ $subsection POSTPONE: V{ }
"Vectors are documented in " { $link "vectors" } "." ;

ARTICLE: "syntax-hashtables" "Hashtable syntax"
{ $subsection POSTPONE: H{ }
"Hashtables are documented in " { $link "hashtables" } "." ;

ARTICLE: "syntax-tuples" "Tuple syntax"
{ $subsection POSTPONE: T{ }
"Tuples are documented in " { $link "tuples" } "."  ;

ARTICLE: "syntax-quots" "Quotation syntax"
{ $subsection POSTPONE: [ }
{ $subsection POSTPONE: ] }
"Quotations are documented in " { $link "quotations" } "." ;

ARTICLE: "syntax-byte-arrays" "Byte array syntax"
{ $subsection POSTPONE: B{ }
"Byte arrays are documented in " { $link "byte-arrays" } "." ;

ARTICLE: "syntax-pathnames" "Pathname syntax"
{ $subsection POSTPONE: P" }
"Pathnames are documented in " { $link "io.pathnames" } "." ;

ARTICLE: "syntax-literals" "Literals"
"Many different types of objects can be constructed at parse time via literal syntax. Numbers are a special case since support for reading them is built-in to the parser. All other literals are constructed via parsing words."
$nl
"If a quotation contains a literal object, the same literal object instance is used each time the quotation executes; that is, literals are “live”."
$nl
"Using mutable object literals in word definitions requires care, since if those objects are mutated, the actual word definition will be changed, which is in most cases not what you would expect. Literals should be " { $link clone } "d before being passed to word which may potentially mutate them."
{ $subsection "syntax-numbers" }
{ $subsection "syntax-words" }
{ $subsection "syntax-quots" }
{ $subsection "syntax-arrays" }
{ $subsection "syntax-strings" }
{ $subsection "syntax-byte-arrays" }
{ $subsection "syntax-vectors" }
{ $subsection "syntax-sbufs" }
{ $subsection "syntax-hashtables" }
{ $subsection "syntax-tuples" }
{ $subsection "syntax-pathnames" } ;

ARTICLE: "syntax" "Syntax"
"Factor has two main forms of syntax: " { $emphasis "definition" } " syntax and " { $emphasis "literal" } " syntax. Code is data, so the syntax for code is a special case of object literal syntax. This section documents literal syntax. Definition syntax is covered in " { $link "words" } ". Extending the parser is the main topic of " { $link "parser" } "."
{ $subsection "parser-algorithm" }
{ $subsection "syntax-comments" }
{ $subsection "syntax-literals" }
{ $subsection "syntax-immediate" } ;

ABOUT: "syntax"

HELP: delimiter
{ $syntax ": foo ... ; delimiter" }
{ $description "Declares the most recently defined word as a delimiter. Delimiters are words which are only ever valid as the end of a nested block to be read by " { $link parse-until } ". An unpaired occurrence of a delimiter is a parse error." } ;

HELP: SYNTAX:
{ $syntax "SYNTAX: foo ... ;" }
{ $description "Defines a parsing word." }
{ $examples "In the below example, the " { $snippet "world" } " word is never called, however its body references a parsing word which executes immediately:" { $example "USE: io" "IN: scratchpad" "<< SYNTAX: HELLO \"Hello parser!\" print ; >>\n: world ( -- ) HELLO ;" "Hello parser!" } } ;

HELP: inline
{ $syntax ": foo ... ; inline" }
{ $description
    "Declares the most recently defined word as an inline word. The optimizing compiler copies definitions of inline words when compiling calls to them."
    $nl
    "Combinators must be inlined in order to compile with the optimizing compiler - see " { $link "inference-combinators" } ". For any other word, inlining is merely an optimization."
    $nl
    "The non-optimizing quotation compiler ignores inlining declarations."
} ;

HELP: recursive
{ $syntax ": foo ... ; recursive" }
{ $description "Declares the most recently defined word as a recursive word." }
{ $notes "This declaration is only required for " { $link POSTPONE: inline } " words which call themselves. See " { $link "inference-recursive-combinators" } "." } ;

HELP: foldable
{ $syntax ": foo ... ; foldable" }
{ $description
    "Declares that the most recently defined word may be evaluated at compile-time if all inputs are literal. Foldable words must satisfy a very strong contract:"
    { $list
        "foldable words must not have any observable side effects,"
        "foldable words must halt - for example, a word computing a series until it coverges should not be foldable, since compilation will not halt in the event the series does not converge."
        "both inputs and outputs of foldable words must be immutable."
    }
    "The last restriction ensures that words such as " { $link clone } " do not satisfy the foldable word contract. Indeed, " { $link clone } " will output a mutable object if its input is mutable, and so it is undesirable to evaluate it at compile-time, since doing so would give incorrect semantics for code that clones mutable objects and proceeds to mutate them."
}
{ $notes
    "Folding optimizations are not applied if the call site of a word is in the same source file as the word. This is a side-effect of the compilation unit system; see " { $link "compilation-units" } "."
}
{ $examples "Most operations on numbers are foldable. For example, " { $snippet "2 2 +" } " compiles to a literal 4, since " { $link + } " is declared foldable." } ;

HELP: flushable
{ $syntax ": foo ... ; flushable" }
{ $description
    "Declares that the most recently defined word has no side effects, and thus calls to this word may be pruned by the compiler if the outputs are not used."
    $nl
    "Note that many words are flushable but not foldable, for example " { $link clone } " and " { $link <array> } "."
} ;

HELP: t
{ $syntax "t" }
{ $values { "t" "the canonical truth value" } }
{ $class-description "The canonical truth value, which is an instance of itself." } ;

HELP: f
{ $syntax "f" }
{ $values { "f" "the singleton false value" } }
{ $description "The " { $link f } " parsing word adds the " { $link f } " object to the parse tree, and is also the class whose sole instance is the " { $link f } " object. The " { $link f } " object is the singleton false value, the only object that is not true. The " { $link f } " object is not equal to the " { $link f } " class word, which can be pushed on the stack using word wrapper syntax:"
{ $code "f    ! the singleton f object denoting falsity\n\\ f  ! the f class word" } } ;

HELP: [
{ $syntax "[ elements... ]" }
{ $description "Marks the beginning of a literal quotation." }
{ $examples { $code "[ 1 2 3 ]" } } ;

{ POSTPONE: [ POSTPONE: ] } related-words

HELP: ]
{ $syntax "]" }
{ $description "Marks the end of a literal quotation."
$nl
"Parsing words can use this word as a generic end delimiter." } ;

HELP: }
{ $syntax "}" }
{ $description "Marks the end of an array, vector, hashtable, complex number, tuple, or wrapper."
$nl
"Parsing words can use this word as a generic end delimiter." } ;

{ POSTPONE: { POSTPONE: V{ POSTPONE: H{ POSTPONE: C{ POSTPONE: T{ POSTPONE: W{ POSTPONE: } } related-words

HELP: {
{ $syntax "{ elements... }" }
{ $values { "elements" "a list of objects" } }
{ $description "Marks the beginning of a literal array. Literal arrays are terminated by " { $link POSTPONE: } } "." } 
{ $examples { $code "{ 1 2 3 }" } } ;

HELP: V{
{ $syntax "V{ elements... }" }
{ $values { "elements" "a list of objects" } }
{ $description "Marks the beginning of a literal vector. Literal vectors are terminated by " { $link POSTPONE: } } "." } 
{ $examples { $code "V{ 1 2 3 }" } } ;

HELP: B{
{ $syntax "B{ elements... }" }
{ $values { "elements" "a list of integers" } }
{ $description "Marks the beginning of a literal byte array. Literal byte arrays are terminated by " { $link POSTPONE: } } "." } 
{ $examples { $code "B{ 1 2 3 }" } } ;

HELP: H{
{ $syntax "H{ { key value }... }" }
{ $values { "key" "an object" } { "value" "an object" } }
{ $description "Marks the beginning of a literal hashtable, given as a list of two-element arrays holding key/value pairs. Literal hashtables are terminated by " { $link POSTPONE: } } "." } 
{ $examples { $code "H{ { \"tuna\" \"fish\" } { \"jalapeno\" \"vegetable\" } }" } } ;

HELP: C{
{ $syntax "C{ real-part imaginary-part }" }
{ $values { "real-part" "a real number" } { "imaginary-part" "a real number" } }
{ $description "Parses a complex number given in rectangular form as a pair of real numbers. Literal complex numbers are terminated by " { $link POSTPONE: } } "." }  ;

HELP: T{
{ $syntax "T{ class slots... }" }
{ $values { "class" "a tuple class word" } { "slots" "slot values" } }
{ $description "Marks the beginning of a literal tuple."
$nl
"Three literal syntax forms are recognized:"
{ $list
    { "empty tuple form: if no slot values are specified, then the literal tuple will have all slots set to their initial values (see " { $link "slot-initial-values" } ")." }
    { "BOA-form: if the first element of " { $snippet "slots" } " is " { $snippet "f" } ", then the remaining elements are slot values corresponding to slots in the order in which they are defined in the " { $link POSTPONE: TUPLE: } " form." }
    { "assoc-form: otherwise, " { $snippet "slots" } " is interpreted as a sequence of " { $snippet "{ slot-name value }" } " pairs. The " { $snippet "slot-name" } " should not be quoted." }
}
"BOA form is more concise, whereas assoc form is more readable for larger tuples with many slots, or if only a few slots are to be specified."
$nl
"With BOA form, specifying an insufficient number of values is given after the class word, the remaining slots of the tuple are set to their initial values (see " { $link "slot-initial-values" } "). If too many values are given, an error will be raised." }
{ $examples
"An empty tuple; since vectors have their own literal syntax, the above is equivalent to " { $snippet "V{ }" } ""
{ $code "T{ vector }" }
"A BOA-form tuple:"
{ $code
    "USE: colors"
    "T{ rgba f 1.0 0.0 0.5 }"
}
"An assoc-form tuple equal to the above:"
{ $code
    "USE: colors"
    "T{ rgba { red 1.0 } { green 0.0 } { blue 0.5 } }"
} } ;

HELP: W{
{ $syntax "W{ object }" }
{ $values { "object" "an object" } }
{ $description "Marks the beginning of a literal wrapper. Literal wrappers are terminated by " { $link POSTPONE: } } "." }  ;

HELP: POSTPONE:
{ $syntax "POSTPONE: word" }
{ $values { "word" "a word" } }
{ $description "Reads the next word from the input string and appends the word to the parse tree, even if it is a parsing word." }
{ $examples "For an ordinary word " { $snippet "foo" } ", " { $snippet "foo" } " and " { $snippet "POSTPONE: foo" } " are equivalent; however, if " { $snippet "foo" } " is a parsing word, the former will execute it at parse time, while the latter will execute it at runtime." }
{ $notes "This word is used inside parsing words to delegate further action to another parsing word, and to refer to parsing words literally from literal arrays and such." } ;

HELP: :
{ $syntax ": word ( stack -- effect ) definition... ;" }
{ $values { "word" "a new word to define" } { "definition" "a word definition" } }
{ $description "Defines a word with the given stack effect in the current vocabulary. The stack effect is optional for words which only push literals on the stack." }
{ $examples { $code ": ask-name ( -- name )\n    \"What is your name? \" write readln ;\n: greet ( name -- )\n    \"Greetings, \" write print ;\n: friend ( -- )\n    ask-name greet ;" } } ;

{ POSTPONE: : POSTPONE: ; define } related-words

HELP: ;
{ $syntax ";" }
{ $description
    "Marks the end of a definition."
    $nl
    "Parsing words can use this word as a generic end delimiter."
} ;

HELP: SYMBOL:
{ $syntax "SYMBOL: word" }
{ $values { "word" "a new word to define" } }
{ $description "Defines a new symbol word in the current vocabulary. Symbols push themselves on the stack when executed, and are used to identify variables (see " { $link "namespaces" } ") as well as for storing crufties in word properties (see " { $link "word-props" } ")." }
{ $examples { $example "USE: prettyprint" "IN: scratchpad" "SYMBOL: foo\nfoo ." "foo" } } ;

{ define-symbol POSTPONE: SYMBOL: POSTPONE: SYMBOLS: } related-words

HELP: SYMBOLS:
{ $syntax "SYMBOLS: words... ;" }
{ $values { "words" "a sequence of new words to define" } }
{ $description "Creates a new symbol for every token until the " { $snippet ";" } "." }
{ $examples { $example "USING: prettyprint ;" "IN: scratchpad" "SYMBOLS: foo bar baz ;\nfoo . bar . baz ." "foo\nbar\nbaz" } } ;

HELP: SINGLETON:
{ $syntax "SINGLETON: class" }
{ $values
    { "class" "a new singleton to define" }
}
{ $description
    "Defines a new singleton class. The class word itself is the sole instance of the singleton class."
}
{ $examples
    { $example "USING: classes.singleton kernel io ;" "IN: singleton-demo" "USE: prettyprint SINGLETON: foo\nGENERIC: bar ( obj -- )\nM: foo bar drop \"a foo!\" print ;\nfoo bar" "a foo!" }
} ;
    
HELP: SINGLETONS:
{ $syntax "SINGLETONS: words... ;" }
{ $values { "words" "a sequence of new words to define" } }
{ $description "Creates a new singleton for every token until the " { $snippet ";" } "." } ;

HELP: ALIAS:
{ $syntax "ALIAS: new-word existing-word" }
{ $values { "new-word" word } { "existing-word" word } }
{ $description "Creates a new inlined word that calls the existing word." }
{ $examples
    { $example "USING: prettyprint sequences ;"
               "IN: alias.test"
               "ALIAS: sequence-nth nth"
               "0 { 10 20 30 } sequence-nth ."
               "10"
    }
} ;

{ define-alias POSTPONE: ALIAS: } related-words

HELP: CONSTANT:
{ $syntax "CONSTANT: word value" }
{ $values { "word" word } { "value" object } }
{ $description "Creates a word which pushes a value on the stack." }
{ $examples { $code "CONSTANT: magic 1" "CONSTANT: science HEX: ff0f" } } ;

{ define-constant POSTPONE: CONSTANT: } related-words

HELP: \
{ $syntax "\\ word" }
{ $values { "word" "a word" } }
{ $description "Reads the next word from the input and appends a wrapper holding the word to the parse tree. When the evaluator encounters a wrapper, it pushes the wrapped word literally on the data stack." }
{ $examples "The following two lines are equivalent:" { $code "0 \\ <vector> execute\n0 <vector>" } "If " { $snippet "foo" } " is a symbol, the following two lines are equivalent:" { $code "foo" "\\ foo" } } ;

HELP: DEFER:
{ $syntax "DEFER: word" }
{ $values { "word" "a new word to define" } }
{ $description "Create a word in the current vocabulary that simply raises an error when executed. Usually, the word will be replaced with a real definition later." }
{ $notes "Due to the way the parser works, words cannot be referenced before they are defined; that is, source files must order definitions in a strictly bottom-up fashion. Mutually-recursive pairs of words can be implemented by " { $emphasis "deferring" } " one of the words in the pair allowing the second word in the pair to parse, then by defining the first word." }
{ $examples { $code "DEFER: foe\n: fie ... foe ... ;\n: foe ... fie ... ;" } } ;

HELP: FORGET:
{ $syntax "FORGET: word" }
{ $values { "word" "a word" } }
{ $description "Removes the word from its vocabulary, or does nothing if no such word exists. Existing definitions that reference forgotten words will continue to work, but new occurrences of the word will not parse." } ;

HELP: USE:
{ $syntax "USE: vocabulary" }
{ $values { "vocabulary" "a vocabulary name" } }
{ $description "Adds a new vocabulary at the front of the search path. Subsequent word lookups by the parser will search this vocabulary first." }
{ $errors "Throws an error if the vocabulary does not exist." } ;

HELP: USING:
{ $syntax "USING: vocabularies... ;" }
{ $values { "vocabularies" "a list of vocabulary names" } }
{ $description "Adds a list of vocabularies to the front of the search path, with later vocabularies taking precedence." }
{ $errors "Throws an error if one of the vocabularies does not exist." } ;

HELP: QUALIFIED:
{ $syntax "QUALIFIED: vocab" }
{ $description "Similar to " { $link POSTPONE: USE: } " but loads vocabulary with prefix." }
{ $examples { $example
    "USING: prettyprint ;"
    "QUALIFIED: math"
    "1 2 math:+ ." "3"
} } ;

HELP: QUALIFIED-WITH:
{ $syntax "QUALIFIED-WITH: vocab word-prefix" }
{ $description "Works like " { $link POSTPONE: QUALIFIED: } " but uses " { $snippet "word-prefix" } " as prefix." }
{ $examples { $code
    "USING: prettyprint ;"
    "QUALIFIED-WITH: math m"
    "1 2 m:+ ."
    "3"
} } ;

HELP: FROM:
{ $syntax "FROM: vocab => words ... ;" }
{ $description "Imports " { $snippet "words" } " from " { $snippet "vocab" } "." }
{ $examples { $code
    "FROM: math.parser => bin> hex> ; ! imports only bin> and hex>" } } ;

HELP: EXCLUDE:
{ $syntax "EXCLUDE: vocab => words ... ;" }
{ $description "Imports everything from " { $snippet "vocab" } " excluding " { $snippet "words" } "." }
{ $examples { $code
    "EXCLUDE: math.parser => bin> hex> ; ! imports everything but bin> and hex>" } } ;

HELP: RENAME:
{ $syntax "RENAME: word vocab => newname" }
{ $description "Imports " { $snippet "word" } " from " { $snippet "vocab" } ", but renamed to " { $snippet "newname" } "." }
{ $examples { $example
    "USING: prettyprint ;"
    "RENAME: + math => -"
    "2 3 - ."
    "5"
} } ;

HELP: IN:
{ $syntax "IN: vocabulary" }
{ $values { "vocabulary" "a new vocabulary name" } }
{ $description "Sets the current vocabulary where new words will be defined, creating the vocabulary first if it does not exist. After the vocabulary has been created, it can be listed in " { $link POSTPONE: USE: } " and " { $link POSTPONE: USING: } " declarations." } ;

HELP: CHAR:
{ $syntax "CHAR: token" }
{ $values { "token" "a literal character, escape code, or Unicode character name" } }
{ $description "Adds a Unicode code point to the parse tree." }
{ $examples
    { $code
        "CHAR: x"
        "CHAR: \\u000032"
        "CHAR: \\u{exclamation-mark}"
        "CHAR: exclamation-mark"
        "CHAR: ugaritic-letter-samka"
    }
} ;

HELP: "
{ $syntax "\"string...\"" }
{ $values { "string" "literal and escaped characters" } }
{ $description "Reads from the input string until the next occurrence of " { $link POSTPONE: " } ", and appends the resulting string to the parse tree. String literals cannot span multiple lines. Strings containing the " { $link POSTPONE: " } " character and various other special characters can be read by inserting " { $link "escape" } "." }
{ $examples
  "A string with a newline in it:"
  { $example "USE: io" "\"Hello\\nworld\" print" "Hello\nworld" }
  "A string with a named Unicode code point:"
  { $example "USE: io" "\"\\u{greek-capital-letter-sigma}\" print" "\u{greek-capital-letter-sigma}" }
} ;

HELP: SBUF"
{ $syntax "SBUF\" string... \"" }
{ $values { "string" "literal and escaped characters" } }
{ $description "Reads from the input string until the next occurrence of " { $link POSTPONE: " } ", converts the string to a string buffer, and appends it to the parse tree." }
{ $examples { $example "USING: io strings ;" "SBUF\" Hello world\" >string print" "Hello world" } } ;

HELP: P"
{ $syntax "P\" pathname\"" }
{ $values { "pathname" "a pathname string" } }
{ $description "Reads from the input string until the next occurrence of " { $link POSTPONE: " } ", creates a new " { $link pathname } ", and appends it to the parse tree." }
{ $examples { $example "USING: accessors io io.files ;" "P\" foo.txt\" string>> print" "foo.txt" } } ;

HELP: (
{ $syntax "( inputs -- outputs )" }
{ $values { "inputs" "a list of tokens" } { "outputs" "a list of tokens" } }
{ $description "A stack effect declaration. This is treated as a comment unless it appears inside a word definition." }
{ $see-also "effect-declaration" } ;

HELP: ((
{ $syntax "(( inputs -- outputs ))" }
{ $values { "inputs" "a list of tokens" } { "outputs" "a list of tokens" } }
{ $description "Literal stack effect syntax." }
{ $notes "Useful for meta-programming with " { $link define-declared } "." }
{ $examples
    { $code
        "SYMBOL: my-dynamic-word"
        "USING: math random words ;"
        "3 { [ + ] [ - ] [ * ] [ / ] } random curry"
        "(( x -- y )) define-declared"
    }
} ;

HELP: !
{ $syntax "! comment..." }
{ $values { "comment" "characters" } }
{ $description "Discards all input until the end of the line." } ;

{ POSTPONE: ! POSTPONE: #! } related-words

HELP: #!
{ $syntax "#! comment..." }
{ $values { "comment" "characters" } }
{ $description "Discards all input until the end of the line." } ;

HELP: HEX:
{ $syntax "HEX: integer" }
{ $values { "integer" "hexadecimal digits (0-9, a-f, A-F)" } }
{ $description "Adds an integer read from a hexadecimal literal to the parse tree." }
{ $examples { $example "USE: prettyprint" "HEX: ff ." "255" } } ;

HELP: OCT:
{ $syntax "OCT: integer" }
{ $values { "integer" "octal digits (0-7)" } }
{ $description "Adds an integer read from an octal literal to the parse tree." }
{ $examples { $example "USE: prettyprint" "OCT: 31337 ." "13023" } } ;

HELP: BIN:
{ $syntax "BIN: integer" }
{ $values { "integer" "binary digits (0 and 1)" } }
{ $description "Adds an integer read from an binary literal to the parse tree." }
{ $examples { $example "USE: prettyprint" "BIN: 100 ." "4" } } ;

HELP: GENERIC:
{ $syntax "GENERIC: word" "GENERIC: word ( stack -- effect )" }
{ $values { "word" "a new word to define" } }
{ $description "Defines a new generic word in the current vocabulary. Initially, it contains no methods, and thus will throw a " { $link no-method } " error when called." } ;

HELP: GENERIC#
{ $syntax "GENERIC# word n" "GENERIC# word n ( stack -- effect )" }
{ $values { "word" "a new word to define" } { "n" "the stack position to dispatch on" } }
{ $description "Defines a new generic word which dispatches on the " { $snippet "n" } "th most element from the top of the stack in the current vocabulary. Initially, it contains no methods, and thus will throw a " { $link no-method } " error when called." }
{ $notes
    "The following two definitions are equivalent:"
    { $code "GENERIC: foo" }
    { $code "GENERIC# foo 0" }
} ;

HELP: MATH:
{ $syntax "MATH: word" }
{ $values { "word" "a new word to define" } }
{ $description "Defines a new generic word which uses the " { $link math-combination } " method combination." } ;

HELP: HOOK:
{ $syntax "HOOK: word variable" "HOOK: word variable ( stack -- effect ) " }
{ $values { "word" "a new word to define" } { "variable" word } }
{ $description "Defines a new hook word in the current vocabulary. Hook words are generic words which dispatch on the value of a variable, so methods are defined with " { $link POSTPONE: M: } ". Hook words differ from other generic words in that the dispatch value is removed from the stack before the chosen method is called." }
{ $examples
    { $example
        "USING: io namespaces ;"
        "IN: scratchpad"
        "SYMBOL: transport"
        "TUPLE: land-transport ;"
        "TUPLE: air-transport ;"
        "HOOK: deliver transport ( destination -- )"
        "M: land-transport deliver \"Land delivery to \" write print ;"
        "M: air-transport deliver \"Air delivery to \"  write print ;"
        "T{ air-transport } transport set"
        "\"New York City\" deliver"
        "Air delivery to New York City"
    }
}
{ $notes
    "Hook words are really just generic words with a custom method combination (see " { $link "method-combination" } ")."
} ;

HELP: M:
{ $syntax "M: class generic definition... ;" }
{ $values { "class" "a class word" } { "generic" "a generic word" } { "definition" "a method definition" } }
{ $description "Defines a method, that is, a behavior for the generic word specialized on instances of the class." } ;

HELP: UNION:
{ $syntax "UNION: class members... ;" }
{ $values { "class" "a new class word to define" } { "members" "a list of class words separated by whitespace" } }
{ $description "Defines a union class. An object is an instance of a union class if it is an instance of one of its members." } ;

HELP: INTERSECTION:
{ $syntax "INTERSECTION: class participants... ;" }
{ $values { "class" "a new class word to define" } { "participants" "a list of class words separated by whitespace" } }
{ $description "Defines an intersection class. An object is an instance of an intersection class if it is an instance of all of its participants." } ;

HELP: MIXIN:
{ $syntax "MIXIN: class" }
{ $values { "class" "a new class word to define" } }
{ $description "Defines a mixin class. A mixin is similar to a union class, except it has no members initially, and new members can be added with the " { $link POSTPONE: INSTANCE: } " word." }
{ $examples "The " { $link sequence } " and " { $link assoc } " mixin classes." } ;

HELP: INSTANCE:
{ $syntax "INSTANCE: instance mixin" }
{ $values { "instance" "a class word" } { "mixin" "a mixin class word" } }
{ $description "Makes " { $snippet "instance" } " an instance of " { $snippet "mixin" } "." } ;

HELP: PREDICATE:
{ $syntax "PREDICATE: class < superclass predicate... ;" }
{ $values { "class" "a new class word to define" } { "superclass" "an existing class word" } { "predicate" "membership test with stack effect " { $snippet "( superclass -- ? )" } } }
{ $description
    "Defines a predicate class deriving from " { $snippet "superclass" } "."
    $nl
    "An object is an instance of a predicate class if two conditions hold:"
    { $list
        "it is an instance of the predicate's superclass,"
        "it satisfies the predicate"
    }
    "Each predicate must be defined as a subclass of some other class. This ensures that predicates inheriting from disjoint classes do not need to be exhaustively tested during method dispatch."
}
{ $examples
    { $code "USING: math ;" "PREDICATE: positive < integer 0 > ;" }
} ;

HELP: TUPLE:
{ $syntax "TUPLE: class slots... ;" "TUPLE: class < superclass slots ... ;" }
{ $values { "class" "a new tuple class to define" } { "slots" "a list of slot specifiers" } }
{ $description "Defines a new tuple class."
$nl
"The superclass is optional; if left unspecified, it defaults to " { $link tuple } "."
$nl
"Slot specifiers take one of the following three forms:"
{ $list
    { { $snippet "name" } " - a slot which can hold any object, with no attributes" }
    { { $snippet "{ name attributes... }" } " - a slot which can hold any object, with optional attributes" }
    { { $snippet "{ name class attributes... }" } " - a slot specialized to a specific class, with optional attributes" }
}
"Slot attributes are lists of slot attribute specifiers followed by values; a slot attribute specifier is one of " { $link initial: } " or " { $link read-only } ". See " { $link "tuple-declarations" } " for details." }
{ $examples
    "A simple tuple class:"
    { $code "TUPLE: color red green blue ;" }
    "Declaring slots to be integer-valued:"
    { $code "TUPLE: color" "{ red integer }" "{ green integer }" "{ blue integer } ;" }
    "An example mixing short and long slot specifiers:"
    { $code "TUPLE: person" "{ age integer initial: 0 }" "{ department string initial: \"Marketing\" }" "manager ;" }
} ;

HELP: initial:
{ $syntax "TUPLE: ... { slot initial: value } ... ;" }
{ $values { "slot" "a slot name" } { "value" "any literal" } }
{ $description "Specifies an initial value for a tuple slot." } ;

HELP: read-only
{ $syntax "TUPLE: ... { slot read-only } ... ;" }
{ $values { "slot" "a slot name" } }
{ $description "Defines a tuple slot to be read-only. If a tuple has read-only slots, instances of the tuple should only be created by calling " { $link boa } ", instead of " { $link new } ". Using " { $link boa } " is the only way to set the value of a read-only slot." } ;

{ initial: read-only } related-words

HELP: SLOT:
{ $syntax "SLOT: name" }
{ $values { "name" "a slot name" } }
{ $description "Defines a protocol slot; that is, defines the accessor words for a slot named " { $snippet "slot" } " without associating it with any specific tuple." } ;

HELP: ERROR:
{ $syntax "ERROR: class slots... ;" }
{ $values { "class" "a new tuple class to define" } { "slots" "a list of slot names" } }
{ $description "Defines a new tuple class whose class word throws a new instance of the error." }
{ $notes
    "The following two snippets are equivalent:"
    { $code
        "ERROR: invalid-values x y ;"
        ""
        "TUPLE: invalid-values x y ;"
        ": invalid-values ( x y -- * )"
        "    \\ invalid-values boa throw ;"
    }
} ;

HELP: C:
{ $syntax "C: constructor class" }
{ $values { "constructor" "a new word to define" } { "class" tuple-class } }
{ $description "Define a constructor word for a tuple class which simply performs BOA (by order of arguments) construction using " { $link boa } "." }
{ $examples
    "Suppose the following tuple has been defined:"
    { $code "TUPLE: color red green blue ;" }
    "The following two lines are equivalent:"
    { $code
        "C: <color> color"
        ": <color> color boa ;"
    }
    "In both cases, a word " { $snippet "<color>" } " is defined, which reads three values from the stack and creates a " { $snippet "color" } " instance having these values in the " { $snippet "red" } ", " { $snippet "green" } " and " { $snippet "blue" } " slots, respectively."
} ;

HELP: MAIN:
{ $syntax "MAIN: word" }
{ $values { "word" word } }
{ $description "Defines the main entry point for the current vocabulary. This word will be executed when this vocabulary is passed to " { $link run } "." } ;

HELP: <PRIVATE
{ $syntax "<PRIVATE ... PRIVATE>" }
{ $description "Marks the start of a block of private word definitions. Private word definitions are placed in a vocabulary named by suffixing the current vocabulary with " { $snippet ".private" } "." }
{ $notes
    "The following is an example of usage:"
    { $code
        "IN: factorial"
        ""
        "<PRIVATE"
        ""
        ": (fac) ( accum n -- n! )"
        "    dup 1 <= [ drop ] [ [ * ] keep 1- (fac) ] if ;"
        ""
        "PRIVATE>"
        ""
        ": fac ( n -- n! ) 1 swap (fac) ;"
    }
    "The above is equivalent to:"
    { $code
        "IN: factorial.private"
        ""
        ": (fac) ( accum n -- n! )"
        "    dup 1 <= [ drop ] [ [ * ] keep 1- (fac) ] if ;"
        ""
        "IN: factorial"
        ""
        ": fac ( n -- n! ) 1 swap (fac) ;"
    }
} ;

HELP: PRIVATE>
{ $syntax "<PRIVATE ... PRIVATE>" }
{ $description "Marks the end of a block of private word definitions." } ;

{ POSTPONE: <PRIVATE POSTPONE: PRIVATE> } related-words

HELP: <<
{ $syntax "<< ... >>" }
{ $description "Evaluates some code at parse time." }
{ $notes "Calling words defined in the same source file at parse time is prohibited; see compilation unit as where it was defined; see " { $link "compilation-units" } "." } ;

HELP: >>
{ $syntax ">>" }
{ $description "Marks the end of a parse time code block." } ;

HELP: call-next-method
{ $description "Calls the next applicable method. Only valid inside a method definition. The values at the top of the stack are passed on to the next method, and they must be compatible with that method's class specializer." }
{ $errors
    "Throws a " { $link no-next-method } " error if this is the least specific method, and throws an " { $link inconsistent-next-method } " error if the values at the top of the stack are not compatible with the current method's specializer."
} ;

{ POSTPONE: call-next-method (call-next-method) next-method } related-words

{ POSTPONE: << POSTPONE: >> } related-words

HELP: call(
{ $syntax "call( stack -- effect )" }
{ $description "Calls the quotation on the top of the stack, asserting that it has the given stack effect. The quotation does not need to be known at compile time." } ;

HELP: execute(
{ $syntax "execute( stack -- effect )" }
{ $description "Calls the word on the top of the stack, asserting that it has the given stack effect. The word does not need to be known at compile time." } ;

{ POSTPONE: call( POSTPONE: execute( } related-words