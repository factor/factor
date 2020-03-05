USING: help.markup help.syntax strings ;
IN: porter-stemmer

HELP: step1a
{ $values { "str" string } { "newstr" "a new string" } }
{ $description "Gets rid of plurals." }
{ $examples
    { $table
        { { $strong "Input" } { $strong "Output" } }
        { "caresses" "caress" }
        { "ponies" "poni" }
        { "ties" "ti" }
        { "caress" "caress" }
        { "cats" "cat" }
    }
} ;

HELP: step1b
{ $values { "str" string } { "newstr" "a new string" } }
{ $description "Gets rid of \"-ed\" and \"-ing\" suffixes." }
{ $examples
    { $table
        { { $strong "Input" } { $strong "Output" } }
        { "feed"  "feed" }
        { "agreed"  "agree" }
        { "disabled"  "disable" }
        { "matting"  "mat" }
        { "mating"  "mate" }
        { "meeting"  "meet" }
        { "milling"  "mill" }
        { "messing"  "mess" }
        { "meetings"  "meet" }
    }
} ;

HELP: step1c
{ $values { "str" string } { "newstr" "a new string" } }
{ $description "Turns a terminal y to i when there is another vowel in the stem." } ;

HELP: step2
{ $values { "str" string } { "newstr" "a new string" } }
{ $description "Maps double suffices to single ones. so -ization maps to -ize etc. note that the string before the suffix must give positive " { $link consonant-seq } "." } ;

HELP: step3
{ $values { "str" string } { "newstr" "a new string" } }
{ $description "Deals with -c-, -full, -ness, etc. Similar strategy to " { $link step2 } "." } ;

HELP: step5
{ $values { "str" string } { "newstr" "a new string" } }
{ $description "Removes a final -e and changes a final -ll to -l if " { $link consonant-seq } " is greater than 1," } ;

HELP: stem
{ $values { "str" string } { "newstr" "a new string" } }
{ $description "Applies the Porter stemming algorithm to the input string." } ;

ARTICLE: "porter-stemmer" "Porter stemming algorithm"
"The help system uses the Porter stemming algorithm to normalize words when building the full-text search index."
$nl
"The Factor implementation of the algorithm is based on the Common Lisp version, which was hand-translated from ANSI C by Steven M. Haflich. The original ANSI C was written by Martin Porter."
$nl
"A detailed description of the algorithm, along with implementations in various languages, can be at in " { $url "http://www.tartarus.org/~martin/PorterStemmer" } "."
$nl
"The main word of the algorithm takes an English word as input and outputs its stem:"
{ $subsections stem }
"The algorithm consists of a number of steps:"
{ $subsections
    step1a
    step1b
    step1c
    step2
    step3
    step4
    step5
} ;

ABOUT: "porter-stemmer"
