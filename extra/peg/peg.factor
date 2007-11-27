! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences strings namespaces math assocs shuffle vectors combinators.lib ;
IN: peg

TUPLE: parse-result remaining ast ;

GENERIC: parse ( state parser -- result )

<PRIVATE

SYMBOL: ignore 

: <parse-result> ( remaining ast -- parse-result )
  parse-result construct-boa ;

SYMBOL: next-id 

: get-next-id ( -- number )
  next-id get-global 0 or dup 1+ next-id set-global ;

TUPLE: parser id ;

: init-parser ( parser -- parser )
  get-next-id parser construct-boa over set-delegate ;

TUPLE: token-parser symbol ;

M: token-parser parse ( state parser -- result )
  token-parser-symbol 2dup head? [
    dup >r length tail-slice r> <parse-result>
  ] [
    2drop f
  ] if ;

TUPLE: satisfy-parser quot ;

M: satisfy-parser parse ( state parser -- result )
  over empty? [
    2drop f 
  ] [
    satisfy-parser-quot [ unclip-slice dup ] dip call [  
      <parse-result>
    ] [
      2drop f
    ] if
  ] if ;

TUPLE: range-parser min max ;

M: range-parser parse ( state parser -- result )
  over empty? [
    2drop f
  ] [
    0 pick nth dup rot 
    { range-parser-min range-parser-max } get-slots between? [
      [ 1 tail-slice ] dip <parse-result>
    ] [
      2drop f
    ] if
  ] if ;

TUPLE: seq-parser parsers ;

: do-seq-parser ( result parser -- result )
  [ dup parse-result-remaining ] dip parse [
    [ parse-result-remaining swap set-parse-result-remaining ] 2keep  
    parse-result-ast dup ignore = [ drop ] [ swap [ parse-result-ast push ] keep ] if
  ] [
    drop f
  ] if* ;

: (seq-parser) ( result parsers -- result )
  dup empty? not pick and [
    unclip swap [ do-seq-parser ] dip (seq-parser)
  ] [
    drop   
  ] if ;

M: seq-parser parse ( state parser -- result )
  seq-parser-parsers [ V{ } clone <parse-result> ] dip  (seq-parser) ;

TUPLE: choice-parser parsers ;
  
: (choice-parser) ( state parsers -- result )
  dup empty? [
    2drop f
  ] [
    unclip pick swap parse [
      2nip 
    ] [
      (choice-parser)
    ] if* 
  ] if ;

M: choice-parser parse ( state parser -- result )
  choice-parser-parsers (choice-parser) ;

TUPLE: repeat0-parser p1 ;

: (repeat-parser) ( parser result -- result )
  2dup parse-result-remaining swap parse [
    [ parse-result-remaining swap set-parse-result-remaining ] 2keep 
    parse-result-ast swap [ parse-result-ast push ] keep
    (repeat-parser) 
 ] [
    nip
  ] if* ;

: clone-result ( result -- result )
  { parse-result-remaining parse-result-ast }
  get-slots 1vector  <parse-result> ;

M: repeat0-parser parse ( state parser -- result )
     repeat0-parser-p1 2dup parse [ 
       nipd clone-result (repeat-parser) 
     ] [ 
       drop V{ } clone <parse-result> 
     ] if* ;

TUPLE: repeat1-parser p1 ;

M: repeat1-parser parse ( state parser -- result )
   repeat1-parser-p1 tuck parse dup [ clone-result (repeat-parser) ] [ nip ] if ;

TUPLE: optional-parser p1 ;

M: optional-parser parse ( state parser -- result )
   dupd optional-parser-p1 parse swap f <parse-result> or ;

TUPLE: ensure-parser p1 ;

M: ensure-parser parse ( state parser -- result )
   dupd ensure-parser-p1 parse [
     ignore <parse-result>  
   ] [
     drop f
   ] if ;

TUPLE: ensure-not-parser p1 ;

M: ensure-not-parser parse ( state parser -- result )
   dupd ensure-not-parser-p1 parse [
     drop f
   ] [
     ignore <parse-result>  
   ] if ;

TUPLE: action-parser p1 quot ;

M: action-parser parse ( state parser -- result )
   tuck action-parser-p1 parse dup [ 
     dup parse-result-ast rot action-parser-quot call
     swap [ set-parse-result-ast ] keep
   ] [
     nip
   ] if ;

: left-trim-slice ( string -- string )
  #! Return a new string without any leading whitespace
  #! from the original string.
  dup empty? [
    dup first blank? [ 1 tail-slice left-trim-slice ] when
  ] unless ;

TUPLE: sp-parser p1 ;

M: sp-parser parse ( state parser -- result )
  [ left-trim-slice ] dip sp-parser-p1 parse ;

TUPLE: delay-parser quot ;

M: delay-parser parse ( state parser -- result )
  delay-parser-quot call parse ;

PRIVATE>

: token ( string -- parser )
  token-parser construct-boa init-parser ;      

: satisfy ( quot -- parser )
  satisfy-parser construct-boa init-parser ;

: range ( min max -- parser )
  range-parser construct-boa init-parser ;

: seq ( seq -- parser )
  seq-parser construct-boa init-parser ;

: choice ( seq -- parser )
  choice-parser construct-boa init-parser ;

: repeat0 ( parser -- parser )
  repeat0-parser construct-boa init-parser ;

: repeat1 ( parser -- parser )
  repeat1-parser construct-boa init-parser ;

: optional ( parser -- parser )
  optional-parser construct-boa init-parser ;

: ensure ( parser -- parser )
  ensure-parser construct-boa init-parser ;

: ensure-not ( parser -- parser )
  ensure-not-parser construct-boa init-parser ;

: action ( parser quot -- parser )
  action-parser construct-boa init-parser ;

: sp ( parser -- parser )
  sp-parser construct-boa init-parser ;

: hide ( parser -- parser )
  [ drop ignore ] action ;

: delay ( parser -- parser )
  delay-parser construct-boa init-parser ;
