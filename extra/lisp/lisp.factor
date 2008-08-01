! Copyright (C) 2008 James Cash
! See http://factorcode.org/license.txt for BSD license.
USING: kernel peg sequences arrays strings combinators.lib
namespaces combinators math locals locals.private locals.backend accessors
vectors syntax lisp.parser assocs parser sequences.lib words
quotations fry lists summary combinators.short-circuit continuations ;
IN: lisp

DEFER: convert-form
DEFER: funcall
DEFER: lookup-var
DEFER: lookup-macro
DEFER: lisp-macro?
DEFER: lisp-var?
DEFER: define-lisp-macro

! Functions to convert s-exps to quotations
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
: convert-body ( cons -- quot )
    [ ] [ convert-form compose ] foldl ; inline

: convert-cond ( cons -- quot )
    cdr [ 2car [ convert-form ] bi@ 2array ]
    { } lmap-as '[ , cond ] ;

: convert-general-form ( cons -- quot )
    uncons [ convert-body ] [ convert-form ] bi* '[ , @ funcall ] ;

! words for convert-lambda
<PRIVATE
: localize-body ( assoc body -- newbody )
    {
      { [ dup list? ] [ [ lisp-symbol? ] rot '[ [ name>> , at ] [ ] bi or ] traverse ] }
      { [ dup lisp-symbol? ] [ name>> swap at ] }
     [ nip ]
    } cond ;

: localize-lambda ( body vars -- newvars newbody )
    swap [ make-locals dup push-locals ] dip
    dupd [ localize-body convert-form ] with lmap>array
    >quotation swap pop-locals ;

: split-lambda ( cons -- body-cons vars-seq )
    cdr uncons [ name>> ] lmap>array ; inline

: rest-lambda ( body vars -- quot )
    "&rest" swap [ remove ] [ index ] 2bi
    [ localize-lambda <lambda> lambda-rewrite call ] dip
    swap '[ , cut '[ @ , seq>list ] call , call ] ;

: normal-lambda ( body vars -- quot )
    localize-lambda <lambda> lambda-rewrite [ compose call ] compose 1quotation ;
PRIVATE>

: convert-lambda ( cons -- quot )
    split-lambda "&rest" over member? [ rest-lambda ] [ normal-lambda ] if ;

: convert-quoted ( cons -- quot )
    cadr 1quotation ;

: convert-defmacro ( cons -- quot )
    cdr [ car ] keep [ convert-lambda ] [ car name>> ] bi define-lisp-macro 1quotation ;

: macro-expand ( cons -- quot )
    uncons [ list>seq >quotation ] [ lookup-macro ] bi* call convert-form ;

: form-dispatch ( cons lisp-symbol -- quot )
    name>>
    { { "lambda" [ convert-lambda ] }
      { "defmacro" [ convert-defmacro ] }
      { "quote" [ convert-quoted ] }
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
      { [ dup lisp-var? ] [ lookup-var 1quotation ] }
      { [ dup lisp-symbol? ] [ '[ , lookup-var ] ] }
     [ 1quotation ]
    } cond ;

: lisp-string>factor ( str -- quot )
    lisp-expr convert-form ;

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

: defun ( name quot -- name )
    over name>> lisp-define ;

: lisp-get ( name -- word )
    lisp-env get at ;

: lookup-var ( lisp-symbol -- quot )
    [ name>> ] [ lisp-var? ] bi [ lisp-get ] [ no-such-var ] if ;

: lisp-var? ( lisp-symbol -- ? )
    dup lisp-symbol? [ name>> lisp-env get key? ] [ drop f ] if ;

: funcall ( quot sym -- * )
    [ 1array [ call ] with-datastack >quotation ] dip
    dup lisp-symbol? [ lookup-var ] when curry call ; inline

: define-primitive ( name vocab word -- )
    swap lookup 1quotation '[ , compose call ] swap lisp-define ;

: lookup-macro ( lisp-symbol -- lambda )
    name>> macro-env get at ;

: define-lisp-macro ( quot name -- )
    macro-env get set-at ;

: lisp-macro? ( car -- ? )
    dup lisp-symbol? [ name>> macro-env get key? ] [ drop f ] if ;
