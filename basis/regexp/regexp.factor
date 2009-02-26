! Copyright (C) 2008, 2009 Doug Coleman, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators kernel math sequences strings sets
assocs prettyprint.backend prettyprint.custom make lexer
namespaces parser arrays fry locals regexp.minimize
regexp.parser regexp.nfa regexp.dfa regexp.traversal
regexp.transition-tables splitting sorting regexp.ast
regexp.negation ;
IN: regexp

TUPLE: regexp
    { raw read-only }
    { parse-tree read-only }
    { options read-only }
    dfa reverse-dfa ;

: make-regexp ( string ast -- regexp )
    f f <options> f f regexp boa ; foldable
    ! Foldable because, when the dfa slot is set,
    ! it'll be set to the same thing regardless of who sets it

: <optioned-regexp> ( string options -- regexp )
    [ dup parse-regexp ] [ string>options ] bi*
    f f regexp boa ;

: <regexp> ( string -- regexp ) "" <optioned-regexp> ;

<PRIVATE

: get-ast ( regexp -- ast )
    [ parse-tree>> ] [ options>> ] bi <with-options> ;

: compile-regexp ( regexp -- regexp )
    dup '[ [ _ get-ast ast>dfa ] unless* ] change-dfa ;

: <reversed-option> ( ast -- reversed )
    "r" string>options <with-options> ;

: compile-reverse ( regexp -- regexp )
    dup '[ [ _ get-ast <reversed-option> ast>dfa ] unless* ] change-reverse-dfa ;

: (match) ( string regexp -- dfa-traverser )
    compile-regexp dfa>> <dfa-traverser> do-match ;

: (match-reversed) ( string regexp -- dfa-traverser )
    [ <reversed> ] [ compile-reverse reverse-dfa>> ] bi*
    <dfa-traverser> do-match ;

PRIVATE>

: match ( string regexp -- slice/f )
    (match) return-match ;

: match-from-end ( string regexp -- slice/f )
    (match-reversed) return-match ;

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

<PRIVATE

: (re-split) ( string regexp -- )
    over [ [ re-cut , ] keep (re-split) ] [ 2drop ] if ;

PRIVATE>

: re-split ( string regexp -- seq )
    [ (re-split) ] { } make ;

: re-replace ( string regexp replacement -- result )
    [ re-split ] dip join ;

: next-match ( string regexp -- end/f match/f )
    dupd first-match dup
    [ [ split1-slice nip ] keep ] [ 2drop f f ] if ;

: all-matches ( string regexp -- seq )
    [ dup ] swap '[ _ next-match ] [ ] produce nip harvest ;

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

: take-until ( end lexer -- string )
    dup skip-blank [
        [ index-from ] 2keep
        [ swapd subseq ]
        [ 2drop 1+ ] 3bi
    ] change-lexer-column ;

: parse-noblank-token ( lexer -- str/f )
    dup still-parsing-line? [ (parse-token) ] [ drop f ] if ;

: parsing-regexp ( accum end -- accum )
    lexer get [ take-until ] [ parse-noblank-token ] bi
    <optioned-regexp> compile-regexp parsed ;

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
