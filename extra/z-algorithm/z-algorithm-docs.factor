! Copyright (C) 2010 Dmitry Shubin.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays help.markup help.syntax sequences ;
IN: z-algorithm

HELP: lcp
{ $values
  { "seq1" sequence } { "seq2" sequence }
  { "n" "a non-negative integer" }
}
{ $description
  "Outputs the length of longest common prefix of two sequences."
} ;

HELP: z-values
{ $values
  { "seq" sequence } { "Z" array }
}
{ $description
  "Outputs an array of the same length as " { $snippet "seq" }
  ", containing Z-values for given sequence. See "
  { $link "z-algorithm" } " for details."
} ;

ARTICLE: "z-algorithm" "Z algorithm"
{ $heading "Definition" }
"Given the sequence " { $snippet "S" } " and the index "
{ $snippet "i" } ", let " { $snippet "i" } "-th Z value of "
{ $snippet "S" } " be the length of the longest subsequence of "
{ $snippet "S" } " that starts at " { $snippet "i" }
" and matches the prefix of " { $snippet "S" } "."

{ $heading "Example" }
"Here is an example for string " { $snippet "\"abababaca\"" } ":"
{ $table
  { { $snippet "i:" } "0" "1" "2" "3" "4" "5" "6" "7" "8" }
  { { $snippet "S:" } "a" "b" "a" "b" "a" "b" "a" "c" "a" }
  { { $snippet "Z:" } "9" "0" "5" "0" "3" "0" "1" "0" "1" }
}

{ $heading "Summary" }
"The " { $vocab-link "z-algorithm" }
" vocabulary implements algorithm for finding all Z values for sequence "
{ $snippet "S" }
" in linear time. In contrast to naive approach which takes "
{ $snippet "Θ(n^2)" } " time."
;

ABOUT: "z-algorithm"
