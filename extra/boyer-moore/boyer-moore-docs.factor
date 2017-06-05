! Copyright (C) 2010 Dmitry Shubin.
! See http://factorcode.org/license.txt for BSD license.
USING: boyer-moore.private help.markup help.syntax kernel sequences ;
IN: boyer-moore

HELP: <boyer-moore>
{ $values
  { "pat" sequence } { "bm" boyer-moore }
}
{ $description
  "Given a pattern performs pattern preprocessing and returns "
  "results as an (opaque) object that is reusable across "
  "searches in different sequences via " { $link search-from }
  " generic word."
} ;

HELP: search-from
{ $values
  { "seq" sequence }
  { "from" "a non-negative integer" }
  { "obj" object }
  { "i/f" "the index of first match or " { $link f } }
}
{ $description "Performs an attempt to find the first "
  "occurrence of pattern in " { $snippet "seq" }
  " starting from " { $snippet "from" } " using "
  "Boyer-Moore search algorithm. Output is the index "
  "if the attempt was succeessful and " { $link f }
  " otherwise."
} ;

HELP: search
{ $values
  { "seq" sequence }
  { "obj" object }
  { "i/f" "the index of first match or " { $link f } }
}
{ $description "A simpler variant of " { $link search-from }
  " that starts searching from the beginning of the sequence."
} ;

ARTICLE: "boyer-moore" "The Boyer-Moore algorithm"
{ $heading "Summary" }
"The " { $vocab-link "boyer-moore" } " vocabulary "
"implements a Boyer-Moore string search algorithm with "
"so-called 'strong good suffix shift rule'. Since algorithm is "
"alphabet-independent it is applicable to searching in any "
"collection that implements " { $links "sequence-protocol" } "."

{ $heading "Complexity" }
"Let " { $snippet "n" } " and " { $snippet "m" } " be lengths "
"of the sequences being searched " { $emphasis "in" } " and "
{ $emphasis "for" } " respectively. Then searching runs in "
{ $snippet "O(n)" } " time in its worst case using additional "
{ $snippet "O(m)" } " space. The preprocessing phase runs in "
{ $snippet "O(m)" } " time."
;

ABOUT: "boyer-moore"
