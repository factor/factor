! Copyright (C) 2008 James Cash
! See http://factorcode.org/license.txt for BSD license.
USING: kernel peg sequences arrays strings combinators.lib
namespaces combinators math bake locals.private accessors vectors syntax lisp.parser ;
IN: lisp

DEFER: convert-form
DEFER: funcall

! Functions to convert s-exps to quotations
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
: convert-body ( s-exp -- quot )
  [ convert-form ] map reverse [ ] [ compose ] reduce ; inline
  
: convert-if ( s-exp -- quot )
  rest [ convert-form ] map reverse first3  [ % , , if ] bake ;
  
: convert-begin ( s-exp -- quot )  
  rest convert-body ;
  
: convert-cond ( s-exp -- quot )  
  rest [ [ convert-body map ] map ] [ % cond ] bake ;
  
: convert-general-form ( s-exp -- quot )
  unclip swap convert-body [ % , funcall ] bake ;
  
<PRIVATE  
: localize-body ( vars body -- newbody )  
  [ dup lisp-symbol? [ tuck name>> swap member? [ name>> make-local ] [ ] if ]
                     [ dup s-exp? [ body>> localize-body <s-exp> ] [ nip ] if ] if ] with map ;
PRIVATE>                     
  
: convert-lambda ( s-exp -- quot )  
  first3 -rot nip [ body>> ] bi@ reverse [ name>> ] map dup make-locals dup push-locals
  [ swap localize-body convert-body ] dipd pop-locals swap <lambda> ;
  
: convert-quoted ( s-exp -- quot )  
  second [ , ] bake ;
  
: convert-list-form ( s-exp -- quot )  
  dup first dup lisp-symbol?
    [ name>>
      { { "lambda" [ convert-lambda ] }
        { "quote" [ convert-quoted ] }
        { "if" [ convert-if ] }
        { "begin" [ convert-begin ] }
        { "cond" [ convert-cond ] }
       [ drop convert-general-form ]
      } case ]
    [ drop convert-general-form ] if ;
  
: convert-form ( lisp-form -- quot )
  { { [ dup s-exp? ] [ body>> convert-list-form ] }
   [ [ , ] [ ] make ]
  } cond ;
  
: lisp-string>factor ( str -- quot )
  lisp-expr parse-result-ast convert-form ;
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: lisp-env  

H{ } clone lisp-env set

: define-lisp-word ( name body -- )
  lisp-env get set-at ;
  
: get-lisp-word ( name -- word )  
  lisp-env get at ;
  
: funcall ( quot sym -- * )  
  name>> get-lisp-word call ;