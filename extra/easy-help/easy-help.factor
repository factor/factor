
USING: kernel multiline parser sequences splitting grouping help.markup ;

IN: easy-help

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: Description:

  ".." parse-multiline-string
  string-lines
  1 tail
  [ dup "   " head? [ 4 tail     ] [ ] if ] map
  [ dup ""    =     [ drop { $nl } ] [ ] if ] map
  \ $description prefix
  parsed
  
  ; parsing

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: Example:

  { $heading "Example" } parsed

  ".." parse-multiline-string
  string-lines
  [ dup "   " head? [ 4 tail ] [ ] if ] map
  [ "" = not ] filter
  ! \ $example prefix
  \ $code prefix
  parsed

  ; parsing

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: Summary:

  ".." parse-multiline-string
  string-lines
  1 tail
  [ dup "   " head? [ 4 tail     ] [ ] if ] map
  [ dup ""    =     [ drop { $nl } ] [ ] if ] map
  { $heading "Summary" } prefix
  parsed
  
  ; parsing

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: Values:

  ".." parse-multiline-string
  " \n" split
  [ "" = not ] filter
  2 group
  \ $values prefix
  parsed

  ; parsing