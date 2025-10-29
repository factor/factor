USING: combinators command-line.parser io io.encodings.utf8
io.files io.streams.256color io.streams.ansi io.streams.html
io.streams.pdf kernel namespaces pdf.layout prettyprint
sequences unicode xml.writer xmode.catalog xmode.highlight ;

IN: tools.highlight

CONSTANT: OPTIONS {
    T{ option
        { name "--xmode" }
        { help "set the file mode, or guess from filename" }
        { #args 1 }
    }
    T{ option
        { name "--format" }
        { help "set the format to: 256, ansi, html, or pdf" }
        { #args 1 }
        { convert [ >lower ] }
        { validate [ { "256" "ansi" "html" "pdf" } member? ] }
        { default "256" }
    }
    T{ option
        { name "--output" }
        { help "set the output filename, or default to stdout" }
        { #args 1 }
    }
    T{ option
        { name "input" }
        { #args "?" }
        { help "set the input filename, or default to stdin" }
    }
}

MAIN: [
    OPTIONS [
        "input" get dup { f "-" } member? [
            drop read-lines "mode" get "factor" or
        ] [
            [ utf8 file-lines "mode" get ] keep
            '[ _ over ?first find-mode ] unless*
        ] if

        [
            "format" get {
                { "html" [ [ highlight-lines ] with-html-writer write-xml ] }
                { "pdf" [ [ highlight-lines ] with-pdf-writer write-pdf ] }
                { "ansi" [ [ highlight-lines ] with-ansi ] }
                { "256" [ [ highlight-lines ] with-256color ] }
            } case
        ]

        "output" get [
            utf8 rot '[ _ call( lines mode -- ) ] with-file-writer
        ] [
            call( lines mode -- )
        ] if*
    ] with-options
]

! { "-m" "--mode" }   ! or guess from filename
! { "-f" "--format" } ! or terminal by default
! { "-o" "--output" } ! or stdout by default
! [inputfile]         ! or stdin by default

! factor -run=tools.highlight -m factor -f html,pdf,terminal -o outputfile inputfile
