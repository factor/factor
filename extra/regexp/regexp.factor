USING: arrays combinators kernel lazy-lists math math.parser
namespaces parser parser-combinators parser-combinators.simple
promises quotations sequences combinators.lib strings
assocs prettyprint.backend memoize ;
USE: io
IN: regexp

<PRIVATE

SYMBOL: ignore-case?

: char=-quot ( ch -- quot )
    ignore-case? get
    [ ch>upper [ swap ch>upper = ] ] [ [ = ] ] if
    curry ;

: char-between?-quot ( ch1 ch2 -- quot )
    ignore-case? get
    [ [ ch>upper ] 2apply [ >r >r ch>upper r> r> between? ] ]
    [ [ between? ] ]
    if 2curry ;

: or-predicates ( quots -- quot )
    [ \ dup add* ] map [ [ t ] ] f short-circuit \ nip add ;

: <@literal [ nip ] curry <@ ;

: <@delay [ curry ] curry <@ ;

PRIVATE>

: ascii? ( n -- ? ) 
    0 HEX: 7f between? ;

: octal-digit? ( n -- ? )
    CHAR: 0 CHAR: 7 between? ;

: decimal-digit? ( n -- ? )
    CHAR: 0 CHAR: 9 between? ;

: hex-digit? ( n -- ? )
    dup decimal-digit?
    over CHAR: a CHAR: f between? or
    swap CHAR: A CHAR: F between? or ;

: control-char? ( n -- ? )
    dup 0 HEX: 1f between?
    swap HEX: 7f = or ;

: punct? ( n -- ? )
    "!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~" member? ;

: c-identifier-char? ( ch -- ? )
    dup alpha? swap CHAR: _ = or ;

: java-blank? ( n -- ? )
    {
        CHAR: \s
        CHAR: \t CHAR: \n CHAR: \r
        HEX: c HEX: 7 HEX: 1b
    } member? ;

: java-printable? ( n -- ? )
    dup alpha? swap punct? or ;

: 'ordinary-char' ( -- parser )
    [ "\\^*+?|(){}[$" member? not ] satisfy
    [ char=-quot ] <@ ;

: 'octal-digit' ( -- parser ) [ octal-digit? ] satisfy ;

: 'octal' ( -- parser )
    "0" token 'octal-digit' 1 3 from-m-to-n &>
    [ oct> ] <@ ;

: 'hex-digit' ( -- parser ) [ hex-digit? ] satisfy ;

: 'hex' ( -- parser )
    "x" token 'hex-digit' 2 exactly-n &>
    "u" token 'hex-digit' 4 exactly-n &> <|>
    [ hex> ] <@ ;

: satisfy-tokens ( assoc -- parser )
    [ >r token r> <@literal ] { } assoc>map <or-parser> ;

: 'simple-escape-char' ( -- parser )
    {
        { "\\" CHAR: \\ }
        { "t"  CHAR: \t }
        { "n"  CHAR: \n }
        { "r"  CHAR: \r }
        { "f"  HEX: c   }
        { "a"  HEX: 7   }
        { "e"  HEX: 1b  }
    } [ char=-quot ] assoc-map satisfy-tokens ;

: 'predefined-char-class' ( -- parser )
    {
        { "d" [ digit? ] }
        { "D" [ digit? not ] }
        { "s" [ java-blank? ] }
        { "S" [ java-blank? not ] }
        { "w" [ c-identifier-char? ] }
        { "W" [ c-identifier-char? not ] }
    } satisfy-tokens ;

: 'posix-character-class' ( -- parser )
    {
        { "Lower" [ letter? ] }
        { "Upper" [ LETTER? ] }
        { "ASCII" [ ascii? ] }
        { "Alpha" [ Letter? ] }
        { "Digit" [ digit? ] }
        { "Alnum" [ alpha? ] }
        { "Punct" [ punct? ] }
        { "Graph" [ java-printable? ] }
        { "Print" [ java-printable? ] }
        { "Blank" [ " \t" member? ] }
        { "Cntrl" [ control-char? ] }
        { "XDigit" [ hex-digit? ] }
        { "Space" [ java-blank? ] }
    } satisfy-tokens "p{" "}" surrounded-by ;

: 'simple-escape' ( -- parser )
    'octal'
    'hex' <|>
    "c" token [ LETTER? ] satisfy &> <|>
    any-char-parser <|>
    [ char=-quot ] <@ ;

: 'escape' ( -- parser )
    "\\" token
    'simple-escape-char'
    'predefined-char-class' <|>
    'posix-character-class' <|>
    'simple-escape' <|> &> ;

: 'any-char'
    "." token [ drop t ] <@literal ;

: 'char'
    'any-char' 'escape' 'ordinary-char' <|> <|> [ satisfy ] <@ ;

DEFER: 'regexp'

TUPLE: group-result str ;

C: <group-result> group-result

: 'non-capturing-group' ( -- parser )
    "?:" token 'regexp' &> ;

: 'positive-lookahead-group' ( -- parser )
    "?=" token 'regexp' &> [ ensure ] <@ ;

: 'negative-lookahead-group' ( -- parser )
    "?!" token 'regexp' &> [ ensure-not ] <@ ;

: 'simple-group' ( -- parser )
    'regexp' [ [ <group-result> ] <@ ] <@ ;

: 'group' ( -- parser )
    'non-capturing-group'
    'positive-lookahead-group'
    'negative-lookahead-group'
    'simple-group' <|> <|> <|>
    "(" ")" surrounded-by ;

: 'range' ( -- parser )
    any-char-parser "-" token <& any-char-parser <&>
    [ first2 char-between?-quot ] <@ ;

: 'character-class-term' ( -- parser )
    'range'
    'escape' <|>
    [ "\\]" member? not ] satisfy [ char=-quot ] <@ <|> ;

: 'positive-character-class' ( -- parser )
    "]" token [ CHAR: ] = ] <@literal 'character-class-term' <*> <&:>
    'character-class-term' <+> <|>
    [ or-predicates ] <@ ;

: 'negative-character-class' ( -- parser )
    "^" token 'positive-character-class' &>
    [ [ not ] append ] <@ ;

: 'character-class' ( -- parser )
    'negative-character-class' 'positive-character-class' <|>
    "[" "]" surrounded-by [ satisfy ] <@ ;

: 'escaped-seq' ( -- parser )
    any-char-parser <*>
    [ ignore-case? get <token-parser> ] <@
    "\\Q" "\\E" surrounded-by ;

: 'break' ( quot -- parser )
    satisfy ensure epsilon just <|> ;

: 'break-escape' ( -- parser )
    "$" token [ "\r\n" member? ] 'break' <@literal
    "\\b" token [ blank? ] 'break' <@literal <|>
    "\\B" token [ blank? not ] 'break' <@literal <|>
    "\\z" token epsilon just <@literal <|> ;

: 'simple' ( -- parser )
    'escaped-seq'
    'break-escape' <|>
    'group' <|>
    'character-class' <|>
    'char' <|> ;

: 'exactly-n' ( -- parser )
    'integer' [ exactly-n ] <@delay ;

: 'at-least-n' ( -- parser )
    'integer' "," token <& [ at-least-n ] <@delay ;

: 'at-most-n' ( -- parser )
    "," token 'integer' &> [ at-most-n ] <@delay ;

: 'from-m-to-n' ( -- parser )
    'integer' "," token <& 'integer' <&> [ first2 from-m-to-n ] <@delay ;

: 'greedy-interval' ( -- parser )
    'exactly-n' 'at-least-n' <|> 'at-most-n' <|> 'from-m-to-n' <|> ;

: 'interval' ( -- parser )
    'greedy-interval'
    'greedy-interval' "?" token <& [ "reluctant {}" print ] <@ <|>
    'greedy-interval' "+" token <& [ "possessive {}" print ] <@ <|>
    "{" "}" surrounded-by ;

: 'repetition' ( -- parser )
    ! Posessive
    "*+" token [ <!*> ] <@literal
    "++" token [ <!+> ] <@literal <|>
    "?+" token [ <!?> ] <@literal <|>
    ! Reluctant
    "*?" token [ <(*)> ] <@literal <|>
    "+?" token [ <(+)> ] <@literal <|>
    "??" token [ <(?)> ] <@literal <|>
    ! Greedy
    "*" token [ <*> ] <@literal <|>
    "+" token [ <+> ] <@literal <|>
    "?" token [ <?> ] <@literal <|> ;

: 'dummy' ( -- parser )
    epsilon [ ] <@literal ;

MEMO: 'term' ( -- parser )
    'simple'
    'repetition' 'interval' 'dummy' <|> <|> <&> [ first2 call ] <@
    <!+> [ <and-parser> ] <@ ;

LAZY: 'regexp' ( -- parser )
    'term' "|" token nonempty-list-of [ <or-parser> ] <@ ;
!    "^" token 'term' "|" token nonempty-list-of [ <or-parser> ] <@
!        &> [ "caret" print ] <@ <|>
!    'term' "|" token nonempty-list-of [ <or-parser> ] <@
!        "$" token <& [ "dollar" print ] <@ <|>
!    "^" token 'term' "|" token nonempty-list-of [ <or-parser> ] <@ &>
!        "$" token [ "caret dollar" print ] <@ <& <|> ;

TUPLE: regexp source parser ignore-case? ;

: <regexp> ( string ignore-case? -- regexp )
    [
        ignore-case? [
            dup 'regexp' just parse-1
        ] with-variable
    ] keep regexp construct-boa ;

: do-ignore-case ( string regexp -- string regexp )
    dup regexp-ignore-case? [ >r >upper r> ] when ;

: matches? ( string regexp -- ? )
    do-ignore-case regexp-parser just parse nil? not ;

: match-head ( string regexp -- end )
    do-ignore-case regexp-parser parse dup nil?
    [ drop f ] [ car parse-result-unparsed slice-from ] if ;

! Literal syntax for regexps
: parse-options ( string -- ? )
    #! Lame
    {
        { "" [ f ] }
        { "i" [ t ] }
    } case ;

: parse-regexp ( accum end -- accum )
    lexer get dup skip-blank [
        [ index* dup 1+ swap ] 2keep swapd subseq swap
    ] change-column
    lexer get (parse-token) parse-options <regexp> parsed ;

: R! CHAR: ! parse-regexp ; parsing
: R" CHAR: " parse-regexp ; parsing
: R# CHAR: # parse-regexp ; parsing
: R' CHAR: ' parse-regexp ; parsing
: R( CHAR: ) parse-regexp ; parsing
: R/ CHAR: / parse-regexp ; parsing
: R@ CHAR: @ parse-regexp ; parsing
: R[ CHAR: ] parse-regexp ; parsing
: R` CHAR: ` parse-regexp ; parsing
: R{ CHAR: } parse-regexp ; parsing
: R| CHAR: | parse-regexp ; parsing

: find-regexp-syntax ( string -- prefix suffix )
    {
        { "R/ "  "/"  }
        { "R! "  "!"  }
        { "R\" " "\"" }
        { "R# "  "#"  }
        { "R' "  "'"  }
        { "R( "  ")"  }
        { "R@ "  "@"  }
        { "R[ "  "]"  }
        { "R` "  "`"  }
        { "R{ "  "}"  }
        { "R| "  "|"  }
    } swap [ subseq? not nip ] curry assoc-find drop ;

M: regexp pprint*
    [
        dup regexp-source
        dup find-regexp-syntax swap % swap % %
        dup regexp-ignore-case? [ "i" % ] when
    ] "" make
    swap present-text ;
