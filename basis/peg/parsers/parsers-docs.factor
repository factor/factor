! Copyright (C) 2008 Chris Double, Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel math sequences
unicode strings ;
IN: peg.parsers

HELP: 1token
{ $values
    { "ch" "a character" }
    { "parser" "a parser" }
} { $description
    "Calls 1string on a character and returns a parser that matches that character."
} { $examples
    { $example "USING: peg peg.parsers prettyprint ;" "\"a\" CHAR: a 1token parse ." "\"a\"" }
} { $see-also string-parser } ;

HELP: (list-of)
{ $values
    { "items" sequence }
    { "separator" "a parser" }
    { "repeat1?" boolean }
    { "parser" "a parser" }
} { $description
    "Returns a parser that returns a list of items separated by the separator parser. Does not hide the separators."
} { $see-also list-of list-of-many } ;

HELP: list-of
{ $values
    { "items" sequence }
    { "separator" "a parser" }
    { "parser" "a parser" }
} { $description
    "Returns a parser that returns a list of items separated by the separator parser. Hides the separators and matches a list of one or more items."
} { $notes "Use " { $link list-of-many } " to ensure a list contains two or more items." }
{ $examples
    { $example "USING: peg peg.parsers prettyprint ;" "\"a\" \"a\" token \",\" token list-of parse ." "V{ \"a\" }" }
    { $example "USING: peg peg.parsers prettyprint ;" "\"a,a,a,a\" \"a\" token \",\" token list-of parse ." "V{ \"a\" \"a\" \"a\" \"a\" }" }
} { $see-also list-of-many } ;

HELP: list-of-many
{ $values
    { "items" sequence }
    { "separator" "a parser" }
    { "parser" "a parser" }
} { $description
    "Returns a parser that returns a list of items separated by the separator parser. Hides the separators and matches a list of two or more items."
} { $notes "Use " { $link list-of } " to return a list of only one item."
} { $examples
    { $code "USING: peg peg.parsers prettyprint ;" "\"a\" \"a\" token \",\" token list-of-many parse => exception" }
    { $example "USING: peg peg.parsers prettyprint ;" "\"a,a,a,a\" \"a\" token \",\" token list-of-many parse ." "V{ \"a\" \"a\" \"a\" \"a\" }" }
} { $see-also list-of } ;

HELP: epsilon
{ $values
    { "parser" "a parser" }
} { $description
    "Returns a parser that matches the empty sequence."
} ;

HELP: any-char
{ $values
    { "parser" "a parser" }
} { $description
    "Returns a parser that matches any single character."
} ;

HELP: exactly-n
{ $values
    { "parser" "a parser" }
    { "n" integer }
    { "parser'" "a parser" }
} { $description
    "Returns a parser that matches an exact repetition of the input parser."
} { $examples
    { $code "USING: peg peg.parsers prettyprint ;" "\"aaa\" \"a\" token 4 exactly-n parse => exception" }
    { $example "USING: peg peg.parsers prettyprint ;" "\"aaaa\" \"a\" token 4 exactly-n parse ." "V{ \"a\" \"a\" \"a\" \"a\" }" }
} { $see-also at-least-n at-most-n from-m-to-n } ;

HELP: at-least-n
{ $values
    { "parser" "a parser" }
    { "n" integer }
    { "parser'" "a parser" }
} { $description
    "Returns a parser that matches n or more repetitions of the input parser."
} { $examples
    { $code "USING: peg peg.parsers prettyprint ;" "\"aaa\" \"a\" token 4 at-least-n parse => exception" }
    { $example "USING: peg peg.parsers prettyprint ;" "\"aaaa\" \"a\" token 4 at-least-n parse ." "V{ \"a\" \"a\" \"a\" \"a\" }" }
    { $example "USING: peg peg.parsers prettyprint ;" "\"aaaaa\" \"a\" token 4 at-least-n parse ." "V{ \"a\" \"a\" \"a\" \"a\" \"a\" }" }
} { $see-also exactly-n at-most-n from-m-to-n } ;

HELP: at-most-n
{ $values
    { "parser" "a parser" }
    { "n" integer }
    { "parser'" "a parser" }
} { $description
    "Returns a parser that matches n or fewer repetitions of the input parser."
} { $examples
    { $example "USING: peg peg.parsers prettyprint ;" "\"aaaa\" \"a\" token 4 at-most-n parse ." "V{ \"a\" \"a\" \"a\" \"a\" }" }
    { $example "USING: peg peg.parsers prettyprint ;" "\"aaaaa\" \"a\" token 4 at-most-n parse ." "V{ \"a\" \"a\" \"a\" \"a\" }" }
} { $see-also exactly-n at-least-n from-m-to-n } ;

HELP: from-m-to-n
{ $values
    { "parser" "a parser" }
    { "m" integer }
    { "n" integer }
    { "parser'" "a parser" }
} { $description
    "Returns a parser that matches between and including m to n repetitions of the input parser."
} { $examples
    { $example "USING: peg peg.parsers prettyprint ;" "\"aaa\" \"a\" token 3 4 from-m-to-n parse ." "V{ \"a\" \"a\" \"a\" }" }
    { $example "USING: peg peg.parsers prettyprint ;" "\"aaaa\" \"a\" token 3 4 from-m-to-n parse ." "V{ \"a\" \"a\" \"a\" \"a\" }" }
    { $example "USING: peg peg.parsers prettyprint ;" "\"aaaaa\" \"a\" token 3 4 from-m-to-n parse ." "V{ \"a\" \"a\" \"a\" \"a\" }" }
} { $see-also exactly-n at-most-n at-least-n } ;

HELP: pack
{ $values
    { "begin" "a parser" }
    { "body" "a parser" }
    { "end" "a parser" }
    { "parser" "a parser" }
} { $description
    "Returns a parser that parses the begin, body, and end parsers in order. The begin and end parsers are hidden."
} { $examples
    { $example "USING: peg peg.parsers prettyprint ;" "\"hi123bye\" \"hi\" token integer-parser \"bye\" token pack parse ." "123" }
} { $see-also surrounded-by } ;

HELP: surrounded-by
{ $values
    { "parser" "a parser" }
    { "begin" string }
    { "end" string }
    { "parser'" "a parser" }
} { $description
    "Calls token on begin and end to make them into string parsers. Returns a parser that parses the begin, body, and end parsers in order. The begin and end parsers are hidden."
} { $examples
    { $example "USING: peg peg.parsers prettyprint ;" "\"hi123bye\" integer-parser \"hi\" \"bye\" surrounded-by parse ." "123" }
} { $see-also pack } ;

HELP: digit-parser
{ $values
    { "parser" "a parser" }
} { $description
    "Returns a parser that matches a single digit as defined by the " { $link digit? } " word."
} { $see-also integer-parser } ;

HELP: integer-parser
{ $values
    { "parser" "a parser" }
} { $description
    "Returns a parser that matches an integer composed of digits, as defined by the " { $link digit-parser } " word."
} { $see-also digit-parser string-parser } ;

HELP: string-parser
{ $values
    { "parser" "a parser" }
} { $description
    "Returns a parser that matches an string composed of a \", anything that is not \", and another \"."
} { $see-also integer-parser } ;

HELP: range-pattern
{ $values
    { "pattern" string }
    { "parser" "a parser" }
} { $description
"Returns a parser that matches a single character based on the set "
"of characters in the pattern string. "
"Any single character in the pattern matches that character. "
"If the pattern begins with a ^ then the set is negated "
"(the element matches any character not in the set). Any pair "
"of characters separated with a dash (-) represents the "
"range of characters from the first to the second, inclusive."
{ $examples
    { $example "USING: peg peg.parsers prettyprint strings ;" "\"a\" \"_a-zA-Z\" range-pattern parse 1string ." "\"a\"" }
    { $code "USING: peg peg.parsers prettyprint ;\n\"0\" \"^0-9\" range-pattern parse => exception" }
}
} ;
