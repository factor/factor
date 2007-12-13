! Copyright (C) 2006 Chris Double. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel lazy-lists parser-combinators  parser-combinators.simple
       strings promises sequences math math.parser namespaces words
       quotations arrays hashtables io io.streams.string assocs ;
IN: fjsc

TUPLE: ast-number value ;
C: <ast-number> ast-number

TUPLE: ast-identifier value vocab ;
C: <ast-identifier> ast-identifier

TUPLE: ast-string value ;
C: <ast-string> ast-string

TUPLE: ast-quotation values ;
C: <ast-quotation> ast-quotation

TUPLE: ast-array elements ;
C: <ast-array> ast-array

TUPLE: ast-define name stack-effect expression ;
C: <ast-define> ast-define

TUPLE: ast-expression values ;
C: <ast-expression> ast-expression

TUPLE: ast-word value vocab ;
C: <ast-word> ast-word

TUPLE: ast-comment ;
C: <ast-comment> ast-comment

TUPLE: ast-stack-effect in out ;
C: <ast-stack-effect> ast-stack-effect

TUPLE: ast-use name ;
C: <ast-use> ast-use

TUPLE: ast-using names ;
C: <ast-using> ast-using

TUPLE: ast-in name ;
C: <ast-in> ast-in

TUPLE: ast-hashtable elements ;
C: <ast-hashtable> ast-hashtable

: identifier-middle? ( ch -- bool )
  [ blank? not ] keep
  [ CHAR: } = not ] keep
  [ CHAR: ] = not ] keep
  [ CHAR: ;" = not ] keep
  [ CHAR: " = not ] keep
  digit? not
  and and and and and ;

LAZY: 'identifier-ends' ( -- parser )
  [
    [ blank? not ] keep
    [ CHAR: " = not ] keep
    [ CHAR: ;" = not ] keep
    [ LETTER? not ] keep
    [ letter? not ] keep
    identifier-middle? not
    and and and and and
  ] satisfy <!*> ;

LAZY: 'identifier-middle' ( -- parser )
  [ identifier-middle? ] satisfy <!+> ;

LAZY: 'identifier' ( -- parser )
  'identifier-ends'
  'identifier-middle' <&>
  'identifier-ends' <:&>
  [ concat >string f <ast-identifier> ] <@ ;


DEFER: 'expression'

LAZY: 'effect-name' ( -- parser )
  [
    [ blank? not ] keep
    CHAR: - = not
    and
  ] satisfy <!+> [ >string ] <@ ;

LAZY: 'stack-effect' ( -- parser )
  "(" token sp
  'effect-name' sp <*> &>
  "--" token sp <&
  'effect-name' sp <*> <&>
  ")" token sp <& [ first2 <ast-stack-effect> ] <@ ;

LAZY: 'define' ( -- parser )
  ":" token sp
  'identifier' sp [ ast-identifier-value ] <@ &>
  'stack-effect' sp <!?> <&>
  'expression' <:&>
  ";" token sp <& [ first3 <ast-define> ] <@ ;

LAZY: 'quotation' ( -- parser )
  "[" token sp
  'expression' [ ast-expression-values ] <@ &>
  "]" token sp <& [ <ast-quotation> ] <@ ;

LAZY: 'array' ( -- parser )
  "{" token sp
  'expression' [ ast-expression-values ] <@ &>
  "}" token sp <& [ <ast-array> ] <@ ;

LAZY: 'word' ( -- parser )
  "\\" token sp
  'identifier' sp &> [ ast-identifier-value f <ast-word> ] <@ ;

LAZY: 'atom' ( -- parser )
  'identifier' 'integer' [ <ast-number> ] <@ <|> 'string' [ <ast-string> ] <@ <|> ;

LAZY: 'comment' ( -- parser )
  "#!" token sp
  "!" token sp <|> [
    dup CHAR: \n = swap CHAR: \r = or not
  ] satisfy <*> <&> [ drop <ast-comment> ] <@ ;

LAZY: 'USE:' ( -- parser )
  "USE:" token sp
  'identifier' sp &> [ ast-identifier-value <ast-use> ] <@ ;

LAZY: 'IN:' ( -- parser )
  "IN:" token sp
  'identifier' sp &> [ ast-identifier-value <ast-in> ] <@ ;

LAZY: 'USING:' ( -- parser )
  "USING:" token sp
  'identifier' sp [ ast-identifier-value ] <@ <+> &>
  ";" token sp <& [ <ast-using> ] <@ ;

LAZY: 'hashtable' ( -- parser )
  "H{" token sp
  'expression' [ ast-expression-values ] <@ &>
  "}" token sp <& [ <ast-hashtable> ] <@ ;

LAZY: 'parsing-word' ( -- parser )
  'USE:'
  'USING:' <|>
  'IN:' <|> ;

LAZY: 'expression' ( -- parser )
  'comment'
  'parsing-word' sp <|>
  'quotation' sp <|>
  'define' sp <|>
  'array' sp <|>
  'hashtable' sp <|>
  'word' sp <|>
  'atom' sp <|>
  <*> [ <ast-expression> ] <@ ;

LAZY: 'statement' ( -- parser )
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
  'expression' parse-1 ;

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
  ] string-out ;

: fjsc-compile* ( string -- string )
  'statement' parse-1 fjsc-compile ;

: fc* ( string -- string )
  [
  'statement' parse-1 ast-expression-values do-expressions
  ] { } make [ write ] each ;


: fjsc-literal ( ast -- string )
  [
    [ (literal) ] { } make [ write ] each
  ] string-out ;

