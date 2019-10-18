! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel parser words arrays strings math.parser sequences 
       quotations vectors namespaces math assocs continuations peg ;
IN: peg.ebnf

TUPLE: ebnf-non-terminal symbol ;
TUPLE: ebnf-terminal symbol ;
TUPLE: ebnf-choice options ;
TUPLE: ebnf-sequence elements ;
TUPLE: ebnf-repeat0 group ;
TUPLE: ebnf-optional elements ;
TUPLE: ebnf-rule symbol elements ;
TUPLE: ebnf-action word ;
TUPLE: ebnf rules ;

C: <ebnf-non-terminal> ebnf-non-terminal
C: <ebnf-terminal> ebnf-terminal
C: <ebnf-choice> ebnf-choice
C: <ebnf-sequence> ebnf-sequence
C: <ebnf-repeat0> ebnf-repeat0
C: <ebnf-optional> ebnf-optional
C: <ebnf-rule> ebnf-rule
C: <ebnf-action> ebnf-action
C: <ebnf> ebnf

SYMBOL: parsers
SYMBOL: non-terminals
SYMBOL: last-parser

: reset-parser-generation ( -- ) 
  V{ } clone parsers set 
  H{ } clone non-terminals set 
  f last-parser set ;

: store-parser ( parser -- number )
  parsers get [ push ] keep length 1- ;

: get-parser ( index -- parser )
  parsers get nth ;
  
: non-terminal-index ( name -- number )
  dup non-terminals get at [
    nip
  ] [
    f store-parser [ swap non-terminals get set-at ] keep
  ] if* ;

GENERIC: (generate-parser) ( ast -- id )

: generate-parser ( ast -- id )
  (generate-parser) dup last-parser set ;

M: ebnf-terminal (generate-parser) ( ast -- id )
  ebnf-terminal-symbol token sp store-parser ;

M: ebnf-non-terminal (generate-parser) ( ast -- id )
  [
    ebnf-non-terminal-symbol dup non-terminal-index , 
    parsers get , \ nth , [ search ] [ 2drop f ] recover , \ or ,
  ] [ ] make delay sp store-parser ;

M: ebnf-choice (generate-parser) ( ast -- id )
  ebnf-choice-options [
    generate-parser get-parser 
  ] map choice store-parser ;

M: ebnf-sequence (generate-parser) ( ast -- id )
  ebnf-sequence-elements [
    generate-parser get-parser
  ] map seq store-parser ;

M: ebnf-repeat0 (generate-parser) ( ast -- id )
  ebnf-repeat0-group generate-parser get-parser repeat0 store-parser ;

M: ebnf-optional (generate-parser) ( ast -- id )
  ebnf-optional-elements generate-parser get-parser optional store-parser ;

M: ebnf-rule (generate-parser) ( ast -- id )
  dup ebnf-rule-symbol non-terminal-index swap 
  ebnf-rule-elements generate-parser get-parser ! nt-id body
  swap [ parsers get set-nth ] keep ;

M: ebnf-action (generate-parser) ( ast -- id )
  ebnf-action-word search 1quotation 
  last-parser get get-parser swap action store-parser ;

M: vector (generate-parser) ( ast -- id )
  [ generate-parser ] map peek ;

M: f (generate-parser) ( ast -- id )
  drop last-parser get ;

M: ebnf (generate-parser) ( ast -- id )
  ebnf-rules [
    generate-parser 
  ] map peek ;

DEFER: 'rhs'

: 'non-terminal' ( -- parser )
  CHAR: a CHAR: z range repeat1 [ >string <ebnf-non-terminal> ] action ;

: 'terminal' ( -- parser )
  "'" token hide [ CHAR: ' = not ] satisfy repeat1 "'" token hide 3array seq [ first >string <ebnf-terminal> ] action ;

: 'element' ( -- parser )
  'non-terminal' 'terminal' 2array choice ;

DEFER: 'choice'

: 'group' ( -- parser )
  "(" token sp hide
  [ 'choice' sp ] delay
  ")" token sp hide 
  3array seq [ first ] action ;

: 'repeat0' ( -- parser )
  "{" token sp hide
  [ 'choice' sp ] delay
  "}" token sp hide 
  3array seq [ first <ebnf-repeat0> ] action ;

: 'optional' ( -- parser )
  "[" token sp hide
  [ 'choice' sp ] delay
  "]" token sp hide 
  3array seq [ first <ebnf-optional> ] action ;

: 'sequence' ( -- parser )
  [ 
    'element' sp ,
    'group' sp , 
    'repeat0' sp ,
    'optional' sp , 
   ] { } make  choice  
   repeat1 [ 
     dup length 1 = [ first ] [ <ebnf-sequence> ] if
   ] action ;  

: 'choice' ( -- parser )
  'sequence' sp "|" token sp list-of [ 
    dup length 1 = [ first ] [ <ebnf-choice> ] if
   ] action ;

: 'action' ( -- parser )
  "=>" token hide
  [ blank? ] satisfy ensure-not [ drop t ] satisfy 2array seq [ first ] action repeat1 [ >string ] action sp
  2array seq [ first <ebnf-action> ] action ;
  
: 'rhs' ( -- parser )
  'choice' 'action' sp optional 2array seq ;
 
: 'rule' ( -- parser )
  'non-terminal' [ ebnf-non-terminal-symbol ] action 
  "=" token sp hide 
  'rhs' 
  3array seq [ first2 <ebnf-rule> ] action ;

: 'ebnf' ( -- parser )
  'rule' sp "." token sp hide list-of [ <ebnf> ] action ;

: ebnf>quot ( string -- quot )
  'ebnf' parse [
     parse-result-ast [
         reset-parser-generation
         generate-parser drop
         [
             non-terminals get
             [
               get-parser [
                 swap , \ in , \ get , \ create ,
                 1quotation , \ define-compound , 
               ] [
                 drop
               ] if*
             ] assoc-each
         ] [ ] make
     ] with-scope
   ] [
    f
   ] if* ;

: <EBNF "EBNF>" parse-tokens " " join ebnf>quot call ; parsing