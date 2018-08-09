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

CONSTANT: A_TEXT ch'0
CONSTANT: A_MENU ch'1
CONSTANT: A_CSO ch'2
CONSTANT: A_ERROR ch'3
CONSTANT: A_MACBINHEX ch'4
CONSTANT: A_PCBINHEX ch'5
CONSTANT: A_UUENCODED ch'6
CONSTANT: A_INDEX ch'7
CONSTANT: A_TELNET ch'8
CONSTANT: A_BINARY ch'9
CONSTANT: A_DUPLICATE ch'+
CONSTANT: A_SOUND ch's
CONSTANT: A_EVENT ch'e
CONSTANT: A_CALENDAR ch'c
CONSTANT: A_HTML ch'h
CONSTANT: A_TN3270 ch'T
CONSTANT: A_MIME ch'M
CONSTANT: A_IMAGE ch'I
CONSTANT: A_WHOIS ch'w
CONSTANT: A_QUERY ch'q
CONSTANT: A_GIF ch'g
CONSTANT: A_WWW ch'w
CONSTANT: A_PLUS_IMAGE ch'\:
CONSTANT: A_PLUS_MOVIE ch'\;
CONSTANT: A_PLUS_SOUND ch'<

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
    dup type>> ch'h = [
        selector>> "URL:" ?head drop
    ] [
        {
            [ host>> ] [ port>> ] [ type>> ] [ selector>> ]
        } cleave "gopher://%s:%s/%c%s" sprintf
    ] if >url ;

: gopher-link. ( gopher-link -- )
    dup type>> ch'i = [
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
