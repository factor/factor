USING: hashtables assocs sequences locals math accessors multiline delegate strings
delegate.protocols kernel peg peg.ebnf lexer namespaces combinators parser words ;
IN: peg-lexer

TUPLE: lex-hash hash ;
CONSULT: assoc-protocol lex-hash hash>> ;
: <lex-hash> ( a -- lex-hash ) lex-hash boa ;

: pos-or-0 ( neg? -- pos/0 ) dup 0 < [ drop 0 ] when ;

:: prepare-pos ( v i -- c l )
    [let | n [ i v head-slice ] |
           v CHAR: \n n last-index -1 or 1+ -
           n [ CHAR: \n = ] count 1+
    ] ;
      
: store-pos ( v a -- )
    input swap at prepare-pos
    lexer get [ (>>line) ] keep (>>column) ;

M: lex-hash set-at
    swap {
        { pos [ store-pos ] }
        [ swap hash>> set-at ]
    } case ;

:: at-pos ( t l c -- p ) t l head-slice [ length ] map sum l 1- + c + ;

M: lex-hash at*
    swap {
      { input [ drop lexer get text>> "\n" join t ] }
      { pos [ drop lexer get [ text>> ] [ line>> 1- ] [ column>> 1+ ] tri at-pos t ] }
      [ swap hash>> at* ]
    } case ;

: with-global-lexer ( quot -- result )
   [
       f lrstack set
       V{ } clone error-stack set H{ } clone \ heads set
       H{ } clone \ packrat set
   ] f make-assoc <lex-hash>
   swap bind ; inline

: parse* ( parser -- ast )
    compile
    [ execute( -- result ) [ error-stack get first throw ] unless* ] with-global-lexer
    ast>> ;

: create-bnf ( name parser -- )
    reset-tokenizer [ lexer get skip-blank parse* parsed ] curry
    define-syntax ;
    
SYNTAX: ON-BNF:
    CREATE-WORD reset-tokenizer ";ON-BNF" parse-multiline-string parse-ebnf
    main swap at create-bnf ;

! Tokenizer like standard factor lexer
EBNF: factor
space = " " | "\n" | "\t"
spaces = space* => [[ drop ignore ]]
chunk = (!(space) .)+ => [[ >string ]]
expr = spaces chunk
;EBNF