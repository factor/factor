USING: xmode.tokens xmode.marker xmode.catalog kernel locals
html.elements io io.files sequences words io.encodings.utf8
namespaces xml.entities accessors xml.interpolate locals xml.writer ;
IN: xmode.code2html

: htmlize-tokens ( tokens -- xml )
    [
        [ str>> ] [ id>> ] bi [
            name>> swap
            [XML <span class=<->><-></span> XML]
        ] [ ] if*
    ] map ;

: htmlize-line ( line-context line rules -- line-context' xml )
    tokenize-line htmlize-tokens ;

: htmlize-lines ( lines mode -- xml )
    f -rot load-mode [ htmlize-line ] curry map nip ;

: default-stylesheet ( -- xml )
    "resource:basis/xmode/code2html/stylesheet.css"
    utf8 file-contents
    [XML <style><-></style> XML] ;

:: htmlize-stream ( path stream -- xml )
    stream lines
    [ "" ] [ first find-mode path swap htmlize-lines ]
    if-empty :> input
    default-stylesheet :> stylesheet
    <XML <html>
        <head>
            <-stylesheet->
            <title><-path-></title>
        </head>
        <body>
            <pre><-input-></pre>
        </body>
    </html> XML> ;

: htmlize-file ( path -- )
    dup utf8 [
        dup ".html" append utf8 [
            input-stream get htmlize-stream write-xml
        ] with-file-writer
    ] with-file-reader ;
