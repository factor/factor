! Copyright (C) 2014 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors byte-arrays colors.constants combinators
formatting fry images images.loader images.loader.private
images.viewer io io.encodings.binary io.encodings.string
io.encodings.utf8 io.sockets io.styles kernel make math
math.parser namespaces present prettyprint sequences splitting
summary urls urls.encoding vocabs ;

IN: gopher

<PRIVATE

CONSTANT: A_TEXT CHAR: 0
CONSTANT: A_MENU CHAR: 1
CONSTANT: A_CSO CHAR: 2
CONSTANT: A_ERROR CHAR: 3
CONSTANT: A_MACBINHEX CHAR: 4
CONSTANT: A_PCBINHEX CHAR: 5
CONSTANT: A_UUENCODED CHAR: 6
CONSTANT: A_INDEX CHAR: 7
CONSTANT: A_TELNET CHAR: 8
CONSTANT: A_BINARY CHAR: 9
CONSTANT: A_DUPLICATE CHAR: +
CONSTANT: A_SOUND CHAR: s
CONSTANT: A_EVENT CHAR: e
CONSTANT: A_CALENDAR CHAR: c
CONSTANT: A_HTML CHAR: h
CONSTANT: A_TN3270 CHAR: T
CONSTANT: A_MIME CHAR: M
CONSTANT: A_IMAGE CHAR: I
CONSTANT: A_WHOIS CHAR: w
CONSTANT: A_QUERY CHAR: q
CONSTANT: A_GIF CHAR: g
CONSTANT: A_WWW CHAR: w
CONSTANT: A_PLUS_IMAGE CHAR: :
CONSTANT: A_PLUS_MOVIE CHAR: ;
CONSTANT: A_PLUS_SOUND CHAR: <

: gopher-get ( selector -- item-type byte-array )
    "/" split1 "" or
    [ dup length 1 > [ string>number ] [ first ] if ]
    [
        "?" split1 [ "\t" glue ] when*
        "\r\n" append utf8 encode write flush
        input-stream get (stream-contents-by-block)
    ] bi* ;

PRIVATE>

ERROR: not-a-gopher-url url ;

: gopher ( url -- item-type byte-array )
    dup url? [ >url ] unless
    dup protocol>> "gopher" = [ not-a-gopher-url ] unless {
        [ host>> ]
        [ port>> 70 or <inet> binary ]
        [ path>> rest [ "1/" ] when-empty ]
        [ query>> [ assoc>query url-decode "?" glue ] when* ]
    } cleave '[ _ gopher-get ] with-client ;

<PRIVATE

TUPLE: gopher-link type name selector host port ;

M: gopher-link summary >url present ;

: <gopher-link> ( item -- gopher-link )
    unclip swap "\t" split first4 gopher-link boa ;

M: gopher-link >url
    dup type>> CHAR: h = [
        selector>> "URL:" ?head drop
    ] [
        {
            [ host>> ] [ port>> ] [ type>> ] [ selector>> ]
        } cleave "gopher://%s:%s/%s%s" sprintf
    ] if >url ;

: gopher-link. ( gopher-link -- )
    dup type>> CHAR: i = [
        name>> print
    ] [
        [ name>> ] keep [
            presented ,,
            COLOR: blue foreground ,,
        ] H{ } make format nl
    ] if ;

: gopher-text ( object -- lines )
    utf8 decode string-lines { "." } split1 drop ;

: gopher-text. ( object -- )
    gopher-text [ print ] each ;

: gopher-gif. ( object -- )
    "gif" (image-class) load-image* image. ;

: gopher-menu. ( object -- )
    gopher-text [
        [ nl ] [ <gopher-link> gopher-link. ] if-empty
    ] each ;

PRIVATE>

: gopher. ( url -- )
    gopher swap {
        { A_TEXT [ gopher-text. ] }
        { A_MENU [ gopher-menu. ] }
        { A_INDEX [ gopher-menu. ] }
        { A_GIF [ gopher-gif. ] }
        [ drop . ]
    } case ;
