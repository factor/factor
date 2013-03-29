! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel words arrays strings math.parser
sequences quotations vectors namespaces make math assocs
continuations peg peg.parsers unicode.categories multiline
splitting accessors effects sequences.deep peg.search
combinators.short-circuit lexer io.streams.string stack-checker
io combinators parser summary ;
FROM: compiler.units => with-compilation-unit ;
FROM: vocabs.parser => search ;
FROM: peg.search => replace ;
IN: peg.ebnf

: rule ( name word -- parser )
  #! Given an EBNF word produced from EBNF: return the EBNF rule
  "ebnf-parser" word-prop at ;

ERROR: no-rule rule parser ;

<PRIVATE

: lookup-rule ( rule parser -- rule' )
    2dup rule [ 2nip ] [ no-rule ] if* ;
TUPLE: tokenizer-tuple any one many ;

: default-tokenizer ( -- tokenizer )
  T{ tokenizer-tuple f
    [ any-char ]
    [ token ]
    [ [ = ] curry any-char swap semantic ]
  } ;

: parser-tokenizer ( parser -- tokenizer )
  [ 1quotation ] keep
  [ swap [ = ] curry semantic ] curry dup \ tokenizer-tuple boa ;

: rule-tokenizer ( name word -- tokenizer )
  rule parser-tokenizer ;

: tokenizer ( -- word )
  \ tokenizer get-global [ default-tokenizer ] unless* ;

: reset-tokenizer ( -- )
  default-tokenizer \ tokenizer set-global ;

ERROR: no-tokenizer name ;

M: no-tokenizer summary
    drop "Tokenizer not found" ;

SYNTAX: TOKENIZER:
  scan-word-name dup search [ nip ] [ no-tokenizer ] if*
  execute( -- tokenizer ) \ tokenizer set-global ;

TUPLE: ebnf-non-terminal symbol ;
TUPLE: ebnf-terminal symbol ;
TUPLE: ebnf-foreign word rule ;
TUPLE: ebnf-any-character ;
TUPLE: ebnf-range pattern ;
TUPLE: ebnf-ensure group ;
TUPLE: ebnf-ensure-not group ;
TUPLE: ebnf-choice options ;
TUPLE: ebnf-sequence elements ;
TUPLE: ebnf-ignore group ;
TUPLE: ebnf-repeat0 group ;
TUPLE: ebnf-repeat1 group ;
TUPLE: ebnf-optional group ;
TUPLE: ebnf-whitespace group ;
TUPLE: ebnf-tokenizer elements ;
TUPLE: ebnf-rule symbol elements ;
TUPLE: ebnf-action parser code ;
TUPLE: ebnf-var parser name ;
TUPLE: ebnf-semantic parser code ;
TUPLE: ebnf rules ;

C: <ebnf-non-terminal> ebnf-non-terminal
C: <ebnf-terminal> ebnf-terminal
C: <ebnf-foreign> ebnf-foreign
C: <ebnf-any-character> ebnf-any-character
C: <ebnf-range> ebnf-range
C: <ebnf-ensure> ebnf-ensure
C: <ebnf-ensure-not> ebnf-ensure-not
C: <ebnf-choice> ebnf-choice
C: <ebnf-sequence> ebnf-sequence
C: <ebnf-ignore> ebnf-ignore
C: <ebnf-repeat0> ebnf-repeat0
C: <ebnf-repeat1> ebnf-repeat1
C: <ebnf-optional> ebnf-optional
C: <ebnf-whitespace> ebnf-whitespace
C: <ebnf-tokenizer> ebnf-tokenizer
C: <ebnf-rule> ebnf-rule
C: <ebnf-action> ebnf-action
C: <ebnf-var> ebnf-var
C: <ebnf-semantic> ebnf-semantic
C: <ebnf> ebnf

: filter-hidden ( seq -- seq )
  #! Remove elements that produce no AST from sequence
  [ ebnf-ensure-not? not ] filter [ ebnf-ensure? not ] filter ;

: syntax ( string -- parser )
  #! Parses the string, ignoring white space, and
  #! does not put the result in the AST.
  token sp hide ;

: syntax-pack ( begin parser end -- parser )
  #! Parse 'parser' surrounded by syntax elements
  #! begin and end.
  [ syntax ] 2dip syntax pack ;

#! Don't want to use 'replace' in an action since replace doesn't infer.
#! Do the compilation of the peg at parse time and call (replace).
PEG: escaper ( string -- ast )
  [
    "\\t" token [ drop "\t" ] action ,
    "\\n" token [ drop "\n" ] action ,
    "\\r" token [ drop "\r" ] action ,
    "\\\\" token [ drop "\\" ] action ,
  ] choice* any-char-parser 2array choice repeat0 ;

: replace-escapes ( string -- string )
  escaper sift [ [ tree-write ] each ] with-string-writer ;

: insert-escapes ( string -- string )
  [
    "\t" token [ drop "\\t" ] action ,
    "\n" token [ drop "\\n" ] action ,
    "\r" token [ drop "\\r" ] action ,
  ] choice* replace ;

: 'identifier' ( -- parser )
  #! Return a parser that parses an identifer delimited by
  #! a quotation character. The quotation can be single
  #! or double quotes. The AST produced is the identifier
  #! between the quotes.
  [
    [ CHAR: " = not ] satisfy repeat1 "\"" "\"" surrounded-by ,
    [ CHAR: ' = not ] satisfy repeat1 "'" "'" surrounded-by ,
  ] choice* [ >string replace-escapes ] action ;

: 'non-terminal' ( -- parser )
  #! A non-terminal is the name of another rule. It can
  #! be any non-blank character except for characters used
  #! in the EBNF syntax itself.
  [
    {
      [ blank?    ]
      [ CHAR: " = ]
      [ CHAR: ' = ]
      [ CHAR: | = ]
      [ CHAR: { = ]
      [ CHAR: } = ]
      [ CHAR: = = ]
      [ CHAR: ) = ]
      [ CHAR: ( = ]
      [ CHAR: ] = ]
      [ CHAR: [ = ]
      [ CHAR: . = ]
      [ CHAR: ! = ]
      [ CHAR: & = ]
      [ CHAR: * = ]
      [ CHAR: + = ]
      [ CHAR: ? = ]
      [ CHAR: : = ]
      [ CHAR: ~ = ]
      [ CHAR: < = ]
      [ CHAR: > = ]
    } 1|| not
  ] satisfy repeat1 [ >string <ebnf-non-terminal> ] action ;

: 'terminal' ( -- parser )
  #! A terminal is an identifier enclosed in quotations
  #! and it represents the literal value of the identifier.
  'identifier' [ <ebnf-terminal> ] action ;

: 'foreign-name' ( -- parser )
  #! Parse a valid foreign parser name
  [
    {
      [ blank?    ]
      [ CHAR: > = ]
    } 1|| not
  ] satisfy repeat1 [ >string ] action ;

: 'foreign' ( -- parser )
  #! A foreign call is a call to a rule in another ebnf grammar
  [
    "<foreign" syntax ,
    'foreign-name' sp ,
    'foreign-name' sp optional ,
    ">" syntax ,
  ] seq* [ first2 <ebnf-foreign> ] action ;

: 'any-character' ( -- parser )
  #! A parser to match the symbol for any character match.
  [ CHAR: . = ] satisfy [ drop <ebnf-any-character> ] action ;

: 'range-parser' ( -- parser )
  #! Match the syntax for declaring character ranges
  [
    [ "[" syntax , "[" token ensure-not , ] seq* hide ,
    [ CHAR: ] = not ] satisfy repeat1 ,
    "]" syntax ,
  ] seq* [ first >string <ebnf-range> ] action ;

: ('element') ( -- parser )
  #! An element of a rule. It can be a terminal or a
  #! non-terminal but must not be followed by a "=".
  #! The latter indicates that it is the beginning of a
  #! new rule.
  [
    [
      [
        'non-terminal' ,
        'terminal' ,
        'foreign' ,
        'range-parser' ,
        'any-character' ,
      ] choice*
      [ dup , "~" token hide , ] seq* [ first <ebnf-ignore> ] action ,
      [ dup , "*" token hide , ] seq* [ first <ebnf-repeat0> ] action ,
      [ dup , "+" token hide , ] seq* [ first <ebnf-repeat1> ] action ,
      [ dup , "?[" token ensure-not , "?" token hide , ] seq* [ first <ebnf-optional> ] action ,
      ,
    ] choice* ,
    [
      "=" syntax ensure-not ,
      "=>" syntax ensure ,
    ] choice* ,
  ] seq* [ first ] action ;

DEFER: 'action'

: 'element' ( -- parser )
  [
    [
      ('element') , ":" syntax ,
      "a-zA-Z_" range-pattern
      "a-zA-Z0-9_-" range-pattern repeat1 2seq [ first2 swap prefix >string ] action ,
    ] seq* [ first2 <ebnf-var> ] action ,
    ('element') ,
  ] choice* ;

DEFER: 'choice'

: grouped ( quot suffix  -- parser )
  #! Parse a group of choices, with a suffix indicating
  #! the type of group (repeat0, repeat1, etc) and
  #! an quot that is the action that produces the AST.
  2dup
  [
    "(" [ 'choice' sp ] delay ")" syntax-pack
    swap 2seq
    [ first ] rot compose action ,
    "{" [ 'choice' sp ] delay "}" syntax-pack
    swap 2seq
    [ first <ebnf-whitespace> ] rot compose action ,
  ] choice* ;

: 'group' ( -- parser )
  #! A grouping with no suffix. Used for precedence.
  [ ] [
    "~" token sp ensure-not ,
    "*" token sp ensure-not ,
    "+" token sp ensure-not ,
    "?" token sp ensure-not ,
  ] seq* hide grouped ;

: 'ignore' ( -- parser )
  [ <ebnf-ignore> ] "~" syntax grouped ;

: 'repeat0' ( -- parser )
  [ <ebnf-repeat0> ] "*" syntax grouped ;

: 'repeat1' ( -- parser )
  [ <ebnf-repeat1> ] "+" syntax grouped ;

: 'optional' ( -- parser )
  [ <ebnf-optional> ] "?" syntax grouped ;

: 'factor-code' ( -- parser )
  [
    "]]" token ensure-not ,
    "]?" token ensure-not ,
    [ drop t ] satisfy ,
  ] seq* repeat0 [ "" concat-as ] action ;

: 'ensure-not' ( -- parser )
  #! Parses the '!' syntax to ensure that
  #! something that matches the following elements do
  #! not exist in the parse stream.
  [
    "!" syntax ,
    'group' sp ,
  ] seq* [ first <ebnf-ensure-not> ] action ;

: 'ensure' ( -- parser )
  #! Parses the '&' syntax to ensure that
  #! something that matches the following elements does
  #! exist in the parse stream.
  [
    "&" syntax ,
    'group' sp ,
  ] seq* [ first <ebnf-ensure> ] action ;

: ('sequence') ( -- parser )
  #! A sequence of terminals and non-terminals, including
  #! groupings of those.
  [
    [
      'ensure-not' sp ,
      'ensure' sp ,
      'element' sp ,
      'group' sp ,
      'ignore' sp ,
      'repeat0' sp ,
      'repeat1' sp ,
      'optional' sp ,
    ] choice*
    [ dup  , ":" syntax , "a-zA-Z" range-pattern repeat1 [ >string ] action , ] seq* [ first2 <ebnf-var> ] action ,
    ,
  ] choice* ;

: 'action' ( -- parser )
   "[[" 'factor-code' "]]" syntax-pack ;

: 'semantic' ( -- parser )
   "?[" 'factor-code' "]?" syntax-pack ;

: 'sequence' ( -- parser )
  #! A sequence of terminals and non-terminals, including
  #! groupings of those.
  [
    [ ('sequence') , 'action' , ] seq* [ first2 <ebnf-action> ] action ,
    [ ('sequence') , 'semantic' , ] seq* [ first2 <ebnf-semantic> ] action ,
    ('sequence') ,
  ] choice* repeat1 [
     dup length 1 = [ first ] [ <ebnf-sequence> ] if
  ] action ;

: 'actioned-sequence' ( -- parser )
  [
    [ 'sequence' , "=>" syntax , 'action' , ] seq* [ first2 <ebnf-action> ] action ,
    'sequence' ,
  ] choice* ;

: 'choice' ( -- parser )
  'actioned-sequence' sp repeat1 [ dup length 1 = [ first ] [ <ebnf-sequence> ] if  ] action "|" token sp list-of [
    dup length 1 = [ first ] [ <ebnf-choice> ] if
  ] action ;

: 'tokenizer' ( -- parser )
  [
    "tokenizer" syntax ,
    "=" syntax ,
    ">" token ensure-not ,
    [ "default" token sp , 'choice' , ] choice* ,
  ] seq* [ first <ebnf-tokenizer> ] action ;

: 'rule' ( -- parser )
  [
    "tokenizer" token ensure-not ,
    'non-terminal' [ symbol>> ] action  ,
    "=" syntax  ,
    ">" token ensure-not ,
    'choice' ,
  ] seq* [ first2 <ebnf-rule> ] action ;

: 'ebnf' ( -- parser )
  [ 'tokenizer' sp , 'rule' sp , ] choice* repeat1 [ <ebnf> ] action ;

GENERIC: (transform) ( ast -- parser )

SYMBOL: parser
SYMBOL: main
SYMBOL: ignore-ws

: transform ( ast -- object )
  H{ } clone dup dup [
    f ignore-ws set
    parser set
    swap (transform)
    main set
  ] with-variables ;

M: ebnf (transform) ( ast -- parser )
  rules>> [ (transform) ] map last ;

M: ebnf-tokenizer (transform) ( ast -- parser )
  elements>> dup "default" = [
    drop default-tokenizer \ tokenizer set-global any-char
  ] [
  (transform)
  dup parser-tokenizer \ tokenizer set-global
  ] if ;

ERROR: redefined-rule name ;

M: redefined-rule summary
  name>> "Rule '" "' defined more than once" surround ;

M: ebnf-rule (transform) ( ast -- parser )
  dup elements>>
  (transform) [
    swap symbol>> dup get parser? [ redefined-rule ] [ set ] if
  ] keep ;

M: ebnf-sequence (transform) ( ast -- parser )
  #! If ignore-ws is set then each element of the sequence
  #! ignores leading whitespace. This is not inherited by
  #! subelements of the sequence.
  elements>> [
    f ignore-ws [ (transform) ] with-variable
    ignore-ws get [ sp ] when
  ] map seq [ dup length 1 = [ first ] when ] action ;

M: ebnf-choice (transform) ( ast -- parser )
  options>> [ (transform) ] map choice ;

M: ebnf-any-character (transform) ( ast -- parser )
  drop tokenizer any>> call( -- parser ) ;

M: ebnf-range (transform) ( ast -- parser )
  pattern>> range-pattern ;

: transform-group ( ast -- parser )
  #! convert a ast node with groups to a parser for that group
  group>> (transform) ;

M: ebnf-ensure (transform) ( ast -- parser )
  transform-group ensure ;

M: ebnf-ensure-not (transform) ( ast -- parser )
  transform-group ensure-not ;

M: ebnf-ignore (transform) ( ast -- parser )
  transform-group [ drop ignore ] action ;

M: ebnf-repeat0 (transform) ( ast -- parser )
  transform-group repeat0 ;

M: ebnf-repeat1 (transform) ( ast -- parser )
  transform-group repeat1 ;

M: ebnf-optional (transform) ( ast -- parser )
  transform-group optional ;

M: ebnf-whitespace (transform) ( ast -- parser )
  t ignore-ws [ transform-group ] with-variable ;

GENERIC: build-locals ( code ast -- code )

M: ebnf-sequence build-locals ( code ast -- code )
  #! Note the need to filter out this ebnf items that
  #! leave nothing in the AST
  elements>> filter-hidden dup length 1 = [
    first build-locals
  ]  [
    dup [ ebnf-var? ] any? not [
      drop
    ] [
      [
        "FROM: locals => [let :> ; FROM: sequences => nth ; FROM: kernel => nip over ; [let " %
          [
            over ebnf-var? [
              " " % # " over nth :> " %
              name>> %
            ] [
              2drop
            ] if
          ] each-index
          " " %
          %
          " nip ]" %   
       ] "" make
    ] if
  ] if ;

M: ebnf-var build-locals ( code ast -- code )
  [
    "FROM: locals => [let :> ; FROM: kernel => dup nip ; [let " %
    " dup :> " % name>> %
    " " %
    % 
    " nip ]" %    
  ] "" make ;

M: object build-locals ( code ast -- code )
  drop ;

ERROR: bad-effect quot effect ;

: check-action-effect ( quot -- quot )
  dup infer {
    { [ dup ( a -- b ) effect<= ] [ drop ] }
    { [ dup ( -- b ) effect<= ] [ drop [ drop ] prepose ] }
    [ bad-effect ]
  } cond ;

: ebnf-transform ( ast -- parser quot )
  [ parser>> (transform) ]
  [ code>> insert-escapes ]
  [ parser>> ] tri build-locals 
  [ string-lines parse-lines ] call( string -- quot ) ;

M: ebnf-action (transform) ( ast -- parser )
  ebnf-transform check-action-effect action ;

M: ebnf-semantic (transform) ( ast -- parser )
  ebnf-transform semantic ;

M: ebnf-var (transform) ( ast -- parser )
  parser>> (transform) ;

M: ebnf-terminal (transform) ( ast -- parser )
  symbol>> tokenizer one>> call( symbol -- parser ) ;

ERROR: ebnf-foreign-not-found name ;

M: ebnf-foreign-not-found summary
  name>> "Foreign word '" "' not found" surround ;

M: ebnf-foreign (transform) ( ast -- parser )
  dup word>> search [ word>> ebnf-foreign-not-found ] unless*
  swap rule>> [ main ] unless* over rule [
    nip
  ] [
    execute( -- parser )
  ] if* ;

ERROR: parser-not-found name ;

M: ebnf-non-terminal (transform) ( ast -- parser )
  symbol>>  [
    , \ dup , parser get , \ at , [ parser-not-found ] , \ unless* , \ nip ,   
  ] [ ] make box ;

: transform-ebnf ( string -- object )
  'ebnf' parse transform ;

ERROR: unable-to-fully-parse-ebnf remaining ;

ERROR: could-not-parse-ebnf ;

: check-parse-result ( result -- result )
  [
    dup remaining>> [ blank? ] trim [
        unable-to-fully-parse-ebnf
    ] unless-empty
  ] [
    could-not-parse-ebnf
  ] if* ;

: parse-ebnf ( string -- hashtable )
  'ebnf' (parse) check-parse-result ast>> transform ;

: ebnf>quot ( string -- hashtable quot )
  parse-ebnf dup dup parser [ main of compile ] with-variable
  [ compiled-parse ] curry [ with-scope ast>> ] curry ;

PRIVATE>

SYNTAX: <EBNF
  "EBNF>"
  reset-tokenizer parse-multiline-string parse-ebnf main of
  suffix! reset-tokenizer ;

SYNTAX: [EBNF
  "EBNF]"
  reset-tokenizer parse-multiline-string ebnf>quot nip
  suffix! \ call suffix! reset-tokenizer ;

SYNTAX: EBNF:
  reset-tokenizer scan-new-word dup ";EBNF" parse-multiline-string 
  ebnf>quot swapd
  ( input -- ast ) define-declared "ebnf-parser" set-word-prop
  reset-tokenizer ;
