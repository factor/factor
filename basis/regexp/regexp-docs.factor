! Copyright (C) 2008, 2009 Doug Coleman, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel strings help.markup help.syntax math ;
IN: regexp

ABOUT: "regexp"

ARTICLE: "regexp" "Regular expressions"
"The " { $vocab-link "regexp" } " vocabulary provides word for creating and using regular expressions."
{ $subsection { "regexp" "syntax" } }
{ $subsection { "regexp" "construction" } }
{ $vocab-subsection "regexp.combinators" "Regular expression combinators" }
{ $subsection { "regexp" "operations" } }
{ $subsection regexp }
{ $subsection { "regexp" "theory" } } ;

ARTICLE: { "regexp" "construction" } "Constructing regular expressions"
"Words which are useful for creating regular expressions:"
{ $subsection POSTPONE: R/ }
{ $subsection <regexp> } 
{ $subsection <optioned-regexp> }
{ $heading "See also" }
{ $vocab-link "regexp.combinators" } ;

ARTICLE: { "regexp" "syntax" } "Regular expression syntax"
"Regexp syntax is largely compatible with Perl, Java and extended POSTFIX regexps, but not completely." $nl
"A new addition is the inclusion of a negation operator, with the syntax " { $snippet "(?~foo)" } " to match everything that does not match " { $snippet "foo" } "." $nl
"One missing feature is backreferences. This is because of a design decision to allow only regular expressions following the formal theory of regular languages. For more information, see " { $link { "regexp" "theory" } } ". You can create a new regular expression to match a particular string using " { $vocab-link "regexp.combinators" } " and group capture is available to extract parts of a regular expression match." $nl
"A distinction from Perl is that " { $snippet "\\G" } ", which references the previous match, is not included. This is because that sequence is inherently stateful, and Factor regexps don't hold state." $nl
"Additionally, none of the operations which embed code into a regexp are supported, as this would require the inclusion of the Factor parser and compiler in any application which wants to expose regexps to the user. None of the casing operations are included, for simplicity." ; ! Also describe syntax, from the beginning

ARTICLE: { "regexp" "theory" } "The theory of regular expressions"
"Far from being just a practical tool invented by Unix hackers, regular expressions were studied formally before computer programs were written to process them." $nl
"A regular language is a set of strings that is matched by a regular expression, which is defined to have characters and the empty string, along with the operations concatenation, disjunction and Kleene star. Another way to define the class of regular languages is as the class of languages which can be recognized with constant space overhead, ie with a DFA. These two definitions are provably equivalent." $nl
"One basic result in the theory of regular language is that the complement of a regular language is regular. In other words, for any regular expression, there exists another regular expression which matches exactly the strings that the first one doesn't match." $nl
"This implies, by DeMorgan's law, that, if you have two regular languages, their intersection is also regular. That is, for any two regular expressions, there exists a regular expression which matches strings that match both inputs." $nl
"Traditionally, regular expressions on computer support an additional operation: backreferences. For example, the Perl regexp " { $snippet "/(.*)$1/" } " matches a string repated twice. If a backreference refers to a string with a predetermined maximum length, then the resulting language is still regular." $nl
"But, if not, the language is not regular. There is strong evidence that there is no efficient way to parse with backreferences in the general case. Perl uses a naive backtracking algorithm which has pathological behavior in some cases, taking exponential time to match even if backreferences aren't used. Additionally, expressions with backreferences don't have the properties with negation and intersection described above." $nl
"The Factor regular expression engine was built with the design decision to support negation and intersection at the expense of backreferences. This lets us have a guaranteed linear-time matching algorithm. Systems like Ragel and Lex also use this algorithm, but in the Factor regular expression engine, all other features of regexps are still present." ;

ARTICLE: { "regexp" "operations" } "Matching operations with regular expressions"
{ $subsection all-matches }
{ $subsection matches? }
{ $subsection re-split1 }
{ $subsection re-split }
{ $subsection re-replace }
{ $subsection count-matches }
{ $subsection re-replace } ;

HELP: <regexp>
{ $values { "string" string } { "regexp" regexp } }
{ $description "Creates a regular expression object, given a string in regular expression syntax. When it is first used for matching, a DFA is compiled, and this DFA is stored for reuse so it is only compiled once." } ;

HELP: <optioned-regexp>
{ $values { "string" string } { "options" string } { "regexp" regexp } }
{ $description "Given a string in regular expression syntax, and a string of options, creates a regular expression object. When it is first used for matching, a DFA is compiled, and this DFA is stored for reuse so it is only compiled once." } ;

HELP: R/
{ $syntax "R/ foo.*|[a-zA-Z]bar/i" }
{ $description "Literal syntax for a regular expression. When this syntax is used, the DFA is compiled at compile-time, rather than on first use." } ;

HELP: regexp
{ $class-description "The class of regular expressions. To construct these, see " { $link { "regexp" "construction" } } "." } ;

HELP: matches?
{ $values { "string" string } { "matcher" regexp } { "?" "a boolean" } }
{ $description "Tests if the string as a whole matches the given regular expression." } ;

HELP: re-split1
{ $values { "string" string } { "matcher" regexp } { "before" string } { "after/f" string } }
{ $description "Searches the string for a substring which matches the pattern. If found, the input string is split on the leftmost and longest occurence of the match, and the two halves are given as output. If no match is found, then the input string and " { $link f } " are output." } ;

HELP: all-matches
{ $values { "string" string } { "matcher" regexp } { "seq" "a sequence of slices of the input" } }
{ $description "Finds a sequence of disjoint substrings which each match the pattern. It chooses this by finding the leftmost longest match, and then the leftmost longest match which starts after the end of the previous match, and so on." } ;

HELP: count-matches
{ $values { "string" string } { "matcher" regexp } { "n" integer } }
{ $description "Counts how many disjoint matches the regexp has in the string, as made unambiguous by " { $link all-matches } "." } ;

HELP: re-split
{ $values { "string" string } { "matcher" regexp } { "seq" "a sequence of slices of the input" } }
{ $description "Splits the input string into chunks separated by the regular expression. Each chunk contains no match of the regexp. The chunks are chosen by the strategy of " { $link all-matches } "." } ;

HELP: re-replace
{ $values { "string" string } { "matcher" regexp } { "replacement" string } { "result" string } }
{ $description "Replaces substrings which match the input regexp with the given replacement text. The boundaries of the substring are chosen by the strategy used by " { $link all-matches } "." } ;
