USING: hashtables assocs sequences locals math accessors multiline delegate strings
delegate.protocols kernel peg peg.ebnf lexer namespaces combinators parser words ;
IN: peg-lexer

TUPLE: lex-hash hash ;
CONSULT: assoc-protocol lex-hash hash>> ;
: <lex-hash> ( a -- lex-hash ) lex-hash boa ;

: pos-or-0 ( neg? -- pos/0 ) dup 0 < [ drop 0 ] when ;

:: store-pos ( v a -- )
   [let | n [ input a at v head-slice ] |
      v "\n" n last-index 0 or - lexer get (>>column)
      n [ "\n" = ] filter length 1 + lexer get (>>line) ] ;

M: lex-hash set-at swap {
   { pos [ store-pos ] }
   [ swap hash>> set-at ] } case ;

:: at-pos ( t l c -- p ) t l 1 - head-slice [ length ] map sum pos-or-0 c + ;

M: lex-hash at* swap {
      { input [ drop lexer get text>> "\n" join t ] }
      { pos [ drop lexer get [ text>> ] [ line>> ] [ column>> ] tri at-pos t ] }
      [ swap hash>> at* ] } case ;

: with-global-lexer ( quot -- result )
   [ f lrstack set
        V{ } clone error-stack set H{ } clone \ heads set
        H{ } clone \ packrat set ] f make-assoc <lex-hash>
   swap bind ; inline

! Usage:
! ON-BNF: word expr= [1-9] ;ON-BNF
! << name parser create-bnf >>

: parse* ( parser -- ast ) compile
   [ execute [ error-stack get first throw ] unless* ] with-global-lexer
   ast>> ;

: create-bnf ( name parser -- ) reset-tokenizer [ lexer get skip-blank parse* dup V{ } = [ parsed ] unless ] curry
    define word make-parsing ;
    
: ON-BNF: CREATE-WORD reset-tokenizer ";ON-BNF" parse-multiline-string parse-ebnf
    main swap at create-bnf ; parsing

! Tokenizer like standard factor lexer
EBNF: factor
space = " " | "\n" | "\t"
spaces = space* => [[ drop ignore ]]
chunk = (!(space) .)+ => [[ >string ]]
expr = spaces chunk
;EBNF