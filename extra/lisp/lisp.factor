! Copyright (C) 2008 James Cash
! See http://factorcode.org/license.txt for BSD license.
USING: kernel peg sequences arrays strings combinators.lib
namespaces combinators math locals locals.private accessors
vectors syntax lisp.parser assocs parser sequences.lib words
quotations fry lists inspector ;
IN: lisp

DEFER: convert-form
DEFER: funcall
DEFER: lookup-var
DEFER: lookup-macro
DEFER: lisp-macro?
DEFER: macro-expand
DEFER: define-lisp-macro
    
! Functions to convert s-exps to quotations
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
: convert-body ( cons -- quot )
    [ ] [ convert-form compose ] foldl ; inline
    
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
    [ lisp-symbol? ] pick '[ [ name>> , at ] [ ] bi or ] traverse ;

: localize-lambda ( body vars -- newbody newvars )
    make-locals dup push-locals swap
    [ swap localize-body convert-form swap pop-locals ] dip swap ;
                   
: split-lambda ( cons -- body-cons vars-seq )                   
    3car -rot nip [ name>> ] lmap>array ; inline
    
: rest-lambda ( body vars -- quot )
    "&rest" swap [ index ] [ remove ] 2bi
    swapd localize-lambda <lambda>
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
    
: convert-unquoted-splicing ( cons -- quot )    
    "unquote-splicing not valid outside of quasiquote!" throw ;
    
<PRIVATE    
: quasiquote-unquote ( cons -- newcons )
    [ { [ dup list? ] [ car dup lisp-symbol? ] [ name>> "unquote" equal? dup ] } 0&& nip ]
    [ cadr ] traverse ;
    
: quasiquote-unquote-splicing ( cons -- newcons )    
    [ { [ dup list? ] [ dup cdr [ cons? ] [ car cons? ] bi and ]
        [ dup cadr car lisp-symbol? ] [ cadr car name>> "unquote-splicing" equal? dup ] } 0&& nip ]
    [ dup cadr cdr >>cdr ] traverse ;
PRIVATE>

: convert-quasiquoted ( cons -- newcons )
    quasiquote-unquote quasiquote-unquote-splicing ;
    
: convert-defmacro ( cons -- quot )
    cdr [ car ] keep [ convert-lambda ] [ car name>> ] bi define-lisp-macro 1quotation ;
    
: form-dispatch ( cons lisp-symbol -- quot )
    name>>
    { { "lambda" [ convert-lambda ] }
      { "defmacro" [ convert-defmacro ] }
      { "quote" [ convert-quoted ] }
      { "unquote" [ convert-unquoted ] }
      { "unquote-splicing" [ convert-unquoted-splicing ] }
      { "quasiquote" [ convert-quasiquoted ] }
      { "begin" [ convert-begin ] }
      { "cond" [ convert-cond ] }
     [ drop convert-general-form ]
    } case ;
    
: convert-list-form ( cons -- quot )  
    dup car
    { { [ dup lisp-macro?  ] [ drop macro-expand ] }
      { [ dup lisp-symbol? ] [ form-dispatch ] } 
     [ drop convert-general-form ]
    } cond ;
    
: convert-form ( lisp-form -- quot )
    {
      { [ dup cons? ] [ convert-list-form ] }
      { [ dup lisp-symbol? ] [ '[ , lookup-var ] ] }
     [ 1quotation ]
    } cond ;
    
: compile-form ( lisp-ast -- quot )
    convert-form lambda-rewrite call ; inline
    
: macro-call ( lambda -- cons )
    call ; inline
    
: macro-expand ( cons -- quot )
    uncons [ list>seq [ ] like ] [ lookup-macro ] bi* call compile-form ;
    
: lisp-string>factor ( str -- quot )
    lisp-expr parse-result-ast compile-form ;
    
: lisp-eval ( str -- * )    
  lisp-string>factor call ;
    
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: lisp-env
SYMBOL: macro-env
    
ERROR: no-such-var variable-name ;
M: no-such-var summary drop "No such variable" ;

: init-env ( -- )
    H{ } clone lisp-env set
    H{ } clone macro-env set ;

: lisp-define ( quot name -- )
    lisp-env get set-at ;
    
: lisp-get ( name -- word )
    dup lisp-env get at [ ] [ no-such-var ] ?if ;
    
: lookup-var ( lisp-symbol -- quot )
    name>> lisp-get ;
    
: funcall ( quot sym -- * )
    dup lisp-symbol?  [ lookup-var ] when call ; inline
    
: define-primitive ( name vocab word -- )  
    swap lookup 1quotation '[ , compose call ] swap lisp-define ;
    
: lookup-macro ( lisp-symbol -- lambda )
    name>> macro-env get at ;
    
: define-lisp-macro ( quot name -- )
    macro-env get set-at ;
    
: lisp-macro? ( car -- ? )
    dup lisp-symbol? [ name>> macro-env get key? ] [ drop f ] if ;
