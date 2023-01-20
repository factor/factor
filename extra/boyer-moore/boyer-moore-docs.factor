! Copyright (C) 2010 Dmitry Shubin.
! See https://factorcode.org/license.txt for BSD license.
USING: boyer-moore.private help.markup help.syntax kernel sequences ;
IN: boyer-moore

HELP: <boyer-moore>
{ $values
  { "pattern" sequence } { "boyer-moore" boyer-moore }
}
{ $description
  "Given a pattern performs pattern preprocessing and returns "
  "results as an (opaque) object that is reusable across "
  "searches in different sequences via " { $link search-from } "."
} { $examples
    { $example
        "USING: boyer-moore prettyprint ;"
        "\"abc\" <boyer-moore> ."
        "T{ boyer-moore
    { pattern \"abc\" }
    { bad-char-table H{ { 97 0 } { 98 -1 } { 99 -2 } } }
    { good-suffix-table { 3 3 1 } }
}"
    }
} ;

HELP: search-from
{ $values
  { "seq" sequence }
  { "from" "a non-negative integer" }
  { "obj" object }
  { "i/f" "the index of first match or " { $link f } }
}
{ $contract "Performs an attempt to find the first "
  "occurrence of pattern in " { $snippet "seq" }
  " starting from " { $snippet "from" } " using "
  "Boyer-Moore search algorithm. Output is the index "
  "if the attempt was succeessful, or " { $link f }
  " otherwise."
} { $examples
    { $example
        "USING: boyer-moore prettyprint ;"
        "{ 1 2 7 10 20 2 7 10 } 3 { 2 7 10 } search-from ."
        "5"
    }
} ;

HELP: search
{ $values
  { "seq" sequence }
  { "obj" object }
  { "i/f" "the index of first match or " { $link f } }
}
{ $description "A simpler variant of " { $link search-from }
  " that starts searching from the beginning of the sequence."
} { $examples
    { $example
        "USING: boyer-moore prettyprint ;"
        "\"Source string\" \"ce st\" search ."
        "4"
    }
} ;

ARTICLE: "boyer-moore" "The Boyer-Moore algorithm"
{ $heading "Summary" }
"The " { $vocab-link "boyer-moore" } " vocabulary "
"implements a Boyer-Moore string search algorithm with the "
"so-called 'strong good suffix shift rule'. Since the algorithm is "
"alphabet-independent, it is applicable to searching in any "
"collection that implements the " { $links "sequence-protocol" } "."

{ $heading "Complexity" }
"Let " { $snippet "n" } " and " { $snippet "m" } " be the lengths "
"of the sequences being searched " { $emphasis "in" } " and "
{ $emphasis "for" } " respectively. Then searching runs in "
{ $snippet "O(n)" } " time worst-case, using additional "
{ $snippet "O(m)" } " space. The preprocessing phase runs in "
{ $snippet "O(m)" } " time."
;

ABOUT: "boyer-moore"
