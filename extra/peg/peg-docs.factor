! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax peg ;

HELP: parse
{ $values 
  { "string" "a string" } 
  { "parse" "a parser" } 
  { "result" "a <parse-result> or f" } 
}
{ $description 
    "Given the input string, parse it using the given parser. The result is a <parse-result> object if "
    "the parse was successful, otherwise it is f." } ;

HELP: token
{ $values 
  { "string" "a string" } 
  { "parser" "a parser" } 
}
{ $description 
    "Returns a parser that matches the given string." } ;

HELP: satisfy
{ $values 
  { "quot" "a quotation" } 
  { "parser" "a parser" } 
}
{ $description 
    "Returns a parser that calls the quotation on the first character of the input string, "
    "succeeding if that quotation returns true. The AST is the character from the string." } ;

HELP: range
{ $values 
  { "min" "a character" } 
  { "max" "a character" } 
  { "parser" "a parser" } 
}
{ $description 
    "Returns a parser that matches a single character that lies within the range of characters given, inclusive." }
{ $example ": digit ( -- parser ) CHAR: 0 CHAR: 9 range ;" } ;

HELP: seq
{ $values 
  { "seq" "a sequence of parsers" } 
  { "parser" "a parser" } 
}
{ $description 
    "Returns a parser that calls all parsers in the given sequence, in order. The parser succeeds if "
    "all the parsers succeed, otherwise it fails. The AST produced is a sequence of the AST produced by "
    "the individual parsers." } ;

HELP: choice
{ $values 
  { "seq" "a sequence of parsers" } 
  { "parser" "a parser" } 
}
{ $description 
    "Returns a parser that will try all the parsers in the sequence, in order, until one succeeds. "
    "The resulting AST is that produced by the successful parser." } ;

HELP: repeat0
{ $values 
  { "p1" "a parser" } 
  { "p2" "a parser" } 
}
{ $description 
    "Returns a parser that parses 0 or more instances of the 'p1' parser. The AST produced is "
    "an array of the AST produced by the 'p1' parser. An empty array indicates 0 instances were "
    "parsed." } ;

HELP: repeat1
{ $values 
  { "p1" "a parser" } 
  { "p2" "a parser" } 
}
{ $description 
    "Returns a parser that parses 1 or more instances of the 'p1' parser. The AST produced is "
    "an array of the AST produced by the 'p1' parser." } ;

HELP: optional
{ $values 
  { "p1" "a parser" } 
  { "p2" "a parser" } 
}
{ $description 
    "Returns a parser that parses 0 or 1 instances of the 'p1' parser. The AST produced is "
    "'f' if 0 instances are parsed the AST produced is 'f', otherwise it is the AST produced by 'p1'." } ;

HELP: ensure
{ $values 
  { "p1" "a parser" } 
  { "p2" "a parser" } 
}
{ $description 
    "Returns a parser that succeeds if the 'p1' parser succeeds but does not add anything to the "
    "AST and does not move the location in the input string. This can be used for lookahead and "
    "disambiguation, along with the " { $link ensure-not } " word." }
{ $example "\"0\" token ensure octal-parser" } ;

HELP: ensure-not
{ $values 
  { "p1" "a parser" } 
  { "p2" "a parser" } 
}
{ $description 
    "Returns a parser that succeeds if the 'p1' parser fails but does not add anything to the "
    "AST and does not move the location in the input string. This can be used for lookahead and "
    "disambiguation, along with the " { $link ensure } " word." }
{ $example "\"+\" token \"=\" token ensure-not \"+=\" token 3array seq" } ;

HELP: action
{ $values 
  { "p1" "a parser" } 
  { "quot" "a quotation with stack effect ( ast -- ast )" } 
}
{ $description 
    "Returns a parser that calls the 'p1' parser and applies the quotation to the AST resulting "
    "from that parse. The result of the quotation is then used as the final AST. This can be used "
    "for manipulating the parse tree to produce a AST better suited for the task at hand rather than "
    "the default AST." }
{ $example "CHAR: 0 CHAR: 9 range [ to-digit ] action" } ;

