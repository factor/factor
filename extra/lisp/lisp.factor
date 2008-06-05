! Copyright (C) 2008 James Cash
! See http://factorcode.org/license.txt for BSD license.
USING: kernel peg sequences arrays strings combinators.lib
namespaces combinators math locals locals.private accessors
vectors syntax lisp.parser assocs parser sequences.lib words quotations
fry lists inspector ;
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
    [ ] [ convert-form compose ] foldl ; inline
  
: convert-if ( cons -- quot )
    cdr 3car [ convert-form ] tri@ '[ @ , , if ] ;
    
: convert-begin ( cons -- quot )  
    cdr [ convert-form ] [ ] lmap-as '[ , [ funcall ] each ] ;
    
: convert-cond ( cons -- quot )  
    cdr [ 2car [ convert-form ] bi@ [ '[ @ funcall ] ] dip 2array ]
    { } lmap-as '[ , cond ]  ;
    
: convert-general-form ( cons -- quot )
    uncons [ convert-body ] [ convert-form ] bi* '[ , @ funcall ] ;

! words for convert-lambda  
<PRIVATE  
: localize-body ( assoc body -- assoc newbody )  
    dupd [ dup lisp-symbol? [ tuck name>> swap at swap or ]
                           [ dup cons? [ localize-body ] when nip ] if
    ] with lmap>array ;
    
: localize-lambda ( body vars -- newbody newvars )
    make-locals dup push-locals swap
    [ swap localize-body seq>cons convert-form swap pop-locals ] dip swap ;
                   
: split-lambda ( cons -- body-cons vars-seq )                   
    3car -rot nip [ name>> ] lmap>array ; inline
    
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
    
: convert-unquoted ( cons -- quot )    
    "unquote not valid outside of quasiquote!" throw ;
    
: convert-quasiquoted ( cons -- newcons )
    [ { [ dup list? ] [ car dup lisp-symbol? ] [ name>> "unquote" equal? dup ] } && nip ]
    [ cadr ] traverse ;
    
: form-dispatch ( lisp-symbol -- quot )
    name>>
    { { "lambda" [ convert-lambda ] }
      { "quote" [ convert-quoted ] }
      { "unquote" [ convert-unquoted ] }
      { "quasiquote" [ convert-quasiquoted ] }
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
    
SYMBOL: macro-env
    
M: no-such-var summary drop "No such variable" ;

: init-env ( -- )
    H{ } clone lisp-env set
    H{ } clone macro-env set ;

: lisp-define ( name quot -- )
    swap lisp-env get set-at ;
    
: lisp-get ( name -- word )
    dup lisp-env get at [ ] [ no-such-var ] ?if ;
    
: lookup-var ( lisp-symbol -- quot )
    name>> lisp-get ;
    
: funcall ( quot sym -- * )
    dup lisp-symbol?  [ lookup-var ] when call ; inline
    
: define-primitive ( name vocab word -- )  
    swap lookup 1quotation '[ , compose call ] lisp-define ;
    
: lookup-macro ( lisp-symbol -- macro )
    name>> macro-env get at ;
    
: lisp-macro? ( car -- ? )
    dup lisp-symbol? [ name>> macro-env get key? ] [ drop f ] if ;
