! Copyright (C) 2020 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors arrays ascii combinators
combinators.short-circuit help help.markup help.topics kernel
lexer math namespaces parser sequences splitting strings vectors
vocabs.parser words ;

IN: easy-help

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
        [ dup empty? not ]
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
                    dup ?first ".,;:" member? [
                        [ push-help-space ] dip
                    ] unless append!
                ] [
                    [ push-help-space ]
                    [ push-help-text ] bi*
                ] if
            ] when*
        ] keep
    ] loop [ >string suffix! ] unless-empty >array ; inline

<<
SYNTAX: HELP-TEXT:
    scan-new dup name>> but-last parse-word
    '[ parse-help-text _ prefix suffix! ] define-syntax ;
>>

HELP-TEXT: $description{
HELP-TEXT: $snippet{
HELP-TEXT: $emphasis{
HELP-TEXT: $strong{
HELP-TEXT: $url{
HELP-TEXT: $heading{
HELP-TEXT: $subheading{
HELP-TEXT: $code{
HELP-TEXT: $syntax{
HELP-TEXT: $class-description{
HELP-TEXT: $error-description{
HELP-TEXT: $var-description{
HELP-TEXT: $contract{
HELP-TEXT: $notes{
HELP-TEXT: $curious{
HELP-TEXT: $deprecated{
HELP-TEXT: $errors{
HELP-TEXT: $side-effects{
HELP-TEXT: $content{
HELP-TEXT: $slot{
HELP-TEXT: $image{

: parse-help-word ( -- str/obj/f )
    ?scan-token dup search {
        { [ dup \ f eq? pick "f" = and ] [ 2drop f ] }
        { [ dup parsing-word? ] [ nip V{ } clone swap execute-parsing first ] }
        { [ dup ] [ nip ] }
        [ drop ]
    } cond ;

: parse-help-words ( end -- seq )
    '[ parse-help-word dup _ eq? not ] [ ] produce nip ;

<<
SYNTAX: HELP-WORD:
    scan-new dup name>> but-last parse-word
    '[ \ } parse-help-words _ prefix suffix! ] define-syntax ;
>>



HELP-WORD: $subsection{
HELP-WORD: $subsections{
HELP-WORD: $link{
HELP-WORD: $links{
HELP-WORD: $vocab-link{
HELP-WORD: $vocab-links{
HELP-WORD: $instance{
HELP-WORD: $or{
HELP-WORD: $maybe{
HELP-WORD: $quotation{
HELP-WORD: $sequence{
HELP-WORD: $see-also{
HELP-WORD: $pretty-link{
HELP-WORD: $long-link{
HELP-WORD: $see{
HELP-WORD: $definition{
HELP-WORD: $value{
HELP-WORD: $methods{
HELP-WORD: $related{

<PRIVATE

: make-example ( str type -- seq )
    over string? [
        [ string-lines [ [ blank? ] trim ] map harvest ]
        [ prefix ] bi*
    ] [ drop ] if ;

: parse-help-examples ( -- seq )
    \ } parse-until [ \ $example make-example ] { } map-as ;

: parse-help-example ( -- seq )
    \ } parse-until dup { [ length 1 = ] [ first string? ] } 1&&
    [ first string-lines [ [ blank? ] trim ] map harvest ] when ;

PRIVATE>

SYNTAX: $examples{ parse-help-examples \ $examples prefix suffix! ;

SYNTAX: $example:
    scan-object \ $example make-example suffix! ;

SYNTAX: $unchecked-example:
    scan-object \ $unchecked-example make-example suffix! ;

<PRIVATE

: parse-help-values ( -- seq )
    [ scan-token dup "}" = not ] [
        dup "{" = [
            parse-datum dup parsing-word?
            [ V{ } clone swap execute-parsing first ] when
        ] [
            ":" ?tail drop scan-object 2array
        ] if
    ] produce nip ;

PRIVATE>

SYNTAX: $values{ parse-help-values \ $values prefix suffix! ;
SYNTAX: $inputs{ parse-help-values \ $inputs prefix suffix! ;
SYNTAX: $outputs{ parse-help-values \ $outputs prefix suffix! ;

! XXX: more syntax to consider

! HELP-SYNTAX: $markup-example{
! HELP-SYNTAX: $vocab-subsection{
! HELP-SYNTAX: $list{
! HELP-SYNTAX: $table{
! HELP-SYNTAX: $slots{
! HELP-SYNTAX: $references{
! HELP-SYNTAX: $effect{
! HELP-SYNTAX: $vocabulary{
! HELP-SYNTAX: $shuffle{
! HELP-SYNTAX: $complex-shuffle{
! HELP-SYNTAX: $low-level-note{
! HELP-SYNTAX: $values-x/y{
! HELP-SYNTAX: $parsing-note{
! HELP-SYNTAX: $io-error{
! HELP-SYNTAX: $prettyprinting-note{
! HELP-SYNTAX: $definition-icons{

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

<<
SYNTAX: HELP{
    scan-word dup \ } eq? [ drop { } ] [
        {
            { [ dup help-text? ] [ parse-help-text ] }
            { [ dup help-values? ] [ parse-help-values ] }
            { [ dup help-example? ] [ parse-help-example ] }
            { [ dup help-examples? ] [ parse-help-examples ] }
            [ \ } parse-until >array ]
        } cond swap prefix
    ] if suffix! ;
>>

! HELP{ $description something blah blah \ execute }

SYNTAX: EASY-HELP:
    H{ { "{" POSTPONE: HELP{ } } [
        scan-word bootstrap-word
        [ >link save-location ]
        [ [ parse-array-def ] dip set-word-help ] bi
    ] with-words ;
