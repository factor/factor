! Copyright (C) 2010 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors arrays help help.markup help.topics
io.encodings.utf8 io.files io.pathnames kernel namespaces
pdf.canvas pdf.layout pdf.streams sequences sets strings ;

IN: help.pdf

<PRIVATE

: next-articles ( str -- seq )
    lookup-article content>> [ array? ] filter
    [ first \ $subsections eq? ] filter
    [ rest [ string? ] filter ] gather ;

: topic>pdf ( str -- pdf )
    [
        [ print-topic ]
        [
            next-articles [
                [ article-title $heading ]
                [ article-content print-content ] bi
            ] each
        ] bi
    ] with-pdf-writer ;

: topics>pdf ( seq -- pdf )
    [ topic>pdf ] map <pb> 1array join ;

: write-pdf ( pdf name -- )
    [ pdf>string ] dip home prepend-path utf8 set-file-contents ;

PRIVATE>

: article-pdf ( str name -- )
    1.25 +line-height+ [
        [
            [ [ print-topic ] with-pdf-writer ]
            [ next-articles topics>pdf ] bi
            [ <pb> 1array glue ] unless-empty
        ] [ write-pdf ] bi*
    ] with-variable ;

: cookbook-pdf ( -- )
    "cookbook" "cookbook.pdf" article-pdf ;

: first-program-pdf ( -- )
    "first-program" "first-program.pdf" article-pdf ;

: handbook-pdf ( -- )
    "handbook-language-reference" "handbook.pdf" article-pdf ;

: system-pdf ( -- )
    "handbook-system-reference" "system.pdf" article-pdf ;

: tools-pdf ( -- )
    "handbook-tools-reference" "tools" article-pdf ;

: index-pdf ( -- )
    {
        "vocab-index"
        "article-index"
        "primitive-index"
        "error-index"
        "class-index"
    } topics>pdf "index.pdf" write-pdf ;

: furnace-pdf ( -- )
    "furnace" "furnace.pdf" article-pdf ;

: alien-pdf ( -- )
    "alien" "alien.pdf" article-pdf ;

: io-pdf ( -- )
    "io" "io.pdf" article-pdf ;
