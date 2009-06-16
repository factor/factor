IN: lexer
USING: help.markup help.syntax kernel math sequences strings
words quotations ;

HELP: lexer
{ $var-description "Stores the current " { $link lexer } " instance." }
{ $class-description "An object for tokenizing parser input. It has the following slots:"
    { $list
        { { $snippet "text" } " - the lines being parsed; an array of strings" }
        { { $snippet "line" } " - the line number being parsed; unlike most indices this is 1-based for friendlier error reporting and integration with text editors" }
        { { $snippet "column" } " - the current column position, zero-based" }
    }
"Custom lexing can be implemented by delegating a tuple to an instance of this class and implementing the " { $link skip-word } " and " { $link skip-blank } " generic words." } ;

HELP: <lexer>
{ $values { "text" "a sequence of strings" } { "lexer" lexer } }
{ $description "Creates a new lexer for tokenizing the given sequence of lines." } ;

HELP: next-line
{ $values { "lexer" lexer } }
{ $description "Advances the lexer to the next input line, discarding the remainder of the current line." } ;

HELP: lexer-error
{ $error-description "Thrown when the lexer encounters invalid input. A lexer error wraps an underlying error together with line and column numbers." } ;

HELP: <lexer-error>
{ $values { "msg" "an error" } { "error" lexer-error } }
{ $description "Creates a new " { $link lexer-error } ", filling in the location information from the current " { $link lexer } "." } ;

HELP: skip
{ $values { "i" "a starting index" } { "seq" sequence } { "?" "a boolean" } { "n" integer } }
{ $description "Skips to the first space character (if " { $snippet "boolean" } " is " { $link f } ") or the first non-space character (otherwise). Tabulations used as separators instead of spaces will be flagged as an error." } ;

HELP: change-lexer-column
{ $values { "lexer" lexer } { "quot" { $quotation "( col line -- newcol )" } } }
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
{ $values { "lexer" lexer } { "str/f" { $maybe string } } }
{ $description "Reads the next token from the lexer. Tokens are delimited by whitespace, with the exception that " { $snippet "\"" } " is treated like a single token even when not followed by whitespace." } ;

HELP: scan
{ $values { "str/f" { $maybe string } } }
{ $description "Reads the next token from the lexer. See " { $link parse-token } " for details." }
$parsing-note ;

HELP: still-parsing?
{ $values { "lexer" lexer } { "?" "a boolean" } }
{ $description "Outputs " { $link f } " if end of input has been reached, " { $link t } " otherwise." } ;

HELP: parse-tokens
{ $values { "end" string } { "seq" "a new sequence of strings" } }
{ $description "Reads a sequence of tokens until the first occurrence of " { $snippet "end" } ". The tokens remain as strings and are not processed in any way." }
{ $examples "This word is used to implement " { $link POSTPONE: USING: } "." }
$parsing-note ;

HELP: unexpected
{ $values { "want" { $maybe word } } { "got" word } }
{ $description "Throws an " { $link unexpected } " error." }
{ $error-description "Thrown by the parser if an unmatched closing delimiter is encountered." }
{ $examples
    "Parsing the following snippet will throw this error:"
    { $code "[ 1 2 3 }" }
} ;

HELP: unexpected-eof
{ $values { "word" "a " { $link word } } }
{ $description "Throws an " { $link unexpected } " error indicating the parser was looking for an occurrence of " { $snippet "word" } " but encountered end of file." } ;

HELP: with-lexer
{ $values { "lexer" lexer } { "quot" quotation } { "newquot" quotation } }
{ $description "Calls the quotation with the " { $link lexer } " variable set to the given lexer. The quotation can make use of words such as " { $link scan } ". Any errors thrown by the quotation are wrapped in " { $link lexer-error } " instances." } ;

HELP: lexer-factory
{ $var-description "A variable holding a quotation with stack effect " { $snippet "( lines -- lexer )" } ". This quotation is called by the parser to create " { $link lexer } " instances. This variable can be rebound to a quotation which outputs a custom tuple delegating to " { $link lexer } " to customize syntax." } ;


ARTICLE: "parser-lexer" "The lexer"
"A variable that encapsulate internal parser state:"
{ $subsection lexer }
"Creating a default lexer:"
{ $subsection <lexer> }
"A word to test of the end of input has been reached:"
{ $subsection still-parsing? }
"A word to advance the lexer to the next line:"
{ $subsection next-line }
"Two generic words to override the lexer's token boundary detection:"
{ $subsection skip-blank }
{ $subsection skip-word }
"Utility combinator:"
{ $subsection with-lexer } ;
