! Copyright (C) 2005 Alex Chapman
! Copyright (C) 2006, 2007 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: sequences kernel parser namespaces io io.files
io.streams.lines io.streams.string html html.elements
source-files debugger combinators math quotations generic
strings splitting ;

IN: http.server.templating

: templating-vocab ( -- vocab-name ) "http.server.templating" ;

! See apps/http-server/test/ or libs/furnace/ for template usage
! examples

! We use a custom lexer so that %> ends a token even if not
! followed by whitespace
TUPLE: template-lexer ;

: <template-lexer> ( lines -- lexer )
    <lexer> template-lexer construct-delegate ;

M: template-lexer skip-word
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

: parse-template-lines ( lines -- quot )
    <template-lexer> [
        V{ } clone lexer get parse-%> f (parse-until)
    ] with-parser ;

: parse-template ( string -- quot )
    [
        use [ clone ] change
        templating-vocab use+
        string-lines parse-template-lines
    ] with-scope ;

: eval-template ( string -- ) parse-template call ;

: run-template-file ( filename -- )
    [
        [
            file-vocabs
            parser-notes off
            templating-vocab use+
            dup source-file file set ! so that reload works properly
            [
                ?resource-path <file-reader> contents
                eval-template
            ] keep
        ] with-scope
    ] assert-depth drop ;

: run-relative-template-file ( filename -- )
    file get source-file-path parent-dir
    swap path+ run-template-file ;

: template-convert ( infile outfile -- )
    <file-writer> [ run-template-file ] with-stream ;
