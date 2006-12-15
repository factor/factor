! Copyright (C) 2006 Chris Double. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
!
IN: fjsc
USING: kernel lazy-lists parser-combinators strings math sequences namespaces io ;

TUPLE: ast-number value ;
TUPLE: ast-identifier value ;
TUPLE: ast-string value ;
TUPLE: ast-quotation expression ;
TUPLE: ast-array elements ;
TUPLE: ast-define name stack-effect expression ;
TUPLE: ast-expression values ;
TUPLE: ast-word value ;
TUPLE: ast-alien return method args ;
TUPLE: ast-comment ;
TUPLE: ast-stack-effect in out ;

LAZY: 'digit' ( -- parser )
  [ digit? ] satisfy [ digit> ] <@ ;

LAZY: 'number' ( -- parser )
  'digit' <!+> [ 0 [ swap 10 * + ] reduce <ast-number> ] <@ ;

LAZY: 'quote' ( -- parser )
  [ CHAR: " = ] satisfy ;

LAZY: 'string' ( -- parser )
  'quote' sp [
    CHAR: " = not
  ] satisfy <+> [ >string <ast-string> ] <@ &> 'quote' <& ;
 
: identifier-middle? ( ch -- bool )
  [ blank? not ] keep
  [ CHAR: } = not ] keep
  [ CHAR: ] = not ] keep
  [ CHAR: " = not ] keep
  digit? not 
  and and and and ;

LAZY: 'identifier-ends' ( -- parser )  
  [ 
    [ blank? not ] keep
    [ CHAR: " = not ] keep
    [ LETTER? not ] keep
    [ letter? not ] keep
    identifier-middle? not
    and and and and
  ] satisfy <!*> ;

LAZY: 'identifier-middle' ( -- parser )  
  [ identifier-middle? ] satisfy <!+> ;

LAZY: 'identifier' ( -- parser )
  'identifier-ends' 
  'identifier-middle' <&>
  'identifier-ends' <:&> 
  [ concat >string <ast-identifier> ] <@ ;

  
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
  'identifier' sp &>
  'stack-effect' sp <!?> <&>
  'expression' <:&>
  ";" token sp <& [ first3 <ast-define> ] <@ ;

LAZY: 'quotation' ( -- parser )
  "[" token sp 
  'expression' &>
  "]" token sp <& [ <ast-quotation> ] <@ ;

LAZY: 'array' ( -- parser )
  "{" token sp 
  'expression' &>
  "}" token sp <& [ <ast-array> ] <@ ;

LAZY: 'word' ( -- parser )
  "\\" token sp 
  'identifier' sp &> [ ast-identifier-value <ast-word> ] <@ ;

LAZY: 'atom' ( -- parser )
  'identifier' 'number' <|> 'string' <|> ;

LAZY: 'alien' ( -- parser )
  'array' [ ast-array-elements ast-expression-values [ ast-string-value ] map ] <@
  'string' [ ast-string-value ] <@ <&>
  'array' [ ast-array-elements ast-expression-values [ ast-string-value ] map ] <@ <:&>
  "alien-invoke" token sp <& [ first3 <ast-alien> ] <@ ;

LAZY: 'comment' ( -- parser )
  "#!" token sp
  "!" token sp <|> [
    dup CHAR: \n = swap CHAR: \r = or not
  ] satisfy <*> <&> [ drop <ast-comment> ] <@ ;

LAZY: 'expression' ( -- parser )
  'comment' 
  'define' sp <|>
  'word' sp <|>
  'alien' sp <|>
  'atom' sp <|> 
  'quotation' sp <|> 
  'array' sp <|>
  <*> [ <ast-expression> ] <@ ;

LAZY: 'statement' ( -- parser )
  'expression' ;

GENERIC: (compile) ( ast -- )
GENERIC: (literal) ( ast -- )

M: ast-number (literal) 
  ast-number-value number>string , ;

M: ast-number (compile) 
  "factor.data_stack.push(" ,
  (literal)  
  ")" , ;

M: ast-string (literal) 
  "'" ,
  ast-string-value ,
  "'" , ;

M: ast-string (compile) 
  "factor.data_stack.push(" ,
  (literal)
  ")" , ;

M: ast-identifier (literal) 
  "factor.words[\"" , ast-identifier-value , "\"]" ,  ;

M: ast-identifier (compile) 
  (literal) "();" ,  ;

M: ast-define (compile) 
  "factor.words[\"" , 
  dup ast-define-name ast-identifier-value , 
  "\"]=function() { " ,  
  ast-define-expression (compile)
  "}" , ;

M: ast-quotation (literal)   
  "function() { " ,  
  ast-quotation-expression (compile)
  "}" , ;

M: ast-quotation (compile)   
  "factor.data_stack.push(" ,  
  (literal)
  ")" , ;

M: ast-array (literal)   
  "[" ,  
  ast-array-elements ast-expression-values [ (literal) ] [ "," , ] interleave
  "]" , ;

M: ast-array (compile)   
  "factor.data_stack.push(" ,  
  (literal)
  ")" , ;

M: ast-expression (literal)
  ast-expression-values [
    (literal) 
  ] each ;

M: ast-expression (compile)
  ast-expression-values [ (compile) ] [ ";" , ] interleave ;

M: ast-alien (compile)
  dup ast-alien-return empty? not [
    "factor.data_stack.push(" ,
  ] when
  dup ast-alien-method ,
  ".apply(" ,
  "factor.data_stack.pop(), [" ,
  dup ast-alien-args [ drop "factor.data_stack.pop()" , ] [ "," , ] interleave 
  "])" ,
  ast-alien-return empty? not [
    ")" ,
  ] when ;

M: ast-word (literal)   
  "factor.words[\"" , 
  ast-word-value ,
  "\"]" , ;

M: ast-word (compile)
  "factor.data_stack.push(" ,
  (literal)
  ")" , ;
  
M: ast-comment (compile)
  drop "/* */" , ;

M: ast-stack-effect (compile)
  drop ;

: fjsc-compile ( ast -- string )
  [
    [ (compile) ] { } make [ write ] each
  ] string-out ;
  
: fjsc-literal ( ast -- string )
  [
    [ (literal) ] { } make [ write ] each
  ] string-out ;
  