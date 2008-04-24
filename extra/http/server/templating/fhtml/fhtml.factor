! Copyright (C) 2005 Alex Chapman
! Copyright (C) 2006, 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: continuations sequences kernel namespaces debugger
combinators math quotations generic strings splitting
accessors assocs fry
parser io io.files io.streams.string io.encodings.utf8 source-files
html html.elements
http.server.static http.server http.server.templating ;
IN: http.server.templating.fhtml

: templating-vocab ( -- vocab-name ) "http.server.templating.fhtml" ;

! We use a custom lexer so that %> ends a token even if not
! followed by whitespace
TUPLE: template-lexer < lexer ;

: <template-lexer> ( lines -- lexer )
    template-lexer new-lexer ;

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

TUPLE: fhtml path ;

C: <fhtml> fhtml

M: fhtml call-template* ( filename -- )
    '[
        , path>> [
            "quiet" on
            parser-notes off
            templating-vocab use+
            ! so that reload works properly
            dup source-file file set
            utf8 file-contents
            [ eval-template ] [ html-error. drop ] recover
        ] with-file-vocabs
    ] assert-depth ;

! file responder integration
: enable-fhtml ( responder -- responder )
    [ <fhtml> serve-template ]
    "application/x-factor-server-page"
    pick special>> set-at ;

INSTANCE: fhtml template
