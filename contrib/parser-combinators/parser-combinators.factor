! Copyright (C) 2004 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
USING: lazy-lists kernel sequences strings math io arrays errors namespaces ;
IN: parser-combinators

! Parser combinator protocol
GENERIC: (parse) ( input parser -- list )

: parse ( input parser -- promise )
  [ (parse) ] curry curry <promise> ;

TUPLE: parse-result parsed unparsed ;

: ?head-slice ( seq begin -- newseq ? )
  2dup head? [ length tail-slice t ] [ drop f ] if ;

: unclip-slice ( seq -- rest first )
  dup 1 tail-slice swap first ;

: h:t ( object -- head tail )
  #! Return the head and tail of the object.
  dup empty? [ dup first swap 1 tail ] unless ;

TUPLE: token-parser string ;

: token ( string -- parser )
  <token-parser> ;

M: token-parser (parse) ( input parser -- list )
  token-parser-string swap over ?head-slice [
    <parse-result> 1list    
  ] [
    2drop nil
  ] if ;

TUPLE: satisfy-parser quot ;

: satisfy ( quot -- parser )
  <satisfy-parser> ;

M: satisfy-parser (parse) ( input parser -- list )
  #! A parser that succeeds if the predicate,
  #! when passed the first character in the input, returns
  #! true.
  satisfy-parser-quot >r unclip-slice dup r> call [
    swap <parse-result> 1list
  ] [
    2drop nil
  ] if ;

TUPLE: epsilon-parser ;

: epsilon ( -- list )
  <epsilon-parser> ;

M: epsilon-parser (parse) ( input parser -- list )
  #! A parser that parses the empty string. It
  #! does not consume any input and always returns
  #! an empty list as the parse tree with the
  #! unmodified input.
  drop "" swap <parse-result> 1list ;

TUPLE: succeed-parser result ;

: succeed ( result -- parser )
  <succeed-parser> ;

M: succeed-parser (parse) ( input parser -- list )
  #! A parser that always returns 'result' as a
  #! successful parse with no input consumed.  
  succeed-parser-result swap <parse-result> 1list ;

TUPLE: fail-parser ;

: fail ( -- parser )
  <fail-parser> ;

M: fail-parser (parse) ( input parser -- list )
  #! A parser that always fails and returns
  #! an empty list of successes.
  2drop nil ;

TUPLE: and-parser p1 p2 ;

: <&> ( parser1 parser2 -- parser )
  <and-parser> ;

M: and-parser (parse) ( input parser -- list )
  #! Parse 'input' by sequentially combining the
  #! two parsers. First parser1 is applied to the
  #! input then parser2 is applied to the rest of
  #! the input strings from the first parser. 
  [ and-parser-p1 ] keep and-parser-p2 -rot parse [
    dup parse-result-unparsed rot parse
    [
      >r parse-result-parsed r>
      [ parse-result-parsed 2array ] keep
      parse-result-unparsed <parse-result>
    ] lmap-with
  ] lmap-with lconcat ;  

TUPLE: or-parser p1 p2 ;

: <|> ( parser1 parser2 -- parser )
  <or-parser> ;

M: or-parser (parse) ( input parser1 -- list )
  #! Return the combined list resulting from the parses
  #! of parser1 and parser2 being applied to the same
  #! input. This implements the choice parsing operator.
  [ or-parser-p1 ] keep or-parser-p2 >r dupd parse swap r> parse lappend ;

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

: <@-parser ( input parser quot -- result )
  #! Calls the parser on the input. For each successfull
  #! parse the quot is call with the parse result on the stack.
  #! The result of that quotation then becomes the new parse result.
  #! This allows modification of parse tree results (like
  #! converting strings to integers, etc).
  -rot call [ 
    [ parse-result-parsed swap call ] keep
    parse-result-unparsed <parse-result>
  ] lmap-with ;

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

: <& ( parser1 parser2 -- parser )
  #! Same as <&> except discard the results of the second parser.
  <&> [ first ] <@ ;

: &> ( parser1 parser2 -- parser )
  #! Same as <&> except discard the results of the first parser.
  <&> [ second ] <@ ;

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
