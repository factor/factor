! Copyright (C) 2008, 2009 Doug Coleman, Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel strings help.markup help.syntax math regexp.parser
regexp.ast ;
IN: regexp

ABOUT: "regexp"

ARTICLE: "regexp" "Regular expressions"
"The " { $vocab-link "regexp" } " vocabulary provides word for creating and using regular expressions."
{ $subsections "regexp-intro" }
"The class of regular expressions:"
{ $subsections regexp }
"Basic usage:"
{ $subsections
    "regexp-syntax"
    "regexp-options"
    "regexp-construction"
    "regexp-operations"
}
"Advanced topics:"
{ $vocab-subsection "Regular expression combinators" "regexp.combinators" }
{ $subsections
    "regexp-theory"
    "regexp-deploy"
} ;

ARTICLE: "regexp-intro" "A quick introduction to regular expressions"
"Regular expressions are a terse way to do certain simple string processing tasks. For example, to replace all instances of " { $snippet "foo" } " in one string with " { $snippet "bar" } ", the following can be used:"
{ $code "R/ foo/ \"bar\" re-replace" }
"That could be done with sequence operations, but consider doing this replacement for an arbitrary number of o's, at least two:"
{ $code "R/ foo+/ \"bar\" re-replace" }
"The " { $snippet "+" } " operator matches one or more occurrences of the previous expression; in this case " { $snippet "o" } ". Another useful feature is alternation. Say we want to do this replacement with fooooo or boooo. Then we could use the code"
{ $code "R/ (f|b)oo+/ \"bar\" re-replace" }
"To search a file for all lines that match a given regular expression, you could use code like this:"
{ $code "\"file.txt\" ascii file-lines [ R/ (f|b)oo+/ re-contains? ] filter" }
"To test if a string in its entirety matches a regular expression, the following can be used:"
{ $example "USE: regexp \"fooo\" R/ (b|f)oo+/ matches? ." "t" }
"Regular expressions can't be used for all parsing tasks. For example, they are not powerful enough to match balancing parentheses." ;

ARTICLE: "regexp-construction" "Constructing regular expressions"
"Most of the time, regular expressions are literals and the parsing word should be used, to construct them at parse time. This ensures that they are only compiled once, and gives parse time syntax checking."
{ $subsections POSTPONE: R/ }
"Sometimes, regular expressions need to be constructed at run time instead; for example, in a text editor, the user might input a regular expression to search for in a document."
{ $subsections <regexp> <optioned-regexp> }
"Another approach is to use " { $vocab-link "regexp.combinators" } "." ;

ARTICLE: "regexp-syntax" "Regular expression syntax"
"Regexp syntax is largely compatible with Perl, Java and extended POSIX regexps, but not completely. Below, the syntax is documented."
{ $heading "Characters" }
"At its core, regular expressions consist of character literals. For example, " { $snippet "R/ f/" } " is a regular expression matching just the string 'f'. In addition, the normal escape codes are provided, like " { $snippet "\\t" } " for the tab character and " { $snippet "\\uxxxxxx" } " for an arbitrary Unicode code point, by its hex value. In addition, any character can be preceded by a backslash to escape it, unless this has special meaning. For example, to match a literal opening parenthesis, use " { $snippet "\\(" } "."
{ $heading "Concatenation, alternation and grouping" }
"Regular expressions can be built out of multiple characters by concatenation. For example, " { $snippet "R/ ab/" } " matches a followed by b. The " { $snippet "|" } " (alternation) operator can construct a regexp which matches one of two alternatives. Parentheses can be used for grouping. So " { $snippet "R/ f(oo|ar)/" } " would match either 'foo' or 'far'."
{ $heading "Character classes" }
"Square brackets define a convenient way to refer to a set of characters. For example, " { $snippet "[ab]" } " refers to either a or b. And " { $snippet "[a-z]" } " refers to all of the characters between a and z, in code point order. You can use these together, as in " { $snippet "[ac-fz]" } " which matches all of the characters between c and f, in addition to a and z. Character classes can be negated using a caret, as in " { $snippet "[^a]" } " which matches all characters which are not a."
{ $heading "Predefined character classes" }
"Several character classes are predefined, both for convenience and because they are too large to represent directly. In Factor regular expressions, all character classes are Unicode-aware."
{ $table
    { { $snippet "\\d" } "Digits" }
    { { $snippet "\\D" } "Not digits" }
    { { $snippet "\\s" } "Whitespace" }
    { { $snippet "\\S" } "Not whitespace" }
    { { $snippet "\\w" } "Word character (alphanumeric or underscore)" }
    { { $snippet "\\W" } "Not word character" }
    { { $snippet "\\p{property}" } "Character which fulfils the property" }
    { { $snippet "\\P{property}" } "Character which does not fulfil the property" } }
"Properties for " { $snippet "\\p" } " and " { $snippet "\\P" } " (case-insensitive):"
{ $table
    { { $snippet "\\p{lower}" } "Lower case letters" }
    { { $snippet "\\p{upper}" } "Upper case letters" }
    { { $snippet "\\p{alpha}" } "Letters" }
    { { $snippet "\\p{ascii}" } "Characters in the ASCII range" }
    { { $snippet "\\p{alnum}" } "Letters or numbers" }
    { { $snippet "\\p{punct}" } "Punctuation" }
    { { $snippet "\\p{blank}" } "Non-newline whitespace" }
    { { $snippet "\\p{cntrl}" } "Control character" }
    { { $snippet "\\p{space}" } "Whitespace" }
    { { $snippet "\\p{xdigit}" } "Hexadecimal digit" }
    { { $snippet "\\p{Nd}" } "Character in Unicode category Nd" }
    { { $snippet "\\p{Z}" } "Character in Unicode category beginning with Z" }
    { { $snippet "\\p{script=Cham}" } "Character in the Cham writing system" } }
{ $heading "Character class operations" }
"Character classes can be composed using four binary operations: " { $snippet "|| && ~~ --" } ". These do the operations union, intersection, symmetric difference and difference, respectively. For example, characters which are lower-case but not Latin script could be matched as " { $snippet "[\\p{lower}--\\p{script=latin}]" } ". These operations are right-associative, and " { $snippet "^" } " binds tighter than them. There is no syntax for grouping."
{ $heading "Boundaries" }
"Special operators exist to match certain points in the string. These are called 'zero-width' because they do not consume any characters."
{ $table
    { { $snippet "^" } "Beginning of a line" }
    { { $snippet "$" } "End of a line" }
    { { $snippet "\\A" } "Beginning of text" }
    { { $snippet "\\z" } "End of text" }
    { { $snippet "\\Z" } "Almost end of text: only thing after is newline" }
    { { $snippet "\\b" } "Word boundary (by Unicode word boundaries)" }
    { { $snippet "\\B" } "Not word boundary (by Unicode word boundaries)" } }
{ $heading "Greedy quantifiers" }
"It is possible to have a regular expression which matches a variable number of occurrences of another regular expression."
{ $table
    { { $snippet "a*" } "Zero or more occurrences of a" }
    { { $snippet "a+" } "One or more occurrences of a" }
    { { $snippet "a?" } "Zero or one occurrences of a" }
    { { $snippet "a{n}" } "n occurrences of a" }
    { { $snippet "a{n,}" } "At least n occurrences of a" }
    { { $snippet "a{,m}" } "At most m occurrences of a" }
    { { $snippet "a{n,m}" } "Between n and m occurrences of a" } }
"All of these quantifiers are " { $emphasis "greedy" } ", meaning that they take as many repetitions as possible within the larger regular expression. Reluctant and possessive quantifiers are not yet supported."
{ $heading "Lookaround" }
"Operators are provided to look ahead and behind the current point in the regular expression. These can be used in any context, but they're the most useful at the beginning or end of a regular expression."
{ $table
    { { $snippet "(?=a)" } "Asserts that the current position is immediately followed by a" }
    { { $snippet "(?!a)" } "Asserts that the current position is not immediately followed by a" }
    { { $snippet "(?<=a)" } "Asserts that the current position is immediately preceded by a" }
    { { $snippet "(?<!a)" } "Asserts that the current position is not immediately preceded by a" } }
{ $heading "Quotation" }
"To make it convenient to have a long string which uses regexp operators, a special syntax is provided. If a substring begins with " { $snippet "\\Q" } " then everything until " { $snippet "\\E" } " is quoted (escaped). For example, " { $snippet "R/ \\Qfoo\\bar|baz()\\E/" } " matches exactly the string " { $snippet "\"foo\\bar|baz()\"" } "."
{ $heading "Unsupported features" }
{ $subheading "Group capture" }
{ $subheading "Reluctant and possessive quantifiers" }
{ $subheading "Backreferences" }
"Backreferences were omitted because of a design decision to allow only regular expressions following the formal theory of regular languages. For more information, see " { $link "regexp-theory" } "."
$nl
"To work around the lack of backreferences, consider using group capture and then creating a new regular expression to match the captured string using " { $vocab-link "regexp.combinators" } "."
{ $subheading "Previous match" }
"Another feature that is not included is Perl's " { $snippet "\\G" } " syntax, which references the previous match. This is because that sequence is inherently stateful, and Factor regexps don't hold state."
{ $subheading "Embedding code" }
"Operations which embed code into a regexp are not supported. This would require the inclusion of the Factor parser and compiler in any deployed application which wants to expose regexps to the user, leading to an undesirable increase in the code size."
{ $heading "Casing operations" }
"No special casing operations are included, for example Perl's " { $snippet "\\L" } "." ;

ARTICLE: "regexp-options" "Regular expression options"
"When " { $link "regexp-construction" } ", various options can be provided. Options have single-character names. A string of options has one of the following two forms:"
{ $code "on" "on-off" }
"The latter syntax allows some options to be disabled. The " { $snippet "on" } " and " { $snippet "off" } " strings name options to be enabled and disabled, respectively."
$nl
"The following options are supported:"
{ $table
  { "i" { $link case-insensitive } }
  { "d" { $link unix-lines } }
  { "m" { $link multiline } }
  { "s" { $link dotall } }
  { "r" { $link reversed-regexp } }
} ;

HELP: case-insensitive
{ $syntax "R/ .../i" }
{ $description "On regexps, the " { $snippet "i" } " option makes the match case-insensitive. Currently, this is handled incorrectly with respect to Unicode, as characters like ß do not expand into SS in upper case. This should be fixed in a future version." } ;

HELP: unix-lines
{ $syntax "R/ .../d" }
{ $description "With this mode, only newlines (" { $snippet "\\n" } ") are recognized for line breaking. This affects " { $snippet "$" } " and " { $snippet "^" } " when in multiline mode." } ;

HELP: multiline
{ $syntax "R/ .../m" }
{ $description "This mode makes the zero-width constraints " { $snippet "$" } " and " { $snippet "^" } " match the beginning or end of a line. Otherwise, they only match the beginning or end of the input text. This can be used together with " { $link dotall } "." } ;

HELP: dotall
{ $syntax "R/ .../s" }
{ $description "This mode, traditionally called single line mode, makes " { $snippet "." } " match everything, including line breaks. By default, it does not match line breaking characters. This can be used together with " { $link multiline } "." } ;

HELP: reversed-regexp
{ $syntax "R/ .../r" }
{ $description "When running a regexp compiled with this mode, matches will start from the end of the input string, going towards the beginning." } ;

ARTICLE: "regexp-theory" "The theory of regular expressions"
"Far from being just a practical tool invented by Unix hackers, regular expressions were studied formally before computer programs were written to process them." $nl
"A regular language is a set of strings that is matched by a regular expression, which is defined to have characters and the empty string, along with the operations concatenation, disjunction and Kleene star. Another way to define the class of regular languages is as the class of languages which can be recognized with constant space overhead, ie with a DFA. These two definitions are provably equivalent." $nl
"One basic result in the theory of regular language is that the complement of a regular language is regular. In other words, for any regular expression, there exists another regular expression which matches exactly the strings that the first one doesn't match." $nl
"This implies, by DeMorgan's law, that, if you have two regular languages, their intersection is also regular. That is, for any two regular expressions, there exists a regular expression which matches strings that match both inputs." $nl
"Traditionally, regular expressions on computer support an additional operation: backreferences. For example, the Perl regexp " { $snippet "/(.*)$1/" } " matches a string repeated twice. If a backreference refers to a string with a predetermined maximum length, then the resulting language is still regular." $nl
"But, if not, the language is not regular. There is strong evidence that there is no efficient way to parse with backreferences in the general case. Perl uses a naive backtracking algorithm which has pathological behavior in some cases, taking exponential time to match even if backreferences aren't used. Additionally, expressions with backreferences don't have the properties with negation and intersection described above." $nl
"The Factor regular expression engine was built with the design decision to support negation and intersection at the expense of backreferences. This lets us have a guaranteed linear-time matching algorithm. Systems like Ragel and Lex use the same algorithm." ;

ARTICLE: "regexp-operations" "Matching operations with regular expressions"
"Testing if a string matches a regular expression:"
{ $subsections matches? }
"Finding a match inside a string:"
{ $subsections re-contains? first-match }
"Finding all matches inside a string:"
{ $subsections
    count-matches
    all-matching-slices
    all-matching-subseqs
}
"Splitting a string into tokens delimited by a regular expression:"
{ $subsections re-split }
"Replacing occurrences of a regular expression with a string:"
{ $subsections re-replace re-replace-with } ;

ARTICLE: "regexp-deploy" "Regular expressions and the deploy tool"
"The " { $link "tools.deploy" } " tool has the option to strip out the optimizing compiler from the resulting image. Since regular expressions compile to Factor code, this creates a minor performance-related caveat."
$nl
"Regular expressions constructed at runtime from a deployed application will be compiled with the non-optimizing compiler, which is always available because it is built into the Factor VM. This will result in lower performance than when using the optimizing compiler."
$nl
"Literal regular expressions constructed at parse time do not suffer from this restriction, since the deployed application is loaded and compiled before anything is stripped out."
$nl
"None of this applies to deployed applications which include the optimizing compiler, or code running inside a development image."
{ $see-also "compiler" "regexp-construction" "deploy-flags" } ;

HELP: <regexp>
{ $values { "string" string } { "regexp" regexp } }
{ $description "Creates a regular expression object, given a string in regular expression syntax. When it is first used for matching, a DFA is compiled, and this DFA is stored for reuse so it is only compiled once." } ;

HELP: <optioned-regexp>
{ $values { "string" string } { "options" "a string of " { $link "regexp-options" } } { "regexp" regexp } }
{ $description "Given a string in regular expression syntax, and a string of options, creates a regular expression object. When it is first used for matching, a DFA is compiled, and this DFA is stored for reuse so it is only compiled once." } ;

HELP: R/
{ $syntax "R/ foo.*|[a-zA-Z]bar/options" }
{ $description "Literal syntax for a regular expression. When this syntax is used, the DFA is compiled at compile-time, rather than on first use. The syntax for the " { $snippet "options" } " string is documented in " { $link "regexp-options" } "." } ;

HELP: regexp
{ $class-description "The class of regular expressions. To construct these, see " { $link "regexp-construction" } "." } ;

HELP: matches?
{ $values { "string" string } { "regexp" regexp } { "?" boolean } }
{ $description "Tests if the string as a whole matches the given regular expression." } ;

HELP: all-matching-slices
{ $values { "string" string } { "regexp" regexp } { "seq" "a sequence of slices of the input" } }
{ $description "Finds a sequence of disjoint substrings which each match the pattern. It chooses this by finding the leftmost longest match, and then the leftmost longest match which starts after the end of the previous match, and so on." } ;

HELP: count-matches
{ $values { "string" string } { "regexp" regexp } { "n" integer } }
{ $description "Counts how many disjoint matches the regexp has in the string, as made unambiguous by " { $link all-matching-slices } "." } ;

HELP: re-split
{ $values { "string" string } { "regexp" regexp } { "seq" "a sequence of slices of the input" } }
{ $description "Splits the input string into chunks separated by the regular expression. Each chunk contains no match of the regexp. The chunks are chosen by the strategy of " { $link all-matching-slices } "." } ;

HELP: re-replace
{ $values { "string" string } { "regexp" regexp } { "replacement" string } { "result" string } }
{ $description "Replaces substrings which match the input regexp with the given replacement text. The boundaries of the substring are chosen by the strategy used by " { $link all-matching-slices } "." }
{ $examples
    { $example
        "USING: prettyprint regexp ;"
        "\"python is pythonic\" R/ python/ \"factor\" re-replace ."
        "\"factor is factoric\"" }
} ;

HELP: re-replace-with
{ $values { "string" string } { "regexp" regexp } { "quot" { $quotation ( slice -- replacement ) } } { "result" string } }
{ $description "Replaces substrings which match the input regexp with the result of calling " { $snippet "quot" } " on each matching slice. The boundaries of the substring are chosen by the strategy used by " { $link all-matching-slices } "." }
{ $examples
    { $example
        "USING: ascii prettyprint regexp ;"
        "\"abcdefghi\" R/ [aeiou]/ [ >upper ] re-replace-with ."
        "\"AbcdEfghI\"" }
} ;

{ re-replace re-replace-with } related-words

HELP: first-match
{ $values { "string" string } { "regexp" regexp } { "slice/f" "the match, if one exists" } }
{ $description "Finds the first match of the regular expression in the string, and returns it as a slice. If there is no match, then " { $link f } " is returned." } ;

HELP: re-contains?
{ $values { "string" string } { "regexp" regexp } { "?" boolean } }
{ $description "Determines whether the string has a substring which matches the regular expression given." } ;
