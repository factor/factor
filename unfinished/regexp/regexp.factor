! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators kernel math math.ranges
sequences regexp.backend regexp.utils memoize sets
regexp.parser regexp.nfa regexp.dfa regexp.traversal
regexp.transition-tables assocs prettyprint.backend
make lexer namespaces parser ;
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

: matches? ( string regexp -- ? )
    dupd match
    [ [ length ] [ length>> 1- ] bi* = ] [ drop f ] if* ;

: match-head ( string regexp -- end ) match length>> 1- ;

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
