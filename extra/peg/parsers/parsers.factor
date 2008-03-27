! Copyright (C) 2007, 2008 Chris Double, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences strings namespaces math assocs shuffle 
     vectors arrays combinators.lib math.parser match
     unicode.categories sequences.deep peg peg.private 
     peg.search math.ranges words memoize ;
IN: peg.parsers

TUPLE: just-parser p1 ;
M: just-parser equal? 2drop f ;

: just-pattern
  [
    execute dup [
      dup parse-result-remaining empty? [ drop f ] unless
    ] when
  ] ;


M: just-parser (compile) ( parser -- quot )
  just-parser-p1 compiled-parser just-pattern curry ;

MEMO: just ( parser -- parser )
  just-parser construct-boa ;

: 1token ( ch -- parser ) 1string token ;

<PRIVATE
: (list-of) ( items separator repeat1? -- parser )
  >r over 2seq r> [ repeat1 ] [ repeat0 ] if [ concat ] action 2seq
  [ unclip 1vector swap first append ] action ;
PRIVATE>

: list-of ( items separator -- parser )
  hide f (list-of) ;

: list-of-many ( items separator -- parser )
  hide t (list-of) ;

: epsilon ( -- parser ) V{ } token ;

: any-char ( -- parser ) [ drop t ] satisfy ;

<PRIVATE

: flatten-vectors ( pair -- vector )
  first2 over push-all ;

PRIVATE>

MEMO: exactly-n ( parser n -- parser' )
  swap <repetition> seq ;

MEMO: at-most-n ( parser n -- parser' )
  dup zero? [
    2drop epsilon
  ] [
    2dup exactly-n
    -rot 1- at-most-n 2choice
  ] if ;

MEMO: at-least-n ( parser n -- parser' )
  dupd exactly-n swap repeat0 2seq
  [ flatten-vectors ] action ;

MEMO: from-m-to-n ( parser m n -- parser' )
  >r [ exactly-n ] 2keep r> swap - at-most-n 2seq
  [ flatten-vectors ] action ;

MEMO: pack ( begin body end -- parser )
  >r >r hide r> r> hide 3seq [ first ] action ;

: surrounded-by ( parser begin end -- parser' )
  [ token ] 2apply swapd pack ;

: 'digit' ( -- parser )
  [ digit? ] satisfy [ digit> ] action ;

: 'integer' ( -- parser )
  'digit' repeat1 [ 10 digits>integer ] action ;

: 'string' ( -- parser )
  [
    [ CHAR: " = ] satisfy hide ,
    [ CHAR: " = not ] satisfy repeat0 ,
    [ CHAR: " = ] satisfy hide ,
  ] seq* [ first >string ] action ;

: (range-pattern) ( pattern -- string )
  #! Given a range pattern, produce a string containing
  #! all characters within that range.
  [ 
    any-char , 
    [ CHAR: - = ] satisfy hide , 
    any-char , 
  ] seq* [
    first2 [a,b] >string    
  ] action
  replace ;

: range-pattern ( pattern -- parser )
  #! 'pattern' is a set of characters describing the
  #! parser to be produced. Any single character in
  #! the pattern matches that character. If the pattern
  #! begins with a ^ then the set is negated (the element
  #! matches any character not in the set). Any pair of
  #! characters separated with a dash (-) represents the
  #! range of characters from the first to the second,
  #! inclusive.
  dup first CHAR: ^ = [
    1 tail (range-pattern) [ member? not ] curry satisfy 
  ] [
    (range-pattern) [ member? ] curry satisfy
  ] if ;
