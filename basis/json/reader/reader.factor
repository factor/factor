! Copyright (C) 2008 Peter Burns, 2009 Philipp Winkler
! See http://factorcode.org/license.txt for BSD license.
USING: assocs combinators fry io io.encodings.utf8 io.files
io.streams.string json kernel kernel.private math math.order
math.parser namespaces sbufs sequences sequences.private strings
vectors ;
IN: json.reader

<PRIVATE

ERROR: not-a-json-number string ;

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
        { ch'\" [ ch'\" ] }
        { ch'\\ [ ch'\\ ] }
        { ch'/ [ ch'/ ] }
        { ch'b [ ch'\b ] }
        { ch'f [ ch'\f ] }
        { ch'n [ ch'\n ] }
        { ch'r [ ch'\r ] }
        { ch't [ ch'\t ] }
        { ch'u [ over read-json-escape-unicode ] }
        [ ]
    } case [ suffix! (read-json-string) ] [ json-error ] if* ;

: (read-json-string) ( stream accum -- accum )
    { sbuf } declare
    "\\\"" pick stream-read-until [ append! ] dip
    ch'\" = [ nip ] [ (read-json-escape) ] if ;

: read-json-string ( stream -- str )
    "\\\"" over stream-read-until ch'\" =
    [ nip ] [ >sbuf (read-json-escape) { sbuf } declare "" like ] if ;

: second-last-unsafe ( seq -- second-last )
    [ length 2 - ] [ nth-unsafe ] bi ; inline

: pop-unsafe ( seq -- elt )
    [ length 1 - ] keep [ nth-unsafe ] [ shorten ] 2bi ; inline

: check-length ( seq n -- seq )
    [ dup length ] [ >= ] bi* [ json-error ] unless ; inline

: v-over-push ( accum -- accum )
    { vector } declare 2 check-length
    dup [ pop-unsafe ] [ last-unsafe ] bi
    { vector } declare push ;

: v-pick-push ( accum -- accum )
    { vector } declare 3 check-length dup
    [ pop-unsafe ] [ second-last-unsafe ] bi
    { vector } declare push ;

: v-pop ( accum -- vector )
    pop { vector } declare ; inline

: v-close ( accum -- accum )
    { vector } declare
    dup last V{ } = not [ v-over-push ] when
    { vector } declare ; inline

: json-open-array ( accum -- accum )
    { vector } declare V{ } clone suffix! ;

: json-open-hash ( accum -- accum )
    { vector } declare V{ } clone suffix! V{ } clone suffix! ;

: json-close-array ( accum -- accum )
    v-close dup v-pop { } like suffix! ;

: json-close-hash ( accum -- accum )
    v-close dup dup [ v-pop ] bi@ swap H{ } zip-as suffix! ;

: scan ( stream accum char -- stream accum )
    ! 2dup 1string swap . . ! Great for debug...
    { object vector object } declare
    {
        { ch'\" [ over read-json-string suffix! ] }
        { ch'\[  [ json-open-array ] }
        { ch',  [ v-over-push ] }
        { ch'\]  [ json-close-array ] }
        { ch'\{  [ json-open-hash ] }
        { ch'\:  [ v-pick-push ] }
        { ch'\}  [ json-close-hash ] }
        { ch'\s [ ] }
        { ch'\t [ ] }
        { ch'\r [ ] }
        { ch'\n [ ] }
        { ch't  [ "rue" pick json-expect t suffix! ] }
        { ch'f  [ "alse" pick json-expect f suffix! ] }
        { ch'n  [ "ull" pick json-expect json-null suffix! ] }
        [ pick json-number [ suffix! ] dip [ scan ] when*  ]
    } case ;

: json-read-input ( stream -- objects )
    V{ } clone over '[ _ stream-read1 dup ] [ scan ] while drop nip ;

! If there are no json objects, return an empty hashtable
! This happens for empty files.
: first-json-object ( objects -- obj )
    [ H{ } clone ] [ first ] if-empty ;

PRIVATE>

: read-json-objects ( -- objects )
    input-stream get json-read-input ;

GENERIC: json> ( string -- object )

M: string json>
    [ read-json-objects first-json-object ] with-string-reader ;

: path>json ( path -- json )
    utf8 [ read-json-objects first-json-object ] with-file-reader ;
