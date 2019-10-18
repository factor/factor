! Copyright (C) 2005 Alex Chapman
! Copyright (C) 2006, 2007 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: embedded
USING: sequences kernel parser namespaces io html errors
math quotations generic strings ;

! See apps/http-server/test/ or libs/furnace/ for embedded usage
! examples

! We use a custom lexer so that %> ends a token even if not
! followed by whitespace
TUPLE: embedded-lexer ;

C: embedded-lexer ( lines -- lexer )
    swap <lexer> over set-delegate ;

M: embedded-lexer skip-word
    [
        {
            { [ 2dup nth CHAR: " = ] [ drop 1+ ] }
            { [ 2dup swap tail-slice "%>" head? ] [ drop 2 + ] }
            { [ t ] [ [ blank? ] skip ] }
        } cond
    ] change-column ;

DEFER: <% delimiter

: check-<% ( lexer -- col )
    "<%" over line-text rot lexer-column start* ;

: found-<% ( accum lexer col -- accum )
    [
        over line-text >r >r lexer-column r> r> subseq parsed
        \ write-html parsed
    ] 2keep 2 + swap set-lexer-column ;

: still-looking ( accum lexer -- accum )
    [
        dup line-text swap lexer-column tail
        parsed \ print-html parsed
    ] keep next-line ;

: parse-%> ( accum lexer -- accum )
    dup still-parsing? [
        dup check-<%
        [ found-<% ] [ [ still-looking ] keep parse-%> ] if*
    ] [
        drop
    ] if ;

: %> lexer get parse-%> ; parsing

: parse-embedded-lines ( lines -- quot )
    <embedded-lexer> [
        V{ } clone lexer get parse-%> f (parse-until)
    ] with-parser ;

: parse-embedded ( string -- quot )
    [
        use [ clone ] change
        "embedded" use+
        string-lines parse-embedded-lines
    ] with-scope ;

: eval-embedded ( string -- ) parse-embedded call ;

: run-embedded-file ( filename -- )
    [
        [
            file-vocabs
            check-shadowing off
            "embedded" use+
            dup file set ! so that reload works properly
            [ <file-reader> contents eval-embedded ] keep
        ] with-scope
    ] assert-depth drop ;

: embedded-convert ( infile outfile -- )
    <file-writer> [ run-embedded-file ] with-stream ;
