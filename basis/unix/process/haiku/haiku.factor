! Haiku's sys/wait.h encodes exit, termination and stop status separately.
USING: kernel math ;
IN: unix.process

CONSTANT: WCONTINUED 0x04
CONSTANT: WEXITED 0x08
CONSTANT: WSTOPPED 0x10
CONSTANT: WNOWAIT 0x20

: WTERMSIG ( status -- value )
    -8 shift 0xff bitand ; inline

: WIFEXITED ( status -- ? )
    0xff bitnot bitand 0 = ; inline

: WEXITSTATUS ( status -- value )
    0xff bitand ; inline

: WIFSIGNALED ( status -- ? )
    WTERMSIG 0 = not ; inline

: WCOREFLAG ( -- value )
    0x10000 ; inline

: WCOREDUMP ( status -- ? )
    WCOREFLAG bitand 0 = not ; inline

: WIFSTOPPED ( status -- ? )
    -16 shift 0xff bitand 0 = not ; inline

: WSTOPSIG ( status -- value )
    -16 shift 0xff bitand ; inline

: WIFCONTINUED ( status -- ? )
    0x20000 bitand 0 = not ; inline
