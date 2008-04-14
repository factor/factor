! Copyright (C) 2005 Alex Chapman
! Copyright (C) 2006, 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: continuations sequences kernel parser namespaces io
io.files io.streams.string html html.elements source-files
debugger combinators math quotations generic strings splitting
accessors http.server.static http.server assocs
io.encodings.utf8 fry accessors ;

IN: http.server.templating.fhtml

: templating-vocab ( -- vocab-name ) "http.server.templating.fhtml" ;

! We use a custom lexer so that %> ends a token even if not
! followed by whitespace
TUPLE: template-lexer < lexer ;

: <template-lexer> ( lines -- lexer )
    template-lexer construct-lexer ;

M: template-lexer skip-word
    [
        {
            { [ 2dup nth CHAR: " = ] [ drop 1+ ] }
            { [ 2dup swap tail-slice "%>" head? ] [ drop 2 + ] }
            [ f skip ]
        } cond
    ] change-lexer-column ;

DEFER: <% delimiter

: check-<% ( lexer -- col )
    "<%" over line-text>> rot column>> start* ;

: found-<% ( accum lexer col -- accum )
    [
        over line-text>>
        >r >r column>> r> r> subseq parsed
        \ write-html parsed
    ] 2keep 2 + >>column drop ;

: still-looking ( accum lexer -- accum )
    [
        [ line-text>> ] [ column>> ] bi tail
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

: html-error. ( error -- )
    <pre> error. </pre> ;

: run-template ( filename -- )
    '[
        , [
            "quiet" on
            parser-notes off
            templating-vocab use+
            ! so that reload works properly
            dup source-file file set
            utf8 file-contents
            [ eval-template ] [ html-error. drop ] recover
        ] with-file-vocabs
    ] assert-depth ;

: template-convert ( infile outfile -- )
    utf8 [ run-template ] with-file-writer ;

! responder integration
: serve-template ( name -- response )
    "text/html" <content>
    swap '[ , run-template ] >>body ;

! file responder integration
: enable-fhtml ( responder -- responder )
    [ serve-template ]
    "application/x-factor-server-page"
    pick special>> set-at ;
