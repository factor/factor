USING: assocs combinators.lib kernel math math.parser
namespaces peg unicode.case sequences unicode.categories
memoize peg.parsers ;
USE: io
USE: tools.walker
IN: regexp2

<PRIVATE
    
SYMBOL: ignore-case?

: char=-quot ( ch -- quot )
    ignore-case? get
    [ ch>upper [ swap ch>upper = ] ] [ [ = ] ] if
    curry ;
    
: char-between?-quot ( ch1 ch2 -- quot )
    ignore-case? get
    [ [ ch>upper ] bi@ [ >r >r ch>upper r> r> between? ] ]
    [ [ between? ] ]
    if 2curry ;
    
: or-predicates ( quots -- quot )
    [ \ dup add* ] map [ [ t ] ] f short-circuit \ nip add ;

: literal-action [ nip ] curry action ;

: delay-action [ curry ] curry action ;
    
PRIVATE>

: ascii? ( n -- ? )
    0 HEX: 7f between? ;
    
: octal-digit? ( n -- ? ) 
    CHAR: 0 CHAR: 7 between? ;

: hex-digit? ( n -- ? )
    {
        [ dup digit? ]
        [ dup CHAR: a CHAR: f between? ]
        [ dup CHAR: A CHAR: F between? ]
    } || nip ;

: control-char? ( n -- ? )
    { [ dup 0 HEX: 1f between? ] [ dup HEX: 7f = ] } || nip ;

: punct? ( n -- ? )
    "!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~" member? ;

: c-identifier-char? ( ch -- ? )
    { [ dup alpha? ] [ dup CHAR: _ = ] } || nip ;

: java-blank? ( n -- ? )
    {
        CHAR: \s
        CHAR: \t CHAR: \n CHAR: \r
        HEX: c HEX: 7 HEX: 1b
    } member? ;

: java-printable? ( n -- ? )
    { [ dup alpha? ] [ dup punct? ] } || nip ;

MEMO: 'ordinary-char' ( -- parser )
    [ "\\^*+?|(){}[$" member? not ] satisfy
    [ char=-quot ] action ;

MEMO: 'octal-digit' ( -- parser ) [ octal-digit? ] satisfy ;

MEMO: 'octal' ( -- parser )
    "0" token hide 'octal-digit' 1 3 from-m-to-n 2seq
    [ first oct> ] action ;

MEMO: 'hex-digit' ( -- parser ) [ hex-digit? ] satisfy ;

MEMO: 'hex' ( -- parser )
    "x" token hide 'hex-digit' 2 exactly-n 2seq
    "u" token hide 'hex-digit' 6 exactly-n 2seq 2choice
    [ first hex> ] action ;

: satisfy-tokens ( assoc -- parser )
    [ >r token r> literal-action ] { } assoc>map choice ;

MEMO: 'simple-escape-char' ( -- parser )
    {
        { "\\" CHAR: \\ }
        { "t"  CHAR: \t }
        { "n"  CHAR: \n }
        { "r"  CHAR: \r }
        { "f"  HEX: c   }
        { "a"  HEX: 7   }
        { "e"  HEX: 1b  }
    } [ char=-quot ] assoc-map satisfy-tokens ;

MEMO: 'predefined-char-class' ( -- parser )
    {   
        { "d" [ digit? ] } 
        { "D" [ digit? not ] }
        { "s" [ java-blank? ] } 
        { "S" [ java-blank? not ] }
        { "w" [ c-identifier-char? ] } 
        { "W" [ c-identifier-char? not ] }
    } satisfy-tokens ;

MEMO: 'posix-character-class' ( -- parser )
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

MEMO: 'simple-escape' ( -- parser )
    [
        'octal' ,
        'hex' ,
        "c" token hide [ LETTER? ] satisfy 2seq ,
        any-char ,
    ] choice* [ char=-quot ] action ;

MEMO: 'escape' ( -- parser )
    "\\" token hide [
        'simple-escape-char' ,
        'predefined-char-class' ,
        'posix-character-class' ,
        'simple-escape' ,
    ] choice* 2seq ;

MEMO: 'any-char' ( -- parser )
    "." token [ drop t ] literal-action ;

MEMO: 'char' ( -- parser )
    'any-char' 'escape' 'ordinary-char' 3choice [ satisfy ] action ;

DEFER: 'regexp'

TUPLE: group-result str ;

C: <group-result> group-result

MEMO: 'non-capturing-group' ( -- parser )
    "?:" token hide 'regexp' ;

MEMO: 'positive-lookahead-group' ( -- parser )
    "?=" token hide 'regexp' [ ensure ] action ;

MEMO: 'negative-lookahead-group' ( -- parser )
    "?!" token hide 'regexp' [ ensure-not ] action ;

MEMO: 'simple-group' ( -- parser )
    'regexp' [ [ <group-result> ] action ] action ;

MEMO: 'group' ( -- parser )
    [
        'non-capturing-group' ,
        'positive-lookahead-group' ,
        'negative-lookahead-group' ,
        'simple-group' ,
    ] choice* "(" ")" surrounded-by ;

MEMO: 'range' ( -- parser )
    any-char "-" token hide any-char 3seq
    [ first2 char-between?-quot ] action ;

MEMO: 'character-class-term' ( -- parser )
    'range'
    'escape'
    [ "\\]" member? not ] satisfy [ char=-quot ] action
    3choice ;

MEMO: 'positive-character-class' ( -- parser )
    ! todo
    "]" token [ CHAR: ] = ] literal-action 'character-class-term' repeat0 2seq 
    'character-class-term' repeat1 2choice [ or-predicates ] action ;

MEMO: 'negative-character-class' ( -- parser )
    "^" token hide 'positive-character-class' 2seq
    [ [ not ] append ] action ;

MEMO: 'character-class' ( -- parser )
    'negative-character-class' 'positive-character-class' 2choice
    "[" "]" surrounded-by [ satisfy ] action ;

MEMO: 'escaped-seq' ( -- parser )
    any-char repeat1
    [ ignore-case? get token ] action "\\Q" "\\E" surrounded-by ;
    
MEMO: 'break' ( quot -- parser )
    satisfy ensure
    epsilon just 2choice ;
    
MEMO: 'break-escape' ( -- parser )
    "$" token [ "\r\n" member? ] 'break' literal-action
    "\\b" token [ blank? ] 'break' literal-action
    "\\B" token [ blank? not ] 'break' literal-action
    "\\z" token epsilon just literal-action 4choice ;
    
MEMO: 'simple' ( -- parser )
    [
        'escaped-seq' ,
        'break-escape' ,
        'group' ,
        'character-class' ,
        'char' ,
    ] choice* ;

MEMO: 'exactly-n' ( -- parser )
    'integer' [ exactly-n ] delay-action ;

MEMO: 'at-least-n' ( -- parser )
    'integer' "," token hide 2seq [ at-least-n ] delay-action ;

MEMO: 'at-most-n' ( -- parser )
    "," token hide 'integer' 2seq [ at-most-n ] delay-action ;

MEMO: 'from-m-to-n' ( -- parser )
    'integer' "," token hide 'integer' 3seq
    [ first2 from-m-to-n ] delay-action ;

MEMO: 'greedy-interval' ( -- parser )
    'exactly-n' 'at-least-n' 'at-most-n' 'from-m-to-n' 4choice ;

MEMO: 'interval' ( -- parser )
    'greedy-interval'
    'greedy-interval' "?" token hide 2seq [ "reluctant {}" print ] action
    'greedy-interval' "+" token hide 2seq [ "possessive {}" print ] action
    3choice "{" "}" surrounded-by ;

MEMO: 'repetition' ( -- parser )
    [
        ! Possessive
        ! "*+" token [ <!*> ] literal-action ,
        ! "++" token [ <!+> ] literal-action ,
        ! "?+" token [ <!?> ] literal-action ,
        ! Reluctant
        ! "*?" token [ <(*)> ] literal-action ,
        ! "+?" token [ <(+)> ] literal-action ,
        ! "??" token [ <(?)> ] literal-action ,
        ! Greedy
        "*" token [ repeat0 ] literal-action ,
        "+" token [ repeat1 ] literal-action ,
        "?" token [ optional ] literal-action ,
    ] choice* ;

MEMO: 'dummy' ( -- parser )
    epsilon [ ] literal-action ;

! todo -- check the action
! MEMO: 'term' ( -- parser )
    ! 'simple'
    ! 'repetition' 'interval' 'dummy' 3choice 2seq [ first2 call ] action
    ! <!+> [ <and-parser> ] action ;

