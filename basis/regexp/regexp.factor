! Copyright (C) 2008, 2009 Doug Coleman, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators kernel math sequences strings sets
assocs prettyprint.backend prettyprint.custom make lexer
namespaces parser arrays fry locals regexp.minimize
regexp.parser regexp.nfa regexp.dfa regexp.traversal
regexp.transition-tables splitting sorting regexp.ast
regexp.negation regexp.matchers regexp.compiler ;
IN: regexp

TUPLE: regexp
    { raw read-only }
    { parse-tree read-only }
    { options read-only }
    dfa reverse-dfa dfa-quot ;

: make-regexp ( string ast -- regexp )
    f f <options> f f f regexp boa ; foldable
    ! Foldable because, when the dfa slot is set,
    ! it'll be set to the same thing regardless of who sets it

: <optioned-regexp> ( string options -- regexp )
    [ dup parse-regexp ] [ string>options ] bi*
    f f f regexp boa ;

: <regexp> ( string -- regexp ) "" <optioned-regexp> ;

TUPLE: reverse-matcher regexp ;
C: <reverse-matcher> reverse-matcher

<PRIVATE

: get-ast ( regexp -- ast )
    [ parse-tree>> ] [ options>> ] bi <with-options> ;

: compile-regexp ( regexp -- regexp )
    dup '[ [ _ get-ast ast>dfa ] unless* ] change-dfa ;

: compile-dfa-quot ( regexp -- regexp )
    dup '[ [ _ compile-regexp dfa>> dfa>quotation ] unless* ] change-dfa-quot ;

: <reversed-option> ( ast -- reversed )
    "r" string>options <with-options> ;

: compile-reverse ( regexp -- regexp )
    dup '[ [ _ get-ast <reversed-option> ast>dfa ] unless* ] change-reverse-dfa ;

M: regexp match-index ( string regexp -- index/f )
    dup dfa-quot>>
    [ <quot-matcher> ]
    [ compile-regexp dfa>> <dfa-matcher> ] ?if
    match-index ;

M: reverse-matcher match-index ( string regexp -- index/f )
    [ <reversed> ] [ regexp>> compile-reverse reverse-dfa>> ] bi*
    <dfa-traverser> do-match match-index>> ;

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
    <optioned-regexp> compile-dfa-quot parsed ;

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
