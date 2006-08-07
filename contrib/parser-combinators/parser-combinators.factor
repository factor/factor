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
USING: lazy-lists kernel sequences strings math io arrays errors namespaces ;
IN: parser-combinators

TUPLE: parse-result parsed unparsed ;

: h:t ( object -- head tail )
  #! Return the head and tail of the object.
  dup empty? [ dup first swap 1 tail ] unless ;

: token-parser ( inp sequence -- llist )
  #! A parser that parses a specific sequence of
  #! characters.
  [
    2dup length head over = [
      swap over length tail <parse-result> lunit
    ] [
      2drop nil
    ] if 
  ] [
    3drop nil
  ] recover ;

: token ( string -- parser )
  #! Return a token parser that parses the given string.
  [ token-parser ] curry ;

: satisfy-parser ( inp pred -- llist )
  #! A parser that succeeds if the predicate,
  #! when passed the first character in the input, returns
  #! true.
  over empty? [
    2drop nil
  ] [        
    over first swap call [
      h:t <parse-result> lunit
    ] [
      drop nil
    ] if
  ] if ;
  
: satisfy ( p -- parser )
  #! Return a parser that succeeds if the predicate 'p',
  #! when passed the first character in the input, returns
  #! true.
  [ satisfy-parser ] curry ;

: satisfy2-parser ( inp pred quot -- llist )
  #! A parser that succeeds if the predicate,
  #! when passed the first character in the input, returns
  #! true. On success the quotation is called with the
  #! successfully parsed character on the stack. The result
  #! of that call is returned as the result portion of the
  #! successfull parse lazy list.
  -rot over first swap call [ ( quot inp -- )
    h:t >r swap call r> <parse-result> lunit
  ] [
    2drop nil
  ] if ;

  : satisfy2 ( pred quot -- parser )
  #! Return a satisfy2-parser.
  [ satisfy2-parser ] curry curry ;

: epsilon-parser ( input -- llist )
  #! A parser that parses the empty string. It
  #! does not consume any input and always returns
  #! an empty list as the parse tree with the
  #! unmodified input.
  "" swap <parse-result> lunit ;

: epsilon ( -- parser )
  #! Return an epsilon parser
  [ epsilon-parser ] ;

: succeed-parser ( input result -- llist )
  #! A parser that always returns 'result' as a
  #! successful parse with no input consumed.
  swap <parse-result> lunit ;

: succeed ( result -- parser )
  #! Return a succeed parser.
  [ succeed-parser ] curry ;

: fail-parser ( input -- llist )
  #! A parser that always fails and returns
  #! an empty list of successes.
  drop nil ;

: fail ( -- parser )
  #! Return a fail-parser.
  [ fail-parser ] ;

: <&>-do-parser3 ( <parse-result> x -- result )
  #! Called by <&>-do-parser2 on each result of the
  #! parse from parser2. 
  >r dup parse-result-unparsed swap parse-result-parsed r> ( x1 xs2 x )
  swap 2array  swap <parse-result> ;

: <&>-do-parser2 ( <parse-result> parser2 -- result )
  #! Called by the <&>-parser on each result of the
  #! successfull parse of parser1. It's input is the
  #! cons containing the data parsed and the remaining
  #! input. This word will parser2 on the remaining input
  #! returning a new cons cell containing the combined
  #! parse result.
  >r dup parse-result-parsed swap parse-result-unparsed r> ( x xs parser2 )
  call swap    ( llist x )
  [ <&>-do-parser3 ] curry lmap ;

: <&>-parser ( input parser1 parser2 -- llist )
  #! Parse 'input' by sequentially combining the
  #! two parsers. First parser1 is applied to the
  #! input then parser2 is applied to the rest of
  #! the input strings from the first parser. 
  >r call r>   ( <parse-result> p2 -- result )
  [ <&>-do-parser2 ] curry lmap lappend* ;

: <&> ( parser1 parser2 -- parser )
  #! Sequentially combine two parsers, returning a parser
  #! that first calls p1, then p2 all remaining results from
  #! p1. 
  [ <&>-parser ] curry curry ;

: <|>-parser ( input parser1 parser2 -- result )
  #! Return the combined list resulting from the parses
  #! of parser1 and parser2 being applied to the same
  #! input. This implements the choice parsing operator.
  >r dupd call swap r> call lappend ;

: <|> ( p1 p2 -- parser )
  #! Choice operator for parsers. Return a parser that does
  #! p1 or p2 depending on which will succeed.
  [ <|>-parser ] curry curry ;

: string-ltrim ( string -- string )
  #! Return a new string without any leading whitespace
  #! from the original string.
  dup first blank? [ 1 tail string-ltrim ] when ;

: sp-parser ( input parser -- result )
  #! Skip all leading whitespace from the input then call
  #! the parser on the remaining input.
  >r string-ltrim r> call ;

: sp ( parser -- parser )
  #! Return a parser that first skips all whitespace before
  #! calling the original parser.
  [ sp-parser ] curry ;

: just-parser ( input parser -- result )
  #! Calls the given parser on the input removes
  #! from the results anything where the remaining
  #! input to be parsed is not empty. So ensures a 
  #! fully parsed input string.
  call [ parse-result-unparsed empty? ] lsubset ;

: just ( parser -- parser )
  #! Return an instance of the just-parser.
  [ just-parser ] curry ;

: (<@-parser-replace) ( [[ inp result ]] quot -- [[ inp new-result ]] )
  #! Perform the result replacement step of <@-parser. 
  #! Given a successfull parse result, calls the quotation
  #! with the result portion on the stack. The result of
  #! that call is then used as the new result.
  swap dup parse-result-unparsed swap parse-result-parsed rot call swap <parse-result> ;

: <@-parser ( input parser quot -- result )
  #! Calls the parser on the input. For each successfull
  #! parse the quot is call with the parse result on the stack.
  #! The result of that quotation then becomes the new parse result.
  #! This allows modification of parse tree results (like
  #! converting strings to integers, etc).
  -rot call dup nil? [ ( quot nil -- )
    nip
  ] [ ( quot result -- )
    [ (<@-parser-replace) ] rot swap curry lmap
  ] if ;

: <@ ( parser quot -- parser )
  #! Return an <@-parser.
  [ <@-parser ] curry curry ;

: some-parser ( input parser -- result )
  #! Calls the parser on the input, guarantees
  #! the parse is complete (the remaining input is empty),
  #! picks the first solution and only returns the parse
  #! tree since the remaining input is empty.
  just call car parse-result-parsed ;

: some ( parser -- deterministic-parser )
  #! Creates a 'some-parser'.
  [ some-parser ] curry ;

: <&-parser ( input parser1 parser2 -- result )
  #! Same as <&> except discard the results of the second parser.
  <&> [ first ] <@ call ;

: <& ( parser1 parser2 -- parser )
  #! Same as <&> except discard the results of the second parser.
  [ <&-parser ] curry curry ;

: &>-parser ( input parser1 parser2 -- result )
  #! Same as <&> except discard the results of the first parser.
  <&> [ second ] <@ call ;

: &> ( parser1 parser2 -- parser )
  #! Same as <&> except discard the results of the first parser.
  [ &>-parser ] curry curry ;

: <:&>-parser ( input parser1 parser2 -- result )
  #! Same as <&> except flatten the result.
  <&> [ dup second swap first [ % , ] { } make ] <@ call ;

: <:&> ( parser1 parser2 -- parser )
  #! Same as <&> except flatten the result.
  [ <:&>-parser ] curry curry ;

: <&:>-parser ( input parser1 parser2 -- result )
  #! Same as <&> except flatten the result.
  <&> [ dup second swap first [ , % ] { } make ] <@ call ;

: <&:> ( parser1 parser2 -- parser )
  #! Same as <&> except flatten the result.
  [ <&:>-parser ] curry curry ;

DEFER: <*>

: (<*>) ( parser -- parser )
  #! Non-delayed implementation of <*>
  dup <*> <&:> [ ] succeed <|> ;
  
: <*> ( parser -- parser )
  #! Return a parser that accepts zero or more occurences of the original
  #! parser.
  [  (<*>) call ] curry ;

: (<+>) ( parser -- parser )
  #! Non-delayed implementation of <+>
  dup <*> <&:> ;
  
: <+> ( parser -- parser )
  #! Return a parser that accepts one or more occurences of the original
  #! parser.
  [  (<+>) call ] curry ;

: (<?>) ( parser -- parser )
  #! Non-delayed implementation of <?>
  [ unit ] <@ f succeed <|> ;
  
: <?> ( parser -- parser )
  #! Return a parser that optionally uses the parser
  #! if that parser would be successfull.
  [  (<?>) call ] curry ;
