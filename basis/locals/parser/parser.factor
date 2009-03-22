! Copyright (C) 2007, 2009 Slava Pestov, Eduardo Cavazos.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators effects.parser
generic.parser kernel lexer locals.errors fry
locals.rewrite.closures locals.types make namespaces parser
quotations sequences splitting words vocabs.parser ;
IN: locals.parser

SYMBOL: in-lambda?

: ?rewrite-closures ( form -- form' )
    in-lambda? get [ 1array ] [ rewrite-closures ] if ;

: make-local ( name -- word )
    "!" ?tail [
        <local-reader>
        dup <local-writer> dup name>> set
    ] [ <local> ] if
    dup dup name>> set ;

: make-locals ( seq -- words assoc )
    [ [ make-local ] map ] H{ } make-assoc ;

: make-local-word ( name def -- word )
    [ <local-word> [ dup name>> set ] [ ] [ ] tri ] dip
    "local-word-def" set-word-prop ;

: push-locals ( assoc -- )
    use get push ;

: pop-locals ( assoc -- )
    use get delq ;

SINGLETON: lambda-parser

SYMBOL: locals

: ((parse-lambda)) ( assoc quot -- quot' )
    '[
        in-lambda? on
        lambda-parser quotation-parser set
        [ locals set ] [ push-locals @ ] [ pop-locals ] tri
    ] with-scope ; inline
    
: (parse-lambda) ( assoc -- quot )
    [ \ ] parse-until >quotation ] ((parse-lambda)) ;

: parse-lambda ( -- lambda )
    "|" parse-tokens make-locals
    (parse-lambda) <lambda>
    ?rewrite-closures ;

M: lambda-parser parse-quotation ( -- quotation )
    H{ } clone (parse-lambda) ;

: parse-binding ( end -- pair/f )
    scan {
        { [ dup not ] [ unexpected-eof ] }
        { [ 2dup = ] [ 2drop f ] }
        [ nip scan-object 2array ]
    } cond ;

: (parse-bindings) ( end -- )
    dup parse-binding dup [
        first2 [ make-local ] dip 2array ,
        (parse-bindings)
    ] [ 2drop ] if ;

: with-bindings ( quot -- words assoc )
    '[
        in-lambda? on
        _ H{ } make-assoc
    ] { } make swap ; inline

: parse-bindings ( end -- bindings vars )
    [ (parse-bindings) ] with-bindings ;

: parse-let ( -- form )
    "|" expect "|" parse-bindings
    (parse-lambda) <let> ?rewrite-closures ;

: parse-bindings* ( end -- words assoc )
    [
        namespace push-locals
        (parse-bindings)
        namespace pop-locals
    ] with-bindings ;

: parse-let* ( -- form )
    "|" expect "|" parse-bindings*
    (parse-lambda) <let*> ?rewrite-closures ;

: (parse-wbindings) ( end -- )
    dup parse-binding dup [
        first2 [ make-local-word ] keep 2array ,
        (parse-wbindings)
    ] [ 2drop ] if ;

: parse-wbindings ( end -- bindings vars )
    [ (parse-wbindings) ] with-bindings ;

: parse-wlet ( -- form )
    "|" expect "|" parse-wbindings
    (parse-lambda) <wlet> ?rewrite-closures ;

: parse-locals ( -- effect vars assoc )
    complete-effect
    dup
    in>> [ dup pair? [ first ] when ] map make-locals ;

: parse-locals-definition ( word reader -- word quot effect )
    [ parse-locals ] dip
    ((parse-lambda)) <lambda>
    [ nip "lambda" set-word-prop ]
    [ nip rewrite-closures dup length 1 = [ first ] [ bad-rewrite ] if ]
    [ drop nip ] 3tri ; inline

: (::) ( -- word def effect )
    CREATE-WORD
    [ parse-definition ]
    parse-locals-definition ;

: (M::) ( -- word def )
    CREATE-METHOD
    [
        [ parse-definition ] 
        parse-locals-definition drop
    ] with-method-definition ;