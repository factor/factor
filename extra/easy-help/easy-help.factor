! Copyright (C) 2020 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors arrays ascii combinators help.markup kernel
lexer math namespaces parser sequences splitting strings vectors
vocabs.parser words ;

IN: easy-help

:: parse-help-token ( end -- str/obj/f )
    ?scan-token dup search {
        { [ dup end eq? ] [ 2drop f ] }
        { [ dup parsing-word? ] [
            nip V{ } clone swap execute-parsing first
            dup wrapper? [ wrapped>> \ $link swap 2array ] when ] }
        [ drop ]
    } cond ;

:: parse-help-text ( end -- seq )
    V{ } clone SBUF" " clone [
        lexer get line>> end parse-help-token
        [ lexer get line>> swap - 1 > [ CHAR: \n suffix! ] when ] dip
        [
            [
                [
                    2dup [ empty? ] both? not
                    over ?last CHAR: \n eq? not and
                    [ CHAR: \s suffix! ] when
                ] [
                    dup string? [ append! ] [
                        [ dup empty? [ >string suffix! SBUF" " clone ] unless ]
                        [ [ suffix! ] curry dip ] bi*
                    ] if
                ] bi*
            ] when*
        ] keep
    ] loop [ >string suffix! ] unless-empty >array ; inline

<<
SYNTAX: HELP-TEXT:
    scan-new dup name>> but-last parse-word
    '[ \ } parse-help-text _ prefix suffix! ] define-syntax ;
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

PRIVATE>

SYNTAX: $examples{
    \ } [
        [ \ $example make-example ] { } map-as \ $examples prefix
    ] parse-literal ;

SYNTAX: $example:
    scan-object \ $example make-example suffix! ;

SYNTAX: $unchecked-example:
    scan-object \ $unchecked-example make-example suffix! ;

<PRIVATE

: parse-values ( -- seq )
    [ scan-token dup "}" = not ]
    [ ":" ?tail drop scan-object 2array ] produce nip ;

PRIVATE>

SYNTAX: $values{ parse-values \ $values prefix suffix! ;
SYNTAX: $inputs{ parse-values \ $inputs prefix suffix! ;
SYNTAX: $outputs{ parse-values \ $outputs prefix suffix! ;

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

<<
SYNTAX: HELP{
        scan-word dup \ } eq?
        [ drop { } ] [ \ } parse-help-text swap prefix ] if suffix! ;
>>

! HELP{ $description something blah blah \ execute }
