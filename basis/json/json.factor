USING: kernel vocabs summary debugger io ;
IN: json

SINGLETON: json-null

ERROR: json-error ;

ERROR: json-fp-special-error value ;
M: json-fp-special-error summary drop "JSON serialization: illegal float:" ;

: if-json-null ( x if-null else -- )
    [ dup json-null? ]
    [ [ drop ] prepose ]
    [ ] tri* if ; inline

: when-json-null ( x if-null -- ) [ ] if-json-null ; inline

: unless-json-null ( x else -- ) [ ] swap if-json-null ; inline

"json.reader" require
"json.writer" require
