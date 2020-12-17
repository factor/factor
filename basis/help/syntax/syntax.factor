! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays ascii combinators
combinators.short-circuit compiler.units definitions help
help.markup help.topics kernel lexer math namespaces parser
sequences splitting strings strings.parser vocabs.parser words ;
IN: help.syntax

<PRIVATE

:: parse-help-token ( end -- str/obj/f )
    ?scan-token dup {
        [ "syntax" lookup-word ]
        [ "help.markup" lookup-word ]
        [ dup ?last ":{[(/\"" member-eq? [ search ] [ drop f ] if ]
    } 1|| {
        { [ dup not ] [ drop ] }
        { [ dup end eq? ] [ 2drop f ] }
        { [ dup parsing-word? ] [
            nip V{ } clone swap execute-parsing first
            dup wrapper? [ wrapped>> \ $link swap 2array ] when ] }
        { [ dup ] [ nip ] }
    } cond ;

: push-help-text ( accum sbuf obj -- accum sbuf' )
    [ dup empty? [ >string suffix! SBUF" " clone ] unless ]
    [ [ suffix! ] curry dip ] bi* ;

: help-block? ( word -- ? )
    {
        $description $heading $subheading $syntax
        $class-description $error-description $var-description
        $contract $notes $curious $deprecated $errors
        $side-effects $content $warning $subsections $nl
        $list $table $example $unchecked-example $code
    } member-eq? ;

: push-help-space ( accum sbuf -- accum sbuf )
    dup empty? [
        over empty? not
        pick ?last dup array? [ ?first ] when
        help-block? not and
    ] [
        dup last CHAR: \s eq? not
    ] if [ CHAR: \s suffix! ] when ;

:: parse-help-text ( end -- seq )
    V{ } clone SBUF" " clone [
        lexer get line>> :> m
        end parse-help-token :> obj
        lexer get line>> :> n

        obj string? n m - 1 > and [
            { [ dup empty? not ] [ over ?last string? ] } 0||
            [ \ $nl push-help-text ] when
        ] when

        obj [
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

: code-lines ( str -- seq )
    string-lines [ [ blank? ] trim ] map harvest ;

: make-example ( str -- seq )
    code-lines dup { [ array? ] [ length 1 > ] } 1&& [
        dup length 1 - over [ unescape-string ] change-nth
        \ $example prefix
    ] when ;

: parse-help-examples ( -- seq )
    \ } parse-until dup [ string? ] all?
    [ [ make-example ] { } map-as ] [ >array ] if ;

: parse-help-code ( -- seq )
    \ } parse-until dup { [ length 1 = ] [ first string? ] } 1&&
    [ first code-lines ] [ >array ] if ;

: help-text? ( word -- ? )
    {
        $description $snippet $emphasis $strong $url $heading
        $subheading $syntax $class-description
        $error-description $var-description $contract $notes
        $curious $deprecated $errors $side-effects $content
        $slot $image $warning
    } member-eq? ;

: help-code? ( word -- ? )
    { $example $unchecked-example $code } member-eq? ;

: help-values? ( word -- ? )
    { $values $inputs $outputs } member-eq? ;

: help-examples? ( word -- ? )
    { $examples } member-eq? ;

PRIVATE>

SYNTAX: HELP{
    scan-object dup \ } eq? [ drop { } ] [
        {
            { [ dup help-text? ] [ \ } parse-help-text ] }
            { [ dup help-code? ] [ parse-help-code ] }
            { [ dup help-values? ] [ parse-help-values ] }
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

SYNTAX: ARTICLE:
    location [
        scan-object scan-object
        \ ; parse-help-text <article>
        over add-article >link
    ] dip remember-definition ;

SYNTAX: ABOUT:
    current-vocab scan-object >>help changed-definition ;
