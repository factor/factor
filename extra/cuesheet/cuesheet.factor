! Copyright (C) 2013 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors ascii combinators io io.encodings.utf8 io.files
io.streams.string kernel math.parser sequences splitting ;

IN: cuesheet

TUPLE: cuesheet catalog cdtextfile files flags remarks performer
songwriter title ;

: <cuesheet> ( -- cuesheet )
    f f f f f f f f cuesheet boa ;

TUPLE: file name type tracks ;

: <file> ( name type -- file )
    f file boa ;

TUPLE: track number datatype title performer songwriter pregap
indices isrc postgap ;

: <track> ( number datatype -- track )
    f f f f f f f track boa ;

TUPLE: index number duration ;

C: <index> index

ERROR: unknown-filetype filetype ;

: check-filetype ( filetype -- filetype )
    dup { "BINARY" "MOTOROLA" "AIFF" "WAVE" "MP3" } member?
    [ unknown-filetype ] unless ;

ERROR: unknown-flag flag ;

: check-flag ( flag -- flag )
    dup { "DCP" "4CH" "PRE" "SCMS" "DATA" } member?
    [ unknown-flag ] unless ;

: check-flags ( flags -- flags )
    dup [ check-flag drop ] each ;

ERROR: unknown-datatype datatype ;

: check-datatype ( datatype -- datatype )
    dup {
        "AUDIO" "CDG" "MODE1/2048" "MODE1/2352" "MODE2/2336"
        "MODE2/2352" "CDI/2336" "CDI/2352"
    } member? [ unknown-datatype ] unless ;

ERROR: unknown-syntax syntax ;

<PRIVATE

: trim-comments ( str -- str' )
    dup [ CHAR: ; = ] find drop [ head ] when* ;

: trim-quotes ( str -- str' )
    [ CHAR: \" = ] trim ;

: last-track ( cuesheet -- cuesheet track )
    dup files>> last tracks>> last ;

: track-or-disc ( cuesheet -- cuesheet track/disc )
    dup files>> [ dup ] [ last tracks>> last ] if-empty ;

: parse-file ( cuesheet str -- cuesheet )
    " " split1-last [ trim-quotes ] [ check-filetype ] bi*
    <file> [ suffix ] curry change-files ;

: parse-flags ( cuesheet str -- cuesheet )
    check-flag [ suffix ] curry change-flags ;

: parse-index ( cuesheet str -- cuesheet )
    [ last-track ] [
        " " split1 [ string>number ] dip <index>
        [ suffix ] curry change-indices drop
    ] bi* ;

: parse-isrc ( cuesheet str -- cuesheet )
    [ last-track ] [ >>isrc drop ] bi* ;

: parse-performer ( cuesheet str -- cuesheet )
    [ track-or-disc ] [ trim-quotes >>performer drop ] bi* ;

: parse-postgap ( cuesheet str -- cuesheet )
    [ last-track ] [ >>postgap drop ] bi* ;

: parse-pregap ( cuesheet str -- cuesheet )
    [ last-track ] [ >>pregap drop ] bi* ;

: parse-remarks ( cuesheet str -- cuesheet )
    [ suffix ] curry change-remarks ;

: parse-songwriter ( cuesheet str -- cuesheet )
    [ track-or-disc ] [ trim-quotes >>songwriter drop ] bi* ;

: parse-title ( cuesheet str -- cuesheet )
    [ track-or-disc ] [ trim-quotes >>title drop ] bi* ;

: parse-track ( cuesheet str -- cuesheet )
    [ dup files>> last ] [
        " " split1 [ string>number ] [ check-datatype ] bi*
    ] bi* <track> [ suffix ] curry change-tracks drop ;

: parse-line ( cuesheet line -- cuesheet )
    trim-comments [ blank? ] trim " " split1 swap {
        { "CATALOG" [ >>catalog ] }
        { "CDTEXTFILE" [ >>cdtextfile ] }
        { "FILE" [ parse-file ] }
        { "FLAGS" [ parse-flags ] }
        { "INDEX" [ parse-index ] }
        { "ISRC" [ parse-isrc ] }
        { "PERFORMER" [ parse-performer ] }
        { "POSTGAP" [ parse-postgap ] }
        { "PREGAP" [ parse-pregap ] }
        { "REM" [ parse-remarks ] }
        { "SONGWRITER" [ parse-songwriter ] }
        { "TITLE" [ parse-title ] }
        { "TRACK" [ parse-track ] }
        { "" [ drop ] }
        [ unknown-syntax ]
    } case ;

PRIVATE>

: read-cuesheet ( -- cuesheet )
    <cuesheet> [ readln ] [ parse-line ] while* ;

: file>cuesheet ( path -- cuesheet )
    utf8 [ read-cuesheet ] with-file-reader ;

: string>cuesheet ( str -- cuesheet )
    [ read-cuesheet ] with-string-reader ;
