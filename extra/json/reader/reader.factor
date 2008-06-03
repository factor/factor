! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel parser-combinators namespaces sequences promises strings 
       assocs math math.parser math.vectors math.functions math.order
       lists lists.lazy hashtables ascii ;
IN: json.reader

! Grammar for JSON from RFC 4627

SYMBOL: json-null

: [<&>] ( quot -- quot )
  { } make unclip [ <&> ] reduce ;

: [<|>] ( quot -- quot )
  { } make unclip [ <|> ] reduce ;

LAZY: 'ws' ( -- parser )
  " " token 
  "\n" token <|>
  "\r" token <|>
  "\t" token <|> <*> ;

LAZY: spaced ( parser -- parser )
  'ws' swap &> 'ws' <& ;

LAZY: 'begin-array' ( -- parser )
  "[" token spaced ;

LAZY: 'begin-object' ( -- parser )
  "{" token spaced ;

LAZY: 'end-array' ( -- parser )
  "]" token spaced ;

LAZY: 'end-object' ( -- parser )
  "}" token spaced ;

LAZY: 'name-separator' ( -- parser )
  ":" token spaced ;

LAZY: 'value-separator' ( -- parser )
  "," token spaced ;

LAZY: 'false' ( -- parser )
  "false" token [ drop f ] <@ ;

LAZY: 'null' ( -- parser )
  "null" token [ drop json-null ] <@ ;

LAZY: 'true' ( -- parser )
  "true" token [ drop t ] <@ ;

LAZY: 'quot' ( -- parser )
  "\"" token ;

LAZY: 'hex-digit' ( -- parser )
  [ digit> ] satisfy [ digit> ] <@ ;

: hex-digits>ch ( digits -- ch )
    0 [ swap 16 * + ] reduce ;

LAZY: 'string-char' ( -- parser )
  [ quotable? ] satisfy
  "\\b" token [ drop 8 ] <@ <|>
  "\\t" token [ drop CHAR: \t ] <@ <|>
  "\\n" token [ drop CHAR: \n ] <@ <|>
  "\\f" token [ drop 12 ] <@ <|>
  "\\r" token [ drop CHAR: \r ] <@ <|>
  "\\\"" token [ drop CHAR: " ] <@ <|>
  "\\/" token [ drop CHAR: / ] <@ <|>
  "\\\\" token [ drop CHAR: \\ ] <@ <|>
  "\\u" token 'hex-digit' 4 exactly-n &>
  [ hex-digits>ch ] <@ <|> ;

LAZY: 'string' ( -- parser )
  'quot' 
  'string-char' <*> &> 
  'quot' <& [ >string ] <@  ;

DEFER: 'value'

LAZY: 'member' ( -- parser )
  'string'
  'name-separator' <&  
  'value' <&> ;

USE: prettyprint 
LAZY: 'object' ( -- parser )
  'begin-object' 
  'member' 'value-separator' list-of &>
  'end-object' <& [ >hashtable ] <@ ;

LAZY: 'array' ( -- parser )
  'begin-array' 
  'value' 'value-separator' list-of &>
  'end-array' <&  ;
  
LAZY: 'minus' ( -- parser )
  "-" token ;

LAZY: 'plus' ( -- parser )
  "+" token ;

LAZY: 'sign' ( -- parser )
  'minus' 'plus' <|> ;

LAZY: 'zero' ( -- parser )
  "0" token [ drop 0 ] <@ ;

LAZY: 'decimal-point' ( -- parser )
  "." token ;

LAZY: 'digit1-9' ( -- parser )
  [ 
    dup integer? [ 
      CHAR: 1 CHAR: 9 between? 
    ] [ 
      drop f 
    ] if 
  ] satisfy [ digit> ] <@ ;

LAZY: 'digit0-9' ( -- parser )
  [ digit? ] satisfy [ digit> ] <@ ;

: decimal>integer ( seq -- num ) 10 digits>integer ;

LAZY: 'int' ( -- parser )
  'zero' 
  'digit1-9' 'digit0-9' <*> <&:> [ decimal>integer ] <@ <|>  ;

LAZY: 'e' ( -- parser )
  "e" token "E" token <|> ;

: sign-number ( pair -- number )
  #! Pair is { minus? num }
  #! Convert the json number value to a factor number
  dup second swap first [ first "-" = [ -1 * ] when ] when* ;

LAZY: 'exp' ( -- parser )
    'e' 
    'sign' <?> &>
    'digit0-9' <+> [ decimal>integer ] <@ <&> [ sign-number ] <@ ;

: sequence>frac ( seq -- num ) 
  #! { 1 2 3 } => 0.123
  reverse 0 [ swap 10 / + ] reduce 10 / >float ;

LAZY: 'frac' ( -- parser )
  'decimal-point' 'digit0-9' <+> &> [ sequence>frac ] <@ ;

: raise-to-power ( pair -- num )
  #! Pair is { num exp }.
  #! Multiply 'num' by 10^exp
  dup second dup [ 10 swap first ^ swap first * ] [ drop first ] if ;

LAZY: 'number' ( -- parser )
  'sign' <?>
  [ 'int' , 'frac' 0 succeed <|> , ] [<&>] [ sum ] <@ 
  'exp' <?> <&> [ raise-to-power ] <@ <&> [ sign-number ] <@ ;

LAZY: 'value' ( -- parser )
  [
    'false' ,
    'null' ,
    'true' ,
    'string' ,
    'object' ,
    'array' ,
    'number' ,
  ] [<|>] spaced ;

: json> ( string -- object )
  #! Parse a json formatted string to a factor object
  'value' parse dup nil? [ 
    "Could not parse json" throw
  ] [ 
    car parse-result-parsed 
  ] if ;
