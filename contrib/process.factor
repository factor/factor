IN: process
USING: compiler io io-internals kernel parser ;

FUNCTION: int system ( char* command ) ;

FUNCTION: void* popen ( char* command, char* type ) ;

: <process-stream> ( command mode -- stream )
    popen dup <c-stream> ;

: !" parse-string system drop ; parsing

PROVIDE: contrib/process ;
