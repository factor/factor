! Copyright (C) 2007, 2009 Slava Pestov, Eduardo Cavazos.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators effects.parser
generic.parser kernel lexer locals.errors fry
locals.rewrite.closures locals.types make namespaces parser
quotations sequences splitting words vocabs.parser ;
IN: locals.parser

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

SYMBOL: locals

: push-locals ( assoc -- )
    use get push ;

: pop-locals ( assoc -- )
    use get delete ;

SYMBOL: in-lambda?

: (parse-lambda) ( assoc end -- quot )
    [
        in-lambda? on
        over locals set
        over push-locals
        parse-until >quotation
        swap pop-locals
    ] with-scope ;

: parse-lambda ( -- lambda )
    "|" parse-tokens make-locals
    \ ] (parse-lambda) <lambda> ;

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

: parse-bindings* ( end -- words assoc )
    [
        namespace push-locals
        (parse-bindings)
        namespace pop-locals
    ] with-bindings ;

: (parse-wbindings) ( end -- )
    dup parse-binding dup [
        first2 [ make-local-word ] keep 2array ,
        (parse-wbindings)
    ] [ 2drop ] if ;

: parse-wbindings ( end -- bindings vars )
    [ (parse-wbindings) ] with-bindings ;

: parse-locals ( -- vars assoc )
    "(" expect ")" parse-effect
    word [ over "declared-effect" set-word-prop ] when*
    in>> [ dup pair? [ first ] when ] map make-locals ;

: parse-locals-definition ( word -- word quot )
    parse-locals \ ; (parse-lambda) <lambda>
    [ "lambda" set-word-prop ]
    [ rewrite-closures dup length 1 = [ first ] [ bad-lambda-rewrite ] if ] 2bi ;

: (::) ( -- word def ) CREATE-WORD parse-locals-definition ;

: (M::) ( -- word def )
    CREATE-METHOD
    [ parse-locals-definition ] with-method-definition ;

: parsed-lambda ( accum form -- accum )
    in-lambda? get [ parsed ] [ rewrite-closures over push-all ] if ;
