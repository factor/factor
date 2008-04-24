! Copyright (C) 2008 James Cash
! See http://factorcode.org/license.txt for BSD license.
USING: kernel peg.ebnf peg.expr math.parser sequences arrays strings combinators.lib
namespaces combinators math bake locals.private accessors vectors syntax ;
IN: lisp

TUPLE: lisp-symbol name ;

C: <lisp-symbol> lisp-symbol

EBNF: lisp-expr
_            = (" " | "\t" | "\n")*
LPAREN       = "("
RPAREN       = ")"
dquote       = '"'
digit        = [0-9]
integer      = (digit)+                               => [[ string>number ]]
float        = (digit)+ "." (digit)*                  => [[ first3 >string [ >string ] dipd 3append string>number ]]
number       = float
              | integer
id-specials  = "!" | "$" | "%" | "&" | "*" | "/" | ":" | "<"
              | " =" | ">" | "?" | "^" | "_" | "~" | "+" | "-" | "." | "@"
letters      = [a-zA-Z]                               => [[ 1array >string ]]
initials     = letters | id-specials
numbers      = [0-9]                                  => [[ 1array >string ]]
subsequents  = initials | numbers
identifier   = initials (subsequents)*                => [[ first2 concat append <lisp-symbol> ]]
string       = dquote ("\" . | !(dquote) . )*  dquote => [[ second >string ]]
atom         = number
              | identifier
              | string
list-item    = _ (atom|list) _                        => [[ second ]]
list         = LPAREN (list-item)* RPAREN             => [[ second ]]
;EBNF

DEFER: convert-form

: convert-body ( lisp-form -- quot )
  [ convert-form ] map [ ] [ compose ] reduce ; inline
  
: convert-if ( lisp-form -- quot )
  1 tail [ convert-form ] map reverse first3  [ % , , if ] bake ;
  
: convert-begin ( lisp-form -- quot )  
  1 tail convert-body ;
  
: convert-cond ( lisp-form -- quot )  
  1 tail [ [ convert-body map ] map ] [ % cond ] bake ;
  
: convert-general-form ( lisp-form -- quot )  
  unclip swap convert-body [ % , ] bake ;
  
<PRIVATE  
: localize-body ( vars body -- newbody )  
  [ dup lisp-symbol? [ tuck name>> swap member? [ name>> make-local ] [ ] if ]
                     [ dup vector? [ localize-body ] [ nip ] if ] if ] with map ; inline
PRIVATE>                     
  
: convert-lambda ( lisp-form -- quot )  
  1 tail unclip reverse [ name>> ] map dup make-locals dup push-locals
  [ swap localize-body convert-body ] dipd pop-locals swap <lambda> ;
  
: convert-list-form ( lisp-form -- quot )  
dup first
  { { [ dup "if" <lisp-symbol> equal? ] [ drop convert-if ] }
    { [ dup "begin" <lisp-symbol> equal? ] [ drop convert-begin ] }
    { [ dup "cond" <lisp-symbol> equal? ] [ drop convert-cond ] }
    { [ dup "lambda" <lisp-symbol> equal? ] [ drop convert-lambda ] }
   [ drop convert-general-form ]
  } cond ;
  
: convert-form ( lisp-form -- quot )
  { { [ dup [ sequence? ] [ number? not ] bi and ] [ convert-list-form ] }
   [ [ , ] [ ] make ]
  } cond ;