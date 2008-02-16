! Copyright (C) 2006 Chris Double. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel peg strings promises sequences math math.parser
       namespaces words quotations arrays hashtables io
       io.streams.string assocs memoize ascii ;
IN: fjsc

TUPLE: ast-number value ;
TUPLE: ast-identifier value vocab ;
TUPLE: ast-string value ;
TUPLE: ast-quotation values ;
TUPLE: ast-array elements ;
TUPLE: ast-define name stack-effect expression ;
TUPLE: ast-expression values ;
TUPLE: ast-word value vocab ;
TUPLE: ast-comment ;
TUPLE: ast-stack-effect in out ;
TUPLE: ast-use name ;
TUPLE: ast-using names ;
TUPLE: ast-in name ;
TUPLE: ast-hashtable elements ;

C: <ast-number> ast-number
C: <ast-identifier> ast-identifier
C: <ast-string> ast-string
C: <ast-quotation> ast-quotation
C: <ast-array> ast-array
C: <ast-define> ast-define
C: <ast-expression> ast-expression
C: <ast-word> ast-word
C: <ast-comment> ast-comment
C: <ast-stack-effect> ast-stack-effect
C: <ast-use> ast-use
C: <ast-using> ast-using
C: <ast-in> ast-in
C: <ast-hashtable> ast-hashtable

: identifier-middle? ( ch -- bool )
  [ blank? not ] keep
  [ CHAR: } = not ] keep
  [ CHAR: ] = not ] keep
  [ CHAR: ; = not ] keep
  [ CHAR: " = not ] keep
  digit? not
  and and and and and ;

MEMO: 'identifier-ends' ( -- parser )
  [
    [ blank? not ] keep
    [ CHAR: " = not ] keep
    [ CHAR: ; = not ] keep
    [ LETTER? not ] keep
    [ letter? not ] keep
    identifier-middle? not
    and and and and and
  ] satisfy repeat0 ;

MEMO: 'identifier-middle' ( -- parser )
  [ identifier-middle? ] satisfy repeat1 ;

MEMO: 'identifier' ( -- parser )
  [
    'identifier-ends' ,
    'identifier-middle' ,
    'identifier-ends' ,
  ] { } make seq [
    concat >string f <ast-identifier>
  ] action ;


DEFER: 'expression'

MEMO: 'effect-name' ( -- parser )
  [
    [ blank? not ] keep
    [ CHAR: ) = not ] keep
    CHAR: - = not
    and and
  ] satisfy repeat1 [ >string ] action ;

MEMO: 'stack-effect' ( -- parser )
  [
    "(" token hide ,
    'effect-name' sp repeat0 ,
    "--" token sp hide ,
    'effect-name' sp repeat0 ,
    ")" token sp hide ,
  ] { } make seq [
    first2 <ast-stack-effect>
  ] action ;

MEMO: 'define' ( -- parser )
  [
    ":" token sp hide ,
    'identifier' sp [ ast-identifier-value ] action ,
    'stack-effect' sp optional ,
    'expression' ,
    ";" token sp hide ,
  ] { } make seq [ first3 <ast-define> ] action ;

MEMO: 'quotation' ( -- parser )
  [
    "[" token sp hide ,
    'expression' [ ast-expression-values ] action ,
    "]" token sp hide ,
  ] { } make seq [ first <ast-quotation> ] action ;

MEMO: 'array' ( -- parser )
  [
    "{" token sp hide ,
    'expression' [ ast-expression-values ] action ,
    "}" token sp hide ,
  ] { } make seq [ first <ast-array> ] action ;

MEMO: 'word' ( -- parser )
  [
    "\\" token sp hide ,
    'identifier' sp ,
  ] { } make seq [ first ast-identifier-value f <ast-word> ] action ;

MEMO: 'atom' ( -- parser )
  [
    'identifier' ,
    'integer' [ <ast-number> ] action ,
    'string' [ <ast-string> ] action ,
  ] { } make choice ;

MEMO: 'comment' ( -- parser )
  [
    [
      "#!" token sp ,
      "!" token sp ,
    ] { } make choice hide ,
    [
      dup CHAR: \n = swap CHAR: \r = or not
    ] satisfy repeat0 ,
  ] { } make seq [ drop <ast-comment> ] action ;

MEMO: 'USE:' ( -- parser )
  [
    "USE:" token sp hide ,
    'identifier' sp ,
  ] { } make seq [ first ast-identifier-value <ast-use> ] action ;

MEMO: 'IN:' ( -- parser )
  [
    "IN:" token sp hide ,
    'identifier' sp ,
  ] { } make seq [ first ast-identifier-value <ast-in> ] action ;

MEMO: 'USING:' ( -- parser )
  [
    "USING:" token sp hide ,
    'identifier' sp [ ast-identifier-value ] action repeat1 ,
    ";" token sp hide ,
  ] { } make seq [ first <ast-using> ] action ;

MEMO: 'hashtable' ( -- parser )
  [
    "H{" token sp hide ,
    'expression' [ ast-expression-values ] action ,
    "}" token sp hide ,
  ] { } make seq [ first <ast-hashtable> ] action ;

MEMO: 'parsing-word' ( -- parser )
  [
    'USE:' ,
    'USING:' ,
    'IN:' ,
  ] { } make choice ;

MEMO: 'expression' ( -- parser )
  [
    [
      'comment' ,
      'parsing-word' sp ,
      'quotation' sp ,
      'define' sp ,
      'array' sp ,
      'hashtable' sp ,
      'word' sp ,
      'atom' sp ,
    ] { } make choice repeat0 [ <ast-expression> ] action
  ] delay ;

MEMO: 'statement' ( -- parser )
  'expression' ;

GENERIC: (compile) ( ast -- )
GENERIC: (literal) ( ast -- )

M: ast-number (literal)
  ast-number-value number>string , ;

M: ast-number (compile)
  "factor.push_data(" ,
  (literal)
  "," , ;

M: ast-string (literal)
  "\"" ,
  ast-string-value ,
  "\"" , ;

M: ast-string (compile)
  "factor.push_data(" ,
  (literal)
  "," , ;

M: ast-identifier (literal)
  dup ast-identifier-vocab [
   "factor.get_word(\"" ,
   dup ast-identifier-vocab ,
   "\",\"" ,
   ast-identifier-value ,
   "\")" ,
  ] [
   "factor.find_word(\"" , ast-identifier-value , "\")" ,
  ] if ;

M: ast-identifier (compile)
  (literal) ".execute(" ,  ;

M: ast-define (compile)
  "factor.define_word(\"" ,
  dup ast-define-name ,
  "\",\"source\"," ,
  ast-define-expression (compile)
  "," , ;

: do-expressions ( seq -- )
  dup empty? not [
    unclip
    dup ast-comment? not [
      "function() {" ,
      (compile)
      do-expressions
      ")}" ,
    ] [
      drop do-expressions
    ] if
  ] [
    drop "factor.cont.next" ,
  ] if  ;

M: ast-quotation (literal)
  "factor.make_quotation(\"source\"," ,
  ast-quotation-values do-expressions
  ")" , ;

M: ast-quotation (compile)
  "factor.push_data(factor.make_quotation(\"source\"," ,
  ast-quotation-values do-expressions
  ")," , ;

M: ast-array (literal)
  "[" ,
  ast-array-elements [ "," , ] [ (literal) ] interleave
  "]" , ;

M: ast-array (compile)
  "factor.push_data(" , (literal) "," , ;

M: ast-hashtable (literal)
  "new Hashtable().fromAlist([" ,
  ast-hashtable-elements [ "," , ] [ (literal) ] interleave
  "])" , ;

M: ast-hashtable (compile)
  "factor.push_data(" , (literal) "," , ;


M: ast-expression (literal)
  ast-expression-values [
    (literal)
  ] each ;

M: ast-expression (compile)
  ast-expression-values do-expressions ;

M: ast-word (literal)
  dup ast-word-vocab [
   "factor.get_word(\"" ,
   dup ast-word-vocab ,
   "\",\"" ,
   ast-word-value ,
   "\")" ,
  ] [
   "factor.find_word(\"" , ast-word-value , "\")" ,
  ] if ;

M: ast-word (compile)
  "factor.push_data(" ,
  (literal)
  "," , ;

M: ast-comment (compile)
  drop ;

M: ast-stack-effect (compile)
  drop ;

M: ast-use (compile)
  "factor.use(\"" ,
  ast-use-name ,
  "\"," , ;

M: ast-in (compile)
  "factor.set_in(\"" ,
  ast-in-name ,
  "\"," , ;

M: ast-using (compile)
  "factor.using([" ,
  ast-using-names [
    "," ,
  ] [
    "\"" , , "\"" ,
  ] interleave
  "]," , ;

GENERIC: (parse-factor-quotation) ( object -- ast )

M: number (parse-factor-quotation) ( object -- ast )
  <ast-number> ;

M: symbol (parse-factor-quotation) ( object -- ast )
  dup >string swap word-vocabulary <ast-identifier> ;

M: word (parse-factor-quotation) ( object -- ast )
  dup word-name swap word-vocabulary <ast-identifier> ;

M: string (parse-factor-quotation) ( object -- ast )
  <ast-string> ;

M: quotation (parse-factor-quotation) ( object -- ast )
  [
    [ (parse-factor-quotation) , ] each
  ] { } make <ast-quotation> ;

M: array (parse-factor-quotation) ( object -- ast )
  [
    [ (parse-factor-quotation) , ] each
  ] { } make <ast-array> ;

M: hashtable (parse-factor-quotation) ( object -- ast )
  >alist [
    [ (parse-factor-quotation) , ] each
  ] { } make <ast-hashtable> ;

M: wrapper (parse-factor-quotation) ( object -- ast )
  wrapped dup word-name swap word-vocabulary <ast-word> ;

GENERIC: fjsc-parse ( object -- ast )

M: string fjsc-parse ( object -- ast )
  'expression' parse parse-result-ast ;

M: quotation fjsc-parse ( object -- ast )
  [
    [ (parse-factor-quotation) , ] each
  ] { } make <ast-expression> ;

: fjsc-compile ( ast -- string )
  [
    [
      "(" ,
      (compile)
      ")" ,
    ] { } make [ write ] each
  ] with-string-writer ;

: fjsc-compile* ( string -- string )
  'statement' parse parse-result-ast fjsc-compile ;

: fc* ( string -- string )
  [
  'statement' parse parse-result-ast ast-expression-values do-expressions
  ] { } make [ write ] each ;


: fjsc-literal ( ast -- string )
  [
    [ (literal) ] { } make [ write ] each
  ] with-string-writer ;

