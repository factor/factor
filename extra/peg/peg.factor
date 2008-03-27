! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences strings namespaces math assocs shuffle 
       vectors arrays combinators.lib math.parser match
       unicode.categories sequences.lib compiler.units parser
       words quotations effects memoize accessors 
       combinators.cleave locals ;
IN: peg

TUPLE: parse-result remaining ast ;

SYMBOL: ignore 

: <parse-result> ( remaining ast -- parse-result )
  parse-result construct-boa ;

SYMBOL: packrat

: compiled-parsers ( -- cache )
  \ compiled-parsers get-global [ H{ } clone dup \ compiled-parsers set-global ] unless* ;

: reset-compiled-parsers ( -- )
  H{ } clone \ compiled-parsers set-global ;

GENERIC: (compile) ( parser -- quot )

: input-from ( input -- n )
  #! Return the index from the original string that the
  #! input slice is based on.
  dup slice? [ slice-from ] [ drop 0 ] if ;

: input-cache ( quot cache -- cache )
  #! From the packrat cache, obtain the cache for the parser quotation 
  #! that maps the input string position to the parser result.
  [ drop H{ } clone ] cache ;

:: cached-result ( n input-cache input quot -- result )
  #! Get the cached result for input position n
  #! from the input cache. If the item is not in the cache,
  #! call 'quot' with 'input' on the stack to get the result
  #! and store that in the cache and return it.
  n input-cache [ 
    drop
    f n input-cache set-at
    input quot call 
  ] cache ; inline

:: run-packrat-parser ( input quot c -- result )
  input input-from
  quot c input-cache 
  input quot cached-result ; inline

: run-parser ( input quot -- result )
  #! If a packrat cache is available, use memoization for
  #! packrat parsing, otherwise do a standard peg call.
  packrat get [ run-packrat-parser ] [ call ] if* ; inline

: compiled-parser ( parser -- word )
  #! Look to see if the given parser has been compiled.
  #! If not, compile it to a temporary word, cache it,
  #! and return it. Otherwise return the existing one.
  compiled-parsers [
    (compile) [ run-parser ] curry define-temp
  ] cache ;

: compile ( parser -- word )
  [ compiled-parser ] with-compilation-unit ;

: parse ( state parser -- result )
  compile execute ; inline

: with-packrat ( quot -- result )
  #! Run the quotation with a packrat cache active.
  [ H{ } clone packrat ] dip with-variable ; inline

: packrat-parse ( state parser -- result )
  [ parse ] with-packrat ;

: packrat-call ( state quot -- result )
  with-packrat ; inline

<PRIVATE

TUPLE: token-parser symbol ;
M: token-parser equal? 2drop f ;

MATCH-VARS: ?token ;

: parse-token ( input string -- result )
  #! Parse the string, returning a parse result
  2dup head? [
    dup >r length tail-slice r> <parse-result>
  ] [
    2drop f
  ] if ;

M: token-parser (compile) ( parser -- quot )
  symbol>> [ parse-token ] curry ;
      
TUPLE: satisfy-parser quot ;
M: satisfy-parser equal? 2drop f ;

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

M: satisfy-parser (compile) ( parser -- quot )
  quot>> \ ?quot satisfy-pattern match-replace ;

TUPLE: range-parser min max ;
M: range-parser equal? 2drop f ;

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

M: range-parser (compile) ( parser -- quot )
  T{ range-parser _ ?min ?max } range-pattern match-replace ;

TUPLE: seq-parser parsers ;
M: seq-parser equal? 2drop f ;

: seq-pattern ( -- quot )
  [
    dup [
      dup remaining>> ?quot [
        [ remaining>> swap (>>remaining) ] 2keep
        ast>> dup ignore = [ 
          drop  
        ] [ 
          swap [ ast>> push ] keep 
        ] if
      ] [
        drop f 
      ] if*
    ] [
      drop f
    ] if  
  ] ;

M: seq-parser (compile) ( parser -- quot )
  [
    [ V{ } clone <parse-result> ] %
    parsers>> [ compiled-parser \ ?quot seq-pattern match-replace % ] each 
  ] [ ] make ;

TUPLE: choice-parser parsers ;
M: choice-parser equal? 2drop f ;

: choice-pattern ( -- quot )
  [
    dup [
          
    ] [
      drop dup ?quot 
    ] if
  ] ;

M: choice-parser (compile) ( parser -- quot )
  [
    f ,
    parsers>> [ compiled-parser \ ?quot choice-pattern match-replace % ] each
    \ nip ,
  ] [ ] make ;

TUPLE: repeat0-parser p1 ;
M: repeat0-parser equal? 2drop f ;

: (repeat0) ( quot result -- result )
  2dup remaining>> swap call [
    [ remaining>> swap (>>remaining) ] 2keep 
    ast>> swap [ ast>> push ] keep
    (repeat0) 
 ] [
    nip
  ] if* ; inline

: repeat0-pattern ( -- quot )
  [
    [ ?quot ] swap (repeat0) 
  ] ;

M: repeat0-parser (compile) ( parser -- quot )
  [
    [ V{ } clone <parse-result> ] %
    p1>> compiled-parser \ ?quot repeat0-pattern match-replace %        
  ] [ ] make ;

TUPLE: repeat1-parser p1 ;
M: repeat1-parser equal? 2drop f ;

: repeat1-pattern ( -- quot )
  [
    [ ?quot ] swap (repeat0) [
      dup ast>> empty? [
        drop f
      ] when  
    ] [
      f 
    ] if*
  ] ;

M: repeat1-parser (compile) ( parser -- quot )
  [
    [ V{ } clone <parse-result> ] %
    p1>> compiled-parser \ ?quot repeat1-pattern match-replace % 
  ] [ ] make ;

TUPLE: optional-parser p1 ;
M: optional-parser equal? 2drop f ;

: optional-pattern ( -- quot )
  [
    dup ?quot swap f <parse-result> or 
  ] ;

M: optional-parser (compile) ( parser -- quot )
  p1>> compiled-parser \ ?quot optional-pattern match-replace ;

TUPLE: ensure-parser p1 ;
M: ensure-parser equal? 2drop f ;

: ensure-pattern ( -- quot )
  [
    dup ?quot [
      ignore <parse-result>
    ] [
      drop f
    ] if
  ] ;

M: ensure-parser (compile) ( parser -- quot )
  p1>> compiled-parser \ ?quot ensure-pattern match-replace ;

TUPLE: ensure-not-parser p1 ;
M: ensure-not-parser equal? 2drop f ;

: ensure-not-pattern ( -- quot )
  [
    dup ?quot [
      drop f
    ] [
      ignore <parse-result>
    ] if
  ] ;

M: ensure-not-parser (compile) ( parser -- quot )
  p1>> compiled-parser \ ?quot ensure-not-pattern match-replace ;

TUPLE: action-parser p1 quot ;
M: action-parser equal? 2drop f ;

MATCH-VARS: ?action ;

: action-pattern ( -- quot )
  [
    ?quot dup [ 
      dup ast>> ?action call
      >>ast
    ] when 
  ] ;

M: action-parser (compile) ( parser -- quot )
  { [ p1>> ] [ quot>> ] } cleave [ compiled-parser ] dip 
  2array { ?quot ?action } action-pattern match-replace ;

: left-trim-slice ( string -- string )
  #! Return a new string without any leading whitespace
  #! from the original string.
  dup empty? [
    dup first blank? [ 1 tail-slice left-trim-slice ] when
  ] unless ;

TUPLE: sp-parser p1 ;
M: sp-parser equal? 2drop f ;

M: sp-parser (compile) ( parser -- quot )
  [
    \ left-trim-slice , p1>> compiled-parser , 
  ] [ ] make ;

TUPLE: delay-parser quot ;
M: delay-parser equal? 2drop f ;

M: delay-parser (compile) ( parser -- quot )
  #! For efficiency we memoize the quotation.
  #! This way it is run only once and the 
  #! parser constructed once at run time.
  [
    quot>> % \ compile ,
  ] [ ] make 
  { } { "word" } <effect> memoize-quot 
  [ % \ execute , ] [ ] make ;

PRIVATE>

MEMO: token ( string -- parser )
  token-parser construct-boa ;      

MEMO: satisfy ( quot -- parser )
  satisfy-parser construct-boa ;

MEMO: range ( min max -- parser )
  range-parser construct-boa ;

MEMO: seq ( seq -- parser )
  seq-parser construct-boa ;

MEMO: 2seq ( parser1 parser2 -- parser )
  2array seq ;

MEMO: 3seq ( parser1 parser2 parser3 -- parser )
  3array seq ;

MEMO: 4seq ( parser1 parser2 parser3 parser4 -- parser )
  4array seq ;

: seq* ( quot -- paser )
  { } make seq ; inline 

MEMO: choice ( seq -- parser )
  choice-parser construct-boa ;

MEMO: 2choice ( parser1 parser2 -- parser )
  2array choice ;

MEMO: 3choice ( parser1 parser2 parser3 -- parser )
  3array choice ;

MEMO: 4choice ( parser1 parser2 parser3 parser4 -- parser )
  4array choice ;

: choice* ( quot -- paser )
  { } make choice ; inline 

MEMO: repeat0 ( parser -- parser )
  repeat0-parser construct-boa ;

MEMO: repeat1 ( parser -- parser )
  repeat1-parser construct-boa ;

MEMO: optional ( parser -- parser )
  optional-parser construct-boa ;

MEMO: ensure ( parser -- parser )
  ensure-parser construct-boa ;

MEMO: ensure-not ( parser -- parser )
  ensure-not-parser construct-boa ;

MEMO: action ( parser quot -- parser )
  action-parser construct-boa ;

MEMO: sp ( parser -- parser )
  sp-parser construct-boa ;

: hide ( parser -- parser )
  [ drop ignore ] action ;

MEMO: delay ( quot -- parser )
  delay-parser construct-boa ;

: PEG:
  (:) [
    [
        call compile 1quotation
        [ dup [ parse-result-ast ] [ "Parse failed" throw ] if ]
        append define
    ] with-compilation-unit
  ] 2curry over push-all ; parsing
