! Copyright (C) 2005 Alex Chapman
! Copyright (C) 2006, 2010 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators compiler.units html.templates io
io.encodings.utf8 io.files kernel lexer math namespaces parser
parser.notes quotations sequences splitting vocabs.parser ;
IN: html.templates.fhtml

! We use a custom lexer so that %> ends a token even if not
! followed by whitespace
TUPLE: template-lexer < lexer ;

: <template-lexer> ( lines -- lexer )
    template-lexer new-lexer ;

M: template-lexer skip-word
    [
        {
            { [ 2dup nth CHAR: \" = ] [ drop 1 + ] }
            { [ 2dup swap tail-slice "%>" head? ] [ drop 2 + ] }
            [ f skip ]
        } cond
    ] change-lexer-column ;

DEFER: <% delimiter

: check-<% ( lexer -- col )
    "<%" swap [ line-text>> ] [ column>> ] bi subseq-start-from ;

: found-<% ( accum lexer col -- accum )
    [
        over line-text>>
        [ column>> ] 2dip subseq suffix!
        \ write suffix!
    ] 2keep 2 + >>column drop ;

: still-looking ( accum lexer -- accum )
    [
        [ line-text>> ] [ column>> ] bi tail
        suffix! \ print suffix!
    ] keep next-line ;

: parse-%> ( accum lexer -- accum )
    dup still-parsing? [
        dup check-<%
        [ found-<% ] [ [ still-looking ] keep parse-%> ] if*
    ] [
        drop
    ] if ;

SYNTAX: %> lexer get parse-%> ;

: parse-template-lines ( lines -- quot )
    <template-lexer> [
        V{ } clone lexer get parse-%> f (parse-until) >quotation
    ] with-lexer ;

: parse-template ( string -- quot )
    [
        [
            parser-quiet? on
            "html.templates.fhtml" use-vocab
            string-lines parse-template-lines
        ] with-file-vocabs
    ] with-compilation-unit ;

: eval-template ( string -- )
    parse-template call( -- ) ;

TUPLE: fhtml path ;

C: <fhtml> fhtml

M: fhtml call-template* ( filename -- )
    path>> utf8 file-contents eval-template ;

INSTANCE: fhtml template
