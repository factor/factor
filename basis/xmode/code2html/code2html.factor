USING: accessors io io.encodings.utf8 io.files kernel namespaces
sequences xml.syntax xml.writer xmode.catalog xmode.marker ;
IN: xmode.code2html

: htmlize-tokens ( tokens -- xml )
    [
        [ str>> ] [ id>> ] bi [
            name>> swap
            [XML <span class=<->><-></span> XML]
        ] when*
    ] map ;

: htmlize-line ( line-context line rules -- line-context' xml )
    tokenize-line htmlize-tokens ;

: htmlize-lines ( lines mode -- xml )
    [ f ] 2dip load-mode [ htmlize-line ] curry map nip
    { "\n" } join ;

: default-stylesheet ( -- xml )
    "resource:basis/xmode/code2html/stylesheet.css"
    utf8 file-contents
    [XML <style><-></style> XML] ;

:: htmlize-stream ( path stream -- xml )
    stream stream-lines
    [ "" ] [ path over first find-mode htmlize-lines ]
    if-empty :> input
    default-stylesheet :> stylesheet
    <XML <!DOCTYPE html> <html>
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
