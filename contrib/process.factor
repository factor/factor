IN: process
USING: compiler io io-internals kernel parser ;

FUNCTION: int system ( char* command ) ; compiled

FUNCTION: void* popen ( char* command, char* type ) ; compiled

: <process-stream> ( command mode -- stream )
    popen dup <c-stream> ;

: !" parse-string system drop ; parsing
