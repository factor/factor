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
TUPLE: ast-define name expression ;
TUPLE: ast-expression values ;
TUPLE: ast-alien return object method args ;

LAZY: 'digit' ( -- parser )
  [ digit? ] satisfy [ digit> ] <@ ;

LAZY: 'number' ( -- parser )
  'digit' <+> [ 0 [ swap 10 * + ] reduce <ast-number> ] <@ ;

LAZY: 'quote' ( -- parser )
  [ CHAR: " = ] satisfy ;

LAZY: 'string' ( -- parser )
  'quote' sp [
    CHAR: " = not
  ] satisfy <+> [ >string <ast-string> ] <@ &> 'quote' <& ;

LAZY: 'identifier-ends' ( -- parser )  
  [ 
    [ blank? not ] keep 
    [ CHAR: [ = not ] keep 
    [ CHAR: ] = not ] keep 
    [ CHAR: { = not ] keep 
    [ CHAR: } = not ] keep 
    [ CHAR: : = not ] keep 
    [ CHAR: " = not ] keep 
    CHAR: ; = not 
    and and and and and and and
  ] satisfy <*> ;

LAZY: 'identifier-middle' ( -- parser )  
  [ 
    [ blank? not ] keep 
    [ CHAR: [ = not ] keep 
    [ CHAR: ] = not ] keep 
    [ CHAR: { = not ] keep 
    [ CHAR: } = not ] keep 
    [ CHAR: : = not ] keep 
    [ CHAR: " = not ] keep 
    [ CHAR: ; = not ] keep
    digit? not
    and and and and and and and and
  ] satisfy <+> ;

LAZY: 'identifier' ( -- parser )
  'identifier-ends' 
  'identifier-middle' <&> [ first2 append ] <@
  'identifier-ends' <&> [ first2 append ] <@
  [ >string <ast-identifier> ] <@ ;

DEFER: 'expression'

LAZY: 'define' ( -- parser )
  ":" token sp 
  'identifier' sp &>
  'expression' <&>
  ";" token sp <& [ first2 <ast-define> ] <@ ;

LAZY: 'quotation' ( -- parser )
  "[" token sp 
  'expression' &>
  "]" token sp <& [ <ast-quotation> ] <@ ;

LAZY: 'array' ( -- parser )
  "{" token sp 
  'expression' &>
  "}" token sp <& [ <ast-array> ] <@ ;

LAZY: 'atom' ( -- parser )
  'identifier' 'number' <|> 'string' <|> ;

LAZY: 'alien' ( -- parser )
  'array' [ ast-array-elements ast-expression-values [ ast-string-value ] map ] <@
  'string' [ ast-string-value ] <@ <&>
  'string' [ ast-string-value ] <@ <:&>
  'array' [ ast-array-elements ast-expression-values [ ast-string-value ] map ] <@ <:&>
  "alien-invoke" token sp <& [ first4 <ast-alien> ] <@ ;

LAZY: 'expression' ( -- parser )
  'define' sp 
  'alien' sp <|>
  'atom' sp <|> 
  'quotation' sp <|> 
  'array' sp <|>
  <*> [ <ast-expression> ] <@ ;

LAZY: 'statement' ( -- parser )
  'define' 'expression' <|> ;

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
  dup ast-alien-object ,	
  "." ,
  dup ast-alien-method ,
  "(" ,
  dup ast-alien-args [ drop "factor.data_stack.pop()" , ] [ "," , ] interleave 
  ")" ,
  ast-alien-return empty? not [
    ")" ,
  ] when ;
  
: fjsc-compile ( ast -- string )
  [
    [ (compile) ] { } make [ write ] each
  ] string-out ;
  
: fjsc-literal ( ast -- string )
  [
    [ (literal) ] { } make [ write ] each
  ] string-out ;
  