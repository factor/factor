USING: xmode.tokens xmode.marker
xmode.catalog kernel html html.elements io io.files
sequences words ;
IN: xmode.code2html

: htmlize-tokens ( tokens -- )
    [
        dup token-str swap token-id [
            <span word-name =class span> write </span>
        ] [
            write
        ] if*
    ] each ;

: htmlize-line ( line-context line rules -- line-context' )
    tokenize-line htmlize-tokens ;

: htmlize-lines ( lines rules -- )
    <pre> f -rot [ htmlize-line nl ] curry each drop </pre> ;

: default-stylesheet ( -- )
    <style>
        "extra/xmode/code2html/stylesheet.css"
        resource-path <file-reader> contents write
    </style> ;

: htmlize-file ( path -- )
    dup <file-reader> lines dup empty? [ 2drop ] [
        swap dup ".html" append <file-writer> [
            [
                <html>
                    <head>
                        <title> dup write </title>
                        default-stylesheet
                    </head>
                    <body>
                        over first
                        find-mode
                        load-mode
                        htmlize-lines
                    </body>
                </html>
            ] with-html-stream
        ] with-stream
    ] if ;
