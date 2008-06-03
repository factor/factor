! Copyright (C) 2008 James Cash
! See http://factorcode.org/license.txt for BSD license.
USING: kernel peg sequences arrays strings combinators.lib
namespaces combinators math locals locals.private accessors
vectors syntax lisp.parser assocs parser sequences.lib words quotations
fry lists ;
IN: lisp

DEFER: convert-form
DEFER: funcall
DEFER: lookup-var
DEFER: lisp-macro?
DEFER: lookup-macro
DEFER: macro-call

! Functions to convert s-exps to quotations
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
: convert-body ( cons -- quot )
    [ ] [ convert-form compose ] reduce-cons ; inline
  
: convert-if ( cons -- quot )
    cdr first3 [ convert-form ] tri@ '[ @ , , if ] ;
    
: convert-begin ( cons -- quot )  
    cdr [ convert-form ] [ ] map-as '[ , [ funcall ] each ] ;
    
: convert-cond ( cons -- quot )  
    cdr [ body>> first2 [ convert-form ] bi@ [ '[ @ funcall ] ] dip 2array ]
    { } map-as '[ , cond ]  ;
    
: convert-general-form ( cons -- quot )
    uncons convert-form swap convert-body swap '[ , @ funcall ] ;

! words for convert-lambda  
<PRIVATE  
: localize-body ( assoc body -- assoc newbody )  
    [ dup lisp-symbol? [ over dupd [ name>> ] dip at swap or ]
                     [ dup cons? [ localize-body ] when ] if
                   ] map-cons ;
    
: localize-lambda ( body vars -- newbody newvars )
    make-locals dup push-locals swap
    [ swap localize-body cons convert-form swap pop-locals ] dip swap ;
                   
: split-lambda ( cons -- body vars )                   
    first3 -rot nip [ body>> ] bi@ [ name>> ] map ; inline
    
: rest-lambda ( body vars -- quot )  
    "&rest" swap [ index ] [ remove ] 2bi
    localize-lambda <lambda>
    '[ , cut '[ @ , ] , compose ] ;
    
: normal-lambda ( body vars -- quot )
    localize-lambda <lambda> '[ , compose ] ;
PRIVATE>
    
: convert-lambda ( cons -- quot )  
    split-lambda "&rest" over member? [ rest-lambda ] [ normal-lambda ] if ;
    
: convert-quoted ( cons -- quot )  
    cdr 1quotation ;
    
: form-dispatch ( lisp-symbol -- quot )
    name>>
    { { "lambda" [ convert-lambda ] }
      { "quote" [ convert-quoted ] }
      { "if" [ convert-if ] }
      { "begin" [ convert-begin ] }
      { "cond" [ convert-cond ] }
     [ drop convert-general-form ]
    } case ;
    
: macro-expand ( cons -- quot )
    uncons lookup-macro macro-call convert-form ;
    
: convert-list-form ( cons -- quot )  
    dup car
    { { [ dup lisp-macro?  ] [ macro-expand ] }
      { [ dup lisp-symbol? ] [ form-dispatch ] } 
     [ drop convert-general-form ]
    } cond ;
    
: convert-form ( lisp-form -- quot )
    {
      { [ dup cons? ] [ convert-list-form ] }
      { [ dup lisp-symbol? ] [ '[ , lookup-var ] ] }
     [ 1quotation ]
    } cond ;
    
: lisp-string>factor ( str -- quot )
    lisp-expr parse-result-ast convert-form lambda-rewrite call ;
    
: lisp-eval ( str -- * )    
  lisp-string>factor call ;
    
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
    
: define-primitive ( name vocab word -- )  
    swap lookup 1quotation '[ , compose call ] lisp-define ;