! Copyright (C) 2010 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.

USING: assocs combinators grouping http.client http.download io
io.files.temp io.files.unique json kernel make sequences urls ;

IN: google.translate

CONSTANT: google-translate-url "https://ajax.googleapis.com/ajax/services/language/translate"

CONSTANT: maximum-translation-size 5120

: parameters>assoc ( text from to -- assoc )
    "|" glue [
        [ "q" ,, ] [ "langpair" ,, ] bi*
        "1.0" "v" ,,
    ] { } make ;

: assoc>query-response ( assoc -- response )
    google-translate-url http-post nip ;

TUPLE: response-error response error ;

: throw-response-error ( response -- * )
    [ ] [ "responseDetails" of ] bi response-error boa throw ;

: check-response ( response -- response )
    "responseStatus" over at {
        { 200 [ ] }
        { 400 [ throw-response-error ] }
        [ drop throw-response-error ]
    } case ;

: query-response>text ( response -- text )
    json> check-response
    "responseData" of
    "translatedText" of ;

: (translate) ( text from to -- text' )
    parameters>assoc
    assoc>query-response
    query-response>text ;

: translate ( text from to -- text' )
    [ maximum-translation-size group ] 2dip
    '[ _ _ (translate) ] map concat ;

:: translation-party ( text source target -- )
    text dup print [
        dup source target translate dup print
        target source translate dup print
        swap dupd = not
    ] loop drop ;

: translate-tts ( text -- file )
    "https://translate.google.com/translate_tts?tl=en" >url
    swap "q" set-query-param [
        "" ".mp3" unique-file download-as
    ] with-temp-directory ;

! Example:
! "dog" "en" "de" translate .
! "Hund"
