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
SYMBOL: lrstack

TUPLE: phead rule involved-set eval-set ;
C: <head> phead 

: input-from ( input -- n )
  #! Return the index from the original string that the
  #! input slice is based on.
  dup slice? [ slice-from ] [ drop 0 ] if ;

: heads ( input -- h )
  input-from \ heads get at ;


: compiled-parsers ( -- cache )
  \ compiled-parsers get-global [ H{ } clone dup \ compiled-parsers set-global ] unless* ;

: reset-compiled-parsers ( -- )
  H{ } clone \ compiled-parsers set-global ;

GENERIC: (compile) ( parser -- quot )

: input-cache ( id -- cache )
  #! From the packrat cache, obtain the cache for the parser quotation 
  #! that maps the input string position to the parser result.
  packrat get [ drop H{ } clone ] cache ;

TUPLE: left-recursion seed rule head next ;
C: <left-recursion> left-recursion

USE: prettyprint
USE: io


:: handle-left-recursive-result ( result -- result )
  #! If the result is from a left-recursive call,
  #! note this and fail, otherwise return normal result
  #! See figure 4 of packrat_TR-2007-002.pdf.
  ">>handle-left-recursive-result " write result . 
  result [
    [let* | ast [ result ast>> ] |
      ast left-recursion? [ t ast (>>detected?) f ] [ result ] if
    ]
  ] [ 
    f
  ] if 
  "<<handle-left-recursive-result " write dup . ;
   
:: (grow-lr) ( input quot parser m h -- result )
  #! 'Grow the Seed' algorithm to handle left recursion
  ">>(grow-lr) " write input . " for parser " write parser . " m is " write m . 
  [let* |
          pos [ input ]  
          ans [ h involved-set>> clone h (>>eval-set) input quot call ] 
        |
    [ ans not ] [ ans [ pos input-from m remaining>> input-from <= ] [ f ] if ] 2array || [ 
      "recursion exiting with = " write ans . "m was " write m . 
      m        
    ] [
      "recursion with = " write ans . 
      pos quot parser pos ans ast>> <parse-result> h (grow-lr)
    ] if
  ] 
  "<<(grow-lr) " write input . " for parser " write parser . " m is " write m . " result is " write dup .  
  ;

:: grow-lr ( input quot parser m h -- result )
  h input input-from \ heads get set-at
  input quot parser m h (grow-lr) 
  f input input-from \ heads get set-at ;

SYMBOL: not-found

: memo ( parser input -- result )
  input-from swap id>> input-cache at* [ drop not-found ] unless ;


:: involved? ( parser h -- ? )
  h rule>> parser = [
    t
  ] [
    parser h involved-set>> member?
  ] if ;

:: recall ( input quot parser -- result )
  [let* |
          m [ parser input memo ]
          h [ input heads ]
        |
    #! If not growing a seed pass, just return what is stored
    #! in the memo table.
    h [
      m not-found = parser h involved? not and [
        f
      ] [
        parser h eval-set>> member? [
          parser h eval-set>> remove h (>>eval-set)
          input quot call          
        ] [
          m
        ] if
      ] if
    ] [
      m
    ] if
  ] ;

:: (setup-lr) ( parser l s -- )
  s head>> l head>> = [
    l head>> s (>>head)
    l head>> [ s rule>> add ] change-involved-set drop
    parser l s next>> (setup-lr)
  ] unless ;

:: setup-lr ( parser l -- )
  [let* |
          s [ lrstack get ] 
        |
    l head>> [ parser V{ } clone V{ } clone <head> l (>>head) ] unless
    parser l s (setup-lr)
  ] ;

:: lr-answer ( quot parser input m -- result )
  [let* |
          h [ m ast>> head>> ]
        |
    h rule>> parser = [
      "changing memo ast to seed " write 
      m [ seed>> ast>> dup . ] change-ast drop
      m input input-from parser id>> input-cache set-at
      m ast>> not [
        f
      ] [
        input quot parser m h grow-lr
      ] if      
    ] [
      m ast>> seed>>
    ] if
  ] ;  

:: (apply-rule) ( quot parser input -- result )
  [let* |
          lr  [ f parser f lrstack get <left-recursion> ]
          m   [ lr lrstack set input lr <parse-result> ]
          ans [ m input input-from parser id>> input-cache set-at input quot call ]
        |
    lrstack get next>> lrstack set
    lr head>> [
"setting seed to ans " write ans . 
      ans lr (>>seed)
      quot parser input m lr-answer      
    ] [ 
      ans 
    ] if
  ] ;

:: apply-rule ( quot parser input -- result )
  [let* |
          m [ input quot parser recall ]
        |
    m not-found = [
      quot parser input (apply-rule)       
      dup input input-from parser id>> input-cache set-at      
    ] [
      m [
        m ast>> left-recursion? [
          "Found left recursion..." print
          parser m ast>> setup-lr m remaining>> m ast>> seed>> <parse-result>
          dup input input-from parser id>> input-cache set-at
        ] [
          m 
          dup input input-from parser id>> input-cache set-at
        ] if
      ] [
        f f input input-from parser id>> input-cache set-at
      ] if
    ] if
  ] ;

:: cached-result ( input-cache input quot parser -- result )
  #! Get the cached result for input position 
  #! from the input cache. If the item is not in the cache,
  #! call 'quot' with 'input' on the stack to get the result
  #! and store that in the cache and return it.
  #! See figure 4 of packrat_TR-2007-002.pdf.
  ">>cached-result " write input . "  for parser " write parser .
  input input-from input-cache [ 
    drop
    [let* | lr  [ f <left-recursion> ] 
            m   [ input lr <parse-result> ]
            ans [ m input input-from input-cache set-at input quot call ]
          |
      "--lr is " write lr . " ans is " write ans . " for parser " write parser .
      ans input input-from input-cache set-at
      lr detected?>> ans and [
        input quot parser ans grow-lr
      ] [
        ans
      ] if
    ]
  ] cache 
  dup [ handle-left-recursive-result ] when  
  "<<cached-result " write dup . " for parser " write parser . ;

:: run-packrat-parser ( input quot parser -- result )
  quot parser input apply-rule ;

:: parser-body ( parser -- quot )
  #! Return the body of the word that is the compiled version
  #! of the parser.
  [let* | parser-quot [ parser (compile) ] 
        |
    [
      packrat get [ 
        parser-quot parser run-packrat-parser
      ] [
        parser-quot call
      ] if
    ] 
  ] ;
 
: compiled-parser ( parser -- word )
  #! Look to see if the given parser has been compiled.
  #! If not, compile it to a temporary word, cache it,
  #! and return it. Otherwise return the existing one.
  #! Circular parsers are supported by getting the word
  #! name and storing it in the cache, before compiling, 
  #! so it is picked up when re-entered.
  dup id>> compiled-parsers [
    drop dup gensym swap 2dup id>> compiled-parsers set-at
    2dup parser-body define 
    dupd "peg" set-word-prop
  ] cache nip ;

: compile ( parser -- word )
  [ compiled-parser ] with-compilation-unit ;

: parse ( state parser -- result )
  compile execute ; inline

: with-packrat ( quot -- result )
  #! Run the quotation with a packrat cache active.
  H{ } clone \ heads [ [ H{ } clone packrat ] dip with-variable ] with-variable ; inline

: packrat-parse ( state parser -- result )
  [ parse ] with-packrat ;

: packrat-call ( state quot -- result )
  with-packrat ; inline

<PRIVATE

SYMBOL: id 

: next-id ( -- n )
  #! Return the next unique id for a parser
  id get-global [
    dup 1+ id set-global
  ] [
    1 id set-global 0
  ] if* ;

TUPLE: parser id ;
M: parser equal? [ id>> ] 2apply = ;
C: <parser> parser

: delegates ( -- cache )
  \ delegates get-global [ H{ } clone dup \ delegates set-global ] unless* ;

: reset-delegates ( -- )
  H{ } clone \ delegates set-global ;

: init-parser ( parser -- parser )
  #! Set the delegate for the parser. Equivalent parsers
  #! get a delegate with the same id.
  dup clone delegates [
    drop next-id <parser> 
  ] cache over set-delegate ;

TUPLE: token-parser symbol ;

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

: optional-pattern ( -- quot )
  [
    dup ?quot swap f <parse-result> or 
  ] ;

M: optional-parser (compile) ( parser -- quot )
  p1>> compiled-parser \ ?quot optional-pattern match-replace ;

TUPLE: ensure-parser p1 ;

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

M: sp-parser (compile) ( parser -- quot )
  [
    \ left-trim-slice , p1>> compiled-parser , 
  ] [ ] make ;

TUPLE: delay-parser quot ;

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

: token ( string -- parser )
  token-parser construct-boa init-parser ;      

: satisfy ( quot -- parser )
  satisfy-parser construct-boa init-parser ;

: range ( min max -- parser )
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

: delay ( quot -- parser )
  delay-parser construct-boa init-parser ;

: PEG:
  (:) [
    [
        call compile 1quotation
        [ dup [ parse-result-ast ] [ "Parse failed" throw ] if ]
        append define
    ] with-compilation-unit
  ] 2curry over push-all ; parsing
