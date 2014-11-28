USING: kernel vocabs ;
IN: json

SINGLETON: json-null

ERROR: json-error ;

: if-json-null ( x if-null else -- )
    [ dup json-null? ]
    [ [ drop ] prepose ]
    [ ] tri* if ; inline

: when-json-null ( x if-null -- ) [ ] if-json-null ; inline

: unless-json-null ( x else -- ) [ ] swap if-json-null ; inline

"json.reader" require
"json.writer" require
