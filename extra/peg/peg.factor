! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences strings namespaces math assocs shuffle vectors combinators.lib ;
IN: peg

SYMBOL: ignore 

TUPLE: parse-result remaining ast ;

: <parse-result> ( remaining ast -- parse-result )
  parse-result construct-boa ;

SYMBOL: next-id 

: get-next-id ( -- number )
  next-id get-global 0 or dup 1+ next-id set-global ;

TUPLE: parser id ;

: init-parser ( parser -- parser )
  get-next-id parser construct-boa over set-delegate ;

GENERIC: parse ( state parser -- result )

TUPLE: token-parser symbol ;

M: token-parser parse ( state parser -- result )
  token-parser-symbol 2dup head? [
    dup >r length tail-slice r> <parse-result>
  ] [
    2drop f
  ] if ;

: token ( string -- parser )
  token-parser construct-boa init-parser ;      

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

: range ( min max -- parser )
  range-parser construct-boa init-parser ;

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

: seq ( seq -- parser )
  seq-parser construct-boa init-parser ;

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

: choice ( seq -- parser )
  choice-parser construct-boa init-parser ;

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

: repeat0 ( parser -- parser )
  repeat0-parser construct-boa init-parser ;

TUPLE: repeat1-parser p1 ;

M: repeat1-parser parse ( state parser -- result )
   repeat1-parser-p1 tuck parse dup [ clone-result (repeat-parser) ] [ nip ] if ;

: repeat1 ( parser -- parser )
  repeat1-parser construct-boa init-parser ;

TUPLE: optional-parser p1 ;

M: optional-parser parse ( state parser -- result )
   dupd optional-parser-p1 parse swap f <parse-result> or ;

: optional ( parser -- parser )
  optional-parser construct-boa init-parser ;

TUPLE: ensure-parser p1 ;

M: ensure-parser parse ( state parser -- result )
   dupd ensure-parser-p1 parse [
     ignore <parse-result>  
   ] [
     drop f
   ] if ;

: ensure ( parser -- parser )
  ensure-parser construct-boa init-parser ;

TUPLE: ensure-not-parser p1 ;

M: ensure-not-parser parse ( state parser -- result )
   dupd ensure-not-parser-p1 parse [
     drop f
   ] [
     ignore <parse-result>  
   ] if ;

: ensure-not ( parser -- parser )
  ensure-not-parser construct-boa init-parser ;

TUPLE: action-parser p1 quot ;

M: action-parser parse ( state parser -- result )
   tuck action-parser-p1 parse dup [ 
     dup parse-result-ast rot action-parser-quot call
     swap [ set-parse-result-ast ] keep
   ] [
     nip
   ] if ;

: action ( parser quot -- parser )
  action-parser construct-boa init-parser ;
