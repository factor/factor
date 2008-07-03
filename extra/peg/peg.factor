! Copyright (C) 2007, 2008 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences strings fry namespaces math assocs shuffle debugger io
       vectors arrays math.parser math.order vectors combinators combinators.lib
       sets unicode.categories compiler.units parser
       words quotations effects memoize accessors locals effects splitting ;
IN: peg

USE: prettyprint

TUPLE: parse-result remaining ast ;
TUPLE: parse-error position messages ; 
TUPLE: parser id compiled ;
M: parser equal? [ id>> ] bi@ = ;

M: parser hashcode* id>> hashcode* ;

C: <parse-result>  parse-result
C: <parse-error> parse-error
C: <parser>        parser

M: parse-error error.
  "Peg parsing error at character position " write dup position>> number>string write 
  "." print "Expected " write messages>> [ " or " write ] [ write ] interleave nl ;

SYMBOL: error-stack

: (merge-errors) ( a b -- c )
  {
    { [ over position>> not ] [ nip ] } 
    { [ dup  position>> not ] [ drop ] } 
    [ 2dup [ position>> ] bi@ <=> {
        { +lt+ [ nip ] }
        { +gt+ [ drop ] }
        { +eq+ [ messages>> over messages>> union [ position>> ] dip <parse-error> ] }
      } case 
    ]
  } cond ;

: merge-errors ( -- )
  error-stack get dup length 1 >  [
    dup pop over pop swap (merge-errors) swap push
  ] [
    drop
  ] if ;

: add-error ( remaining message -- )
  <parse-error> error-stack get push ;
  
SYMBOL: ignore 

SYMBOL: packrat
SYMBOL: pos
SYMBOL: input
SYMBOL: fail
SYMBOL: lrstack
SYMBOL: heads

: failed? ( obj -- ? )
  fail = ;

: delegates ( -- cache )
  \ delegates get-global [ H{ } clone dup \ delegates set-global ] unless* ;

: reset-pegs ( -- )
  H{ } clone \ delegates set-global ;

reset-pegs 

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

: process-rule-result ( p result -- result )
  [
    nip [ ast>> ] [ remaining>> ] bi input-from pos set    
  ] [ 
    pos set fail
  ] if* ; 

: eval-rule ( rule -- ast )
  #! Evaluate a rule, return an ast resulting from it.
  #! Return fail if the rule failed. The rule has
  #! stack effect ( input -- parse-result )
  pos get swap execute process-rule-result ; inline

: memo ( pos rule -- memo-entry )
  #! Return the result from the memo cache. 
  rule-parser input-cache at ;

: set-memo ( memo-entry pos rule -- )
  #! Store an entry in the cache
  rule-parser input-cache set-at ;

: update-m ( ast m -- )
  swap >>ans pos get >>pos drop ;

: stop-growth? ( ast m -- ? )
  [ failed? pos get ] dip 
  pos>> <= or ;

: setup-growth ( h p -- )
  pos set dup involved-set>> clone >>eval-set drop ;

: (grow-lr) ( h p r m -- )
  >r >r [ setup-growth ] 2keep r> r>
  >r dup eval-rule r> swap
  dup pick stop-growth? [
    4drop drop
  ] [
    over update-m
    (grow-lr)
  ] if ; inline
 
: grow-lr ( h p r m -- ast )
  >r >r [ heads get set-at ] 2keep r> r>
  pick over >r >r (grow-lr) r> r>
  swap heads get delete-at
  dup pos>> pos set ans>>
  ; inline

:: (setup-lr) ( r l s -- )
  s head>> l head>> eq? [
    l head>> s (>>head)
    l head>> [ s rule>> suffix ] change-involved-set drop
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
      m ans>> failed? [
        fail
      ] [
        h p r m grow-lr
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
      m r h involved-set>> h rule>> suffix member? not and [
        fail p <memo-entry>
      ] [
        r h eval-set>> member? [
          h [ r swap remove ] change-eval-set drop
          r eval-rule
          m update-m
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

: apply-memo-rule ( r m -- ast )
  [ ans>> ] [ pos>> ] bi pos set
  dup left-recursion? [ 
    [ setup-lr ] keep seed>>
  ] [
    nip
  ] if ; 

: apply-rule ( r p -- ast )
   2dup recall [
     nip apply-memo-rule
   ] [
     apply-non-memo-rule
   ] if* ; inline

: with-packrat ( input quot -- result )
  #! Run the quotation with a packrat cache active.
  swap [ 
    input set
    0 pos set
    f lrstack set
    V{ } clone error-stack set
    H{ } clone heads set
    H{ } clone packrat set
  ] H{ } make-assoc swap bind ; inline


GENERIC: (compile) ( parser -- quot )

: execute-parser ( word -- result )
  pos get apply-rule dup failed? [ 
    drop f 
  ] [
    input-slice swap <parse-result>
  ] if ; inline

: parser-body ( parser -- quot )
  #! Return the body of the word that is the compiled version
  #! of the parser.
  gensym 2dup swap (compile) 0 1 <effect> define-declared swap dupd "peg" set-word-prop
  [ execute-parser ] curry ;

: compiled-parser ( parser -- word )
  #! Look to see if the given parser has been compiled.
  #! If not, compile it to a temporary word, cache it,
  #! and return it. Otherwise return the existing one.
  #! Circular parsers are supported by getting the word
  #! name and storing it in the cache, before compiling, 
  #! so it is picked up when re-entered.
  dup compiled>> [
    nip
  ] [
    gensym tuck >>compiled 2dup parser-body 0 1 <effect> define-declared dupd "peg" set-word-prop
  ] if* ;

SYMBOL: delayed

: fixup-delayed ( -- )
  #! Work through all delayed parsers and recompile their
  #! words to have the correct bodies.
  delayed get [
    call compiled-parser 1quotation 0 1 <effect> define-declared
  ] assoc-each ;

: compile ( parser -- word )
  [
    H{ } clone delayed [ 
      compiled-parser fixup-delayed 
    ] with-variable
  ] with-compilation-unit ;

: compiled-parse ( state word -- result )
  swap [ execute [ error-stack get first throw ] unless* ] with-packrat ; inline 

: parse ( input parser -- result )
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

: init-parser ( parser -- parser )
  #! Set the delegate for the parser. Equivalent parsers
  #! get a delegate with the same id.
  dup clone delegates [
    drop next-id f <parser> 
  ] cache over set-delegate ;

TUPLE: token-parser symbol ;

: parse-token ( input string -- result )
  #! Parse the string, returning a parse result
  dup >r ?head-slice [
    r> <parse-result> f f add-error
  ] [
    drop input-slice input-from "token '" r> append "'" append 1vector add-error f
  ] if ;

M: token-parser (compile) ( parser -- quot )
  symbol>> '[ input-slice , parse-token ] ;
   
TUPLE: satisfy-parser quot ;

: parse-satisfy ( input quot -- result )
  swap dup empty? [
    2drop f 
  ] [
    unclip-slice rot dupd call [
      <parse-result>
    ] [  
      2drop f
    ] if
  ] if ; inline


M: satisfy-parser (compile) ( parser -- quot )
  quot>> '[ input-slice , parse-satisfy ] ;

TUPLE: range-parser min max ;

: parse-range ( input min max -- result )
  pick empty? [ 
    3drop f 
  ] [
    pick first -rot between? [
      unclip-slice <parse-result>
    ] [ 
      drop f
    ] if
  ] if ;

M: range-parser (compile) ( parser -- quot )
  [ min>> ] [ max>> ] bi '[ input-slice , , parse-range ] ;

TUPLE: seq-parser parsers ;

: ignore? ( ast -- bool )
  ignore = ;

: calc-seq-result ( prev-result current-result -- next-result )
  [
    [ remaining>> swap (>>remaining) ] 2keep
    ast>> dup ignore? [  
      drop
    ] [
      swap [ ast>> push ] keep
    ] if
  ] [
    drop f
  ] if* ;

: parse-seq-element ( result quot -- result )
  over [
    call calc-seq-result
  ] [
    2drop f
  ] if ; inline

M: seq-parser (compile) ( parser -- quot )
  [
    [ input-slice V{ } clone <parse-result> ] %
    parsers>> unclip compiled-parser 1quotation , \ parse-seq-element , [ 
      compiled-parser 1quotation [ merge-errors ] compose , \ parse-seq-element , ] each 
  ] [ ] make ;

TUPLE: choice-parser parsers ;

M: choice-parser (compile) ( parser -- quot )
  [ 
    f ,
    parsers>> [ compiled-parser ] map 
    unclip 1quotation , \ unless* , [ 1quotation [ merge-errors ] compose , \ unless* , ] each
  ] [ ] make ;

TUPLE: repeat0-parser p1 ;

: (repeat) ( quot result -- result )
  over call [
    [ remaining>> swap (>>remaining) ] 2keep 
    ast>> swap [ ast>> push ] keep
    (repeat) 
  ] [
    nip
  ] if* ; inline

M: repeat0-parser (compile) ( parser -- quot )
  p1>> compiled-parser 1quotation '[ 
    input-slice V{ } clone <parse-result> , swap (repeat) 
  ] ; 

TUPLE: repeat1-parser p1 ;

: repeat1-empty-check ( result -- result )
  [
    dup ast>> empty? [ drop f ] when
  ] [
    f
  ] if* ;

M: repeat1-parser (compile) ( parser -- quot )
  p1>> compiled-parser 1quotation '[ 
    input-slice V{ } clone <parse-result> , swap (repeat) repeat1-empty-check  
  ] ; 

TUPLE: optional-parser p1 ;

: check-optional ( result -- result )
  [ input-slice f <parse-result> ] unless* ;

M: optional-parser (compile) ( parser -- quot )
  p1>> compiled-parser 1quotation '[ @ check-optional ] ;

TUPLE: semantic-parser p1 quot ;

: check-semantic ( result quot -- result )
  over [
    over ast>> swap call [ drop f ] unless
  ] [
    drop
  ] if ; inline

M: semantic-parser (compile) ( parser -- quot )
  [ p1>> compiled-parser 1quotation ] [ quot>> ] bi  
  '[ @ , check-semantic ] ;

TUPLE: ensure-parser p1 ;

: check-ensure ( old-input result -- result )
  [ ignore <parse-result> ] [ drop f ] if ;

M: ensure-parser (compile) ( parser -- quot )
  p1>> compiled-parser 1quotation '[ input-slice @ check-ensure ] ;

TUPLE: ensure-not-parser p1 ;

: check-ensure-not ( old-input result -- result )
  [ drop f ] [ ignore <parse-result> ] if ;

M: ensure-not-parser (compile) ( parser -- quot )
  p1>> compiled-parser 1quotation '[ input-slice @ check-ensure-not ] ;

TUPLE: action-parser p1 quot ;

: check-action ( result quot -- result )
  over [
    over ast>> swap call >>ast
  ] [
    drop
  ] if ; inline

M: action-parser (compile) ( parser -- quot )
  [ p1>> compiled-parser 1quotation ] [ quot>> ] bi '[ @ , check-action ] ;

: left-trim-slice ( string -- string )
  #! Return a new string without any leading whitespace
  #! from the original string.
  dup empty? [
    dup first blank? [ rest-slice left-trim-slice ] when
  ] unless ;

TUPLE: sp-parser p1 ;

M: sp-parser (compile) ( parser -- quot )
  p1>> compiled-parser 1quotation '[ 
    input-slice left-trim-slice input-from pos set @ 
  ] ;

TUPLE: delay-parser quot ;

M: delay-parser (compile) ( parser -- quot )
  #! For efficiency we memoize the quotation.
  #! This way it is run only once and the 
  #! parser constructed once at run time.
  quot>> gensym [ delayed get set-at ] keep 1quotation ; 

TUPLE: box-parser quot ;

M: box-parser (compile) ( parser -- quot )
  #! Calls the quotation at compile time
  #! to produce the parser to be compiled.
  #! This differs from 'delay' which calls
  #! it at run time. Due to using the runtime
  #! environment at compile time, this parser
  #! must not be cached, so we clear out the
  #! delgates cache.
  f >>compiled quot>> call compiled-parser 1quotation ;

PRIVATE>

: token ( string -- parser )
  token-parser boa init-parser ;      

: satisfy ( quot -- parser )
  satisfy-parser boa init-parser ;

: range ( min max -- parser )
  range-parser boa init-parser ;

: seq ( seq -- parser )
  seq-parser boa init-parser ;

: 2seq ( parser1 parser2 -- parser )
  2array seq ;

: 3seq ( parser1 parser2 parser3 -- parser )
  3array seq ;

: 4seq ( parser1 parser2 parser3 parser4 -- parser )
  4array seq ;

: seq* ( quot -- paser )
  { } make seq ; inline 

: choice ( seq -- parser )
  choice-parser boa init-parser ;

: 2choice ( parser1 parser2 -- parser )
  2array choice ;

: 3choice ( parser1 parser2 parser3 -- parser )
  3array choice ;

: 4choice ( parser1 parser2 parser3 parser4 -- parser )
  4array choice ;

: choice* ( quot -- paser )
  { } make choice ; inline 

: repeat0 ( parser -- parser )
  repeat0-parser boa init-parser ;

: repeat1 ( parser -- parser )
  repeat1-parser boa init-parser ;

: optional ( parser -- parser )
  optional-parser boa init-parser ;

: semantic ( parser quot -- parser )
  semantic-parser boa init-parser ;

: ensure ( parser -- parser )
  ensure-parser boa init-parser ;

: ensure-not ( parser -- parser )
  ensure-not-parser boa init-parser ;

: action ( parser quot -- parser )
  action-parser boa init-parser ;

: sp ( parser -- parser )
  sp-parser boa init-parser ;

: hide ( parser -- parser )
  [ drop ignore ] action ;

: delay ( quot -- parser )
  delay-parser boa init-parser ;

: box ( quot -- parser )
  #! because a box has its quotation run at compile time
  #! it must always have a new parser delgate created, 
  #! not a cached one. This is because the same box,
  #! compiled twice can have a different compiled word
  #! due to running at compile time.
  #! Why the [ ] action at the end? Box parsers don't get
  #! memoized during parsing due to all box parsers being
  #! unique. This breaks left recursion detection during the
  #! parse. The action adds an indirection with a parser type
  #! that gets memoized and fixes this. Need to rethink how
  #! to fix boxes so this isn't needed...
  box-parser boa next-id f <parser> over set-delegate [ ] action ;

ERROR: parse-failed input word ;

M: parse-failed error.
  "The " write dup word>> pprint " word could not parse the following input:" print nl
  input>> . ;

: PEG:
  (:)
  [let | def [ ] word [ ] |
    [
      [
        [let | compiled-def [ def call compile ] |
          [
            dup compiled-def compiled-parse
            [ ast>> ] [ word parse-failed ] ?if
          ]
          word swap define
        ]
      ] with-compilation-unit
    ] over push-all
  ] ; parsing
