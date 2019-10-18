
USING: arrays assocs compiler.units 
       grouping help help.markup help.topics kernel lexer multiline
       namespaces parser sequences splitting words
       easy-help.expand-markup ;

IN: easy-help

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: parse-text-block ( -- array )
  
  ".." parse-multiline-string
  string-lines
  1 tail
  [ dup "    " head? [ 4 tail ] [ ] if ] map
  [ expand-markup ] map
  concat
  [ dup "" = [ drop { $nl } ] [ ] if ] map ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: Text: parse-text-block parsed ; parsing

: Block: scan-word 1array parse-text-block append parsed ; parsing

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: Notes:           { $notes       } parse-text-block append parsed ; parsing
: Description:     { $description } parse-text-block append parsed ; parsing
: Contract:        { $contract    } parse-text-block append parsed ; parsing
: Checked-Example: { $example     } parse-text-block append parsed ; parsing

: Class-Description:
  { $class-description } parse-text-block append parsed ; parsing

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: Code:
  
  { $code }
  parse-text-block [ dup array? [ drop "" ] [ ] if ] map
  append
  parsed
  
  ; parsing

: Example:
  { $heading "Example" }
  { $code }
  parse-text-block
  [ dup array? [ drop "" ] [ ] if ] map ! Each item in $code must be a string
  append 
  2array parsed ; parsing

: Introduction:

  { $heading "Introduction" }
  parse-text-block
  2array parsed ; parsing

: Summary:

  { $heading "Summary" }
  parse-text-block
  2array parsed ; parsing

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: Values:

  ".." parse-multiline-string
  string-lines
  1 tail
  [ dup "    " head? [ 4 tail ] [ ] if ] map
  [ " " split1 [ " " first = ] trim-head 2array ] map
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

: Heading: { $heading } ".." parse-multiline-string suffix parsed ; parsing

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: List:

  { $list }

  ".." parse-multiline-string
  string-lines
  1 tail
  [ dup "    " head? [ 4 tail ] [ ] if ] map
  [ expand-markup ] map

  append parsed

  ; parsing
