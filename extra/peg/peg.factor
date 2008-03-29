! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences strings namespaces math assocs shuffle 
       vectors arrays combinators.lib math.parser match
       unicode.categories sequences.lib compiler.units parser
       words quotations effects memoize accessors 
       combinators.cleave locals ;
IN: peg

USE: prettyprint

TUPLE: parse-result remaining ast ;

SYMBOL: ignore 

: <parse-result> ( remaining ast -- parse-result )
  parse-result construct-boa ;

SYMBOL: packrat
SYMBOL: pos
SYMBOL: input
SYMBOL: fail
SYMBOL: lrstack
SYMBOL: heads

TUPLE: memo-entry ans pos ;
C: <memo-entry> memo-entry

TUPLE: left-recursion seed rule head next ;
C: <left-recursion> left-recursion
 
TUPLE: peg-head rule involved-set eval-set ;
C: <head> peg-head

: rule-parser ( rule -- parser ) 
  #! A rule is the parser compiled down to a word. It has
  #! a "peg" property containing the original parser.
  "peg" word-prop ;

: input-slice ( -- slice )
  #! Return a slice of the input from the current parse position
  input get pos get tail-slice ;

: input-from ( input -- n )
  #! Return the index from the original string that the
  #! input slice is based on.
  dup slice? [ slice-from ] [ drop 0 ] if ;

: input-cache ( parser -- cache )
  #! From the packrat cache, obtain the cache for the parser 
  #! that maps the position to the parser result.
  id>> packrat get [ drop H{ } clone ] cache ;

: eval-rule ( rule -- ast )
  #! Evaluate a rule, return an ast resulting from it.
  #! Return fail if the rule failed. The rule has
  #! stack effect ( input -- parse-result )
  pos get swap 
  execute 
!  drop f f <parse-result>
  [
    nip
    [ ast>> ] [ remaining>> ] bi
    input-from pos set    
  ] [ 
    pos set   
    fail
  ] if* ; inline

: memo ( pos rule -- memo-entry )
  #! Return the result from the memo cache. 
  rule-parser input-cache at ;

: set-memo ( memo-entry pos rule -- )
  #! Store an entry in the cache
  rule-parser input-cache set-at ;

:: (grow-lr) ( r p m h -- )
  p pos set
  h involved-set>> clone h (>>eval-set)
  r eval-rule
  dup fail = pos get m pos>> <= or [
    drop
  ] [
    m (>>ans)
    pos get m (>>pos)
    r p m h (grow-lr)
  ] if ; inline
 
:: grow-lr ( r p m h -- ast )
  h p heads get set-at
  r p m h (grow-lr) 
  p heads get delete-at
  m pos>> pos set m ans>>
  ; inline

:: (setup-lr) ( r l s -- )
  s head>> l head>> eq? [
    l head>> s (>>head)
    l head>> [ s rule>> add ] change-involved-set drop
    r l s next>> (setup-lr)
  ] unless ;

:: setup-lr ( r l -- )
  l head>> [
    r V{ } clone V{ } clone <head> l (>>head)
  ] unless
  r l lrstack get (setup-lr) ;

:: lr-answer ( r p m -- ast )
  [let* |
          h [ m ans>> head>> ]
        |
    h rule>> r eq? [
      m ans>> seed>> m (>>ans)
      m ans>> fail = [
        fail
      ] [
        r p m h grow-lr
      ] if
    ] [
      m ans>> seed>>
    ] if
  ] ; inline

:: recall ( r p -- memo-entry )
  [let* |
          m [ p r memo ]
          h [ p heads get at ]
        |
    h [
      m r h involved-set>> h rule>> add member? not and [
        fail p <memo-entry>
      ] [
        r h eval-set>> member? [
          h [ r swap remove ] change-eval-set drop
          r eval-rule
          m (>>ans)
          pos get m (>>pos)
          m
        ] [ 
          m
        ] if
      ] if
    ] [
      m
    ] if
  ] ; inline

:: apply-non-memo-rule ( r p -- ast )
  [let* |
          lr  [ fail r f lrstack get <left-recursion> ]
          m   [ lr lrstack set lr p <memo-entry> dup p r set-memo ]
          ans [ r eval-rule ]
        |
    lrstack get next>> lrstack set
    pos get m (>>pos)
    lr head>> [
      ans lr (>>seed)
      r p m lr-answer
    ] [
      ans m (>>ans)
      ans
    ] if
  ] ; inline

:: apply-memo-rule ( r m -- ast )
  m pos>> pos set 
  m ans>> left-recursion? [ 
    r m ans>> setup-lr
    m ans>> seed>>
  ] [
    m ans>>
  ] if ;

:: apply-rule ( r p -- ast )
  [let* |
          m [ r p recall ]
        | 
    m [
      r m apply-memo-rule
    ] [
      r p apply-non-memo-rule
    ] if 
  ] ; inline

: with-packrat ( input quot -- result )
  #! Run the quotation with a packrat cache active.
  swap [ 
    input set
    0 pos set
    f lrstack set
    H{ } clone heads set
    H{ } clone packrat set
  ] H{ } make-assoc swap bind ; inline


: compiled-parsers ( -- cache )
  \ compiled-parsers get-global [ H{ } clone dup \ compiled-parsers set-global ] unless* ;

: reset-compiled-parsers ( -- )
  H{ } clone \ compiled-parsers set-global ;

reset-compiled-parsers

GENERIC: (compile) ( parser -- quot )


:: parser-body ( parser -- quot )
  #! Return the body of the word that is the compiled version
  #! of the parser.
  [let* | rule [ parser (compile) define-temp dup parser "peg" set-word-prop ] 
        |
    [
      rule pos get apply-rule dup fail = [ 
        drop f 
      ] [
        input-slice swap <parse-result>
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

: compiled-parse ( state word -- result )
  swap [ execute ] with-packrat ; inline 

: parse ( state parser -- result )
  dup word? [ compile ] unless compiled-parse ;

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

reset-delegates 

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
  [ \ input-slice , symbol>> , \ parse-token , ] [ ] make ;
   
TUPLE: satisfy-parser quot ;

MATCH-VARS: ?quot ;

: satisfy-pattern ( -- quot )
  [
    input-slice dup empty? [
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
    input-slice dup empty? [
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
      ?quot [
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
    [ input-slice V{ } clone <parse-result> ] %
    parsers>> [ compiled-parser \ ?quot seq-pattern match-replace % ] each 
  ] [ ] make ;

TUPLE: choice-parser parsers ;

: choice-pattern ( -- quot )
  [
    [ ?quot ] unless* 
  ] ;

M: choice-parser (compile) ( parser -- quot )
  [ 
    f ,
    parsers>> [ compiled-parser \ ?quot choice-pattern match-replace % ] each
  ] [ ] make ;

TUPLE: repeat0-parser p1 ;

: (repeat0) ( quot result -- result )
  over call [
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
    [ input-slice V{ } clone <parse-result> ] %
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
    [ input-slice V{ } clone <parse-result> ] %
    p1>> compiled-parser \ ?quot repeat1-pattern match-replace % 
  ] [ ] make ;

TUPLE: optional-parser p1 ;

: optional-pattern ( -- quot )
  [
    ?quot [ input-slice f <parse-result> ] unless* 
  ] ;

M: optional-parser (compile) ( parser -- quot )
  p1>> compiled-parser \ ?quot optional-pattern match-replace ;

TUPLE: ensure-parser p1 ;

: ensure-pattern ( -- quot )
  [
    input-slice ?quot [
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
    input-slice ?quot [
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
  [ p1>> compiled-parser ] [ quot>> ] bi  
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
    \ input-slice , \ left-trim-slice , \ input-from , \ pos , \ set , p1>> compiled-parser , 
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
