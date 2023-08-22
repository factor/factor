! Copyright (C) 2009 Chris Double.
! See https://factorcode.org/license.txt for BSD license.
USING: help.syntax help.markup peg peg.search words
multiline ;
IN: peg.ebnf

HELP: EBNF[[
{ $syntax "EBNF[[ ...ebnf... ]]" }
{ $values { "...ebnf..." "EBNF DSL text" } }
{ $description
    "Creates and calls a quotation that parses a string using the syntax "
    "defined with the EBNF DSL. The quotation has stack effect "
    { $snippet "( string -- ast )" } " where 'string' is the text to be parsed "
    "and 'ast' is the resulting abstract syntax tree. If the parsing fails the "
    "quotation throws an exception."
}
{ $examples
    { $example
       "USING: multiline prettyprint peg.ebnf ;"
       "\"ab\" EBNF[[ rule=\"a\" \"b\" ]] ."
       "V{ \"a\" \"b\" }"
    }
} ;

HELP: EBNF-PARSER:
{ $syntax "EBNF-PARSER: word \"...ebnf...\"" }
{ $description
    "Defines a word that when called will return a parser for the "
    "syntax defined with the EBNF DSL. The parser can be used with "
    "the " { $vocab-link "peg.search" } " vocab."
} ;

HELP: EBNF:
{ $syntax "EBNF: word [=[ ...ebnf... ]=]" }
{ $values { "word" word } { "...ebnf..." "EBNF DSL text" } }
{ $description
    "Defines a word that when called will parse a string using the syntax "
    "defined with the EBNF DSL. The word has stack effect "
    { $snippet "( string -- ast )" } " where 'string' is the text to be parsed "
    "and 'ast' is the resulting abstract syntax tree. If the parsing fails the "
    "word throws an exception."
}
{ $examples
    { $example
       "USING: prettyprint multiline peg.ebnf ;"
       "IN: scratchpad"
       "EBNF: foo [=[ rule=\"a\" \"b\" ]=]"
       "\"ab\" foo ."
       "V{ \"a\" \"b\" }"
    }
} ;

ARTICLE: "peg.ebnf.strings" "EBNF Rule: Strings"
"A string in a rule will match that sequence of characters from the input string. "
"The string is delimited by matching single or double quotes. "
"Factor's escape sequences are interpreted: " { $link "escape" } ". "
"For double quotes delimiters, an escaped double quote doesn't terminate the string. "
"The AST result from the match is the string itself."
{ $examples
    { $example
       "USING: prettyprint peg.ebnf ;"
       "\"helloworld\" EBNF[[ rule=\"hello\" \"world\" ]] ."
       "V{ \"hello\" \"world\" }"
    }
    { $example
       "USING: prettyprint peg.ebnf ;"
       "\"AΣ𝄞\" EBNF[[ rule='\\x41' '\\u{greek-capital-letter-sigma}' '\\u01D11E' ]] ."
       "V{ \"A\" \"Σ\" \"𝄞\" }"
    }
    { $example
       "USING: io peg.ebnf ;"
       "\"A double quote: \\\"\" EBNF[[ rule='A double quote: \"' ]] print"
       "A double quote: \""
    }
    { $example
       "USING: io peg.ebnf ;"
       "\"' and \\\"\" EBNF[[ rule=\"' and \\\"\" ]] print"
       "' and \""
    }
} ;

ARTICLE: "peg.ebnf.any" "EBNF Rule: Any"
"A full stop character (.) will match any single token in the input string. "
"The AST resulting from this is the token itself."
{ $examples
    { $example
       "USING: prettyprint peg.ebnf ;"
       "\"abc\" EBNF[[ rule=\"a\" . \"c\" ]] ."
       "V{ \"a\" 98 \"c\" }"
    }
} ;

ARTICLE: "peg.ebnf.sequence" "EBNF Rule: Sequence"
"Any white space separated rule element is considered a sequence. Each rule "
"in the sequence is matched from the input stream, consuming the input as it "
"goes. The AST result is a vector containing the results of each rule element in "
"the sequence."
{ $examples
    { $example
       "USING: prettyprint peg.ebnf ;"
       "\"abbba\" EBNF[[ rule=\"a\" (\"b\")* \"a\" ]] ."
       "V{ \"a\" V{ \"b\" \"b\" \"b\" } \"a\" }"
    }
}
;

ARTICLE: "peg.ebnf.grouping" "EBNF Rule: Group"
"Any sequence of rules may be grouped using parentheses (" { $snippet "()" } "). "
"The parenthesized sequence can then be modified as a group. Parentheses also "
"delimit sets of choices separated by pipe (|) characters."
$nl
"A group can also be delimited with curly braces (" { $snippet "{}" } "), in "
"which case an implicit optional whitespace-matching rule will be inserted between "
"rules sequenced within the braces."
{ $examples
    { $example
       "USING: prettyprint peg.ebnf ;"
       "\"abcca\" EBNF[[ rule=\"a\" (\"b\" | \"c\")* \"a\" ]] ."
       "V{ \"a\" V{ \"b\" \"c\" \"c\" } \"a\" }"
    }
    { $example
       "USING: prettyprint peg.ebnf ;"
       "\"ab  c\nd \" EBNF[[ rule={\"a\" \"b\" \"c\" \"d\"} ]] ."
       "V{ \"a\" \"b\" \"c\" \"d\" }"
    }
}
;

ARTICLE: "peg.ebnf.choice" "EBNF Rule: Choice"
"Any rule element separated by a pipe character (|) is considered a " { $strong "choice" } ". Choices "
"are matched against the input stream in order. If a match succeeds then the remaining "
"choices are discarded and the result of the match is the AST result of the choice."
{ $examples
    { $example
       "USING: prettyprint peg.ebnf ;"
       "\"a\" EBNF[[ rule=\"a\" | \"b\" | \"c\" ]] ."
       "\"a\""
    }
    { $example
       "USING: prettyprint peg.ebnf ;"
       "\"b\" EBNF[[ rule=\"a\" | \"b\" | \"c\" ]] ."
       "\"b\""
    }
    { $example
       "USING: prettyprint peg.ebnf ;"
       "\"d\" EBNF[[ rule=\"a\" | \"b\" | \"c\" ]] ."
       "Peg parsing error at character position 0.\nExpected 'a' or 'b' or 'c'\nGot 'd'"
    }
}
{ $notes "Due to parser caching, rules can't re-use parsers that have already failed earlier in the choice." }
;

ARTICLE: "peg.ebnf.ignore" "EBNF Rule: Ignore"
"Any rule element followed by a tilde (~) will be matched, and its results "
"discarded from the AST."
{ $examples
    { $example
       "USING: prettyprint peg.ebnf ;"
       "\"abc\" EBNF[[ rule=\"a\" \"b\"~ \"c\" ]] ."
       "V{ \"a\" \"c\" }"
    }
}
;

ARTICLE: "peg.ebnf.option" "EBNF Rule: Option"
"Any rule element followed by a question mark (?) is considered optional. The "
"rule is tested against the input. If it succeeds the result is stored in the AST. "
"If it fails then the parse still succeeds and false (f) is stored in the AST."
{ $examples
    { $example
       "USING: prettyprint peg.ebnf ;"
       "\"abc\" EBNF[[ rule=\"a\" \"b\"? \"c\" ]] ."
       "V{ \"a\" \"b\" \"c\" }"
    }
    { $example
       "USING: prettyprint peg.ebnf ;"
       "\"ac\" EBNF[[ rule=\"a\" \"b\"? \"c\" ]] ."
       "V{ \"a\" f \"c\" }"
    }
}
;

ARTICLE: "peg.ebnf.character-class" "EBNF Rule: Character Class"
"Character class matching can be done using a range of characters defined in "
"square brackets. Multiple ranges can be included in a single character class "
"definition. The syntax for the range is a start character, followed by a minus "
"(-) followed by an end character. For example " { $snippet "[a-zA-Z]" } ". "
"To include the minus (-) character in the class, make it the first or the last one: " { $snippet "[-0-9]" } " or " { $snippet "[a-z-]" } ". "
"The AST resulting from the match is an integer of the character code for the "
"character that matched."
{ $examples
    { $example
       "USING: prettyprint peg.ebnf ;"
       "\"123\" EBNF[[ rule=[0-9]+ ]] ."
       "V{ 49 50 51 }"
    }
}
;

ARTICLE: "peg.ebnf.one-or-more" "EBNF Rule: One or more"
"Any rule element followed by a plus (+) matches one or more instances of the rule "
"from the input string. The AST result is the vector of the AST results from "
"the matched rule."
{ $examples
    { $example
       "USING: prettyprint peg.ebnf ;"
       "\"aab\" EBNF[[ rule=\"a\"+ \"b\" ]] ."
       "V{ V{ \"a\" \"a\" } \"b\" }"
    }
}
;

ARTICLE: "peg.ebnf.zero-or-more" "EBNF Rule: Zero or more"
"Any rule element followed by an asterisk (*) matches zero or more instances of the rule "
"from the input string. The AST result is the vector of the AST results from "
"the matched rule. This will be empty if there are no matches."
{ $examples
    { $example
       "USING: prettyprint peg.ebnf ;"
       "\"aab\" EBNF[[ rule=\"a\"* \"b\" ]] ."
       "V{ V{ \"a\" \"a\" } \"b\" }"
    }
    { $example
       "USING: prettyprint peg.ebnf ;"
       "\"b\" EBNF[[ rule=\"a\"* \"b\" ]] ."
       "V{ V{ } \"b\" }"
    }
}
;

ARTICLE: "peg.ebnf.and" "EBNF Rule: And"
"Any rule element prefixed by an ampersand (&) performs the Parsing Expression "
"Grammar 'And Predicate' match. It attempts to match the rule against the input "
"string. It will cause the parse to succeed or fail depending on if the rule "
"succeeds or fails. It will not consume anything from the input string however and "
"does not leave any result in the AST. This can be used for lookahead and "
"disambiguation in choices."
{ $examples
    { $example
       "USING: prettyprint peg.ebnf ;"
       "\"ab\" EBNF[[ rule=&(\"a\") \"a\" \"b\" ]] ."
       "V{ \"a\" \"b\" }"
    }
}
;

ARTICLE: "peg.ebnf.not" "EBNF Rule: Not"
"Any rule element prefixed by an exclamation mark (!) performs the Parsing Expression "
"Grammar 'Not Predicate' match. It attempts to match the rule against the input "
"string. It will cause the parse to succeed if the rule match fails, and to fail "
"if the rule match succeeds. It will not consume anything from the input string "
"however and does not leave any result in the AST. This can be used for lookahead and "
"disambiguation in choices."
{ $examples
    { $example
       "USING: prettyprint peg.ebnf ;"
       "\"<abcd>\" EBNF[[ rule=\"<\" (!(\">\") .)* \">\" ]] ."
       "V{ \"<\" V{ 97 98 99 100 } \">\" }"
    }
}
;

ARTICLE: "peg.ebnf.action" "EBNF Action"
"An action is a quotation that is run after a rule matches. The quotation "
"consumes the AST of the rule match and leaves a new AST as the result. "
"The stack effect of the action can be " { $snippet "( ast -- ast )" } " or "
{ $snippet "( -- ast )" } ". "
"If it is the latter then the original AST is implicitly dropped and will be "
"replaced by the AST left on the stack. This is mostly useful if variables are "
"used in the rule since they can be referenced like locals in the action quotation. "
"The action is defined by having a ' => ' at the end of a rule and "
"using '[[' and ']]' to open and close the quotation. "
"If an action leaves the object 'ignore' on the stack then the result of that "
"action will not be put in the AST of the result."
{ $examples
    { $example
       "USING: prettyprint peg.ebnf strings ;"
       "\"<abcd>\" EBNF[=[ rule=\"<\" ((!(\">\") .)* => [[ >string ]]) \">\" ]=] ."
       "V{ \"<\" \"abcd\" \">\" }"
    }
    { $example
       "USING: prettyprint peg.ebnf math.parser ;"
       "\"123\" EBNF[=[ rule=[0-9]+ => [[ string>number ]] ]=] ."
       "123"
    }
}
;

ARTICLE: "peg.ebnf.semantic-action" "EBNF Semantic Action"
"Semantic actions allow providing a quotation that gets run on the AST of a "
"matched rule that returns success or failure. The result of the parse is decided by "
"the result of the semantic action. The stack effect for the quotation is "
{ $snippet "( ast -- ? )" } ". "
"A semantic action follows the rule it applies to and is delimited by '?[' and ']?'."
{ $examples
    { $example
       "USING: prettyprint peg.ebnf math math.parser ;"
       "\"1\" EBNF[[ rule=[0-9] ?[ digit> odd? ]? ]] ."
       "49"
    }
    { $example
       "USING: prettyprint peg.ebnf math math.parser ;"
       "\"2\" EBNF[[ rule=[0-9] ?[ digit> odd? ]? ]] ."
       "Peg parsing error at character position 0.\nExpected \nGot '2'"
    }
}
;

ARTICLE: "peg.ebnf.variable" "EBNF Variable"
"Variables names can be suffixed to a rule element using the colon character (:) "
"followed by the variable name. These can then be used in rule actions to refer to "
"the AST result of the rule element with that variable name."
{ $examples
    { $example
       "USING: prettyprint peg.ebnf math.parser ;"
       "\"1+2\" EBNF[=[ rule=[0-9]:a \"+\" [0-9]:b => [[ a digit> b digit> + ]] ]=] ."
       "3"
    }
}
;

ARTICLE: "peg.ebnf.foreign-rules" "EBNF Foreign Rules"
"Rules can call out to other " { $vocab-link "peg.ebnf" } " defined parsers. The result of "
"the foreign call then becomes the AST of the successful parse. Foreign rules "
"are invoked using '<foreign word-name>' or '<foreign word-name rule>'. The "
"latter allows calling a specific rule in a previously designed peg.ebnf parser. "
"If the 'word-name' is not the name of a peg.ebnf defined parser then it must be "
"a word with stack effect " { $snippet "( -- parser )" } ". It must return a "
{ $vocab-link "peg" } " defined parser and it will be called to perform the parse "
"for that rule."
{ $examples
    { $code
       "USING: prettyprint peg.ebnf ;"
       "EBNF: parse-string [=["
       "StringBody = (!('\"') .)*"
       "String= '\"' StringBody:b '\"' => [[ b >string ]]"
       "]=]"
       "EBNF: parse-two-strings [=["
       "TwoStrings = <foreign parse-string String> <foreign parse-string String>"
       "]=]"
       "EBNF: parse-two-strings [=["
       "TwoString = <foreign parse-string> <foreign parse-string>"
       "]=]"
    }
    { $code
       ": a-token ( -- parser ) \"a\" token ;"
       "EBNF: parse-abc [=["
       "abc = <foreign a-token> 'b' 'c'"
       "]=]"
    }
} ;

ARTICLE: "peg.ebnf.tokenizers" "EBNF Tokenizers"
"It is possible to override the tokenizer in an EBNF defined parser. "
"Usually the input sequence to be parsed is an array of characters or a string. "
"Terminals in a rule match successive characters in the array or string."
{ $examples
    { $code
        "USING: multiline ;"
        "EBNF: foo [=["
        "rule = \"++\" \"--\""
        "]=]"
    }
}
"This parser when run with the string \"++--\" or the array "
"{ CHAR: + CHAR: + CHAR: - CHAR: - } will succeed with an AST of { \"++\" \"--\" }. "
"If you want to add whitespace handling to the grammar you need to put it "
"between the terminals:"
{ $examples
    { $code
        "USING: multiline ;"
        "EBNF: foo [=["
        "space = (\" \" | \"\\r\" | \"\\t\" | \"\\n\")"
        "spaces = space* => [[ drop ignore ]]"
        "rule = spaces \"++\" spaces \"--\" spaces"
        "]=]"
    }
}
"In a large grammar this gets tedious and makes the grammar hard to read. "
"Instead you can write a rule to split the input sequence into tokens, and "
"have the grammar operate on these tokens. This is how the previous example "
"might look:"
{ $examples
    { $code
        "USING: multiline ;"
        "EBNF: foo [=["
        "space = (\" \" | \"\\r\" | \"\\t\" | \"\\n\")"
        "spaces = space* => [[ drop ignore ]]"
        "tokenizer = spaces ( \"++\" | \"--\" )"
        "rule = \"++\" \"--\""
        "]=]"
     }
}
"'tokenizer' is the name of a built in rule. Once defined it is called to "
"retrieve the next complete token from the input sequence. So the first part "
"of 'rule' is to try and match \"++\". It calls the tokenizer to get the next "
"complete token. This ignores spaces until it finds a \"++\" or \"--\". "
"It is as if the input sequence for the parser was actually { \"++\" \"--\" } "
"instead of the string \"++--\". With the new tokenizer \"....\" sequences "
"in the grammar are matched for equality against the token, rather than a "
"string comparison against successive items in the sequence. This can be used "
"to match an AST from a tokenizer."
$nl
"In this example I split the tokenizer into a separate parser and use "
"'foreign' to call it from the main one. This allows testing of the "
"tokenizer separately:"
{ $examples
    { $example
        "USING: prettyprint peg peg.ebnf kernel math.parser strings"
        "accessors math arrays multiline ;"
        "IN: scratchpad"
        ""
        "TUPLE: ast-number value ;"
        "TUPLE: ast-string value ;"
        ""
        "EBNF: foo-tokenizer [=["
        "space = (\" \" | \"\\r\" | \"\\t\" | \"\\n\")"
        "spaces = space* => [[ drop ignore ]]"
        ""
        "number = [0-9]+ => [[ >string string>number ast-number boa ]]"
        "operator = (\"+\" | \"-\")"
        ""
        "token = spaces ( number | operator )"
        "tokens = token*"
        "]=]"
        ""
        "EBNF: foo [=["
        "tokenizer = <foreign foo-tokenizer token>"
        ""
        "number = . ?[ ast-number? ]? => [[ value>> ]]"
        "string = . ?[ ast-string? ]? => [[ value>> ]]"
        ""
        "rule = string:a number:b \"+\" number:c => [[ a b c + 2array ]]"
        "]=]"
        ""
        "\"123 456 +\" foo-tokenizer ."
        "V{\n    T{ ast-number { value 123 } }\n    T{ ast-number { value 456 } }\n    \"+\"\n}"
    }
}
"The '.' EBNF production means match a single object in the source sequence. "
"Usually this is a character. With the replacement tokenizer it is either a "
"number object, a string object or a string containing the operator. "
"Using a tokenizer in language grammars makes it easier to deal with whitespace. "
"Defining tokenizers in this way has the advantage of the tokenizer and parser "
"working in one pass. There is no tokenization occurring over the whole string "
"followed by the parse of that result. It tokenizes as it needs to. You can even "
"switch tokenizers multiple times during a grammar. Rules use the tokenizer that "
"was defined lexically before the rule. This is useful in the JavaScript grammar:"
{ $examples
    { $code
        "USING: multiline ;"
        "EBNF: javascript [=["
        "tokenizer         = default"
        "nl                = \"\\r\" \"\\n\" | \"\\n\""
        "tokenizer         = <foreign tokenize-javascript Tok>"
        "..."
        "End                = !(.)"
        "Name               = . ?[ ast-name?   ]?   => [[ value>> ]] "
        "Number             = . ?[ ast-number? ]?   => [[ value>> ]]"
        "String             = . ?[ ast-string? ]?   => [[ value>> ]]"
        "RegExp             = . ?[ ast-regexp? ]?   => [[ value>> ]]"
        "SpacesNoNl         = (!(nl) Space)* => [[ ignore ]]"
        "Sc                 = SpacesNoNl (nl | &(\"}\") | End)| \";\""
        "]=]"
    }
}
"Here the rule 'nl' is defined using the default tokenizer of sequential "
"characters ('default' has the special meaning of the built in tokenizer). "
"This is followed by using the JavaScript tokenizer for the remaining rules. "
"This tokenizer strips out whitespace and newlines. Some rules in the grammar "
"require checking for a newline. In particular the automatic semicolon insertion "
"rule (managed by the 'Sc' rule here). If there is a newline, the semicolon can "
"be optional in places."
{ $examples
    { $code
      "\"do\" Stmt:s \"while\" \"(\" Expr:c \")\" Sc    => [[ s c ast-do-while boa ]]"
    }
}
"Even though the JavaScript tokenizer has removed the newlines, the 'nl' rule can "
"be used to detect them since it is using the default tokenizer. This allows "
"grammars to mix and match the tokenizer as required to make them more readable."
;

ARTICLE: "peg.ebnf" "EBNF"
"The " { $vocab-link "peg.ebnf" } " vocabulary provides a DSL that allows writing PEG parsers that look like "
"EBNF syntax. It provides three parsing words described below. These words all "
"accept the same EBNF syntax. The difference is in how they are used."
{ $subsections
    POSTPONE: EBNF:
    POSTPONE: EBNF[[
    POSTPONE: EBNF[=[
    POSTPONE: EBNF[==[
    POSTPONE: EBNF[===[
    POSTPONE: EBNF[====[
}
"The EBNF syntax is composed of a series of rules of the form:"
{ $code
  "rule1 = ..."
  "rule2 = ..."
}
"The last defined rule is the main rule for the EBNF. It is the first one run "
"and it is expected that the remaining rules are used by that rule. Rules may be "
"left recursive. "
"Each rule can contain the following:"
{ $subsections "peg.ebnf.strings"
"peg.ebnf.any"
"peg.ebnf.sequence"
"peg.ebnf.grouping"
"peg.ebnf.choice"
"peg.ebnf.ignore"
"peg.ebnf.option"
"peg.ebnf.one-or-more"
"peg.ebnf.zero-or-more"
"peg.ebnf.and"
"peg.ebnf.not"
"peg.ebnf.character-class"
"peg.ebnf.foreign-rules"
"peg.ebnf.action"
"peg.ebnf.semantic-action"
"peg.ebnf.variable" }
"Grammars defined in EBNF need to handle each character, or sequence of "
"characters in the input. This can be tedious for dealing with whitespace in "
"grammars that have 'tokens' separated by whitespace. You can define your "
"own tokenizer that for an EBNF grammar, and write the grammar in terms of "
"those tokens, allowing you to ignore the whitespace issue. The tokenizer "
"can be changed at various parts in the grammar as needed. The JavaScript grammar "
"does this to define the optional semicolon rule for example."
{ $subsections "peg.ebnf.tokenizers" }
;

ABOUT: "peg.ebnf"
