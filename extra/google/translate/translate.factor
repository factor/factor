! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs combinators fry grouping http.client io
json.reader kernel locals namespaces sequences ;
IN: google.translate

CONSTANT: google-translate-url "http://ajax.googleapis.com/ajax/services/language/translate"

CONSTANT: maximum-translation-size 5120

: parameters>assoc ( text from to -- assoc )
    "|" glue [
        [ "q" ,, ] [ "langpair" ,, ] bi*
        "1.0" "v" ,,
    ] { } make ;

: assoc>query-response ( assoc -- response )
    google-translate-url http-post nip ;

ERROR: response-error response error ;

: throw-response-error ( response -- * )
    "responseDetails" over at response-error ;

: check-response ( response -- response )
    "responseStatus" over at {
        { 200 [ ] }
        { 400 [ throw-response-error ] }
        [ drop throw-response-error ]
    } case ;

: query-response>text ( response -- text )
    json> check-response
    "responseData" swap at
    "translatedText" swap at ;

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

! Example:
! "dog" "en" "de" translate .
! "Hund"
