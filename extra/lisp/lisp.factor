! Copyright (C) 2008 James Cash
! See http://factorcode.org/license.txt for BSD license.
USING: kernel peg sequences arrays strings combinators.lib
namespaces combinators math bake locals locals.private accessors
vectors syntax lisp.parser assocs parser sequences.lib words quotations
fry ;
IN: lisp

DEFER: convert-form
DEFER: funcall
DEFER: lookup-var

! Functions to convert s-exps to quotations
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
: convert-body ( s-exp -- quot )
    [ ] [ convert-form compose ] reduce ; inline
  
: convert-if ( s-exp -- quot )
    rest first3 [ convert-form ] tri@ '[ @ , , if ] ;
    
: convert-begin ( s-exp -- quot )  
    rest [ convert-form ] [ ] map-as '[ , [ funcall ] each ] ;
    
: convert-cond ( s-exp -- quot )  
    rest [ body>> first2 [ convert-form ] bi@ [ '[ @ funcall ] ] dip 2array ]
    { } map-as '[ , cond ]  ;
    
: convert-general-form ( s-exp -- quot )
    unclip convert-form swap convert-body swap '[ , @ funcall ] ;

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
    "&rest" swap [ index ] [ remove ] 2bi
    localize-lambda <lambda>
    '[ , cut '[ @ , ] , compose ] ;
    
: normal-lambda ( body vars -- quot )
    localize-lambda <lambda> '[ , compose ] ;
PRIVATE>
    
: convert-lambda ( s-exp -- quot )  
    split-lambda "&rest" over member? [ rest-lambda ] [ normal-lambda ] if ;
    
: convert-quoted ( s-exp -- quot )  
    second 1quotation ;
    
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