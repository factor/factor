! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators kernel math math.ranges sequences
sets assocs prettyprint.backend make lexer namespaces parser
arrays fry regexp.backend regexp.utils regexp.parser regexp.nfa
regexp.dfa regexp.traversal regexp.transition-tables ;
IN: regexp

: default-regexp ( string -- regexp )
    regexp new
        swap >>raw
        <transition-table> >>nfa-table
        <transition-table> >>dfa-table
        <transition-table> >>minimized-table
        H{ } clone >>nfa-traversal-flags
        H{ } clone >>dfa-traversal-flags
        H{ } clone >>options
        reset-regexp ;

: construct-regexp ( regexp -- regexp' )
    {
        [ parse-regexp ]
        [ construct-nfa ]
        [ construct-dfa ]
        [ ]
    } cleave ;

: match ( string regexp -- pair )
    <dfa-traverser> do-match return-match ;

: match* ( string regexp -- pair )
    <dfa-traverser> do-match [ return-match ] [ captured-groups>> ] bi ;

: matches? ( string regexp -- ? )
    dupd match
    [ [ length ] [ length>> 1- ] bi* = ] [ drop f ] if* ;

: match-head ( string regexp -- end/f ) match [ length>> 1- ] [ f ] if* ;

: match-at ( string m regexp -- n/f finished? )
    [
        2dup swap length > [ 2drop f f ] [ tail-slice t ] if
    ] dip swap [ match-head f ] [ 2drop f t ] if ;

: match-range ( string m regexp -- a/f b/f )
    3dup match-at over [
        drop nip rot drop dupd +
    ] [
        [ 3drop drop f f ] [ drop [ 1+ ] dip match-range ] if
    ] if ;

: first-match ( string regexp -- pair/f )
    0 swap match-range dup [ 2array ] [ 2drop f ] if ;

: re-cut ( string regexp -- end/f start )
    dupd first-match
    [ [ second tail-slice ] [ first head ] 2bi ]
    [ "" like f swap ]
    if* ;

: re-split ( string regexp -- seq )
    [ dup ] swap '[ _ re-cut ] [ ] produce nip ;

: re-replace ( string regexp replacement -- result )
    [ re-split ] dip join ;

: next-match ( string regexp -- end/f match/f )
    dupd first-match dup
    [ [ second tail-slice ] keep ]
    [ 2drop f f ]
    if ;

: all-matches ( string regexp -- seq )
    [ dup ] swap '[ _ next-match ] [ ] produce nip ;

: count-matches ( string regexp -- n )
    all-matches length 1- ;

: initial-option ( regexp option -- regexp' )
    over options>> conjoin ;

: <regexp> ( string -- regexp )
    default-regexp construct-regexp ;

: <iregexp> ( string -- regexp )
    default-regexp
    case-insensitive initial-option
    construct-regexp ;

: <rregexp> ( string -- regexp )
    default-regexp
    reversed-regexp initial-option
    construct-regexp ;

: parsing-regexp ( accum end -- accum )
    lexer get dup skip-blank
    [ [ index-from dup 1+ swap ] 2keep swapd subseq swap ] change-lexer-column
    lexer get dup still-parsing-line?
    [ (parse-token) ] [ drop f ] if
    "i" = [ <iregexp> ] [ <regexp> ] if parsed ;

: R! CHAR: ! parsing-regexp ; parsing
: R" CHAR: " parsing-regexp ; parsing
: R# CHAR: # parsing-regexp ; parsing
: R' CHAR: ' parsing-regexp ; parsing
: R( CHAR: ) parsing-regexp ; parsing
: R/ CHAR: / parsing-regexp ; parsing
: R@ CHAR: @ parsing-regexp ; parsing
: R[ CHAR: ] parsing-regexp ; parsing
: R` CHAR: ` parsing-regexp ; parsing
: R{ CHAR: } parsing-regexp ; parsing
: R| CHAR: | parsing-regexp ; parsing

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

: option? ( option regexp -- ? )
    options>> key? ;

USE: multiline
/*
M: regexp pprint*
    [
        [
            dup raw>>
            dup find-regexp-syntax swap % swap % %
            case-insensitive swap option? [ "i" % ] when
        ] "" make
    ] keep present-text ;
*/
