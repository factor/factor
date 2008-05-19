! Copyright (C) 2008 James Cash
! See http://factorcode.org/license.txt for BSD license.
USING: kernel peg sequences arrays strings combinators.lib
namespaces combinators math bake locals locals.private accessors
vectors syntax lisp.parser assocs parser sequences.lib words quotations ;
IN: lisp

DEFER: convert-form
DEFER: funcall
DEFER: lookup-var

! Functions to convert s-exps to quotations
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
: convert-body ( s-exp -- quot )
  [ convert-form ] map [ ] [ compose ] reduce ; inline
  
: convert-if ( s-exp -- quot )
  rest [ convert-form ] map reverse first3  [ % , , if ] bake ;
  
: convert-begin ( s-exp -- quot )  
  rest [ convert-form ] map >quotation [ , [ funcall ] each ] bake ;
  
: convert-cond ( s-exp -- quot )  
  rest [ body>> >array [ convert-form ] map first2 swap `{ [ % funcall ] , } bake ]
  map >array [ , cond ] bake ;
  
: convert-general-form ( s-exp -- quot )
  unclip convert-form swap convert-body [ , % funcall ] bake ;

! words for convert-lambda  
<PRIVATE  
: localize-body ( assoc body -- assoc newbody )  
  [ dup lisp-symbol? [ over dupd [ name>> ] dip at swap or ]
                     [ dup s-exp? [ body>> localize-body <s-exp> ] when ] if
                   ] map ;
  
: localize-lambda ( body vars -- newbody newvars )
  make-locals dup push-locals swap
  [ swap localize-body <s-exp> convert-form swap pop-locals ] dip swap ;
                   
: split-lambda ( s-exp -- body vars )                   
  first3 -rot nip [ body>> ] bi@ [ name>> ] map ; inline
  
: rest-lambda ( body vars -- quot )  
  "&rest" swap [ remove ] [ index ] 2bi
  [ localize-lambda <lambda> ] dip
  [ , cut swap [ % , ] bake , compose ] bake ;
  
: normal-lambda ( body vars -- quot )
  localize-lambda <lambda> [ , compose ] bake ;
PRIVATE>
  
: convert-lambda ( s-exp -- quot )  
  split-lambda dup "&rest"  swap member? [ rest-lambda ] [ normal-lambda ] if ;
  
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
    { [ dup lisp-symbol? ] [ [ , lookup-var ] bake ] }
    [ [ , ] bake ]
  } cond ;
                
: lisp-string>factor ( str -- quot )
  lisp-expr parse-result-ast convert-form lambda-rewrite call ;
  
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: lisp-env
ERROR: no-such-var var ;

: init-env ( -- )
  H{ } clone lisp-env set ;

: lisp-define ( name quot -- )
  swap lisp-env get set-at ;
  
: lisp-get ( name -- word )
  dup lisp-env get at [ ] [ no-such-var throw ] ?if ;
  
: lookup-var ( lisp-symbol -- quot )
  name>> lisp-get ;
  
: funcall ( quot sym -- * )
  dup lisp-symbol?  [ lookup-var ] when call ; inline
  
: define-primitve ( name vocab word -- )  
  swap lookup [ [ , ] compose call ] bake lisp-define ;