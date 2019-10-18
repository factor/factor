! Copyright (C) 2004 Chris Double.
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
IN: parser-combinators
USE: lazy
USE: stack
USE: lists
USE: strings
USE: math
USE: logic
USE: kernel
USE: combinators
USE: parser

: phead ( object -- head )
  #! Polymorphic head. Return the head item of the object. 
  #! For a string this is the first character.
  #! For a list this is the car.
  [
    [ string? ] [ 0 swap str-nth ]
    [ list? ] [ car ]
  ] cond ;

: ptail ( object -- tail )
  #! Polymorphic tail. Return the tail of the object.
  #! For a string this is everything but the first character.
  #! For a list this is the cdr.
  [
    [ string? ] [ 1 str-tail ]
    [ list? ] [ cdr ]
  ] cond ;

: pfirst ( object -- first )
  #! Polymorphic first
  phead ;

: psecond ( object -- second )
  #! Polymorphic second
  [
    [ string? ] [ 1 swap str-nth ]
    [ list? ] [ cdr car ]
  ] cond ;

: ph:t ( object -- head tail )
  #! Return the head and tail of the object.
  dup phead swap ptail ;

: pempty? ( object -- bool )
  #! Polymorphic empty test.
  [
    [ string? ] [ "" = ]
    [ list? ] [ not ]
  ] cond ;
  
: string-take ( n string -- string )
  #! Return a string with the first 'n' characters
  #! of the original string.
  dup str-length pick < [
    2drop ""
  ] [
    swap str-head
  ] ifte ;

: (list-take) ( n list accum -- list )
  >r >r pred dup 0 < [ 
    drop r> drop r> reverse 
  ] [ 
    r> uncons swap r> cons (list-take) 
  ] ifte ;

: list-take ( n list -- list )
  #! Return a list with the first 'n' characters
  #! of the original list.
  [ ] (list-take) ;

: ptake ( n object -- object )
  #! Polymorphic take.
  #! Return a collection of the first 'n' 
  #! characters from the original collection.
  [
    [ string? ] [ string-take ]
    [ list? ] [ list-take ]
  ] cond ;

: string-drop ( n string -- string )
  #! Return a string with the first 'n' characters
  #! of the original string removed.
  dup str-length pick < [
    2drop "" 
  ] [
    swap str-tail 
  ] ifte ;
  
: list-drop ( n list -- list )
  #! Return a list with the first 'n' items
  #! of the original list removed.
  >r pred dup 0 < [ 
    drop r>
  ] [
    r> cdr list-drop
  ] ifte ;
  
: pdrop ( n object -- object )
  #! Polymorphic drop.
  #! Return a collection the same as 'object'
  #! but with the first n items removed. 
  [
    [ string? ] [ string-drop ]
    [ list? ] [ list-drop ]
  ] cond ;
  
: ifte-head= ( string-or-list ch [ quot1 ] [ quot2 ] -- )
  #! When the character 'ch' is equal to the head
  #! of the string or list, run the quot1 otherwise run quot2.
  r> r> swap phead = r> r> ifte ;

: symbol ( ch -- parser )
  #! Return a parser that parses the given symbol.
  [ ( inp ch -- result )
    2dup [
      swap ptail cons lunit
    ] [
      2drop [ ] 
    ] ifte-head=
  ] curry1 ;

: token ( string -- parser )
  #! Return a parser that parses the given string.
  [ ( inp string -- result )
    2dup str-length swap ptake over = [
      swap over str-length swap pdrop cons lunit
    ] [
      2drop [ ] 
    ] ifte 
  ] curry1 ;  

: satisfy ( p -- parser )
  #! Return a parser that succeeds if the predicate 'p',
  #! when passed the first character in the input, returns
  #! true.
  [ ( inp p -- result )    
    over pempty? [
      2drop [ ]
    ] [        
      over phead swap call [
        ph:t cons lunit
      ] [
        drop [ ]
      ] ifte
    ] ifte 
  ] curry1 ;

: satisfy2 ( p r -- parser )
  #! Return a parser that succeeds if the predicate 'p',
  #! when passed the first character in the input, returns
  #! true. On success the word 'r' is called with the
  #! successfully parser character on the stack. The result
  #! of this is returned as the result of the parser.
  [ ( inp p r -- result )
    >r over phead swap call [
      ph:t swap r> call swons lunit
    ] [
      r> 2drop [ ]
    ] ifte
  ] curry2 ;

: epsilon ( -- parser )
  #! A parser that parses the empty string.
  [ ( inp -- result ) 
    "" swap cons lunit
  ] ;

: succeed ( r -- parser )
  #! A parser that always returns 'r' and consumes no input.
  [ ( inp r -- result )
    swap cons lunit
  ] curry1 ;

: fail ( -- parser )
  #! A parser that always fails
  [
    drop [ ]
  ] ;

USE: prettyprint
USE: unparser

: ensure-list ( a -- [ a ] )
  #! If 'a' is not a list, make it one.
  dup list? [ unit ] unless ;
   
: ++ ( a b -- [ a b ] )
  #! Join two items into a list. 
  >r ensure-list r> ensure-list append ;
  
: <&> ( p1 p2 -- parser )
  #! Sequentially combine two parsers, returning a parser
  #! that first calls p1, then p2 all remaining results from
  #! p1. 
  [ ( inp p1 p2 -- result )
    >r call r> [ ( [ x | xs ] p2 -- result )
      >r uncons r> call swap [ ( [ x2 | xs2 ] x -- result )
        >r uncons swap r> swap ++ swons
      ] curry1 lmap
    ] curry1 lmap lappend*
  ] curry2 ;

 
: <|> ( p1 p2 -- parser )
  #! Choice operator for parsers. Return a parser that does
  #! p1 or p2 depending on which will succeed.
  [ ( inp p1 p2 -- result )
    rot tuck swap call >r swap call r> lappend
  ] curry2 ;

: p-abc ( -- parser )
  #! Test Parser. Parses the string "abc"
  "a" token "b" token "c" token <&> <&> ;

: parse-skipwhite ( string -- string )
  dup phead blank? [
    ptail parse-skipwhite
  ] [
  ] ifte ;

: sp ( parser -- parser )
  #! Return a parser that first skips all whitespace before
  #! parsing.
  [ ( inp parser -- result )
    >r parse-skipwhite r> call
  ] curry1 ;

: just ( parser -- parser )
  #! Return a parser that works exactly like the input parser
  #! but guarantees that the rest string is empty.
  [ ( inp parser -- result )
    call [ ( [ x | xs ] -- )
      cdr str-length 0 =
    ] lsubset
  ] curry1 ;

: <@ ( p f -- parser )
  #! Given a parser p and a quotation f return a parser
  #! that does the same as p but in addition applies f
  #! to the resulting parse tree.
  [ ( inp p f -- result )
    >r call r> [ ( [ x | xs ] f -- [ fx | xs ] )
      swap uncons r> swap over [ call ] [ drop ] ifte r> cons
    ] curry1 lmap
  ] curry2 ;

: p-1 ( -- parser )
  "1" token "123" swap call lcar ;

: p-2 ( -- parser )
  "1" token [ str>number ] <@ "123" swap call lcar ;

: some ( parser -- det-parser )
  #! Given a parser, return a parser that only produces the
  #! resulting parse tree of the first successful complete parse.
  [ ( inp parser -- result )
    just call lcar car 
  ] curry1 ;
  
: delayed-parser ( [ parser ] -- parser )
  [ ( inp [ parser ] -- result )
    call call
  ] curry1 ;

: parens ;
: parens ( -- parser )
  #! Parse nested parentheses
  "(" token [ parens ] delayed-parser <&> 
  ")" token <&> [ parens ] delayed-parser <&> 
  epsilon <|> ;

: nesting ( -- parser )
  #! Count the maximum depth of nested parentheses.
  "(" token [ nesting ] delayed-parser <&> ")" token <&> 
  [ nesting ] delayed-parser <&> [ .s drop "a" ] <@ epsilon <|> ;

: <& ( parser1 parser2 -- parser )
  #! Same as <&> except only return the first item in the parse tree.
  <&> [ pfirst ] <@ ;

: &> ( parser1 parser2 -- parser )
  #! Same as <&> except only return the second item in the parse tree.
  <&> [ psecond  ] <@ ;

: lst ( [ x [ xs ] ] -- [x:xs] )
  #! I need a good name for this word...
  dup cdr [ uncons car cons ] when unit ;

: <*> ( parser -- parser )
  #! Return a parser that accepts zero or more occurences of the original
  #! parser.
  dup [ <*> ] curry1 delayed-parser <&> [ lst ] <@ [ ] succeed <|> ;

: <+> ( parser -- parser )
  #! Return a parser that accepts one or more occurences of the original
  #! parser.
  dup [ <*> ] curry1 delayed-parser <&> [ lst ] <@  ;

: <?> ( parser -- parser )
  #! Return a parser where its construct is optional. It may or may not occur.
  [ ] succeed <|> ;

: <first> ( parser -- parser )
  #! Transform a parser into a parser that only returns the first success.
  [
    call dup [ lcar lunit ] when
  ] curry1 ;
  
: <!*> ( parser -- parser )
  #! Version of <*> that only returns the first success.
  <*> <first> ;

: <!+> ( parser -- parser )
  #! Version of <+> that only returns the first success.
  <+> <first> ;

: ab-test
  "a" token <*> "b" token <&> "aaaaab" swap call [ . ] leach ;

: ab-test2
  "a" token <*> "b" token <&> [ "a" "a" "a" "b" ] swap call [ . ] leach ;

: a "a" token "a" token <&> epsilon <|> ;
: b "b" token epsilon <|> ;
: c "c" token "c" token <&> ;
: d "d" token "d" token <&> ;
: count-a "a" token [ count-a ] delayed-parser &> "b" token <& [ 1 + ] <@ 0 succeed <|> ;
: tca "aaabbb" count-a call [ . ] leach ;

: parse-digit ( -- parser )
  #! Return a parser for digits
  [ digit? ] satisfy [ CHAR: 0 - ] <@ ;

: (reduce) ( start quot list -- value )
  #! Call quot with start and the first value in the list.
  #! quot is then called with the result of quot and the 
  #! next item in the list until the list is exhausted.
  uncons >r swap dup swap r> call r> r> dup [
    (reduce)
  ] [
    2drop
  ] ifte ;

: reduce ( list start quot -- value )
  #! Call quot with start and the first value in the list.
  #! quot is then called with the result of quot and the 
  #! next item in the list until the list is exhausted.
  rot (reduce) ;

: natural ( -- parser )
  #! a parser for natural numbers.
  parse-digit <*> [ car 0 [ swap 10 * + ] reduce unit  ] <@  ;

: natural2 ( -- parser )
  #! a parser for natural numbers.
  parse-digit <!+> [ car 0 [ swap 10 * + ] reduce unit  ] <@  ;

: integer ( -- parser )
  #! A parser that can parser possible negative numbers.
  "-" token <?> [ drop -1 ] <@ natural2 <&> [ 1 [ * ] reduce ] <@  ;

: identifier ( -- parser )
  #! Parse identifiers
  [ letter? ] satisfy <+> [ car cat ] <@ ;

: identifier2 ( -- parser )
  #! Parse identifiers
  [ letter? ] satisfy <!+> [ car cat ] <@  ;

: ints ( -- parser )
  integer "+" token [ drop [ [ + ] ] ] <@ <&> 
  integer <&> [ call swap call ] <@ ;

: url-quotable ( -- parser )
 ! [a-zA-Z0-9/_?] re-matches
 [ letter? ] satisfy 
 [ LETTER? ] satisfy <|>
 [ digit? ] satisfy <|>
 CHAR: / symbol <|>
 CHAR: _ symbol <|>
 CHAR: ? symbol <|> just ;
 
: http-header ( -- parser )
  [ CHAR: : = not ] satisfy <!+> [ car cat ] <@
  ": " token [ drop f ] <@ <&>
  [ drop t ] satisfy <!+> [ car cat ] <@ <&> just ;

: parse-http-header ( string -- [ name value ] )
  http-header call lcar car ;

: get-request ( -- parser )
  "GET" token 
  [ drop t ] satisfy <!+> sp [ car cat ] <@ <&> ; 
 
: post-request ( -- parser )
  "POST" token 
  [ drop t ] satisfy <!+> sp [ car cat ] <@ <&> ; 

: all-request ( -- parser )
  "POST" token
  [ 32 = not  ] satisfy <!+> sp [ car cat ] <@ <&>
  "HTTP/1.0" token sp <&> ;

: split-url ( -- parser )
  "http://" token 
  [ CHAR: / = not ] satisfy <!*> [ car cat ] <@ <&>
  "/" token <&>
  [ drop t ] satisfy <!*> [ car cat ] <@ <&> ;

