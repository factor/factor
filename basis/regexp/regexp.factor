! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators kernel math sequences strings sets
assocs prettyprint.backend prettyprint.custom make lexer
namespaces parser arrays fry regexp.backend regexp.utils
regexp.parser regexp.nfa regexp.dfa regexp.traversal
regexp.transition-tables splitting sorting ;
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
        H{ } clone >>matchers
        reset-regexp ;

: construct-regexp ( regexp -- regexp' )
    {
        [ parse-regexp ]
        [ construct-nfa ]
        [ construct-dfa ]
        [ ]
    } cleave ;

: (match) ( string regexp -- dfa-traverser )
    <dfa-traverser> do-match ; inline

: match ( string regexp -- slice/f )
    (match) return-match ;

: match* ( string regexp -- slice/f captured-groups )
    (match) [ return-match ] [ captured-groups>> ] bi ;

: matches? ( string regexp -- ? )
    dupd match
    [ [ length ] bi@ = ] [ drop f ] if* ;

: match-head ( string regexp -- end/f ) match [ length ] [ f ] if* ;

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

: first-match ( string regexp -- slice/f )
    dupd 0 swap match-range rot over [ <slice> ] [ 3drop f ] if ;

: re-cut ( string regexp -- end/f start )
    dupd first-match
    [ split1-slice swap ] [ "" like f swap ] if* ;

: (re-split) ( string regexp -- )
    over [ [ re-cut , ] keep (re-split) ] [ 2drop ] if ;

: re-split ( string regexp -- seq )
    [ (re-split) ] { } make ;

: re-replace ( string regexp replacement -- result )
    [ re-split ] dip join ;

: next-match ( string regexp -- end/f match/f )
    dupd first-match dup
    [ [ split1-slice nip ] keep ] [ 2drop f f ] if ;

: all-matches ( string regexp -- seq )
    [ dup ] swap '[ _ next-match ] produce nip harvest ;

: count-matches ( string regexp -- n )
    all-matches length ;

<PRIVATE

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

: string>options ( string -- options )
    [ ch>option dup ] H{ } map>assoc ;

: options>string ( options -- string )
    keys [ option>ch ] map natural-sort >string ;

PRIVATE>

: <optioned-regexp> ( string option-string -- regexp )
    [ default-regexp ] [ string>options ] bi* >>options
    construct-regexp ;

: <regexp> ( string -- regexp ) "" <optioned-regexp> ;

<PRIVATE

: parsing-regexp ( accum end -- accum )
    lexer get dup skip-blank
    [ [ index-from dup 1+ swap ] 2keep swapd subseq swap ] change-lexer-column
    lexer get dup still-parsing-line?
    [ (parse-token) ] [ drop f ] if
    <optioned-regexp> parsed ;

PRIVATE>

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

M: regexp pprint*
    [
        [
            [ raw>> dup find-regexp-syntax swap % swap % % ]
            [ options>> options>string % ] bi
        ] "" make
    ] keep present-text ;
