! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences strings namespaces math assocs shuffle 
       vectors arrays combinators.lib memoize math.parser match
       unicode.categories sequences.lib compiler.units parser
       words ;
IN: peg

TUPLE: parse-result remaining ast ;

GENERIC: compile ( parser -- quot )

: (parse) ( state parser -- result )
  compile call ;


<PRIVATE

SYMBOL: packrat-cache
SYMBOL: ignore 
SYMBOL: not-in-cache

: not-in-cache? ( result -- ? )
  not-in-cache = ;

: <parse-result> ( remaining ast -- parse-result )
  parse-result construct-boa ;

SYMBOL: next-id 

: get-next-id ( -- number )
  next-id get-global 0 or dup 1+ next-id set-global ;

TUPLE: parser id ;

: init-parser ( parser -- parser )
  get-next-id parser construct-boa over set-delegate ;

: from ( slice-or-string -- index )
  dup slice? [ slice-from ] [ drop 0 ] if ;

: get-cached ( input parser -- result )
  [ from ] dip parser-id packrat-cache get at at* [ 
    drop not-in-cache 
  ] unless ;

: put-cached ( result input parser -- )
  parser-id dup packrat-cache get at [ 
    nip
  ] [ 
    H{ } clone dup >r swap packrat-cache get set-at r>
  ] if* 
  [ from ] dip set-at ;

PRIVATE>

: parse ( input parser -- result )
  packrat-cache get [
    2dup get-cached dup not-in-cache? [ 
!      "cache missed: " write over parser-id number>string write " - " write nl ! pick .
      drop 
      #! Protect against left recursion blowing the callstack
      #! by storing a failed parse in the cache.
      [ f ] dipd  [ put-cached ] 2keep
      [ (parse) dup ] 2keep put-cached
    ] [ 
!      "cache hit: " write over parser-id number>string write " - " write nl ! pick . 
      2nip
    ] if
  ] [
    (parse)
  ] if ;

: packrat-parse ( input parser -- result )
  H{ } clone packrat-cache [ parse ] with-variable ;

<PRIVATE

TUPLE: token-parser symbol ;

MATCH-VARS: ?token ;

: token-pattern ( -- quot )
  [
    ?token 2dup head? [
      dup >r length tail-slice r> <parse-result>
    ] [
      2drop f
    ] if 
  ] ;
  
M: token-parser compile ( parser -- quot )
  token-parser-symbol \ ?token token-pattern match-replace ;
      
TUPLE: satisfy-parser quot ;

MATCH-VARS: ?quot ;

: satisfy-pattern ( -- quot )
  [
    dup empty? [
      drop f 
    ] [
      unclip-slice dup ?quot call [  
        <parse-result>
      ] [
        2drop f
      ] if
    ] if 
  ] ;

M: satisfy-parser compile ( parser -- quot )
  satisfy-parser-quot \ ?quot satisfy-pattern match-replace ;

TUPLE: range-parser min max ;

MATCH-VARS: ?min ?max ;

: range-pattern ( -- quot )
  [
    dup empty? [
      drop f
    ] [
      0 over nth dup 
      ?min ?max between? [
         [ 1 tail-slice ] dip <parse-result>
      ] [
        2drop f
      ] if
    ] if 
  ] ;

M: range-parser compile ( parser -- quot )
  T{ range-parser _ ?min ?max } range-pattern match-replace ;

TUPLE: seq-parser parsers ;

: seq-pattern ( -- quot )
  [
    dup [
      dup parse-result-remaining ?quot call [
        [ parse-result-remaining swap set-parse-result-remaining ] 2keep
        parse-result-ast dup ignore = [ 
          drop  
        ] [ 
          swap [ parse-result-ast push ] keep 
        ] if
      ] [
        drop f 
      ] if*
    ] [
      drop f
    ] if  
  ] ;

M: seq-parser compile ( parser -- quot )
  [
    [ V{ } clone <parse-result> ] %
    seq-parser-parsers [ compile \ ?quot seq-pattern match-replace % ] each 
  ] [ ] make ;

TUPLE: choice-parser parsers ;

: choice-pattern ( -- quot )
  [
    dup [
          
    ] [
      drop dup ?quot call   
    ] if
  ] ;

M: choice-parser compile ( parser -- quot )
  [
    f ,
    choice-parser-parsers [ compile \ ?quot choice-pattern match-replace % ] each
    \ nip ,
  ] [ ] make ;

TUPLE: repeat0-parser p1 ;

: (repeat0) ( quot result -- result )
  2dup parse-result-remaining swap call [
    [ parse-result-remaining swap set-parse-result-remaining ] 2keep 
    parse-result-ast swap [ parse-result-ast push ] keep
    (repeat0) 
 ] [
    nip
  ] if* ; inline

: repeat0-pattern ( -- quot )
  [
    ?quot swap (repeat0) 
  ] ;

M: repeat0-parser compile ( parser -- quot )
  [
    [ V{ } clone <parse-result> ] %
    repeat0-parser-p1 compile \ ?quot repeat0-pattern match-replace %        
  ] [ ] make ;

TUPLE: repeat1-parser p1 ;

: repeat1-pattern ( -- quot )
  [
    ?quot swap (repeat0) [
      dup parse-result-ast empty? [
        drop f
      ] when  
    ] [
      f 
    ] if*
  ] ;

M: repeat1-parser compile ( parser -- quot )
  [
    [ V{ } clone <parse-result> ] %
    repeat1-parser-p1 compile \ ?quot repeat1-pattern match-replace % 
  ] [ ] make ;

TUPLE: optional-parser p1 ;

: optional-pattern ( -- quot )
  [
    dup ?quot call swap f <parse-result> or 
  ] ;

M: optional-parser compile ( parser -- quot )
  optional-parser-p1 compile \ ?quot optional-pattern match-replace ;

TUPLE: ensure-parser p1 ;

: ensure-pattern ( -- quot )
  [
    dup ?quot call [
      ignore <parse-result>
    ] [
      drop f
    ] if
  ] ;

M: ensure-parser compile ( parser -- quot )
  ensure-parser-p1 compile \ ?quot ensure-pattern match-replace ;

TUPLE: ensure-not-parser p1 ;

: ensure-not-pattern ( -- quot )
  [
    dup ?quot call [
      drop f
    ] [
      ignore <parse-result>
    ] if
  ] ;

M: ensure-not-parser compile ( parser -- quot )
  ensure-not-parser-p1 compile \ ?quot ensure-not-pattern match-replace ;

TUPLE: action-parser p1 quot ;

MATCH-VARS: ?action ;

: action-pattern ( -- quot )
  [
    ?quot call dup [ 
      dup parse-result-ast ?action call
      swap [ set-parse-result-ast ] keep
    ] when 
  ] ;

M: action-parser compile ( parser -- quot )
  { action-parser-p1 action-parser-quot } get-slots [ compile ] dip 
  2array { ?quot ?action } action-pattern match-replace ;

: left-trim-slice ( string -- string )
  #! Return a new string without any leading whitespace
  #! from the original string.
  dup empty? [
    dup first blank? [ 1 tail-slice left-trim-slice ] when
  ] unless ;

TUPLE: sp-parser p1 ;

M: sp-parser compile ( parser -- quot )
  [
    \ left-trim-slice , sp-parser-p1 compile % 
  ] [ ] make ;

TUPLE: delay-parser quot ;

M: delay-parser compile ( parser -- quot )
  [
    delay-parser-quot % \ compile , \ call ,
  ] [ ] make ;

PRIVATE>

MEMO: token ( string -- parser )
  token-parser construct-boa init-parser ;      

: satisfy ( quot -- parser )
  satisfy-parser construct-boa init-parser ;

MEMO: range ( min max -- parser )
  range-parser construct-boa init-parser ;

: seq ( seq -- parser )
  seq-parser construct-boa init-parser ;

: 2seq ( parser1 parser2 -- parser )
  2array seq ;

: 3seq ( parser1 parser2 parser3 -- parser )
  3array seq ;

: 4seq ( parser1 parser2 parser3 parser4 -- parser )
  4array seq ;

: seq* ( quot -- paser )
  { } make seq ; inline 

: choice ( seq -- parser )
  choice-parser construct-boa init-parser ;

: 2choice ( parser1 parser2 -- parser )
  2array choice ;

: 3choice ( parser1 parser2 parser3 -- parser )
  3array choice ;

: 4choice ( parser1 parser2 parser3 parser4 -- parser )
  4array choice ;

: choice* ( quot -- paser )
  { } make choice ; inline 

MEMO: repeat0 ( parser -- parser )
  repeat0-parser construct-boa init-parser ;

MEMO: repeat1 ( parser -- parser )
  repeat1-parser construct-boa init-parser ;

MEMO: optional ( parser -- parser )
  optional-parser construct-boa init-parser ;

MEMO: ensure ( parser -- parser )
  ensure-parser construct-boa init-parser ;

MEMO: ensure-not ( parser -- parser )
  ensure-not-parser construct-boa init-parser ;

: action ( parser quot -- parser )
  action-parser construct-boa init-parser ;

MEMO: sp ( parser -- parser )
  sp-parser construct-boa init-parser ;

MEMO: hide ( parser -- parser )
  [ drop ignore ] action ;

MEMO: delay ( quot -- parser )
  delay-parser construct-boa init-parser ;

: PEG:
  (:) [
    [
        call compile
        [ dup [ parse-result-ast ] [ "Parse failed" throw ] if ]
        append define
    ] with-compilation-unit
  ] 2curry over push-all ; parsing
