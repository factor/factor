! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math io io.streams.string sequences strings
lazy-lists combinators parser-combinators.simple ;
IN: parser-combinators 

: tree-write ( object -- )
  { 
    { [ dup number?   ] [ write1 ] }
    { [ dup string?   ] [ write ] }
    { [ dup sequence? ] [ [ tree-write ] each ] }
    { [ t             ] [ write ] }
  } cond ;

: search ( string parser -- seq )
  'any-char' [ drop f ] <@ <|> <*> parse dup nil? [
    drop { }
  ] [
    car parse-result-parsed [ ] subset 
  ] if ;

: search* ( string parsers -- seq )
  unclip [ <|> ] reduce 'any-char' [ drop f ] <@ <|> <*> parse dup nil? [
    drop { }
  ] [
    car parse-result-parsed [ ] subset 
  ] if ;

: (replace) ( string parser -- seq )
  'any-char' <|> <*> parse car parse-result-parsed ;

: replace ( string parser -- result )
 [  (replace) [ tree-write ] each ] string-out ;

: replace* ( string parsers -- result )
  swap [ replace ] reduce ;

