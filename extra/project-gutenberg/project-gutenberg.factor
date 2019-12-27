! Copyright (C) 2019 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays ascii assocs formatting http.client io.directories
io.encodings.utf8 io.files io.pathnames kernel math.parser
namespaces pcre regexp sequences splitting ;
IN: project-gutenberg

INITIALIZED-SYMBOL: gutenberg-books [ "resource:gutenberg" ]

: cached-path ( name -- path' )
    [ gutenberg-books get dup make-directories ] dip
    append-path ;

: cached-book-path ( n -- path )
    "%d-0.txt" sprintf cached-path ;


: book-cached? ( n -- ? )
    [ gutenberg-books get ] dip "%s/%d-0.txt" sprintf exists? ;

: download-unless-cached ( url path -- )
    dup exists? [
        2drop
    ] [
        download-to
    ] if ;

: download-gutenberg-index ( -- )
    "https://www.gutenberg.org/dirs/GUTINDEX.ALL"
    "GUTINDEX.ALL" cached-path
    download-unless-cached ;

: download-gutenberg ( n -- )
    [ dup "http://www.gutenberg.org/files/%d/%d-0.txt" sprintf ]
    [ cached-book-path ] bi
    download-unless-cached ;

: extra-parse-gutenberg-index ( seq -- seq' )
    [
        dup re[=[^(.*), by (.*) ?(?:\[(.*): (.*)\])?$]=] findall
        ?first [ ] [ nip values rest ] if-empty
    ] assoc-map ;

: parse-gutenberg-index ( -- obj )
    download-gutenberg-index
    "GUTINDEX.ALL" cached-path utf8 file-contents
    "TITLE and AUTHOR                                                     EBOOK NO." split1 nip
    "<==End of GUTINDEX.ALL==>" split1 drop
    4 tail 4 head*
    "\r\n\r\n" split-subseq
    [
        "\r\n" split1
        [ " " split1-last ] dip swap
        [
            [ [ blank? ] trim-tail ] dip
            "\r\n" split-subseq [ [ blank? ] trim ] map
            " " join " " glue [ blank? ] trim
        ] [ string>number ] bi* swap 2array
    ] map ;

    ! [ drop ] assoc-reject ! find badly numbered
