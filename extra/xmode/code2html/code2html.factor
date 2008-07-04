USING: xmode.tokens xmode.marker xmode.catalog kernel
html.elements io io.files sequences words io.encodings.utf8
namespaces xml.entities accessors ;
IN: xmode.code2html

: htmlize-tokens ( tokens -- )
    [
        [ str>> ] [ id>> ] bi [
            <span name>> =class span> escape-string write </span>
        ] [
            escape-string write
        ] if*
    ] each ;

: htmlize-line ( line-context line rules -- line-context' )
    tokenize-line htmlize-tokens ;

: htmlize-lines ( lines mode -- )
    f swap load-mode [ htmlize-line nl ] curry reduce drop ;

: default-stylesheet ( -- )
    <style>
        "resource:extra/xmode/code2html/stylesheet.css"
        utf8 file-contents escape-string write
    </style> ;

: htmlize-stream ( path stream -- )
    lines swap
    <html>
        <head>
            default-stylesheet
            <title> dup escape-string write </title>
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
    dup utf8 [
        dup ".html" append utf8 [
            input-stream get htmlize-stream
        ] with-file-writer
    ] with-file-reader ;
