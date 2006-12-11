! Copyright (C) 2006 Chris Double. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
!
IN: fjsc
USING: kernel lazy-lists parser-combinators strings math sequences namespaces io ;

TUPLE: ast-number value ;
TUPLE: ast-identifier value ;
TUPLE: ast-string value ;
TUPLE: ast-define name expression ;
TUPLE: ast-expression values ;

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
    [ CHAR: : = not ] keep 
    [ CHAR: " = not ] keep 
    CHAR: ; = not 
    and and and 
  ] satisfy <*> ;

LAZY: 'identifier-middle' ( -- parser )  
  [ 
    [ blank? not ] keep 
    [ CHAR: : = not ] keep 
    [ CHAR: " = not ] keep 
    [ CHAR: ; = not ] keep
    digit? not
    and and and and
  ] satisfy <+> ;

USE: prettyprint
LAZY: 'identifier' ( -- parser )
  'identifier-ends' 
  'identifier-middle' <&> [ first2 append ] <@
  'identifier-ends' <&> [ first2 append ] <@
  [ >string <ast-identifier> ] <@ ;

LAZY: 'define' ( -- parser )
  ":" token sp 
  'identifier' sp &>
  'expression' <&>
  ";" token sp <& [ first2 <ast-define> ] <@ ;

LAZY: 'atom' ( -- parser )
  'identifier' 'number' <|> 'string' <|> ;

LAZY: 'expression' ( -- parser )
  'define' sp 'atom' sp <|> <*> [ <ast-expression> ] <@ ;

LAZY: 'statement' ( -- parser )
  'define' 'expression' <|> ;

GENERIC: (compile) ( ast -- )

M: ast-number (compile) 
  "factor.data_stack.push(" ,
  ast-number-value number>string , 
  ")" , ;

M: ast-string (compile) 
  "factor.data_stack.push('" ,
  ast-string-value , 
  "')" , ;

M: ast-identifier (compile) 
  "factor.words[\"" , ast-identifier-value , "\"]()" ,  ;

M: ast-define (compile) 
  "factor.words[\"" , 
  dup ast-define-name ast-identifier-value , 
  "\"]=function() { " ,  
  ast-define-expression (compile)
  "}" , ;

M: ast-expression (compile)
  ast-expression-values [
    (compile) "; " ,
  ] each ;

: fjsc-compile ( ast -- string )
  [
    [ (compile) ] { } make [ write ] each
  ] string-out ;
  
