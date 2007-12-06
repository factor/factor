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

: htmlize-lines ( lines mode -- )
    f swap load-mode [ htmlize-line nl ] curry reduce drop ;

: default-stylesheet ( -- )
    <style>
        "extra/xmode/code2html/stylesheet.css"
        resource-path <file-reader> contents write
    </style> ;

: htmlize-stream ( path stream -- )
    lines swap
    <html>
        <head>
            default-stylesheet
            <title> dup write </title>
        </head>
        <body>
            <pre>
                over empty?
                [ 2drop ]
                [ over first find-mode htmlize-lines ] if
            </pre>
        </body>
    </html> ;

: htmlize-file ( path -- )
    dup <file-reader> over ".html" append <file-writer>
    [ htmlize-stream ] with-stream ;
