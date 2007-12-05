USING: arrays combinators kernel lazy-lists math math.parser
namespaces parser parser-combinators parser-combinators.simple
promises quotations sequences combinators.lib strings macros
assocs prettyprint.backend ;
USE: io
IN: regexp

: or-predicates ( quots -- quot )
    [ \ dup add* ] map [ [ t ] ] f short-circuit \ nip add ;

MACRO: fast-member? ( str -- quot )
    [ dup ] H{ } map>assoc [ key? ] curry ;

: octal-digit? ( n -- ? )
    CHAR: 0 CHAR: 7 between? ;

: decimal-digit? ( n -- ? )
    CHAR: 0 CHAR: 9 between? ;

: hex-digit? ( n -- ? )
    dup decimal-digit?
    swap CHAR: a CHAR: f between? or ;

: control-char? ( n -- ? )
    dup 0 HEX: 1f between?
    swap HEX: 7f = or ;

: punct? ( n -- ? )
    "!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~" fast-member? ;

: c-identifier-char? ( ch -- ? )
    dup alpha? swap CHAR: _ = or ;

: java-blank? ( n -- ? )
    {
        CHAR: \t CHAR: \n CHAR: \r
        HEX: c HEX: 7 HEX: 1b
    } fast-member? ;

: java-printable? ( n -- ? )
    dup alpha? swap punct? or ;

: 'ordinary-char' ( -- parser )
    [ "\\^*+?|(){}[$" fast-member? not ] satisfy
    [ [ = ] curry ] <@ ;

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
    [ >r token r> [ nip ] curry <@ ] { } assoc>map <or-parser> ;

: 'simple-escape-char' ( -- parser )
    {
        { "\\" CHAR: \\ }
        { "t"  CHAR: \t }
        { "n"  CHAR: \n }
        { "r"  CHAR: \r }
        { "f"  HEX: c   }
        { "a"  HEX: 7   }
        { "e"  HEX: 1b  }
    } [ [ = ] curry ] assoc-map satisfy-tokens ;

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
        { "ASCII" [ 0 HEX: 7f between? ] }
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
    [ [ = ] curry ] <@ ;

: 'escape' ( -- parser )
    "\\" token
    'simple-escape-char'
    'predefined-char-class' <|>
    'posix-character-class' <|>
    'simple-escape' <|> &> ;

: 'any-char'
    "." token [ drop [ drop t ] ] <@ ;

: 'char'
    'any-char' 'escape' 'ordinary-char' <|> <|> [ satisfy ] <@ ;

DEFER: 'regexp'

TUPLE: group-result str ;

C: <group-result> group-result

: 'grouping'
    'regexp' [ [ <group-result> ] <@ ] <@
    "(" ")" surrounded-by ;

: 'range' ( -- parser )
    any-char-parser "-" token <& any-char-parser <&>
    [ first2 [ between? ] 2curry ] <@ ;

: 'character-class-term' ( -- parser )
    'range'
    'escape' <|>
    [ "\\]" member? not ] satisfy [ [ = ] curry ] <@ <|> ;

: 'positive-character-class' ( -- parser )
    "]" token [ drop [ CHAR: ] = ] ] <@ 'character-class-term' <*> <&:>
    'character-class-term' <+> <|>
    [ or-predicates ] <@ ;

: 'negative-character-class' ( -- parser )
    "^" token 'positive-character-class' &>
    [ [ not ] append ] <@ ;

: 'character-class' ( -- parser )
    'negative-character-class' 'positive-character-class' <|>
    "[" "]" surrounded-by [ satisfy ] <@ ;

: 'escaped-seq' ( -- parser )
    any-char-parser <*> [ token ] <@ "\\Q" "\\E" surrounded-by ;

: 'simple' ( -- parser )
    'escaped-seq'
    'grouping' <|>
    'char' <|>
    'character-class' <|> ;

: 'greedy-interval' ( -- parser )
    'simple' 'integer' "{" "}" surrounded-by <&> [ first2 exactly-n ] <@
    'simple' 'integer' "{" ",}" surrounded-by <&> [ first2 at-least-n ] <@ <|>
    'simple' 'integer' "{," "}" surrounded-by <&> [ first2 at-most-n ] <@ <|>
    'simple' 'integer' "," token <& 'integer' <&> "{" "}" surrounded-by <&> [ first2 first2 from-m-to-n ] <@ <|> ;

: 'interval' ( -- parser )
    'greedy-interval'
    'greedy-interval' "?" token <& [ "reluctant {}" print ] <@ <|>
    'greedy-interval' "+" token <& [ "possessive {}" print ] <@ <|> ;

: 'greedy-repetition' ( -- parser )
    'simple' "*" token <& [ <*> ] <@
    'simple' "+" token <& [ <+> ] <@ <|>
    'simple' "?" token <& [ <?> ] <@ <|> ;

: 'repetition' ( -- parser )
    'greedy-repetition'
    'greedy-repetition' "?" token <& [ "reluctant" print ] <@ <|>
    'greedy-repetition' "+" token <& [ "possessive" print ] <@ <|> ;

: 'term' ( -- parser )
    'simple' 'repetition' 'interval' <|> <|>
    <+> [ <and-parser> ] <@ ;

LAZY: 'regexp' ( -- parser )
    'term' "|" token nonempty-list-of [ <or-parser> ] <@
    "^" token 'term' "|" token nonempty-list-of [ <or-parser> ] <@
        &> [ "caret" print ] <@ <|>
    'term' "|" token nonempty-list-of [ <or-parser> ] <@
        "$" token <& [ "dollar" print ] <@ <|>
    "^" token 'term' "|" token nonempty-list-of [ <or-parser> ] <@ &>
        "$" token [ "caret dollar" print ] <@ <& <|> ;

TUPLE: regexp source parser ;

: <regexp> dup 'regexp' just parse-1 regexp construct-boa ;

GENERIC: >regexp ( obj -- parser )

M: string >regexp <regexp> ;

M: object >regexp ;

: matches? ( string regexp -- ? )
    >regexp regexp-parser just parse nil? not ;

! Literal syntax for regexps
: parse-regexp ( accum end -- accum )
    lexer get dup skip-blank [
        [ index* dup 1+ swap ] 2keep swapd subseq swap
    ] change-column  <regexp> parsed ;

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
    dup regexp-source dup find-regexp-syntax pprint-string ;
