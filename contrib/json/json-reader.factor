! Copyright (C) 2006 Chris Double.
! 
! Redistribution and use in source and binary forms, with or without
! modification, are permitted provided that the following conditions are met:
! 
! 1. Redistributions of source code must retain the above copyright notice,
!    this list of conditions and the following disclaimer.
! 
! 2. Redistributions in binary form must reproduce the above copyright notice,
!    this list of conditions and the following disclaimer in the documentation
!    and/or other materials provided with the distribution.
! 
! THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
! INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
! FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
! DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
! SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
! PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
! OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
! WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
! OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
! ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
!
USING: kernel namespaces sequences strings math hashtables parser-combinators ;
IN: json

! Grammar for JSON from RFC 4627
USE: tools

: [<&>] ( quot - quot )
  { } make unclip [ <&> ] reduce ;

: [<|>] ( quot - quot )
  { } make unclip [ <|> ] reduce ;

: 'ws' ( -- parser )
  " " token 
  "\n" token <|>
  "\r" token <|>
  "\t" token <|> 
  "" token <|> ;

: spaced ( parser -- parser )
  'ws' swap &> 'ws' <& ;

: 'begin-array' ( -- parser )
  "[" token spaced ;

: 'begin-object' ( -- parser )
  "{" token spaced ;

: 'end-array' ( -- parser )
  "]" token spaced ;

: 'end-object' ( -- parser )
  "}" token spaced ;

: 'name-separator' ( -- parser )
  ":" token spaced ;

: 'value-separator' ( -- parser )
  "," token spaced ;

: 'false' ( -- parser )
  "false" token ;

: 'null' ( -- parser )
  "null" token ;

: 'true' ( -- parser )
  "true" token ;

: 'quot' ( -- parser )
  "\"" token ;

: 'string' ( -- parser )
  'quot' 
  [ quotable? ] satisfy <+> &> 
  'quot' <& [ >string ] <@  ;

DEFER: 'value'

: 'member' ( -- parser )
  'string'
  'name-separator' <&  
  [ 'value' call ] <&> ;

: object>hashtable ( object -- hashtable )
  #! Convert json object to hashtable
  H{ } clone dup rot [ dup second swap first rot set-hash ] each-with ;

: 'object' ( -- parser )
  'begin-object' 
  'member' &>
  'value-separator' 'member' &> <*> <&:>
  'end-object' <& [ object>hashtable ] <@ ;

: 'array' ( -- parser )
  'begin-array' 
  [ 'value' call ] &>
  'value-separator' [ 'value' call ] &> <*> <&:> 
  'end-array' <&  ;
  
: 'minus' ( -- parser )
  "-" token ;

: 'plus' ( -- parser )
  "+" token ;

: 'zero' ( -- parser )
  "0" token [ drop 0 ] <@ ;

: 'decimal-point' ( -- parser )
  "." token ;

: 'digit1-9' ( -- parser )
  [ 
    dup integer? [ 
      CHAR: 1 CHAR: 9 between? 
    ] [ 
      drop f 
    ] if 
  ] satisfy [ digit> ] <@ ;

: 'digit0-9' ( -- parser )
  [ digit? ] satisfy [ digit> ] <@ ;

: sequence>number ( seq -- num ) 
  #! { 1 2 3 } => 123
  0 [ swap 10 * + ] reduce ;

: 'int' ( -- parser )
  'zero' 
  'digit1-9' 'digit0-9' <*> <&:> [ sequence>number ] <@ <|>  ;

: 'e' ( -- parser )
  "e" token "E" token <|> ;

: sign-number ( { minus? num } -- number )
  #! Convert the json number value to a factor number
  dup second swap first [ -1 * ] when ;

: 'exp' ( -- parser )
    'e' 
    'minus' 'plus' <|> <?> &>
    'digit0-9' <+> [ sequence>number ] <@ <&> [ sign-number ] <@ ;

: sequence>frac ( seq -- num ) 
  #! { 1 2 3 } => 0.123
  reverse 0 [ swap 10 / + ] reduce 10 / >float ;

: 'frac' ( -- parser )
  'decimal-point' 'digit0-9' <+> &> [ sequence>frac ] <@ ;

: raise-to-power ( { num exp } -- num )
  #! Multiply 'num' by 10^exp
  dup second dup [ 10 swap first ^ swap first * ] [ drop first ] if ;

: 'number' ( -- parser )
  'minus' <?>
  [ 'int' , 'frac' 0 succeed <|> , ] [<&>] [ sum ] <@ 
  'exp' <?> <&> [ raise-to-power ] <@ <&> [ sign-number ] <@ ;

: 'value' ( -- parser )
  [
    'false' ,
    'null' ,
    'true' ,
    'string' ,
    'object' ,
    'array' ,
    'number' ,
  ] [<|>] ;

: json> ( string -- object )
  #! Parse a json formatted string to a factor object
  'value' some call ;