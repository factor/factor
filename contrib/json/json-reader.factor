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
USING: kernel namespaces sequences strings math hashtables parser-combinators lazy-lists ;
IN: json

! Grammar for JSON from RFC 4627
USE: tools

: [<&>] ( quot - quot )
  { } make unclip [ <&> ] reduce ;

: [<|>] ( quot - quot )
  { } make unclip [ <|> ] reduce ;

LAZY: 'ws' ( -- parser )
  " " token 
  "\n" token <|>
  "\r" token <|>
  "\t" token <|> 
  "" token <|> ;

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
  "false" token ;

LAZY: 'null' ( -- parser )
  "null" token ;

LAZY: 'true' ( -- parser )
  "true" token ;

LAZY: 'quot' ( -- parser )
  "\"" token ;

LAZY: 'string' ( -- parser )
  'quot' 
  [ quotable? ] satisfy <+> &> 
  'quot' <& [ >string ] <@  ;

DEFER: 'value'

LAZY: 'member' ( -- parser )
  'string'
  'name-separator' <&  
  'value' <&> ;

: object>hashtable ( object -- hashtable )
  #! Convert json object to hashtable
  H{ } clone dup rot [ dup second swap first rot set-hash ] each-with ;

LAZY: 'object' ( -- parser )
  'begin-object' 
  'member' &>
  'value-separator' 'member' &> <*> <&:>
  'end-object' <& [ object>hashtable ] <@ ;

LAZY: 'array' ( -- parser )
  'begin-array' 
  'value' &>
  'value-separator' 'value' &> <*> <&:> 
  'end-array' <&  ;
  
LAZY: 'minus' ( -- parser )
  "-" token ;

LAZY: 'plus' ( -- parser )
  "+" token ;

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

: sequence>number ( seq -- num ) 
  #! { 1 2 3 } => 123
  0 [ swap 10 * + ] reduce ;

LAZY: 'int' ( -- parser )
  'zero' 
  'digit1-9' 'digit0-9' <*> <&:> [ sequence>number ] <@ <|>  ;

LAZY: 'e' ( -- parser )
  "e" token "E" token <|> ;

: sign-number ( { minus? num } -- number )
  #! Convert the json number value to a factor number
  dup second swap first [ -1 * ] when ;

LAZY: 'exp' ( -- parser )
    'e' 
    'minus' 'plus' <|> <?> &>
    'digit0-9' <+> [ sequence>number ] <@ <&> [ sign-number ] <@ ;

: sequence>frac ( seq -- num ) 
  #! { 1 2 3 } => 0.123
  reverse 0 [ swap 10 / + ] reduce 10 / >float ;

LAZY: 'frac' ( -- parser )
  'decimal-point' 'digit0-9' <+> &> [ sequence>frac ] <@ ;

: raise-to-power ( { num exp } -- num )
  #! Multiply 'num' by 10^exp
  dup second dup [ 10 swap first ^ swap first * ] [ drop first ] if ;

LAZY: 'number' ( -- parser )
  'minus' <?>
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
  ] [<|>] ;

: json> ( string -- object )
  #! Parse a json formatted string to a factor object
  'value' some parse force ;