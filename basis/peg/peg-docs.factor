! Copyright (C) 2007 Chris Double.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel math quotations sequences
strings words ;
IN: peg

HELP: parse
{ $values
  { "input" string }
  { "parser" parser }
  { "ast" object }
}
{ $description
    "Given the input string, parse it using the given parser. The result is the abstract "
    "syntax tree returned by the parser." } ;

HELP: parse-fully
{ $values
  { "input" string }
  { "parser" parser }
  { "ast" object }
}
{ $description
    "Given the input string, parse it using the given parser. The result is the abstract "
    "syntax tree returned by the parser. Throws an exception if the input is not fully consumed." } ;

{ parse parse-fully } related-words

HELP: token
{ $values
  { "string" string }
  { "parser" parser }
}
{ $description
    "Returns a parser that matches the given string." } ;

HELP: satisfy
{ $values
  { "quot" quotation }
  { "parser" parser }
}
{ $description
    "Returns a parser that calls the quotation on the first character of the input string, "
    "succeeding if that quotation returns true. The AST is the character from the string." } ;

HELP: range
{ $values
  { "min" "a character" }
  { "max" "a character" }
  { "parser" parser }
}
{ $description
    "Returns a parser that matches a single character that lies within the range of characters given, inclusive." }
{ $examples { $code ": digit ( -- parser ) CHAR: 0 CHAR: 9 range ;" } } ;

HELP: seq
{ $values
  { "seq" "a sequence of parsers" }
  { "parser" parser }
}
{ $description
    "Returns a parser that calls all parsers in the given sequence, in order. The parser succeeds if "
    "all the parsers succeed, otherwise it fails. The AST produced is a sequence of the AST produced by "
    "the individual parsers." } ;

HELP: choice
{ $values
  { "seq" "a sequence of parsers" }
  { "parser" parser }
}
{ $description
    "Returns a parser that will try all the parsers in the sequence, in order, until one succeeds. "
    "The resulting AST is that produced by the successful parser." } ;

HELP: repeat0
{ $values
  { "parser" parser }
}
{ $description
    "Returns a parser that parses 0 or more instances of the " { $snippet "parser" } ". The AST produced is "
    "an array of the AST produced by the " { $snippet "parser" } ". An empty array indicates 0 instances were "
    "parsed." } ;

HELP: repeat1
{ $values
  { "parser" parser }
}
{ $description
    "Returns a parser that parses 1 or more instances of the " { $snippet "parser" } ". The AST produced is "
    "an array of the AST produced by the " { $snippet "parser" } "." } ;

HELP: optional
{ $values
  { "parser" parser }
}
{ $description
    "Returns a parser that parses 0 or 1 instances of the " { $snippet "parser" } ". The AST produced is "
    { $link f } " if 0 instances are parsed, otherwise it is the AST produced by " { $snippet "parser" } "." } ;

HELP: semantic
{ $values
  { "parser" parser }
  { "quot" { $quotation ( object -- ? ) } }
}
{ $description
    "Returns a parser that succeeds if the " { $snippet "parser" } " succeeds and the quotation called with "
    "the AST produced by " { $snippet "parser" } " on the stack returns true." }
{ $examples
  { $example "USING: kernel math peg prettyprint ;" "\"C\" [ drop t ] satisfy [ 66 > ] semantic parse ." "67" }
} ;

HELP: ensure
{ $values
  { "parser" parser }
}
{ $description
    "Returns a parser that succeeds if the " { $snippet "parser" } " succeeds but does not add anything to the "
    "AST and does not move the location in the input string. This can be used for lookahead and "
    "disambiguation, along with the " { $link ensure-not } " word." }
{ $examples { $code "\"0\" token ensure octal-parser" } } ;

HELP: ensure-not
{ $values
  { "parser" parser }
}
{ $description
    "Returns a parser that succeeds if the " { $snippet "parser" } " fails but does not add anything to the "
    "AST and does not move the location in the input string. This can be used for lookahead and "
    "disambiguation, along with the " { $link ensure } " word." }
{ $code "\"+\" token \"=\" token ensure-not \"+=\" token 3array seq" } ;

HELP: action
{ $values
  { "parser" parser }
  { "quot" { $quotation ( ast -- ast ) } }
}
{ $description
    "Returns a parser that calls the " { $snippet "parser" } " and applies the quotation to the AST resulting "
    "from that parse. The result of the quotation is then used as the final AST. This can be used "
    "for manipulating the parse tree to produce a AST better suited for the task at hand rather than "
    "the default AST. If the quotation returns " { $link fail } " then the parser fails." }
{ $code "CHAR: 0 CHAR: 9 range [ to-digit ] action" } ;

HELP: sp
{ $values
  { "parser" parser }
}
{ $description
    "Returns a parser that calls the original " { $snippet "parser" } " after stripping any whitespace "
    " from the left of the input string." } ;

HELP: hide
{ $values
  { "parser" parser }
}
{ $description
    "Returns a parser that succeeds if the original parser succeeds, but does not "
    "put any result in the AST. Useful for ignoring 'syntax' in the AST." }
{ $code "\"[\" token hide number \"]\" token hide 3array seq" } ;

HELP: delay
{ $values
  { "quot" quotation }
  { "parser" parser }
}
{ $description
    "Delays the construction of a parser until it is actually required to parse. This "
    "allows for calling a parser that results in a recursive call to itself. The quotation "
    "should return the constructed parser and is called the first time the parser is run. "
    "The compiled result is memoized for future runs. See " { $link box } " for a word "
    "that calls the quotation at compile time." } ;

HELP: box
{ $values
  { "quot" quotation }
  { "parser" parser }
}
{ $description
    "Delays the construction of a parser until the parser is compiled. The quotation "
    "should return the constructed parser and is called when the parser is compiled. "
    "The compiled result is memoized for future runs. See " { $link delay } " for a word "
    "that calls the quotation at runtime." } ;

HELP: PARTIAL-PEG:
{ $syntax "PARTIAL-PEG: word ( stack -- effect ) definition... ;" }
{ $description "Defines a word that when called will " { $link parse }
    " a string using the syntax defined by the parser created by the definition."
    "The definition should have stack effect " { $snippet "( -- parser )" }
    " and the created word " { $snippet "( string -- ast )" }
    ". The parser is compiled when first used and then reused for each "
    "subsequent invocation." }
{ $notes "If the parsing fails, the word throws an exception." } ;

HELP: PEG:
{ $syntax "PEG: word ( stack -- effect ) definition... ;" }
{ $description "Defines a word that when called will " { $link parse-fully }
    " a string using the syntax defined by the parser created by the definition."
    "The definition should have stack effect " { $snippet "( -- parser )" }
    " and the created word " { $snippet "( string -- ast )" }
    ". The parser is compiled when first used and then reused for each "
    "subsequent invocation." }
{ $notes "If the parsing fails, the word throws an exception."
    " If the input is not fully consumed, the word throws an exception." } ;

{ POSTPONE: PARTIAL-PEG: POSTPONE: PEG: } related-words
