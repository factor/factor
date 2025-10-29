! Copyright (C) 2025 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors ascii assocs classes.tuple combinators
hash-sets io io.streams.string kernel linked-assocs make math
math.parser namespaces sequences sets splitting strings
strings.parser vectors words ;

IN: edn

TUPLE: keyword name ;

TUPLE: symbol name ;

TUPLE: tagged name value ;

ERROR: edn-error ;

DEFER: stream-read-edn

<PRIVATE

SYMBOL: edn-separator

SYMBOL: edn-eof

: edn-expect ( token stream -- )
    [ dup length ] [ stream-read ] bi* = [ edn-error ] unless ; inline

: edn-check-eof ( object/edn-eof -- object )
    dup edn-eof = [ edn-error ] when ; inline

: edn-number ( token -- n )
    dup string>number [ nip ] [ edn-error ] if* ;

: stream-read-edn1 ( stream -- elt )
    edn-separator [ f ] change [ nip ] [ stream-read1 ] if* ;

: stream-read-token ( stream -- token )
    "\s\t\r\n,)]}" swap stream-read-until edn-separator namespaces:set ;

: stream-read-edn-keyword ( stream -- keyword )
    stream-read-token keyword boa ;

: stream-read-edn-char ( stream -- char )
    stream-read-token {
        { "newline" [ CHAR: \n ] }
        { "return" [ CHAR: \r ] }
        { "space" [ CHAR: \s ] }
        { "tab" [ CHAR: \t ] }
        [ "u" ?head [ hex> ] [ first ] if ]
    } case ;

: stream-read-edn-string ( stream -- string )
    [
        [
            "\\\"" over stream-read-until [ % ] dip {
                { CHAR: \\ [ dup stream-read1 escape , t ] }
                { CHAR: \" [ f ] }
                { f [ edn-error ] }
            } case
        ] loop
    ] "" make nip ;

DEFER: stream-read-edn-object

: stream-read-edn-unsafe ( stream -- object/edn-eof )
    dup stream-read-edn1 stream-read-edn-object ;

:: stream-read-edn-sequence ( stream end exemplar -- seq )
    [
        stream [
            dup stream-read-edn1 {
                { f [ edn-error ] }
                { end [ f ] }
                [ dupd stream-read-edn-object edn-check-eof , t ]
            } case
        ] loop
    ] exemplar make nip ; inline

: stream-read-edn-list ( stream -- vector )
    CHAR: ) { } stream-read-edn-sequence ;

: stream-read-edn-vector ( stream -- vector )
    CHAR: ] V{ } stream-read-edn-sequence ;

: stream-read-edn-set ( stream -- set )
    CHAR: } { } stream-read-edn-sequence >hash-set ;

: stream-read-edn-map ( stream -- vector )
    [
        [
            dup stream-read-edn1 {
                { f [ B edn-error ] }
                { CHAR: , [ t ] }
                { CHAR: } [ f ] }
                [
                    dupd stream-read-edn-object edn-check-eof
                    [ dup stream-read-edn ] dip ,, t
                ]
            } case
        ] loop
    ] LH{ } make nip ;

: stream-read-edn-ident ( stream -- object )
    dup stream-read-edn1 {
        { f [ edn-error ] }
        { CHAR: _ [ dup stream-read-edn drop stream-read-edn ] }
        { CHAR: { [ stream-read-edn-set ] }
        [
            [ [ stream-read-token ] [ stream-read-edn ] bi ] dip
            swap [ prefix ] dip tagged boa
        ]
    } case ;

: stream-read-edn-object ( stream elt -- object/f )
    {
        { f [ drop edn-eof ] }
        { CHAR: : [ stream-read-edn-keyword ] }
        { CHAR: # [ stream-read-edn-ident ] }
        { CHAR: { [ stream-read-edn-map ] }
        { CHAR: ( [ stream-read-edn-list ] }
        { CHAR: [ [ stream-read-edn-vector ] }
        { CHAR: ; [ [ stream-readln drop ] [ stream-read-edn-unsafe ] bi ] }
        { CHAR: \\ [ stream-read-edn-char ] }
        { CHAR: \" [ stream-read-edn-string ] }
        { CHAR: \s [ stream-read-edn-unsafe ] }
        { CHAR: \t [ stream-read-edn-unsafe ] }
        { CHAR: \r [ stream-read-edn-unsafe ] }
        { CHAR: \n [ stream-read-edn-unsafe ] }
        { CHAR: n [ "il" swap edn-expect null ] }
        { CHAR: t [ "rue" swap edn-expect t ] }
        { CHAR: f [ "alse" swap edn-expect f ] }
        [
            [ stream-read-token ] dip
            [ prefix ] [ [ digit? ] [ "+-" member? ] bi or ] bi
            [ edn-number ] [ symbol boa ] if
        ]
    } case ;

PRIVATE>

: stream-read-edn ( stream -- object )
    stream-read-edn-unsafe edn-check-eof ;

: read-edn ( -- object )
    input-stream get stream-read-edn ;

: stream-read-edns ( stream -- objects )
    '[ _ stream-read-edn-unsafe dup edn-eof = not ] [ ] produce nip ;

: read-edns ( -- objects )
    input-stream get stream-read-edns ;

: edn> ( string -- objects )
    [ read-edns ] with-string-reader ;

GENERIC: write-edn ( object -- )

M: object write-edn edn-error ;

M: word write-edn
    dup null eq? [ drop "nil" write ] [ name>> write ] if ;

M: t write-edn drop "true" write ;

M: f write-edn drop "false" write ;

M: integer write-edn number>string write ;

M: number write-edn >float number>string write ;

M: string write-edn CHAR: \" write1 write CHAR: \" write1 ;

M: sequence write-edn
    "(" write [ bl ] [ write-edn ] interleave ")" write ;

M: assoc write-edn
    "{" write >alist
    [ ", " write ]
    [ first2 [ write-edn CHAR: \s write1 ] [ write-edn ] bi* ] interleave
    "}" write ;

M: sets:set write-edn
    "#{" write members [ bl ] [ write-edn ] interleave "}" write ;

M: vector write-edn
    "[" write [ bl ] [ write-edn ] interleave "]" write ;

M: keyword write-edn CHAR: : write1 name>> write ;

M: symbol write-edn name>> write ;

M: tagged write-edn
    [ CHAR: # write1 name>> write bl ] [ value>> write-edn ] bi ;

M: tuple write-edn
    tuple>slots
    [ [ vocabulary>> ] [ name>> ] bi "/" glue CHAR: # write1 write bl ]
    [ all-slots [ name>> keyword boa ] map swap LH{ } zip-as write-edn ] bi ;

: write-edns ( objects -- )
    [ nl ] [ write-edn ] interleave ;

: >edn ( object -- string )
    [ write-edn ] with-string-writer ;
