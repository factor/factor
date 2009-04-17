! Copyright (C) 2004 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: lists lists.lazy promises kernel sequences strings math
arrays splitting quotations combinators namespaces
unicode.case unicode.categories sequences.deep accessors ;
IN: parser-combinators

! Parser combinator protocol
GENERIC: parse ( input parser -- list )

M: promise parse ( input parser -- list )
    force parse ;

TUPLE: parse-result parsed unparsed ;

ERROR: cannot-parse input ;

: parse-1 ( input parser -- result )
    dupd parse dup nil? [
        swap cannot-parse
    ] [
        nip car parsed>>
    ] if ;

C: <parse-result> parse-result

: <parse-results> ( parsed unparsed -- list )
    <parse-result> 1list ;

: parse-result-parsed-slice ( parse-result -- slice )
    dup parsed>> empty? [
        unparsed>> 0 0 rot <slice>
    ] [
        dup unparsed>>
        dup from>> [ rot parsed>> length - ] keep
        rot seq>> <slice>
    ] if ;

: string= ( str1 str2 ignore-case -- ? )
    [ [ >upper ] bi@ ] when sequence= ;

: string-head? ( str head ignore-case -- ? )
    2over shorter? [
        3drop f
    ] [
        [ [ length head-slice ] keep ] dip string=
    ] if ;

: ?string-head ( str head ignore-case -- newstr ? )
    [ 2dup ] dip string-head?
    [ length tail-slice t ] [ drop f ] if ;

TUPLE: token-parser string ignore-case? ;

C: <token-parser> token-parser

: token ( string -- parser ) f <token-parser> ;

: case-insensitive-token ( string -- parser ) t <token-parser> ;

M: token-parser parse ( input parser -- list )
    [ string>> ] [ ignore-case?>> ] bi
    [ tuck ] dip ?string-head
    [ <parse-results> ] [ 2drop nil ] if ;

: 1token ( n -- parser ) 1string token ;

TUPLE: satisfy-parser quot ;

C: satisfy satisfy-parser ( quot -- parser )

M: satisfy-parser parse ( input parser -- list )
    #! A parser that succeeds if the predicate,
    #! when passed the first character in the input, returns
    #! true.
    over empty? [
        2drop nil
    ] [
        quot>> [ unclip-slice dup ] dip call( char -- ? )
        [ swap <parse-results> ] [ 2drop nil ] if
    ] if ;

LAZY: any-char-parser ( -- parser )
    [ drop t ] satisfy ;

TUPLE: epsilon-parser ;

C: epsilon epsilon-parser ( -- parser )

M: epsilon-parser parse ( input parser -- list )
    #! A parser that parses the empty string. It
    #! does not consume any input and always returns
    #! an empty list as the parse tree with the
    #! unmodified input.
    drop "" swap <parse-results> ;

TUPLE: succeed-parser result ;

C: succeed succeed-parser ( result -- parser )

M: succeed-parser parse ( input parser -- list )
    #! A parser that always returns 'result' as a
    #! successful parse with no input consumed.
    result>> swap <parse-results> ;

TUPLE: fail-parser ;

C: fail fail-parser ( -- parser )

M: fail-parser parse ( input parser -- list )
    #! A parser that always fails and returns
    #! an empty list of successes.
    2drop nil ;

TUPLE: ensure-parser test ;

: ensure ( parser -- ensure )
    ensure-parser boa ;

M: ensure-parser parse ( input parser -- list )
    2dup test>> parse nil?
    [ 2drop nil ] [ drop t swap <parse-results> ] if ;

TUPLE: ensure-not-parser test ;

: ensure-not ( parser -- ensure )
    ensure-not-parser boa ;

M: ensure-not-parser parse ( input parser -- list )
    2dup test>> parse nil?
    [ drop t swap <parse-results> ] [ 2drop nil ] if ;

TUPLE: and-parser parsers ;

: <&> ( parser1 parser2 -- parser )
    over and-parser? [
        [ parsers>> ] dip suffix
    ] [
        2array
    ] if and-parser boa ;

: <and-parser> ( parsers -- parser )
    dup length 1 = [ first ] [ and-parser boa ] if ;

: and-parser-parse ( list p1  -- list )
    swap [
        dup unparsed>> rot parse
        [
            [ parsed>> ] dip
            [ parsed>> 2array ] keep
            unparsed>> <parse-result>
        ] with lazy-map
    ] with lazy-map lconcat ;

M: and-parser parse ( input parser -- list )
    #! Parse 'input' by sequentially combining the
    #! two parsers. First parser1 is applied to the
    #! input then parser2 is applied to the rest of
    #! the input strings from the first parser.
    parsers>> unclip swapd parse
    [ [ and-parser-parse ] reduce ] 2curry promise ;

TUPLE: or-parser parsers ;

: <or-parser> ( parsers -- parser )
    dup length 1 = [ first ] [ or-parser boa ] if ;

: <|> ( parser1 parser2 -- parser )
    2array <or-parser> ;

M: or-parser parse ( input parser1 -- list )
    #! Return the combined list resulting from the parses
    #! of parser1 and parser2 being applied to the same
    #! input. This implements the choice parsing operator.
    parsers>> 0 swap seq>list
    [ parse ] with lazy-map lconcat ;

: trim-head-slice ( string -- string )
    #! Return a new string without any leading whitespace
    #! from the original string.
    dup empty? [
        dup first blank? [ rest-slice trim-head-slice ] when
    ] unless ;

TUPLE: sp-parser p1 ;

#! Return a parser that first skips all whitespace before
#! calling the original parser.
C: sp sp-parser ( p1 -- parser )

M: sp-parser parse ( input parser -- list )
    #! Skip all leading whitespace from the input then call
    #! the parser on the remaining input.
    [ trim-head-slice ] dip p1>> parse ;

TUPLE: just-parser p1 ;

C: just just-parser ( p1 -- parser )

M: just-parser parse ( input parser -- result )
    #! Calls the given parser on the input removes
    #! from the results anything where the remaining
    #! input to be parsed is not empty. So ensures a
    #! fully parsed input string.
    p1>> parse [ unparsed>> empty? ] lfilter ;

TUPLE: apply-parser p1 quot ;

C: <@ apply-parser ( parser quot -- parser )

M: apply-parser parse ( input parser -- result )
    #! Calls the parser on the input. For each successful
    #! parse the quot is call with the parse result on the stack.
    #! The result of that quotation then becomes the new parse result.
    #! This allows modification of parse tree results (like
    #! converting strings to integers, etc).
    [ p1>> ] [ quot>> ] bi
    -rot parse [
        [ parsed>> swap call ] keep
        unparsed>> <parse-result>
    ] with lazy-map ;

TUPLE: some-parser p1 ;

C: some some-parser ( p1 -- parser )

M: some-parser parse ( input parser -- result )
    #! Calls the parser on the input, guarantees
    #! the parse is complete (the remaining input is empty),
    #! picks the first solution and only returns the parse
    #! tree since the remaining input is empty.
    p1>> just parse-1 ;

: <& ( parser1 parser2 -- parser )
    #! Same as <&> except discard the results of the second parser.
    <&> [ first ] <@ ;

: &> ( parser1 parser2 -- parser )
    #! Same as <&> except discard the results of the first parser.
    <&> [ second ] <@ ;

: <:&> ( parser1 parser2 -- result )
    #! Same as <&> except flatten the result.
    <&> [ first2 suffix ] <@ ;

: <&:> ( parser1 parser2 -- result )
    #! Same as <&> except flatten the result.
    <&> [ first2 swap prefix ] <@ ;

: <:&:> ( parser1 parser2 -- result )
    #! Same as <&> except flatten the result.
    <&> [ first2 append ] <@ ;

LAZY: <*> ( parser -- parser )
    dup <*> <&:> { } succeed <|> ;

: <+> ( parser -- parser )
    #! Return a parser that accepts one or more occurences of the original
    #! parser.
    dup <*> <&:> ;

LAZY: <?> ( parser -- parser )
    #! Return a parser that optionally uses the parser
    #! if that parser would be successful.
    [ 1array ] <@ f succeed <|> ;

TUPLE: only-first-parser p1 ;

LAZY: only-first ( parser -- parser )
    only-first-parser boa ;

M: only-first-parser parse ( input parser -- list )
    #! Transform a parser into a parser that only yields
    #! the first possibility.
    p1>> parse 1 swap ltake ;

LAZY: <!*> ( parser -- parser )
    #! Like <*> but only return one possible result
    #! containing all matching parses. Does not return
    #! partial matches. Useful for efficiency since that's
    #! usually the effect you want and cuts down on backtracking
    #! required.
    <*> only-first ;

LAZY: <!+> ( parser -- parser )
    #! Like <+> but only return one possible result
    #! containing all matching parses. Does not return
    #! partial matches. Useful for efficiency since that's
    #! usually the effect you want and cuts down on backtracking
    #! required.
    <+> only-first ;

LAZY: <!?> ( parser -- parser )
    #! Like <?> but only return one possible result
    #! containing all matching parses. Does not return
    #! partial matches. Useful for efficiency since that's
    #! usually the effect you want and cuts down on backtracking
    #! required.
    <?> only-first ;

LAZY: <(?)> ( parser -- parser )
    #! Like <?> but take shortest match first.
    f succeed swap [ 1array ] <@ <|> ;

LAZY: <(*)> ( parser -- parser )
    #! Like <*> but take shortest match first.
    #! Implementation by Matthew Willis.
    { } succeed swap dup <(*)> <&:> <|> ;

LAZY: <(+)> ( parser -- parser )
    #! Like <+> but take shortest match first.
    #! Implementation by Matthew Willis.
    dup <(*)> <&:> ;

: pack ( close body open -- parser )
    #! Parse a construct enclosed by two symbols,
    #! given a parser for the opening symbol, the
    #! closing symbol, and the body.
    <& &> ;

: nonempty-list-of ( items separator -- parser )
    [ over &> <*> <&:> ] keep <?> tuck pack ;

: list-of ( items separator -- parser )
    #! Given a parser for the separator and for the
    #! items themselves, return a parser that parses
    #! lists of those items. The parse tree is an
    #! array of the parsed items.
    nonempty-list-of { } succeed <|> ;

LAZY: surrounded-by ( parser start end -- parser' )
    [ token ] bi@ swapd pack ;

: exactly-n ( parser n -- parser' )
    swap <repetition> <and-parser> [ flatten ] <@ ;

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
    [ [ exactly-n ] 2keep ] dip swap - at-most-n <:&:> ;
