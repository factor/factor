IN: process
USING: compiler io io-internals kernel parser generic ;

LIBRARY: libc
FUNCTION: int system ( char* command ) ;
FUNCTION: void* popen ( char* command, char* type ) ;
FUNCTION: int pclose ( void* file ) ;

: run-process ( string -- ) system io-error ;
: run-detached ( string -- ) " &" append run-process ;

