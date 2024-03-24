! Copyright (C) 2021 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: assocs combinators command-line http.download io
io.directories io.encodings.utf8 io.files io.files.temp
io.launcher io.pathnames json kernel namespaces regexp sequences
splitting system urls wrap.strings ;

IN: tldr

SYMBOL: tldr-language
tldr-language [ "en" ] initialize

SYMBOL: tldr-platform
tldr-platform [
    os {
        { macosx [ "osx" ] }
        { linux [ "linux" ] }
        { windows [ "windows" ] }
    } case
] initialize

<PRIVATE

CONSTANT: tldr-zip URL" https://tldr-pages.github.io/assets/tldr.zip"

: download-tldr ( -- )
    "tldr" cache-file dup make-directory [
        tldr-zip "tldr.zip" download-to drop
        { "unzip" "tldr.zip" } try-process
    ] with-directory ;

: ?download-tldr ( -- )
    "tldr/tldr.zip" cache-file file-exists? [ download-tldr ] unless ;

MEMO: tldr-index ( -- index )
    ?download-tldr "tldr/index.json" cache-file path>json ;

: find-command ( name -- command )
    tldr-index "commands" of [ "name" of = ] with find nip ;

: platform ( command -- platform )
    "platform" of tldr-platform get '[ _ = ] find nip "common" or ;

: language ( command -- language )
    "language" of tldr-language get '[ _ = ] find nip "en" or ;

: tldr-path ( name platform language -- path )
    "pages" over "en" = [ nip ] [ "." glue ] if prepend-path
    swap ".md" append append-path "tldr" cache-file prepend-path ;

PRIVATE>

: tldr ( name -- lines )
    dup find-command [ platform ] [ language ] bi
    tldr-path utf8 file-lines ;

: tldr. ( name -- )
    tldr [
        { "`" "    " } [ ?head ] any? [
            "`" ?tail drop
            R/ \{\{[^}]+\}\}/ [ 2 tail 2 head* ] re-replace-with
            76 "  " wrap-indented-string
        ] [
            { "# " "= " "> " "- " } [ ?head ] any? drop
            76 wrap-string
        ] if print
    ] each ;

: tldr-main ( -- )
    command-line get [ tldr. nl ] each ;

MAIN: tldr-main
