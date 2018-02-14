! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators combinators.short-circuit
effects kernel make math math.parser multiline namespaces parser
peg peg.parsers quotations sequences sequences.deep splitting
stack-checker strings strings.parser summary unicode
vocabs.parser words fry ;
FROM: vocabs.parser => search ;
FROM: peg.search => replace ;
IN: peg.ebnf

: rule ( name word -- parser )
    ! Given an EBNF word produced from EBNF: return the EBNF rule
    "ebnf-parser" word-prop at ;

ERROR: no-rule rule parser ;

<PRIVATE

: lookup-rule ( rule parser -- rule' )
        2dup rule [ 2nip ] [ no-rule ] if* ;

TUPLE: tokenizer-tuple any one many ;

: default-tokenizer ( -- tokenizer )
    T{ tokenizer-tuple f
        [ any-char ]
        [ token ]
        [ [ = ] curry any-char swap semantic ]
    } ;

: parser-tokenizer ( parser -- tokenizer )
    [ 1quotation ] keep
    [ swap [ = ] curry semantic ] curry dup tokenizer-tuple boa ;

: rule-tokenizer ( name word -- tokenizer )
    rule parser-tokenizer ;

: tokenizer ( -- word )
    \ tokenizer get-global [ default-tokenizer ] unless* ;

: reset-tokenizer ( -- )
    default-tokenizer \ tokenizer set-global ;

TUPLE: ebnf-non-terminal symbol ;
TUPLE: ebnf-terminal symbol ;
TUPLE: ebnf-foreign word rule ;
TUPLE: ebnf-any-character ;
TUPLE: ebnf-range pattern ;
TUPLE: ebnf-ensure group ;
TUPLE: ebnf-ensure-not group ;
TUPLE: ebnf-choice options ;
TUPLE: ebnf-sequence elements ;
TUPLE: ebnf-ignore group ;
TUPLE: ebnf-repeat0 group ;
TUPLE: ebnf-repeat1 group ;
TUPLE: ebnf-optional group ;
TUPLE: ebnf-whitespace group ;
TUPLE: ebnf-tokenizer elements ;
TUPLE: ebnf-rule symbol elements ;
TUPLE: ebnf-action parser code ;
TUPLE: ebnf-var parser name ;
TUPLE: ebnf-semantic parser code ;
TUPLE: ebnf rules ;

C: <ebnf-non-terminal> ebnf-non-terminal
C: <ebnf-terminal> ebnf-terminal
C: <ebnf-foreign> ebnf-foreign
C: <ebnf-any-character> ebnf-any-character
C: <ebnf-range> ebnf-range
C: <ebnf-ensure> ebnf-ensure
C: <ebnf-ensure-not> ebnf-ensure-not
C: <ebnf-choice> ebnf-choice
C: <ebnf-sequence> ebnf-sequence
C: <ebnf-ignore> ebnf-ignore
C: <ebnf-repeat0> ebnf-repeat0
C: <ebnf-repeat1> ebnf-repeat1
C: <ebnf-optional> ebnf-optional
C: <ebnf-whitespace> ebnf-whitespace
C: <ebnf-tokenizer> ebnf-tokenizer
C: <ebnf-rule> ebnf-rule
C: <ebnf-action> ebnf-action
C: <ebnf-var> ebnf-var
C: <ebnf-semantic> ebnf-semantic
C: <ebnf> ebnf

: filter-hidden ( seq -- seq )
    ! Remove elements that produce no AST from sequence
    [ ebnf-ensure-not? ] reject [ ebnf-ensure? ] reject ;

: syntax ( string -- parser )
    ! Parses the string, ignoring white space, and
    ! does not put the result in the AST.
    token sp hide ;

: syntax-pack ( begin parser end -- parser )
    ! Parse parser-parser surrounded by syntax elements
    ! begin and end.
    [ syntax ] 2dip syntax pack ;

: insert-escapes ( string -- string )
    [
        "\t" token [ drop "\\t" ] action ,
        "\n" token [ drop "\\n" ] action ,
        "\r" token [ drop "\\r" ] action ,
    ] choice* replace ;

: identifier-parser ( -- parser )
    ! Return a parser that parses an identifer delimited by
    ! a quotation character. The quotation can be single
    ! or double quotes. The AST produced is the identifier
    ! between the quotes.
    [
        [
            [ CHAR: \ = ] satisfy
            [ "\"\\" member? ] satisfy 2seq ,
            [ CHAR: \" = not ] satisfy ,
        ] choice* repeat1 "\"" "\"" surrounded-by ,
        [ CHAR: ' = not ] satisfy repeat1 "'" "'" surrounded-by ,
    ] choice* [ "" flatten-as unescape-string ] action ;

: non-terminal-parser ( -- parser )
    ! A non-terminal is the name of another rule. It can
    ! be any non-blank character except for characters used
    ! in the EBNF syntax itself.
    [
        {
            [ blank? ]
            [ "\"'|{}=)(][.!&*+?:~<>" member? ]
        } 1|| not
    ] satisfy repeat1 [ >string <ebnf-non-terminal> ] action ;

: terminal-parser ( -- parser )
    ! A terminal is an identifier enclosed in quotations
    ! and it represents the literal value of the identifier.
    identifier-parser [ <ebnf-terminal> ] action ;

: foreign-name-parser ( -- parser )
    ! Parse a valid foreign parser name
    [
        {
            [ blank? ]
            [ CHAR: > = ]
        } 1|| not
    ] satisfy repeat1 [ >string ] action ;

: foreign-parser ( -- parser )
    ! A foreign call is a call to a rule in another ebnf grammar
    [
        "<foreign" syntax ,
        foreign-name-parser sp ,
        foreign-name-parser sp optional ,
        ">" syntax ,
    ] seq* [ first2 <ebnf-foreign> ] action ;

: any-character-parser ( -- parser )
    ! A parser to match the symbol for any character match.
    [ CHAR: . = ] satisfy [ drop <ebnf-any-character> ] action ;

: range-parser-parser ( -- parser )
    ! Match the syntax for declaring character ranges
    [
        [ "[" syntax , "[" token ensure-not , ] seq* hide ,
        [ CHAR: ] = not ] satisfy repeat1 ,
        "]" syntax ,
    ] seq* [ first >string unescape-string <ebnf-range> ] action ;

: (element-parser) ( -- parser )
    ! An element of a rule. It can be a terminal or a
    ! non-terminal but must not be followed by a "=".
    ! The latter indicates that it is the beginning of a
    ! new rule.
    [
        [
            [
                non-terminal-parser ,
                terminal-parser ,
                foreign-parser ,
                range-parser-parser ,
                any-character-parser ,
            ] choice*
            [ dup , "~" token hide , ] seq* [ first <ebnf-ignore> ] action ,
            [ dup , "*" token hide , ] seq* [ first <ebnf-repeat0> ] action ,
            [ dup , "+" token hide , ] seq* [ first <ebnf-repeat1> ] action ,
            [ dup , "?[" token ensure-not , "?" token hide , ] seq* [ first <ebnf-optional> ] action ,
            ,
        ] choice* ,
        [
            "=" syntax ensure-not ,
            "=>" syntax ensure ,
        ] choice* ,
    ] seq* [ first ] action ;

DEFER: action-parser

: element-parser ( -- parser )
    [
        [
            (element-parser) , ":" syntax ,
            "a-zA-Z_" range-pattern
            "a-zA-Z0-9_-" range-pattern repeat1 2seq [ first2 swap prefix >string ] action ,
        ] seq* [ first2 <ebnf-var> ] action ,
        (element-parser) ,
    ] choice* ;

DEFER: choice-parser

: grouped ( quot suffix -- parser )
    ! Parse a group of choices, with a suffix indicating
    ! the type of group (repeat0, repeat1, etc) and
    ! an quot that is the action that produces the AST.
    2dup
    [
        "(" [ choice-parser sp ] delay ")" syntax-pack
        swap 2seq
        [ first ] rot compose action ,
        "{" [ choice-parser sp ] delay "}" syntax-pack
        swap 2seq
        [ first <ebnf-whitespace> ] rot compose action ,
    ] choice* ;

: group-parser ( -- parser )
    ! A grouping with no suffix. Used for precedence.
    [ ] [
        "~" token sp ensure-not ,
        "*" token sp ensure-not ,
        "+" token sp ensure-not ,
        "?" token sp ensure-not ,
    ] seq* hide grouped ;

: ignore-parser ( -- parser )
    [ <ebnf-ignore> ] "~" syntax grouped ;

: repeat0-parser ( -- parser )
    [ <ebnf-repeat0> ] "*" syntax grouped ;

: repeat1-parser ( -- parser )
    [ <ebnf-repeat1> ] "+" syntax grouped ;

: optional-parser ( -- parser )
    [ <ebnf-optional> ] "?" syntax grouped ;

: factor-code-parser ( -- parser )
    [
        "]]" token ensure-not ,
        "]?" token ensure-not ,
        [ drop t ] satisfy ,
    ] seq* repeat0 [ "" concat-as ] action ;

: ensure-not-parser ( -- parser )
    ! Parses the '!' syntax to ensure that
    ! something that matches the following elements do
    ! not exist in the parse stream.
    [
        "!" syntax ,
        group-parser sp ,
    ] seq* [ first <ebnf-ensure-not> ] action ;

: ensure-parser ( -- parser )
    ! Parses the '&' syntax to ensure that
    ! something that matches the following elements does
    ! exist in the parse stream.
    [
        "&" syntax ,
        group-parser sp ,
    ] seq* [ first <ebnf-ensure> ] action ;

: (sequence-parser) ( -- parser )
    ! A sequence of terminals and non-terminals, including
    ! groupings of those.
    [
        [
            ensure-not-parser sp ,
            ensure-parser sp ,
            element-parser sp ,
            group-parser sp ,
            ignore-parser sp ,
            repeat0-parser sp ,
            repeat1-parser sp ,
            optional-parser sp ,
        ] choice*
        [ dup    , ":" syntax , "a-zA-Z" range-pattern repeat1 [ >string ] action , ] seq* [ first2 <ebnf-var> ] action ,
        ,
    ] choice* ;

: action-parser ( -- parser )
     "[[" factor-code-parser "]]" syntax-pack ;

: semantic-parser ( -- parser )
     "?[" factor-code-parser "]?" syntax-pack ;

: sequence-parser ( -- parser )
    ! A sequence of terminals and non-terminals, including
    ! groupings of those.
    [
        [ (sequence-parser) , action-parser , ] seq*
        [ first2 <ebnf-action> ] action ,

        [ (sequence-parser) , semantic-parser , ] seq*
        [ first2 <ebnf-semantic> ] action ,

        (sequence-parser) ,
    ] choice* repeat1 [
         dup length 1 = [ first ] [ <ebnf-sequence> ] if
    ] action ;

: actioned-sequence-parser ( -- parser )
    [
        [ sequence-parser , "=>" syntax , action-parser , ] seq*
        [ first2 <ebnf-action> ] action ,
        sequence-parser ,
    ] choice* ;

: choice-parser ( -- parser )
    actioned-sequence-parser sp repeat1 [
        dup length 1 = [ first ] [ <ebnf-sequence> ] if
    ] action "|" token sp list-of [
        dup length 1 = [ first ] [ <ebnf-choice> ] if
    ] action ;

: tokenizer-parser ( -- parser )
    [
        "tokenizer" syntax ,
        "=" syntax ,
        ">" token ensure-not ,
        [ "default" token sp , choice-parser , ] choice* ,
    ] seq* [ first <ebnf-tokenizer> ] action ;

: rule-parser ( -- parser )
    [
        "tokenizer" token ensure-not ,
        non-terminal-parser [ symbol>> ] action ,
        "=" syntax ,
        ">" token ensure-not ,
        choice-parser ,
    ] seq* [ first2 <ebnf-rule> ] action ;

: ebnf-parser ( -- parser )
    [ tokenizer-parser sp , rule-parser sp , ] choice* repeat1 [ <ebnf> ] action ;

GENERIC: (transform) ( ast -- parser )

SYMBOL: parser
SYMBOL: main
SYMBOL: ignore-ws

: transform ( ast -- object )
    H{ } clone dup dup [
        f ignore-ws set
        parser set
        swap (transform)
        main set
    ] with-variables ;

M: ebnf (transform) ( ast -- parser )
    rules>> [ (transform) ] map last ;

M: ebnf-tokenizer (transform) ( ast -- parser )
    elements>> dup "default" = [
        drop default-tokenizer \ tokenizer set-global any-char
    ] [
        (transform)
        dup parser-tokenizer \ tokenizer set-global
    ] if ;

ERROR: redefined-rule name ;

M: redefined-rule summary
    name>> "Rule '" "' defined more than once" surround ;

M: ebnf-rule (transform) ( ast -- parser )
    dup elements>>
    (transform) [
        swap symbol>> dup get parser? [ redefined-rule ] [ set ] if
    ] keep ;

M: ebnf-sequence (transform) ( ast -- parser )
    ! If ignore-ws is set then each element of the sequence
    ! ignores leading whitespace. This is not inherited by
    ! subelements of the sequence.
    elements>> [
        f ignore-ws [ (transform) ] with-variable
        ignore-ws get [ sp ] when
    ] map seq [ dup length 1 = [ first ] when ] action ;

M: ebnf-choice (transform) ( ast -- parser )
    options>> [ (transform) ] map choice ;

M: ebnf-any-character (transform) ( ast -- parser )
    drop tokenizer any>> call( -- parser ) ;

M: ebnf-range (transform) ( ast -- parser )
    pattern>> range-pattern ;

: transform-group ( ast -- parser )
    ! convert a ast node with groups to a parser for that group
    group>> (transform) ;

M: ebnf-ensure (transform) ( ast -- parser )
    transform-group ensure ;

M: ebnf-ensure-not (transform) ( ast -- parser )
    transform-group ensure-not ;

M: ebnf-ignore (transform) ( ast -- parser )
    transform-group [ drop ignore ] action ;

M: ebnf-repeat0 (transform) ( ast -- parser )
    transform-group repeat0 ;

M: ebnf-repeat1 (transform) ( ast -- parser )
    transform-group repeat1 ;

M: ebnf-optional (transform) ( ast -- parser )
    transform-group optional ;

M: ebnf-whitespace (transform) ( ast -- parser )
    t ignore-ws [ transform-group ] with-variable ;

GENERIC: build-locals ( code ast -- code )

M: ebnf-sequence build-locals ( code ast -- code )
    ! Note the need to filter out this ebnf items that
    ! leave nothing in the AST
    elements>> filter-hidden dup length 1 = [
        first build-locals
    ] [
        dup [ ebnf-var? ] none? [
            drop
        ] [
            [
                "[let " %
                [
                    over ebnf-var? [
                        " " % # " over nth :> " %
                        name>> %
                    ] [
                        2drop
                    ] if
                ] each-index
                " " %
                %
                " nip ]" %
             ] "" make
        ] if
    ] if ;

M: ebnf-var build-locals ( code ast -- code )
    [
        "[let dup :> " % name>> %
        " " %
        %
        " nip ]" %
    ] "" make ;

M: object build-locals ( code ast -- code )
    drop ;

ERROR: bad-effect quot effect ;

: check-action-effect ( quot -- quot )
    dup infer {
        { [ dup ( a -- b ) effect<= ] [ drop ] }
        { [ dup ( -- b ) effect<= ] [ drop [ drop ] prepose ] }
        [ bad-effect ]
    } cond ;

: ebnf-transform ( ast -- parser quot )
    [ parser>> (transform) ]
    [ code>> insert-escapes ]
    [ parser>> ] tri build-locals
    ! Add words we need for build-locals, then remove them
    ! so we don't pollute the manifest qualified-vocabs
    ! and also so restarts don't add multiple times
    qualified-vocabs length
    "locals" { "[let" ":>" } add-words-from
    "kernel" { "dup" "nip" "over" } add-words-from
    "sequences" { "nth" } add-words-from
    [ string-lines parse-lines ] dip
    dup 3 + qualified-vocabs delete-slice ;

M: ebnf-action (transform) ( ast -- parser )
    ebnf-transform check-action-effect action ;

M: ebnf-semantic (transform) ( ast -- parser )
    ebnf-transform semantic ;

M: ebnf-var (transform) ( ast -- parser )
    parser>> (transform) ;

M: ebnf-terminal (transform) ( ast -- parser )
    symbol>> tokenizer one>> call( symbol -- parser ) ;

ERROR: ebnf-foreign-not-found name ;

M: ebnf-foreign-not-found summary
    name>> "Foreign word '" "' not found" surround ;

M: ebnf-foreign (transform) ( ast -- parser )
    dup word>> search [ word>> ebnf-foreign-not-found ] unless*
    swap rule>> [ main ] unless* over rule [
        nip
    ] [
        execute( -- parser )
    ] if* ;

ERROR: parser-not-found name ;

M: ebnf-non-terminal (transform) ( ast -- parser )
    symbol>> [
        , \ dup , parser get , \ at ,
        [ parser-not-found ] , \ unless* , \ nip ,
    ] [ ] make box ;

: transform-ebnf ( string -- object )
    ebnf-parser parse transform ;

ERROR: unable-to-fully-parse-ebnf remaining ;

ERROR: could-not-parse-ebnf ;

: check-parse-result ( result -- result )
    [
        dup remaining>> [ blank? ] trim [
            unable-to-fully-parse-ebnf
        ] unless-empty
    ] [
        could-not-parse-ebnf
    ] if* ;

: parse-ebnf ( string -- hashtable )
    ebnf-parser (parse) check-parse-result ast>> transform ;

: ebnf>quot ( string -- hashtable quot )
    parse-ebnf dup dup parser [ main of compile ] with-variable
    [ compiled-parse ] curry [ with-scope ast>> ] curry ;

PRIVATE>

SYNTAX: EBNF:
    reset-tokenizer
    scan-new-word dup scan-object
    ebnf>quot swapd
    ( input -- ast ) define-declared "ebnf-parser" set-word-prop
    reset-tokenizer ;

: define-inline-ebnf ( ast string -- quot )
    reset-tokenizer
    ebnf>quot nip
    suffix! \ call suffix! reset-tokenizer ;

SYNTAX: EBNF[[ "]]" parse-multiline-string define-inline-ebnf ;
SYNTAX: EBNF[=[ "]=]" parse-multiline-string define-inline-ebnf ;
SYNTAX: EBNF[==[ "]==]" parse-multiline-string define-inline-ebnf ;
SYNTAX: EBNF[===[ "]===]" parse-multiline-string define-inline-ebnf ;
SYNTAX: EBNF[====[ "]====]" parse-multiline-string define-inline-ebnf ;

SYNTAX: EBNF-PARSER:
    reset-tokenizer
    scan-new-word
    scan-object parse-ebnf main of '[ _ ]
    ( -- parser ) define-declared
    reset-tokenizer ;
