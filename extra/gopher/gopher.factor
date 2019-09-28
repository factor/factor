! Copyright (C) 2014 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors byte-arrays calendar colors.constants
combinators formatting fry images images.loader
images.loader.private images.viewer io io.encodings.binary
io.encodings.string io.encodings.utf8 io.sockets io.styles
io.timeouts kernel make math math.parser namespaces present
prettyprint sequences splitting summary urls urls.encoding
vocabs ;

IN: gopher

<PRIVATE

CONSTANT: A_TEXT char: 0
CONSTANT: A_MENU char: 1
CONSTANT: A_CSO char: 2
CONSTANT: A_ERROR char: 3
CONSTANT: A_MACBINHEX char: 4
CONSTANT: A_PCBINHEX char: 5
CONSTANT: A_UUENCODED char: 6
CONSTANT: A_INDEX char: 7
CONSTANT: A_TELNET char: 8
CONSTANT: A_BINARY char: 9
CONSTANT: A_DUPLICATE char: +
CONSTANT: A_SOUND char: s
CONSTANT: A_EVENT char: e
CONSTANT: A_CALENDAR char: c
CONSTANT: A_HTML char: h
CONSTANT: A_TN3270 char: T
CONSTANT: A_MIME char: M
CONSTANT: A_IMAGE char: I
CONSTANT: A_WHOIS char: w
CONSTANT: A_QUERY char: q
CONSTANT: A_GIF char: g
CONSTANT: A_WWW char: w
CONSTANT: A_PLUS_IMAGE char: \:
CONSTANT: A_PLUS_MOVIE char: \;
CONSTANT: A_PLUS_SOUND char: <

: gopher-get ( selector -- item-type byte-array )
    "/" split1 "" or [ first ] dip
    "?" split1 [ "\t" glue ] when*
    "\r\n" append utf8 encode write flush contents ;

PRIVATE>

ERROR: not-a-gopher-url url ;

: gopher ( url -- item-type byte-array )
    >url dup protocol>> "gopher" = [ not-a-gopher-url ] unless {
        [ host>> ]
        [ port>> 70 or <inet> binary ]
        [ path>> rest url-encode [ "1/" ] when-empty ]
        [ query>> [ assoc>query url-decode "?" glue ] when* ]
    } cleave '[
        1 minutes input-stream get set-timeout
        _ gopher-get
    ] with-client ;

<PRIVATE

TUPLE: gopher-link type name selector host port ;

M: gopher-link summary >url present ;

: <gopher-link> ( item -- gopher-link )
    unclip swap "\t" split first4 gopher-link boa ;

M: gopher-link >url
    dup type>> char: h = [
        selector>> "URL:" ?head drop
    ] [
        {
            [ host>> ] [ port>> ] [ type>> ] [ selector>> ]
        } cleave "gopher://%s:%s/%c%s" sprintf
    ] if >url ;

: gopher-link. ( gopher-link -- )
    dup type>> char: i = [
        name>> print
    ] [
        [ name>> ] keep [
            presented ,,
            color: blue foreground ,,
        ] H{ } make format nl
    ] if ;

: gopher-text ( object -- lines )
    utf8 decode string-lines { "." } split1 drop ;

: gopher-text. ( object -- )
    gopher-text [ print ] each ;

: gopher-gif. ( object -- )
    "gif" (image-class) load-image* image. ;

: gopher-image. ( path object -- path )
    over image-class load-image* image. ;

: gopher-menu. ( object -- )
    gopher-text [
        [ nl ] [ <gopher-link> gopher-link. ] if-empty
    ] each ;

PRIVATE>

: gopher. ( url -- )
    >url [ path>> ] [ gopher swap ] bi {
        { A_TEXT [ gopher-text. ] }
        { A_MENU [ gopher-menu. ] }
        { A_INDEX [ gopher-menu. ] }
        { A_GIF [ gopher-gif. ] }
        { A_IMAGE [ gopher-image. ] }
        [ drop . ]
    } case drop ;
