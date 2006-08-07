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
USING: kernel namespaces sequences strings math parser-combinators ;
IN: json

! Grammar for JSON from RFC 4627
USE: inspector

: [<&>] ( quot - quot )
  { } make unclip [ <:&> ] reduce ;

: [<|>] ( quot - quot )
  { } make unclip [ <|> ] reduce ;

: 'begin-array' ( -- parser )
  "[" token ;

: 'begin-object' ( -- parser )
  "{" token ;

: 'end-array' ( -- parser )
  "]" token ;

: 'end-object' ( -- parser )
  "}" token ;

: 'name-separator' ( -- parser )
  ":" token ;

: 'value-separator' ( -- parser )
  "," token ;

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
  [ 'value' call ] <:&> ;

: 'object' ( -- parser )
  'begin-object' 
  'member' &>
  'value-separator' 'member' &> <*> <:&>
  'end-object' <& ;

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

USE: inspector

: sequence>number ( seq -- num ) 
  #! { 1 2 3 } => 123
  0 [ swap 10 * + ] reduce ;

: 'int' ( -- parser )
  'zero' 
  'digit1-9' 'digit0-9' <*> <&:> [ sequence>number ] <@ <|>  ;

: 'e' ( -- parser )
  "e" token "E" token <|> ;

: 'exp' ( -- parser )
  [
    'e' ,
    'minus' 'plus' <|> <?> ,
    'digit0-9' <+> ,
  ] [<&>] ;

: 'frac' ( -- parser )
  'decimal-point' 'digit0-9' <+> <&> ;

: 'number' ( -- parser )
  'minus' <?> 
  'int' <&>
  'frac' <?> <:&>
  'exp' <?> <:&> ;

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
