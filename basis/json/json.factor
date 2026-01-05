! Copyright (C) 2006 Chris Double, 2008 Peter Burns, 2009 Philipp Winkler

USING: accessors ascii assocs combinators formatting io
io.encodings.utf16.private io.encodings.utf8 io.files
io.streams.string kernel kernel.private linked-assocs make math
math.order math.parser mirrors namespaces sbufs sequences
sequences.private strings summary tr vectors vocabs.loader words
;

IN: json

SINGLETON: json-null

ERROR: json-error ;

ERROR: json-fp-special-error value ;

M: json-fp-special-error summary
    drop "JSON serialization: illegal float:" ;

: if-json-null ( x if-null else -- )
    [ dup json-null? ]
    [ [ drop ] prepose ]
    [ ] tri* if ; inline

: json-null>f ( obj/json-null -- obj/f )
    dup json-null = [ drop f ] when ; inline

: when-json-null ( x if-null -- ) [ ] if-json-null ; inline

: unless-json-null ( x else -- ) [ ] swap if-json-null ; inline

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
            { "-0" [ -0.0 ] }
            [ [ string>number ] [ not-a-json-number ] ?unless ]
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
    v-close dup dup [ pop ] bi@ swap LH{ } zip-as suffix! ;

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
        [ pick json-number [ suffix! ] dip [ scan ] when* ]
    } case ;

: get-json ( objects -- obj )
    dup length 1 = [ first ] [ json-error ] if ;

: check-json-depth ( quot -- )
    [ 0 json-depth ] dip '[
        @ json-depth get zero? [ json-error ] unless
    ] with-variable ; inline

PRIVATE>

: stream-read-jsons ( stream -- objects )
    [
        V{ } clone over '[ _ stream-read1 ] [ scan ] while* nip
    ] check-json-depth ;

: read-jsons ( -- objects )
    input-stream get stream-read-jsons ;

: stream-read-json ( stream -- object )
    [
        V{ } clone over '[
            _ stream-read1 [ scan dup first vector? ] [ f ] if*
        ] loop nip
    ] check-json-depth get-json ;

: read-json ( -- object )
    input-stream get stream-read-json ;

GENERIC: json> ( string -- object )

M: string json>
    [ read-jsons get-json ] with-string-reader ;

SYMBOL: json-allow-fp-special?
f json-allow-fp-special? set-global

SYMBOL: json-friendly-keys?
f json-friendly-keys? set-global

SYMBOL: json-coerce-keys?
f json-coerce-keys? set-global

SYMBOL: json-escape-slashes?
f json-escape-slashes? set-global

SYMBOL: json-escape-unicode?
f json-escape-unicode? set-global

! Writes the object out to a stream in JSON format
GENERIC#: stream-write-json 1 ( obj stream -- )

: write-json ( obj -- )
    output-stream get stream-write-json ;

: >json ( obj -- string )
    ! Returns a string representing the factor object in JSON format
    [ write-json ] with-string-writer ;

M: f stream-write-json
    [ drop "false" ] [ stream-write ] bi* ;

M: t stream-write-json
    [ drop "true" ] [ stream-write ] bi* ;

M: json-null stream-write-json
    [ drop "null" ] [ stream-write ] bi* ;

<PRIVATE

: write-json-generic-escape-surrogate-pair ( stream char -- stream )
    0x10000 - [ encode-first ] [ encode-second ] bi
    "\\u%02x%02x\\u%02x%02x" sprintf over stream-write ;

: write-json-generic-escape-bmp ( stream char -- stream )
    "\\u%04x" sprintf over stream-write ;

: write-json-generic-escape ( stream char -- stream )
    dup 0xffff > [
        write-json-generic-escape-surrogate-pair
    ] [
        write-json-generic-escape-bmp
    ] if ;

PRIVATE>

M: string stream-write-json
    CHAR: \" over stream-write1 swap [
        {
            { CHAR: \" [ "\\\"" over stream-write ] }
            { CHAR: \\ [ "\\\\" over stream-write ] }
            { CHAR: /  [
                json-escape-slashes? get
                [ "\\/" over stream-write ]
                [ CHAR: / over stream-write1 ] if
            ] }
            { CHAR: \b [ "\\b" over stream-write ] }
            { CHAR: \f [ "\\f" over stream-write ] }
            { CHAR: \n [ "\\n" over stream-write ] }
            { CHAR: \r [ "\\r" over stream-write ] }
            { CHAR: \t [ "\\t" over stream-write ] }
            { 0x2028   [ "\\u2028" over stream-write ] }
            { 0x2029   [ "\\u2029" over stream-write ] }
            [
                {
                    { [ dup printable? ] [ f ] }
                    { [ dup control? ] [ t ] }
                    [ json-escape-unicode? get ]
                } cond [
                    write-json-generic-escape
                ] [
                    over stream-write1
                ] if
            ]
        } case
    ] each CHAR: \" swap stream-write1 ;

M: integer stream-write-json
    [ number>string ] [ stream-write ] bi* ;

: float>json ( float -- string )
    dup fp-special? [
        json-allow-fp-special? get [ json-fp-special-error ] unless
        {
            { [ dup fp-nan? ] [ drop "NaN" ] }
            { [ dup 1/0. = ] [ drop "Infinity" ] }
            { [ dup -1/0. = ] [ drop "-Infinity" ] }
        } cond
    ] [
        number>string
    ] if ;

M: float stream-write-json
    [ float>json ] [ stream-write ] bi* ;

M: real stream-write-json
    [ >float number>string ] [ stream-write ] bi* ;

M: sequence stream-write-json
    CHAR: [ over stream-write1 swap
    over '[ CHAR: , _ stream-write1 ]
    pick '[ _ stream-write-json ] interleave
    CHAR: ] swap stream-write1 ;

<PRIVATE

TR: json-friendly "-" "_" ;

GENERIC: json-coerce ( obj -- str )
M: f json-coerce drop "false" ;
M: t json-coerce drop "true" ;
M: json-null json-coerce drop "null" ;
M: string json-coerce ;
M: integer json-coerce number>string ;
M: float json-coerce float>json ;
M: real json-coerce >float number>string ;

:: write-json-assoc ( obj stream -- )
    CHAR: { stream stream-write1 obj >alist
    [ CHAR: , stream stream-write1 ]
    json-friendly-keys? get
    json-coerce-keys? get '[
        first2 [
            dup string?
            [ _ [ json-friendly ] when ]
            [ _ [ json-coerce ] when ] if
            stream stream-write-json
        ] [
            CHAR: : stream stream-write1
            stream stream-write-json
        ] bi*
    ] interleave
    CHAR: } stream stream-write1 ;

PRIVATE>

M: tuple stream-write-json
    [ <mirror> ] dip write-json-assoc ;

M: assoc stream-write-json write-json-assoc ;

M: word stream-write-json
    [ name>> ] dip stream-write-json ;

: ?>json ( obj -- json ) dup string? [ >json ] unless ;
: ?json> ( obj -- json/f ) f like [ json> ] ?call ;

: stream-read-jsonlines ( stream -- objects )
    [ [ json> , ] each-stream-line ] { } make ;

: read-jsonlines ( -- objects )
    input-stream get stream-read-jsonlines ;

GENERIC: jsonlines> ( string -- objects )

M: string jsonlines>
    [ read-jsonlines ] with-string-reader ;

: stream-write-jsonlines ( objects stream -- )
    [ stream-nl ] [ stream-write-json ] bi-curry interleave ;

: write-jsonlines ( objects -- )
    output-stream get stream-write-jsonlines ;

: >jsonlines ( objects -- string )
    [ write-jsonlines ] with-string-writer ;

: path>json ( path -- json )
    utf8 [ read-jsons get-json ] with-file-reader ;

: path>jsons ( path -- jsons )
    utf8 [ read-jsons ] with-file-reader ;

: json>path ( json path -- )
    utf8 [ write-json ] with-file-writer ;

: jsons>path ( jsons path -- )
    utf8 [ write-jsonlines ] with-file-writer ;

: rewrite-json-string ( string quot: ( json -- json' ) -- string )
    [ json> ] dip call >json ; inline

: rewrite-jsons-string ( string quot: ( jsons -- jsons' ) -- string )
    [ jsonlines> ] dip call >jsonlines ; inline

: rewrite-json-path ( path quot: ( json -- json' ) -- )
    [ [ path>json ] dip call ] keepd json>path ; inline

: rewrite-jsons-path ( path quot: ( jsons -- jsons' ) -- )
    [ [ path>jsons ] dip call ] keepd jsons>path ; inline

{ "json" "ui.tools" } "json.ui" require-when
