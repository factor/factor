USING: arrays combinators kernel lazy-lists math math.parser
namespaces parser parser-combinators parser-combinators.simple
promises quotations sequences sequences.lib strings ;
USING: continuations io prettyprint ;
IN: regexp

: 'any-char'
    "." token [ drop any-char-parser ] <@ ;

: escaped-char
    {
        { CHAR: d [ [ digit? ] ] }
        { CHAR: D [ [ digit? not ] ] }
        { CHAR: s [ [ blank? ] ] }
        { CHAR: S [ [ blank? not ] ] }
        { CHAR: \\ [ [ CHAR: \\ = ] ] }
        [ "bad \\, use \\\\ to match a literal \\" throw ]
    } case ;

: 'escaped-char'
    "\\" token any-char-parser &> [ escaped-char ] <@ ;

! Must escape to use as literals
! : meta-chars "[\\^$.|?*+()" ;

: 'ordinary-char'
    [ "\\^*+?|(){}[" member? not ] satisfy ;

: 'char' 'escaped-char' 'ordinary-char' <|> ;

: 'string'
    'char' <+> [
        [ dup quotation? [ satisfy ] [ 1token ] if ] [ <&> ] map-reduce
    ] <@ ;

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

: 'range'
    any-char-parser "-" token <& any-char-parser <&>
    [ first2 [ between? ] 2curry ] <@ ;

: 'character-class-contents'
    'escaped-char'
    'range' <|>
    [ "\\]" member? not ] satisfy <|> ;

: 'character-class'
    "[" token
    "^" token 'character-class-contents' <+> <&:>
        [ predicates>cond [ not ] compose satisfy ] <@
    "]" token [ first ] <@ 'character-class-contents' <*> <&:>
        [ predicates>cond satisfy ] <@ <|>
    'character-class-contents' <+> [ predicates>cond satisfy ] <@ <|>
    &>
    "]" token <& ;

: 'term'
    'any-char'
    'string' <|>
    'grouping' <|>
    'character-class' <|>
    <+> [
        dup length 1 =
        [ first ] [ and-parser construct-boa ] if
    ] <@ ;

: 'interval'
    'term' "{" token <& 'integer' <&> "}" token <& [ first2 exactly-n ] <@
    'term' "{" token <& 'integer' <&> "," token <& "}" token <&
        [ first2 at-least-n ] <@ <|>
    'term' "{" token <& "," token <& 'integer' <&> "}" token <&
        [ first2 at-most-n ] <@ <|>
    'term' "{" token <& 'integer' <&> "," token <& 'integer' <:&> "}" token <&
        [ first3 from-m-to-n ] <@ <|> ;

: 'repetition'
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
