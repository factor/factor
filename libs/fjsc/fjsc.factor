! Copyright (C) 2006 Chris Double. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
!
IN: fjsc
USING: kernel lazy-lists parser-combinators strings math sequences namespaces io words arrays ;

TUPLE: ast-number value ;
TUPLE: ast-identifier value ;
TUPLE: ast-string value ;
TUPLE: ast-quotation values ;
TUPLE: ast-array elements ;
TUPLE: ast-define name stack-effect expression ;
TUPLE: ast-expression values ;
TUPLE: ast-word value ;
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
  ] satisfy <*> [ >string <ast-string> ] <@ &> 'quote' <& ;
 
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
  'identifier' sp &> [ ast-identifier-value <ast-word> ] <@ ;

LAZY: 'atom' ( -- parser )
  'identifier' 'number' <|> 'string' <|> ;

LAZY: 'comment' ( -- parser )
  "#!" token sp
  "!" token sp <|> [
    dup CHAR: \n = swap CHAR: \r = or not
  ] satisfy <*> <&> [ drop <ast-comment> ] <@ ;

LAZY: 'expression' ( -- parser )
  'comment' 
  'quotation' sp <|> 
  'array' sp <|>
  'define' sp <|>
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
  "world.push_data(" ,
  (literal)  
  ",world," , ;

M: ast-string (literal) 
  "'" ,
  ast-string-value ,
  "'" , ;

M: ast-string (compile) 
  "factor.push_data(" ,
  (literal)
  ",world," , ;

M: ast-identifier (literal) 
  "world.words[\"" , ast-identifier-value , "\"]" ,  ;

M: ast-identifier (compile) 
  (literal) ".execute(world, " ,  ;

M: ast-define (compile) 
  "world.define_word(\"" , 
  dup ast-define-name , 
  "\",\"source\"," ,
  ast-define-expression (compile)
  ",world," , ;

: do-expressions ( seq -- )
  dup empty? not [
    unclip
    dup ast-comment? not [
      "function(world) {" ,
      (compile) 
      do-expressions
      ")}" ,
    ] [
      drop do-expressions
    ] if
  ] [
    drop "world.next" ,
  ] if  ;

M: ast-quotation (literal)   
  "world.make_quotation(\"source\"," ,
  ast-quotation-values do-expressions
  ")" , ;

M: ast-quotation (compile)   
  "world.push_data(world.make_quotation(\"source\"," ,
  ast-quotation-values do-expressions
  "),world," , ;

M: ast-array (literal)   
  "[" ,  
  ast-array-elements [ (literal) ] [ "," , ] interleave
  "]" , ;

M: ast-array (compile)   
  "world.push_data(" , (literal) ",world," , ;


M: ast-expression (literal)
  ast-expression-values [
    (literal) 
  ] each ;
  
M: ast-expression (compile)
  ast-expression-values do-expressions ;

M: ast-word (literal)   
  "factor.words[\"" , 
  ast-word-value ,
  "\"]" , ;

M: ast-word (compile)
  "factor.push_data(" ,
  (literal)
  ",world," , ;
  
M: ast-comment (compile)
  drop ;

M: ast-stack-effect (compile)
  drop ;

GENERIC: (parse-factor-quotation) ( object -- ast )

M: number (parse-factor-quotation) ( object -- ast )
  <ast-number> ;

M: symbol (parse-factor-quotation) ( object -- ast )
  >string <ast-identifier> ;

M: word (parse-factor-quotation) ( object -- ast )
  word-name <ast-identifier> ;

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

M: wrapper (parse-factor-quotation) ( object -- ast )
  wrapped word-name <ast-word> ;

GENERIC: fjsc-parse ( object -- ast )

M: string fjsc-parse ( object -- ast )
  'expression' parse car parse-result-parsed ;

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
  'statement' parse car parse-result-parsed fjsc-compile ;

: fc* ( string -- string )
  [
  'statement' parse car parse-result-parsed ast-expression-values do-expressions 
  ] { } make [ write ] each ;
  

: fjsc-literal ( ast -- string )
  [
    [ (literal) ] { } make [ write ] each
  ] string-out ;
  