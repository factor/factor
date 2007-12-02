USING: arrays combinators kernel lazy-lists math math.parser
namespaces parser parser-combinators parser-combinators.simple
promises quotations sequences sequences.lib strings ;
USING: continuations io prettyprint ;
IN: regexp

: 1satisfy ( n -- parser )
    [ = ] curry satisfy ;

: satisfy-token ( string quot -- parser )
    >r token r> [ satisfy ] curry [ drop ] swap compose <@ ;

: octal-digit? ( n -- ? ) CHAR: 0 CHAR: 7 between? ; inline

: decimal-digit? ( n -- ? ) CHAR: 0 CHAR: 9 between? ; inline

: hex-digit? ( n -- ? )
    dup decimal-digit?
    swap CHAR: a CHAR: f between? or ;

: octal? ( str -- ? ) [ octal-digit? ] all? ;

: decimal? ( str -- ? ) [ decimal-digit? ] all? ;

: hex? ( str -- ? ) [ hex-digit? ] all? ;

: control-char? ( n -- ? )
    dup 0 HEX: 1f between?
    swap HEX: 7f = or ;

: punct? ( n -- ? )
    "!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~" member? ;

: c-identifier-char? ( ch -- ? )
    dup alpha? swap CHAR: _ = or ; inline

: c-identifier? ( str -- ? )
    [ c-identifier-char? ] all? ;

: java-blank? ( n -- ? )
    {
        CHAR: \t CHAR: \n CHAR: \r
        HEX: c HEX: 7 HEX: 1b
    } member? ;

: java-printable? ( n -- ? )
    dup alpha? swap punct? or ;


: 'ordinary-char' ( -- parser )
    [ "\\^*+?|(){}[" member? not ] satisfy [ 1satisfy ] <@ ;

: 'octal-digit' ( -- parser ) [ octal-digit? ] satisfy ;

: 'octal' ( -- parser )
    "\\0" token
    'octal-digit'
    'octal-digit' 'octal-digit' <&> <|>
    [ CHAR: 0 CHAR: 3 between? ] satisfy
    'octal-digit' <&> 'octal-digit' <:&> <|>
    &> just [ oct> 1satisfy ] <@ ;

: 'hex-digit' ( -- parser ) [ hex-digit? ] satisfy ;

: 'hex' ( -- parser )
    "\\x" token 'hex-digit' 'hex-digit' <&> &>
    "\\u" token 'hex-digit' 'hex-digit' <&>
    'hex-digit' <:&> 'hex-digit' <:&> &> <|> [ hex> 1satisfy ] <@ ;

: 'control-character' ( -- parser )
    "\\c" token [ LETTER? ] satisfy &> [ 1satisfy ] <@ ;

: 'simple-escape-char' ( -- parser )
    {
        { "\\\\" [ CHAR: \\ = ] }
        { "\\t" [ CHAR: \t = ] }
        { "\\n" [ CHAR: \n = ] }
        { "\\r" [ CHAR: \r = ] }
        { "\\f" [ HEX: c = ] }
        { "\\a" [ HEX: 7 = ] }
        { "\\e" [ HEX: 1b = ] }
    } [ first2 satisfy-token ] [ <|> ] map-reduce ;

: 'predefined-char-class' ( -- parser )
    {
        { "." [ drop any-char-parser ] }
        { "\\d" [ digit? ] }
        { "\\D" [ digit? not ] }
        { "\\s" [ java-blank? ] }
        { "\\S" [ java-blank? not ] }
        { "\\w" [ c-identifier? ] }
        { "\\W" [ c-identifier? not ] }
    } [ first2 satisfy-token ] [ <|> ] map-reduce ;

: 'posix-character-class' ( -- parser )
    {
        { "\\p{Lower}" [ letter? ] }
        { "\\p{Upper}" [ LETTER? ] }
        { "\\p{ASCII}" [ 0 HEX: 7f between? ] }
        { "\\p{Alpha}" [ Letter? ] }
        { "\\p{Digit}" [ digit? ] }
        { "\\p{Alnum}" [ alpha? ] }
        { "\\p{Punct}" [ punct? ] }
        { "\\p{Graph}" [ java-printable? ] }
        { "\\p{Print}" [ java-printable? ] }
        { "\\p{Blank}" [ " \t" member? ] }
        { "\\p{Cntrl}" [ control-char? ] }
        { "\\p{XDigit}" [ hex-digit? ] }
        { "\\p{Space}" [ java-blank? ] }
    } [ first2 satisfy-token ] [ <|> ] map-reduce ;

: 'escaped-seq' ( -- parser )
    "\\Q" token
    any-char-parser <*> [ token ] <@ &>
    "\\E" token <& ;

: 'escape-seq' ( -- parser )
    'simple-escape-char'
    'predefined-char-class' <|>
    'octal' <|>
    'hex' <|>
    'escaped-seq' <|>
    'control-character' <|>
    'posix-character-class' <|> ;

: 'char' 'escape-seq' 'ordinary-char' <|> ;

: 'string'
    'char' <+> [ [ <&> ] reduce* ] <@ ;

: exactly-n ( parser n -- parser' )
    swap <repetition> and-parser construct-boa ;

: at-most-n ( parser n -- parser' )
    dup zero? [
        2drop epsilon
    ] [
        2dup exactly-n
        -rot 1- at-most-n <|>
    ] if ;

: at-least-n ( parser n -- parser' )
    dupd exactly-n swap <*> <&> ;

: from-m-to-n ( parser m n -- parser' )
    >r [ exactly-n ] 2keep r> swap - at-most-n <&> ;

DEFER: 'regexp'

TUPLE: group-result str ;

C: <group-result> group-result

: 'grouping'
    "(" token
    'regexp' [ [ <group-result> ] <@ ] <@
    ")" token <& &> ;

! Special cases: ]\\^-
: predicates>cond ( seq -- quot )
    #! Takes an array of quotation predicates/objects and makes a cond
    #! Makes a predicate of each obj like so:  [ dup obj = ]
    #! Leaves quotations alone
    #! The cond returns a boolean, t if one of the predicates matches
    [
        dup callable? [ [ = ] curry ] unless
        [ dup ] swap compose [ drop t ] 2array
    ] map { [ t ] [ drop f ] } add [ cond ] curry ;

: 'range' ( -- parser )
    any-char-parser "-" token <& any-char-parser <&>
    [ first2 [ between? ] 2curry satisfy ] <@ ;

: 'character-class-contents' ( -- parser )
    'escape-seq'
    'range' <|>
    [ "\\]" member? not ] satisfy [ 1satisfy ] <@ <|> ;

: make-character-class ( seq ? -- )
    >r [ parser>predicate ] map predicates>cond r>
    [ [ not ] compose ] when satisfy ;

: 'character-class' ( -- parser )
    "[" token
    "^" token 'character-class-contents' <+> &> [ t make-character-class ] <@
    "]" token [ first 1satisfy ] <@ 'character-class-contents' <*> <&:>
        [ f make-character-class ] <@ <|>
    'character-class-contents' <+> [ f make-character-class ] <@ <|>
    &>
    "]" token <& ;

: 'term' ( -- parser )
    'string'
    'grouping' <|>
    'character-class' <|>
    <+> [
        dup length 1 =
        [ first ] [ and-parser construct-boa ] if
    ] <@ ;

: 'interval' ( -- parser )
    'term' "{" token <& 'integer' <&> "}" token <& [ first2 exactly-n ] <@
    'term' "{" token <& 'integer' <&> "," token <& "}" token <&
        [ first2 at-least-n ] <@ <|>
    'term' "{" token <& "," token <& 'integer' <&> "}" token <&
        [ first2 at-most-n ] <@ <|>
    'term' "{" token <& 'integer' <&> "," token <& 'integer' <:&> "}" token <&
        [ first3 from-m-to-n ] <@ <|> ;

: 'repetition' ( -- parser )
    'term'
    [ "*+?" member? ] satisfy <&> [
        first2 {
            { CHAR: * [ <*> ] }
            { CHAR: + [ <+> ] }
            { CHAR: ? [ <?> ] }
        } case
    ] <@ ;

: 'simple' 'term' 'repetition' <|> 'interval' <|> ;

LAZY: 'union' ( -- parser )
    'simple'
    'simple' "|" token 'union' &> <&> [ first2 <|> ] <@
    <|> ;

LAZY: 'regexp' ( -- parser )
    'repetition' 'union' <|> ;

: <regexp> 'regexp' just parse-1 ;

GENERIC: >regexp ( obj -- parser )
M: string >regexp 'regexp' just parse-1 ;
M: object >regexp ;

: matches? ( string regexp -- ? ) >regexp just parse nil? not ;

: parse-regexp ( accum end -- accum )
    lexer get dup skip-blank [
        [ index* dup 1+ swap ] 2keep swapd subseq swap
    ] change-column  <regexp> parsed ;

: R/ CHAR: / parse-regexp ; parsing
: R| CHAR: | parse-regexp ; parsing
: R" CHAR: " parse-regexp ; parsing
: R' CHAR: ' parse-regexp ; parsing
: R` CHAR: ` parse-regexp ; parsing
