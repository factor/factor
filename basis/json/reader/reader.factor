! Copyright (C) 2008 Peter Burns, 2009 Philipp Winkler
! See https://factorcode.org/license.txt for BSD license.
USING: assocs combinators io io.encodings.utf8 io.files
io.streams.string json kernel kernel.private math math.order
math.parser namespaces sbufs sequences sequences.private strings ;
IN: json.reader

<PRIVATE

ERROR: not-a-json-number string ;

SYMBOL: json-depth

: json-number ( char stream -- num char )
    [ 1string ] [ "\s\t\r\n,:}]" swap stream-read-until ] bi*
    [
        append {
            { "Infinity" [ 1/0. ] }
            { "-Infinity" [ -1/0. ] }
            { "NaN" [ 0/0. ] }
            [ dup string>number [ ] [ not-a-json-number ] ?if ]
        } case
    ] dip ;

: json-expect ( token stream -- )
    [ dup length ] [ stream-read ] bi* = [ json-error ] unless ; inline

DEFER: (read-json-string)

: decode-utf16-surrogate-pair ( hex1 hex2 -- char )
    [ 0x3ff bitand ] bi@ [ 10 shift ] dip bitor 0x10000 + ;

: stream-read-4hex ( stream -- hex ) 4 swap stream-read hex> ;

: first-surrogate? ( hex -- ? ) 0xd800 0xdbff between? ;

: read-second-surrogate ( stream -- hex )
    "\\u" over json-expect stream-read-4hex ;

: read-json-escape-unicode ( stream -- char )
    [ stream-read-4hex ] keep over first-surrogate? [
        read-second-surrogate decode-utf16-surrogate-pair
    ] [ drop ] if ;

: (read-json-escape) ( stream accum -- accum )
    { sbuf } declare
    over stream-read1 {
        { CHAR: \" [ CHAR: \" ] }
        { CHAR: \\ [ CHAR: \\ ] }
        { CHAR: / [ CHAR: / ] }
        { CHAR: b [ CHAR: \b ] }
        { CHAR: f [ CHAR: \f ] }
        { CHAR: n [ CHAR: \n ] }
        { CHAR: r [ CHAR: \r ] }
        { CHAR: t [ CHAR: \t ] }
        { CHAR: u [ over read-json-escape-unicode ] }
        [ ]
    } case [ suffix! (read-json-string) ] [ json-error ] if* ;

: (read-json-string) ( stream accum -- accum )
    { sbuf } declare
    "\\\"" pick stream-read-until [ append! ] dip
    CHAR: \" = [ nip ] [ (read-json-escape) ] if ;

: read-json-string ( stream -- str )
    "\\\"" over stream-read-until CHAR: \" =
    [ nip ] [ >sbuf (read-json-escape) "" like ] if ;

: second-last-unsafe ( seq -- second-last )
    [ length 2 - ] [ nth-unsafe ] bi ; inline

: pop-unsafe ( seq -- elt )
    index-of-last [ nth-unsafe ] [ shorten ] 2bi ; inline

: check-length ( seq n -- seq )
    [ dup length ] [ >= ] bi* [ json-error ] unless ; inline

: v-over-push ( accum -- accum )
    2 check-length dup [ pop-unsafe ] [ last-unsafe ] bi push ;

: v-pick-push ( accum -- accum )
    3 check-length dup [ pop-unsafe ] [ second-last-unsafe ] bi push ;

: v-close ( accum -- accum )
    dup last V{ } = not [ v-over-push ] when ;

: json-open-array ( accum -- accum )
    V{ } clone suffix! ;

: json-open-hash ( accum -- accum )
    V{ } clone suffix! V{ } clone suffix! ;

: json-close-array ( accum -- accum )
    v-close dup pop { } like suffix! ;

: json-close-hash ( accum -- accum )
    v-close dup dup [ pop ] bi@ swap H{ } zip-as suffix! ;

: scan ( stream accum char -- stream accum )
    ! 2dup 1string swap . . ! Great for debug...
    {
        { CHAR: \" [ over read-json-string suffix! ] }
        { CHAR: [  [ 1 json-depth +@ json-open-array ] }
        { CHAR: ,  [ v-over-push ] }
        { CHAR: ]  [ -1 json-depth +@ json-close-array ] }
        { CHAR: {  [ json-open-hash ] }
        { CHAR: :  [ v-pick-push ] }
        { CHAR: }  [ json-close-hash ] }
        { CHAR: \s [ ] }
        { CHAR: \t [ ] }
        { CHAR: \r [ ] }
        { CHAR: \n [ ] }
        { CHAR: t  [ "rue" pick json-expect t suffix! ] }
        { CHAR: f  [ "alse" pick json-expect f suffix! ] }
        { CHAR: n  [ "ull" pick json-expect json-null suffix! ] }
        [ pick json-number [ suffix! ] dip [ scan ] when*  ]
    } case ;

: json-read-input ( stream -- objects )
    0 json-depth [
        V{ } clone over '[ _ stream-read1 ] [ scan ] while* nip
        json-depth get zero? [ json-error ] unless
    ] with-variable ;

: get-json ( objects  --  obj )
    dup length 1 = [ first ] [ json-error ] if ;

PRIVATE>

: read-json ( -- objects )
    input-stream get json-read-input ;

GENERIC: json> ( string -- object )

M: string json>
    [ read-json get-json ] with-string-reader ;

: path>json ( path -- json )
    utf8 [ read-json get-json ] with-file-reader ;

: path>jsons ( path -- jsons )
    utf8 [ read-json ] with-file-reader ;
