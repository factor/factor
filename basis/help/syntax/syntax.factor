! Copyright (C) 2005, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors arrays ascii combinators
combinators.short-circuit compiler.units definitions help
help.markup help.topics kernel lexer math math.order namespaces
parser sequences splitting strings strings.parser vocabs.parser
words ;

IN: help.syntax

DEFER: HELP{

<PRIVATE

:: parse-help-token ( end -- str/obj/f literal? )
    ?scan-token dup {
        [ "{" = [ \ HELP{ ] [ f ] if ]
        [ "syntax" lookup-word ]
        [ { [ "$" head? ] [ "help.markup" lookup-word ] } 1&& ]
        [ dup ?last ":{[(/\"" member-eq? [ search ] [ drop f ] if ]
    } 1|| {
        { [ dup not ] [ drop f ] }
        { [ dup end eq? ] [ 2drop f f ] }
        { [ dup parsing-word? ] [
            [
                nip V{ } clone swap execute-parsing first
                dup wrapper? [ wrapped>> \ $link swap 2array ] when
            ] keep \ " = ] }
        { [ dup ] [ nip f ] }
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

: ?push-help-space ( accum sbuf obj -- accum sbuf' obj )
    over empty? [
        pick [ f ] [
            last dup array? [ ?first ] when help-block? not
        ] if-empty
    ] [
        over last " (" member? not
    ] if
    over string? [ over ?first " .,;:)" member? not and ] when
    [ [ CHAR: \s suffix! ] dip ] when ;

:: parse-help-text ( end -- seq )
    V{ } clone SBUF" " clone [
        lexer get line>> :> m
        end parse-help-token :> ( obj literal? )
        lexer get line>> :> n

        obj string? n m - 1 > and [
            { [ dup empty? not ] [ over ?last string? ] } 0||
            [ \ $nl push-help-text ] when
        ] when

        obj [
            [
                literal? [ ?push-help-space ] unless
                dup string? not literal? or
                [ push-help-text ] [ append! ] if
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

: whitespace ( seq -- n )
    [ [ blank? ] all? ] reject [ 0 ] [
        [ [ blank? not ] find drop ] [ min ] map-reduce
    ] if-empty ;

: trim-whitespace ( seq -- seq' )
    dup rest-slice dup whitespace
    [ '[ _ index-or-length tail ] map! ] unless-zero drop
    0 over [ [ blank? ] trim-head ] change-nth ;

: code-lines ( str -- seq )
    split-lines trim-whitespace [ [ blank? ] all? ] trim ;

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
        $description $snippet $emphasis $strong $heading
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
