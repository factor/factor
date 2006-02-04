USING: compiler io io-internals kernel parser ;

FUNCTION: int system ( char* command ) ; compiled

FUNCTION: void* popen ( char* command, char* type ) ; compiled

FUNCTION: int fileno ( void* file ) ; compiled

: <process-stream> ( command mode -- stream )
    popen fileno dup <fd-stream> ;

: !" parse-string system drop ; parsing
