! Copyright (C) 2004 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: lazy-lists promises kernel sequences strings math
arrays splitting quotations combinators ;
IN: parser-combinators

! Parser combinator protocol
GENERIC: parse ( input parser -- list )

M: promise parse ( input parser -- list )
    force parse ;

TUPLE: parse-result parsed unparsed ;

: parse-1 ( input parser -- result )
    dupd parse dup nil? [
        "Cannot parse " rot append throw
    ] [
        nip car parse-result-parsed
    ] if ;

C: <parse-result> parse-result

: parse-result-parsed-slice ( parse-result -- slice )
    dup parse-result-parsed empty? [
        parse-result-unparsed 0 0 rot <slice>
    ] [
        dup parse-result-unparsed
        dup slice-from [ rot parse-result-parsed length - ] keep
        rot slice-seq <slice>
    ] if ;

TUPLE: token-parser string ;

C: token token-parser ( string -- parser )

M: token-parser parse ( input parser -- list )
    token-parser-string swap over ?head-slice [
        <parse-result> 1list
    ] [
        2drop nil
    ] if ;

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
        satisfy-parser-quot >r unclip-slice dup r> call [
            swap <parse-result> 1list
        ] [
            2drop nil
        ] if
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
    drop "" swap <parse-result> 1list ;

TUPLE: succeed-parser result ;

C: succeed succeed-parser ( result -- parser )

M: succeed-parser parse ( input parser -- list )
    #! A parser that always returns 'result' as a
    #! successful parse with no input consumed.
    succeed-parser-result swap <parse-result> 1list ;

TUPLE: fail-parser ;

C: fail fail-parser ( -- parser )

M: fail-parser parse ( input parser -- list )
    #! A parser that always fails and returns
    #! an empty list of successes.
    2drop nil ;

TUPLE: and-parser parsers ;

: <&> ( parser1 parser2 -- parser )
    over and-parser? [
        >r and-parser-parsers r> add
    ] [
        2array
    ] if and-parser construct-boa ;

: <and-parser> ( parsers -- parser )
    dup length 1 = [ first ] [ and-parser construct-boa ] if ;

: and-parser-parse ( list p1  -- list )
    swap [
        dup parse-result-unparsed rot parse
        [
            >r parse-result-parsed r>
            [ parse-result-parsed 2array ] keep
            parse-result-unparsed <parse-result>
        ] lmap-with
    ] lmap-with lconcat ;

M: and-parser parse ( input parser -- list )
    #! Parse 'input' by sequentially combining the
    #! two parsers. First parser1 is applied to the
    #! input then parser2 is applied to the rest of
    #! the input strings from the first parser.
    and-parser-parsers unclip swapd parse
    [ [ and-parser-parse ] reduce ] 2curry promise ;

TUPLE: or-parser parsers ;

: <or-parser> ( parsers -- parser )
    dup length 1 = [ first ] [ or-parser construct-boa ] if ;

: <|> ( parser1 parser2 -- parser )
    2array <or-parser> ;

M: or-parser parse ( input parser1 -- list )
    #! Return the combined list resulting from the parses
    #! of parser1 and parser2 being applied to the same
    #! input. This implements the choice parsing operator.
    or-parser-parsers 0 swap seq>list
    [ parse ] lmap-with lconcat ;

: left-trim-slice ( string -- string )
    #! Return a new string without any leading whitespace
    #! from the original string.
    dup empty? [
        dup first blank? [ 1 tail-slice left-trim-slice ] when
    ] unless ;

TUPLE: sp-parser p1 ;

#! Return a parser that first skips all whitespace before
#! calling the original parser.
C: sp sp-parser ( p1 -- parser )

M: sp-parser parse ( input parser -- list )
    #! Skip all leading whitespace from the input then call
    #! the parser on the remaining input.
    >r left-trim-slice r> sp-parser-p1 parse ;

TUPLE: just-parser p1 ;

C: just just-parser ( p1 -- parser )

M: just-parser parse ( input parser -- result )
    #! Calls the given parser on the input removes
    #! from the results anything where the remaining
    #! input to be parsed is not empty. So ensures a
    #! fully parsed input string.
    just-parser-p1 parse [ parse-result-unparsed empty? ] lsubset ;

TUPLE: apply-parser p1 quot ;

C: <@ apply-parser ( parser quot -- parser )

M: apply-parser parse ( input parser -- result )
    #! Calls the parser on the input. For each successfull
    #! parse the quot is call with the parse result on the stack.
    #! The result of that quotation then becomes the new parse result.
    #! This allows modification of parse tree results (like
    #! converting strings to integers, etc).
    [ apply-parser-p1 ] keep apply-parser-quot
    -rot parse [
        [ parse-result-parsed swap call ] keep
        parse-result-unparsed <parse-result>
    ] lmap-with ;

TUPLE: some-parser p1 ;

C: some some-parser ( p1 -- parser )

M: some-parser parse ( input parser -- result )
    #! Calls the parser on the input, guarantees
    #! the parse is complete (the remaining input is empty),
    #! picks the first solution and only returns the parse
    #! tree since the remaining input is empty.
    some-parser-p1 just parse-1 ;

: <& ( parser1 parser2 -- parser )
    #! Same as <&> except discard the results of the second parser.
    <&> [ first ] <@ ;

: &> ( parser1 parser2 -- parser )
    #! Same as <&> except discard the results of the first parser.
    <&> [ second ] <@ ;

: <:&> ( parser1 parser2 -- result )
    #! Same as <&> except flatten the result.
    <&> [ first2 add ] <@ ;

: <&:> ( parser1 parser2 -- result )
    #! Same as <&> except flatten the result.
    <&> [ first2 swap add* ] <@ ;

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
    #! if that parser would be successfull.
    [ 1array ] <@ f succeed <|> ;

TUPLE: only-first-parser p1 ;

LAZY: only-first ( parser -- parser )
    only-first-parser construct-boa ;

M: only-first-parser parse ( input parser -- list )
    #! Transform a parser into a parser that only yields
    #! the first possibility.
    only-first-parser-p1 parse 1 swap ltake ;

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
    [ token ] 2apply swapd pack ;

: predicates>cond ( seq -- quot )
    #! Takes an array of quotation predicates/objects and makes a cond
    #! Makes a predicate of each obj like so:  [ dup obj = ]
    #! Leaves quotations alone
    #! The cond returns a boolean, t if one of the predicates matches
    [
        dup callable? [ [ = ] curry ] unless
        [ dup ] swap compose [ drop t ] 2array
    ] map { [ t ] [ drop f ] } add [ cond ] curry ;

GENERIC: parser>predicate ( obj -- quot )

M: satisfy-parser parser>predicate ( obj -- quot )
    satisfy-parser-quot ;

