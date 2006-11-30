IN: rpc-example
REQUIRES: contrib/http-client contrib/calendar ;
USING: kernel hashtables xml-rpc xml calendar sequences
    arrays math httpd io http-client namespaces ;

: functions
    H{ { "add" [ + ] }
       { "subtract" [ - ] }
       { "multiply" [ * ] }
       { "divide" [ / ] } } ;

: apply-function ( name args -- {number} )
    >r functions hash r> first2 rot call 1array ;

: problem>solution ( xml-doc -- xml-doc )
    receive-rpc dup rpc-method-name swap rpc-method-params
    apply-function <rpc-response> send-rpc ;

: put-http-response ( string -- )
    "HTTP/1.1 200 OK\nConnection: close\nContent-Length: " write
    dup length number>string write
    "\nContent-Type: text/xml\nDate: " write
    now timestamp>http-string write "\n\n" write
    write ;

: respond-rpc-arith ( -- )
    "raw-response" get
    string>xml problem>solution xml>string
    put-http-response ;

: test-rpc-arith
    "add" { 1 2 } <rpc-method> send-rpc xml>string
    "text/xml" swap "http://localhost:8080/responder/rpc/"
    http-post ;
