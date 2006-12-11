! Copyright (C) 2006 Chris Double. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
!
IN: fjsc
USING: kernel lazy-lists parser-combinators strings math sequences namespaces io ;

TUPLE: ast-number value ;
TUPLE: ast-identifier value ;
TUPLE: ast-string value ;
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
  
LAZY: 'identifier' ( -- parser )
  [ 
    [ blank? not ] keep 
    [ digit? not ] keep 
    [ CHAR: : = not ] keep 
    [ CHAR: " = not ] keep 
    CHAR: ; = not 
    and and and and
  ] satisfy <+> [ >string <ast-identifier> ] <@ ;

LAZY: 'atom' ( -- parser )
  'number' 'identifier' <|> 'string' <|> ;

LAZY: 'expression' ( -- parser )
  'atom' sp <*> [ <ast-expression> ] <@ ;

GENERIC: (compile) ( ast -- )

M: ast-number (compile) 
  "data_stack.push(" ,
  ast-number-value number>string , 
  ")" , ;

M: ast-string (compile) 
  "data_stack.push('" ,
  ast-string-value , 
  "')" , ;

M: ast-identifier (compile) 
  "fjsc_" , ast-identifier-value , "()" ,  ;

M: ast-expression (compile)
  ast-expression-values [
    (compile) "; " ,
  ] each ;

: compile ( ast -- string )
  [
    [ (compile) ] { } make [ write ] each
  ] string-out ;
  
