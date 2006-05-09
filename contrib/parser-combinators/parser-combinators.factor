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
USING: lazy kernel sequences strings lists math io ;
IN: parser-combinators

GENERIC: phead

M: string phead ( object -- head )
  #! Polymorphic head. Return the head item of the object. 
  #! For a string this is the first character.
  0 swap nth ;

M: list phead ( object -- head )
  #! Polymorphic head. Return the head item of the object. 
  #! For a list this is the car.
  car ;

M: cons phead ( object -- head )
  #! Polymorphic head. Return the head item of the object. 
  #! For a list this is the car.
  car ;

GENERIC: ptail

M: string ptail ( object -- tail )
  #! Polymorphic tail. Return the tail of the object.
  #! For a string this is everything but the first character.
  1 swap tail ;

M: list ptail ( object -- tail )
  #! Polymorphic tail. Return the tail of the object.
  #! For a list this is the cdr.
  cdr ;

M: cons ptail ( object -- tail )
  #! Polymorphic tail. Return the tail of the object.
  #! For a list this is the cdr.
  cdr ;

: pfirst ( object -- first )
  #! Polymorphic first. The first item in a collection.
  phead ;

GENERIC: psecond

M: string psecond ( object -- second )
  #! Polymorphic second
  1 swap nth ;

M: list psecond ( object -- second )
  #! Polymorphic second
  cdr car ;

: ph:t ( object -- head tail )
  #! Return the head and tail of the object.
  dup phead swap ptail ;

GENERIC: pempty?

M: string pempty? ( object -- bool )
  #! Return true if the collection is empty.
  length 0 = ;

M: list pempty? ( object -- bool )
  #! Return true if the collection is empty.
  not ;

: string-take ( n string -- string )
  #! Return a string with the first 'n' characters
  #! of the original string.
  dup length pick < [
    2drop ""
  ] [
    head
  ] if ;

: (list-take) ( n list accum -- list )
  >r >r 1 - dup 0 < [ 
    drop r> drop r> reverse 
  ] [ 
    r> uncons swap r> cons (list-take) 
  ] if ;

: list-take ( n list -- list )
  #! Return a list with the first 'n' characters
  #! of the original list.
  [ ] (list-take) ;

GENERIC: ptake

M: string ptake ( n object -- object )
  #! Polymorphic take.
  #! Return a collection of the first 'n' 
  #! characters from the original collection.
  string-take ;

M: list ptake ( n object -- object )
  #! Polymorphic take.
  #! Return a collection of the first 'n' 
  #! characters from the original collection.
  list-take ;

: string-drop ( n string -- string )
  #! Return a string with the first 'n' characters
  #! of the original string removed.
  dup length pick < [
    2drop "" 
  ] [
    tail 
  ] if ;

: list-drop ( n list -- list )
  #! Return a list with the first 'n' items
  #! of the original list removed.
  >r 1 - dup 0 < [ 
    drop r>
  ] [
    r> cdr list-drop
  ] if ;

GENERIC: pdrop

M: string pdrop ( n object -- object )
  #! Polymorphic drop.
  #! Return a collection the same as 'object'
  #! but with the first n items removed. 
  string-drop ;

M: list pdrop ( n object -- object )
  #! Polymorphic drop.
  #! Return a collection the same as 'object'
  #! but with the first n items removed. 
  list-drop ;

: token-parser ( inp sequence -- llist )
  #! A parser that parses a specific sequence of
  #! characters.
  2dup length swap ptake over = [
    swap over length swap pdrop swons unit delay lunit
  ] [
    2drop lnil
  ] if ;

: token ( string -- parser )
  #! Return a token parser that parses the given string.
  [ token-parser ] cons ;

: satisfy-parser ( inp pred -- llist )
  #! A parser that succeeds if the predicate,
  #! when passed the first character in the input, returns
  #! true.
  over pempty? [
    2drop lnil
  ] [        
    over phead swap call [
      ph:t swons unit delay lunit
    ] [
      drop lnil
    ] if
  ] if ;
  
: satisfy ( p -- parser )
  #! Return a parser that succeeds if the predicate 'p',
  #! when passed the first character in the input, returns
  #! true.
  [ satisfy-parser ] cons ;

: satisfy2-parser ( inp pred quot -- llist )
  #! A parser that succeeds if the predicate,
  #! when passed the first character in the input, returns
  #! true. On success the quotation is called with the
  #! successfully parsed character on the stack. The result
  #! of that call is returned as the result portion of the
  #! successfull parse lazy list.
  -rot over phead swap call [ ( quot inp -- )
    ph:t >r swap call r> swons unit delay lunit
  ] [
    2drop lnil
  ] if ;

  : satisfy2 ( pred quot -- parser )
  #! Return a satisfy2-parser.
  [ satisfy2-parser ] cons cons ;

: epsilon-parser ( input -- llist )
  #! A parser that parses the empty string. It
  #! does not consume any input and always returns
  #! an empty list as the parse tree with the
  #! unmodified input.
  "" cons unit delay lunit ;

: epsilon ( -- parser )
  #! Return an epsilon parser
  [ epsilon-parser ] ;

: succeed-parser ( input result -- llist )
  #! A parser that always returns 'result' as a
  #! successful parse with no input consumed.
  cons unit delay lunit ;

: succeed ( result -- parser )
  #! Return a succeed parser.
  [ succeed-parser ] cons ;

: fail-parser ( input -- llist )
  #! A parser that always fails and returns
  #! an empty list of successes.
  drop lnil ;

: fail ( -- parser )
  #! Return a fail-parser.
  [ fail-parser ] ;

: <&>-do-parser3 ( [[ x1 xs2 ]] x -- result )
  #! Called by <&>-do-parser2 on each result of the
  #! parse from parser2. 
  >r uncons r> ( x1 xs2 x )
  swap cons cons ;

: unswons uncons swap ;

: <&>-do-parser2 ( [[ x xs ]] parser2 -- result )
  #! Called by the <&>-parser on each result of the
  #! successfull parse of parser1. It's input is the
  #! cons containing the data parsed and the remaining
  #! input. This word will parser2 on the remaining input
  #! returning a new cons cell containing the combined
  #! parse result.
  >r unswons r> ( x xs parser2 )
  call swap    ( llist x )
  [ <&>-do-parser3 ] cons lmap ;

: <&>-parser ( input parser1 parser2 -- llist )
  #! Parse 'input' by sequentially combining the
  #! two parsers. First parser1 is applied to the
  #! input then parser2 is applied to the rest of
  #! the input strings from the first parser. 
  >r call r>   ( [[ x xs ]] p2 -- result )
  [ <&>-do-parser2 ] cons lmap lappend* ;

: <&> ( parser1 parser2 -- parser )
  #! Sequentially combine two parsers, returning a parser
  #! that first calls p1, then p2 all remaining results from
  #! p1. 
  [ <&>-parser ] cons cons ;

: <|>-parser ( input parser1 parser2 -- result )
  #! Return the combined list resulting from the parses
  #! of parser1 and parser2 being applied to the same
  #! input. This implements the choice parsing operator.
  >r dupd call swap r> call lappend ;

: <|> ( p1 p2 -- parser )
  #! Choice operator for parsers. Return a parser that does
  #! p1 or p2 depending on which will succeed.
  [ <|>-parser ] cons cons ;

: string-ltrim ( string -- string )
  #! Return a new string without any leading whitespace
  #! from the original string.
  dup phead blank? [ ptail string-ltrim ] when ;

: sp-parser ( input parser -- result )
  #! Skip all leading whitespace from the input then call
  #! the parser on the remaining input.
  >r string-ltrim r> call ;

: sp ( parser -- parser )
  #! Return a parser that first skips all whitespace before
  #! calling the original parser.
  [ sp-parser ] cons ;

: just-parser ( input parser -- result )
  #! Calls the given parser on the input removes
  #! from the results anything where the remaining
  #! input to be parsed is not empty. So ensures a 
  #! fully parsed input string.
  call [ car pempty? ] lsubset ;

: just ( parser -- parser )
  #! Return an instance of the just-parser.
  [ just-parser ] cons ;

: (<@-parser-replace) ( [[ inp result ]] quot -- [[ inp new-result ]] )
  #! Perform the result replacement step of <@-parser. 
  #! Given a successfull parse result, calls the quotation
  #! with the result portion on the stack. The result of
  #! that call is then used as the new result.
  swap uncons rot call cons ;

: <@-parser ( input parser quot -- result )
  #! Calls the parser on the input. For each successfull
  #! parse the quot is call with the parse result on the stack.
  #! The result of that quotation then becomes the new parse result.
  #! This allows modification of parse tree results (like
  #! converting strings to integers, etc).
  -rot call dup lnil? [ ( quot lnil -- )
    nip
  ] [ ( quot result -- )
    [ (<@-parser-replace) ] rot swons lmap
  ] if ;

: <@ ( parser quot -- parser )
  #! Return an <@-parser.
  [ <@-parser ] cons cons ;

: some-parser ( input parser -- result )
  #! Calls the parser on the input, guarantees
  #! the parse is complete (the remaining input is empty),
  #! picks the first solution and only returns the parse
  #! tree since the remaining input is empty.
  just call lcar cdr ;

: some ( parser -- deterministic-parser )
  #! Creates a 'some-parser'.
  [ some-parser ] cons ;

: <&-parser ( input parser1 parser2 -- result )
  #! Same as <&> except discard the results of the second parser.
  <&> [ phead ] <@ call ;

: <& ( parser1 parser2 -- parser )
  #! Same as <&> except discard the results of the second parser.
  [ <&-parser ] cons cons ;

: &>-parser ( input parser1 parser2 -- result )
  #! Same as <&> except discard the results of the first parser.
  <&> [ ptail ] <@ call ;

: &> ( parser1 parser2 -- parser )
  #! Same as <&> except discard the results of the first parser.
  [ &>-parser ] cons cons ;

: (a,(b,c))>((a,b,c)) ( list -- list )
  #! Convert a list where the car is a single value 
  #! and the cdr is a list to a list containing a flattened
  #! list.
  uncons car cons unit ;

: <:&>-parser ( input parser1 parser2 -- result )
  #! Same as <&> except postprocess the result with
  #! (a,(b,c))>((a,b,c)).
  <&> [ (a,(b,c))>((a,b,c)) ] <@ call ;

: <:&> ( parser1 parser2 -- parser )
  #! Same as <&> except postprocess the result with
  #! (a,(b,c))>((a,b,c)).
  [ <:&>-parser ] cons cons ;

DEFER: <*>

: (<*>) ( parser -- parser )
  #! Non-delayed implementation of <*>
  dup <*> <:&> [ ] succeed <|> ;
  
: <*> ( parser -- parser )
  #! Return a parser that accepts zero or more occurences of the original
  #! parser.
  [  (<*>) call ] cons ;

: (<+>) ( parser -- parser )
  #! Non-delayed implementation of <+>
  dup <*> <:&> ;
  
: <+> ( parser -- parser )
  #! Return a parser that accepts one or more occurences of the original
  #! parser.
  [  (<+>) call ] cons ;

: (<?>) ( parser -- parser )
  #! Non-delayed implementation of <?>
  [ unit ] <@ [ ] succeed <|> ;
  
: <?> ( parser -- parser )
  #! Return a parser that optionally uses the parser
  #! if that parser would be successfull.
  [  (<?>) call ] cons ;
