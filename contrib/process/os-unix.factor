IN: process
USING: compiler io io-internals kernel parser generic ;

LIBRARY: libc
FUNCTION: int system ( char* command ) ;
FUNCTION: void* popen ( char* command, char* type ) ;
FUNCTION: int pclose ( void* file ) ;

: run-process ( string -- ) system io-error ;
: run-detached ( string -- ) " &" append run-process ;

TUPLE: process-stream pipe ;

C: process-stream ( command mode -- stream )
  >r popen dup r>
  [ set-process-stream-pipe ] keep
  >r dup <duplex-c-stream> r> 
  [ set-delegate ] keep ;

M: process-stream stream-close 
  process-stream-pipe [ pclose drop ] when* ;

: !" parse-string system drop ; parsing
