! Copyright (C) 2010 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays calendar calendar.format combinators
combinators.short-circuit io io.backend io.directories
io.encodings.binary io.encodings.detect io.encodings.utf8
io.files io.files.info io.files.temp io.files.unique io.launcher
io.pathnames kernel math math.parser namespaces sequences
sorting strings unicode xml.syntax xml.writer xmode.catalog
xmode.marker xmode.tokens ;
IN: codebook

! Usage: "my/source/tree" codebook
! Writes tree.opf, tree.ncx, and tree.html to a temporary directory
! Writes tree.mobi to resource:codebooks
! Requires kindlegen to compile tree.mobi for Kindle

CONSTANT: codebook-style
    {
        { COMMENT1 [ [XML <i><font color="#555555"><-></font></i> XML] ] }
        { COMMENT2 [ [XML <i><font color="#555555"><-></font></i> XML] ] }
        { COMMENT3 [ [XML <i><font color="#555555"><-></font></i> XML] ] }
        { COMMENT4 [ [XML <i><font color="#555555"><-></font></i> XML] ] }
        { DIGIT    [ [XML    <font color="#333333"><-></font>     XML] ] }
        { FUNCTION [ [XML <b><font color="#111111"><-></font></b> XML] ] }
        { KEYWORD1 [ [XML <b><font color="#111111"><-></font></b> XML] ] }
        { KEYWORD2 [ [XML <b><font color="#111111"><-></font></b> XML] ] }
        { KEYWORD3 [ [XML <b><font color="#111111"><-></font></b> XML] ] }
        { KEYWORD4 [ [XML <b><font color="#111111"><-></font></b> XML] ] }
        { LABEL    [ [XML <b><font color="#333333"><-></font></b> XML] ] }
        { LITERAL1 [ [XML    <font color="#333333"><-></font>     XML] ] }
        { LITERAL2 [ [XML    <font color="#333333"><-></font>     XML] ] }
        { LITERAL3 [ [XML    <font color="#333333"><-></font>     XML] ] }
        { LITERAL4 [ [XML    <font color="#333333"><-></font>     XML] ] }
        { MARKUP   [ [XML <b><font color="#333333"><-></font></b> XML] ] }
        { OPERATOR [ [XML <b><font color="#111111"><-></font></b> XML] ] }
        [ drop ]
    }

: first-line ( filename encoding -- line )
    [ readln ] with-file-reader ;

TUPLE: code-file
    name encoding mode ;

: include-file-name? ( name -- ? )
    {
        [ path-components [ "." head? ] none? ]
        [ link-info regular-file? ]
    } 1&& ;

: code-files ( dir -- files )
    recursive-directory-files
    [ include-file-name? ] filter [
        dup detect-file dup binary?
        [ f ] [ 2dup dupd first-line find-mode ] if
        code-file boa
    ] map [ mode>> ] filter [ name>> ] sort-by ;

: html-name-char ( char -- str )
    {
        { [ dup alpha? ] [ 1string ] }
        { [ dup digit? ] [ 1string ] }
        [ >hex 6 CHAR: 0 pad-head "_" "_" surround ]
    } cond ;

: file-html-name ( name -- name )
    [ html-name-char ] { } map-as concat ".html" append ;

: toc-list ( files -- list )
    [ name>> ] map sort [
        [ file-html-name ] keep
        [XML <li><a href=<->><-></a></li> XML]
    ] map ;

! insert zero-width non-joiner between all characters so words can wrap anywhere
: zwnj ( string -- s|t|r|i|n|g )
    [ CHAR: \u00200c "" 2sequence ] { } map-as concat ;

! We wrap every line in <tt> because Kindle tends to forget the font when
! moving back pages
: htmlize-tokens ( tokens line# -- html-tokens )
    swap [
        [ str>> zwnj ] [ id>> ] bi codebook-style case
    ] map [XML <tt><font size="-2" color="#666666"><-></font> <-></tt> XML]
    "\n" 2array ;

: line#>string ( i line#len -- i-string )
    [ number>string ] [ CHAR: \s pad-head ] bi* ;

:: code>html ( dir file -- page )
    file name>> :> name
    "Generating HTML for " write name write "..." print flush
    dir [ file [ name>> ] [ encoding>> ] bi file-lines ] with-directory :> lines
    lines length 1 + number>string length :> line#len
    file mode>> load-mode :> rules
    f lines [| l i | l rules tokenize-line i 1 + line#len line#>string htmlize-tokens ]
    map-index concat nip :> html-lines
    <XML <!DOCTYPE html> <html>
        <head>
            <title><-name-></title>
            <meta http-equiv="Content-type" content="text/html; charset=utf-8" />
        </head>
        <body>
            <h2><-name-></h2>
            <pre><-html-lines-></pre>
            <mbp:pagebreak xmlns:mbp="http://www.mobipocket.com/mbp" />
        </body>
    </html> XML> ;

:: code>toc-html ( dir name files -- html )
    "Generating HTML table of contents" print flush

    now timestamp>rfc822 :> timestamp
    dir absolute-path :> source
    dir [
        files toc-list :> toc

        <XML <!DOCTYPE html> <html>
            <head>
                <title><-name-></title>
                <meta http-equiv="Content-type" content="text/html; charset=utf-8" />
            </head>
            <body>
                <h1><-name-></h1>
                <font size="-2">Generated from<br/>
                <b><tt><-source-></tt></b><br/>
                at <-timestamp-></font><br/>
                <br/>
                <ul><-toc-></ul>
                <mbp:pagebreak xmlns:mbp="http://www.mobipocket.com/mbp" />
            </body>
        </html> XML>
    ] with-directory ;

:: code>ncx ( dir name files -- xml )
    "Generating NCX table of contents" print flush

    files [| file i |
        file name>> :> name
        name file-html-name :> filename
        i 2 + number>string :> istr

        [XML <navPoint class="book" id=<-filename-> playOrder=<-istr->>
            <navLabel><text><-name-></text></navLabel>
            <content src=<-filename-> />
        </navPoint> XML]
    ] map-index :> file-nav-points

    <XML <?xml version="1.0" encoding="UTF-8" ?>
    <ncx version="2005-1" xmlns="http://www.daisy.org/z3986/2005/ncx/">
        <navMap>
            <navPoint class="book" id="toc" playOrder="1">
                <navLabel><text>Table of Contents</text></navLabel>
                <content src="_toc.html" />
            </navPoint>
            <-file-nav-points->
        </navMap>
    </ncx> XML> ;

:: code>opf ( dir name files -- xml )
    "Generating OPF manifest" print flush
    name ".ncx"  append :> ncx-name

    files [
        name>> file-html-name dup
        [XML <item id=<-> href=<-> media-type="text/html" /> XML]
    ] map :> html-manifest

    files [ name>> file-html-name [XML <itemref idref=<-> /> XML] ] map :> html-spine

    <XML <?xml version="1.0" encoding="UTF-8" ?>
    <package
        version="2.0"
        xmlns="http://www.idpf.org/2007/opf"
        unique-identifier=<-name->>
        <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
            <dc:title><-name-></dc:title>
            <dc:language>en</dc:language>
            <meta name="cover" content="my-cover-image" />
        </metadata>
        <manifest>
            <item href="cover.jpg" id="my-cover-image" media-type="image/jpeg" />
            <item id="html-toc" href="_toc.html" media-type="text/html" />
            <-html-manifest->
            <item id="toc" href=<-ncx-name-> media-type="application/x-dtbncx+xml" />
        </manifest>
        <spine toc="toc">
            <itemref idref="html-toc" />
            <-html-spine->
        </spine>
        <guide>
            <reference type="toc" title="Table of Contents" href="_toc.html" />
        </guide>
    </package> XML> ;

: write-dest-file ( xml name ext -- )
    append utf8 [ write-xml ] with-file-writer ;

SYMBOL: kindlegen-path
kindlegen-path [ "kindlegen" ] initialize

SYMBOL: codebook-output-path
codebook-output-path [ "resource:codebooks" ] initialize

: kindlegen ( path -- )
    [ kindlegen-path get "-unicode" ] dip 3array try-process ;

: kindle-path ( directory name extension -- path )
    [ append-path ] dip append ;

:: codebook ( src-dir -- )
    codebook-output-path get normalize-path :> dest-dir

    "Generating ebook for " write src-dir write " in " write dest-dir print flush

    dest-dir make-directories
    [
        [
            src-dir file-name :> name
            src-dir code-files :> files

            src-dir name files code>opf
            name ".opf" write-dest-file

            "vocab:codebook/cover.jpg" "." copy-file-into

            src-dir name files code>ncx
            name ".ncx" write-dest-file

            src-dir name files code>toc-html
            "_toc.html" "" write-dest-file

            files [| file |
                src-dir file code>html
                file name>> file-html-name "" write-dest-file
            ] each

            "." name ".opf" kindle-path kindlegen
            "." name ".mobi" kindle-path dest-dir copy-file-into

            dest-dir name ".mobi" kindle-path :> mobi-path

            "Job's finished: " write mobi-path print flush
        ] cleanup-unique-directory
    ] with-temp-directory ;
