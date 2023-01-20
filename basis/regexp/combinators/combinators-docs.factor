! Copyright (C) 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: help.syntax help.markup regexp strings ;
IN: regexp.combinators

ABOUT: "regexp.combinators"

ARTICLE: "regexp.combinators.intro" "Regular expression combinator rationale"
"Regular expression combinators are useful when part of the regular expression contains user input. For example, given a sequence of strings on the stack, a regular expression which matches any one of them can be constructed:"
{ $code
  "[ <literal> ] map <or>"
}
"Without combinators, a naive approach would look as follows:"
{ $code
  "\"|\" join <regexp>"
}
"However, this code is incorrect, because one of the strings in the sequence might contain characters which have special meaning inside a regular expression. Combinators avoid this problem by building a regular expression syntax tree directly, without any parsing." ;

ARTICLE: "regexp.combinators" "Regular expression combinators"
"The " { $vocab-link "regexp.combinators" } " vocabulary defines combinators which can be used to build up regular expressions to match strings. This complements the traditional syntax defined in the " { $vocab-link "regexp" } " vocabulary."
{ $subsections "regexp.combinators.intro" }
"Basic combinators:"
{ $subsections <literal> <nothing> }
"Higher-order combinators for building new regular expressions from existing ones:"
{ $subsections
    <or>
    <and>
    <not>
    <sequence>
    <zero-or-more>
}
"Derived combinators implemented in terms of the above:"
{ $subsections <one-or-more> }
"Setting options:"
{ $subsections <option> } ;

HELP: <literal>
{ $values { "string" string } { "regexp" regexp } }
{ $description "Creates a regular expression which matches the given literal string." } ;

HELP: <nothing>
{ $values { "value" regexp } }
{ $description "The empty regular language." } ;

HELP: <or>
{ $values { "regexps" "a sequence of regular expressions" } { "disjunction" regexp } }
{ $description "Creates a new regular expression which matches the union of what elements of the sequence match." } ;

HELP: <and>
{ $values { "regexps" "a sequence of regular expressions" } { "conjunction" regexp } }
{ $description "Creates a new regular expression which matches the intersection of what elements of the sequence match." } ;

HELP: <sequence>
{ $values { "regexps" "a sequence of regular expressions" } { "regexp" regexp } }
{ $description "Creates a new regular expression which matches strings that match each element of the sequence in order." } ;

HELP: <not>
{ $values { "regexp" regexp } { "not-regexp" regexp } }
{ $description "Creates a new regular expression which matches everything that the given regexp does not match." } ;

HELP: <one-or-more>
{ $values { "regexp" regexp } { "regexp+" regexp } }
{ $description "Creates a new regular expression which matches one or more copies of the given regexp." } ;

HELP: <option>
{ $values { "regexp" regexp } { "regexp?" regexp } }
{ $description "Creates a new regular expression which matches zero or one copies of the given regexp." } ;

HELP: <zero-or-more>
{ $values { "regexp" regexp } { "regexp*" regexp } }
{ $description "Creates a new regular expression which matches zero or more copies of the given regexp." } ;
