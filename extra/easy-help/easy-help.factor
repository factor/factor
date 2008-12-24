
USING: arrays assocs compiler.units 
       grouping help help.markup help.topics kernel lexer multiline
       namespaces parser sequences splitting words
       easy-help.expand-markup ;

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
  string-lines
  1 tail
  [ dup "   " head? [ 4 tail ] [ ] if ] map
  [ " " split1 [ " " first = ] trim-left 2array ] map
  \ $values prefix
  parsed

  ; parsing

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: Word:

  scan current-vocab create dup old-definitions get
  [ delete-at ] with each dup set-word

  bootstrap-word dup set-word
  dup >link save-location
  \ ; parse-until >array swap set-word-help ; parsing

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: Contract:

  ".." parse-multiline-string
  string-lines
  1 tail
  [ dup "   " head? [ 4 tail     ] [ ] if ] map
  [ expand-markup ] map
  concat
  [ dup ""    =     [ drop { $nl } ] [ ] if ] map
  \ $contract prefix
  parsed
  
  ; parsing

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: Notes:

  ".." parse-multiline-string
  string-lines
  1 tail
  [ dup "   " head? [ 4 tail     ] [ ] if ] map
  [ expand-markup ] map
  concat
  [ dup ""    =     [ drop { $nl } ] [ ] if ] map
  \ $notes prefix
  parsed
  
  ; parsing

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

