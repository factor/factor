! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays ascii combinators
combinators.short-circuit compiler.units definitions help
help.markup help.topics kernel lexer math namespaces parser
sequences splitting strings vocabs.parser words ;
IN: help.syntax

<PRIVATE

:: parse-help-token ( -- str/obj/f )
    ?scan-token dup search {
        { [ dup \ } eq? ] [ 2drop f ] }
        { [ dup parsing-word? ] [
            nip V{ } clone swap execute-parsing first
            dup wrapper? [ wrapped>> \ $link swap 2array ] when ] }
        [ drop ]
    } cond ;

: push-help-text ( accum sbuf obj -- accum sbuf' )
    [ dup empty? [ >string suffix! SBUF" " clone ] unless ]
    [ [ suffix! ] curry dip ] bi* ;

: push-help-space ( accum sbuf -- accum sbuf )
    {
        [ dup empty? not over ?last CHAR: \s eq? not and ]
        [ over empty? not pick ?last \ $nl eq? not and ]
    } 0|| [ CHAR: \s suffix! ] when ;

:: parse-help-text ( -- seq )
    V{ } clone SBUF" " clone [
        lexer get line>> parse-help-token [
            lexer get line>> swap - 1 > [
                \ $nl push-help-text
            ] when
        ] dip [
            [
                dup string? [
                    dup ?first " .,;:" member? [
                        [ push-help-space ] dip
                    ] unless append!
                ] [
                    [ push-help-space ]
                    [ push-help-text ] bi*
                ] if
            ] when*
        ] keep
    ] loop [ >string suffix! ] unless-empty >array ; inline

: parse-help-values ( -- seq )
    [ scan-token dup "}" = not ] [
        dup "{" = [
            drop \ } parse-until >array
        ] [
            ":" ?tail drop scan-object 2array
        ] if
    ] produce nip ;

: example-lines ( seq -- seq' )
    dup string? [ string-lines [ [ blank? ] trim ] map harvest ] when ;

: make-example ( str type -- seq )
    over string? [
        [ example-lines ] [ prefix ] bi*
    ] [ drop ] if ;

: parse-help-examples ( -- seq )
    \ } parse-until [ \ $example make-example ] { } map-as ;

: parse-help-example ( -- seq )
    \ } parse-until dup { [ length 1 = ] [ first string? ] } 1&&
    [ first example-lines ] [ >array ] if ;

: help-text? ( word -- ? )
    {
        $description $snippet $emphasis $strong $url $heading
        $subheading $code $syntax $class-description
        $error-description $var-description $contract $notes
        $curious $deprecated $errors $side-effects $content
        $slot $image
    } member-eq? ;

: help-values? ( word -- ? )
    { $values $inputs $outputs } member-eq? ;

: help-examples? ( word -- ? )
    { $examples } member-eq? ;

: help-example? ( word -- ? )
    { $example $unchecked-example } member-eq? ;

PRIVATE>

SYNTAX: HELP{
    scan-object dup \ } eq? [ drop { } ] [
        {
            { [ dup help-text? ] [ parse-help-text ] }
            { [ dup help-values? ] [ parse-help-values ] }
            { [ dup help-example? ] [ parse-help-example ] }
            { [ dup help-examples? ] [ parse-help-examples ] }
            [ \ } parse-until >array ]
        } cond swap prefix
    ] if suffix! ;

SYNTAX: HELP:
    H{ { "{" POSTPONE: HELP{ } } [
        scan-word bootstrap-word
        [ >link save-location ]
        [ [ parse-array-def ] dip set-word-help ]
        bi
    ] with-words ;

ERROR: article-expects-name-and-title got ;

SYNTAX: ARTICLE:
    location [
        parse-array-def
        dup length 2 < [ article-expects-name-and-title ] when
        [ first2 ] [ 2 tail ] bi <article>
        over add-article >link
    ] dip remember-definition ;

SYNTAX: ABOUT:
    current-vocab scan-object >>help changed-definition ;
