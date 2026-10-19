USING: alien.c-types alien.syntax unix.types ;
IN: unix.process

FUNCTION-ALIAS: sigaddset int __sigaddset14 ( sigset_t* set, int signo )
FUNCTION-ALIAS: sigdelset int __sigdelset14 ( sigset_t* set, int signo )
FUNCTION-ALIAS: sigemptyset int __sigemptyset14 ( sigset_t* set )
FUNCTION-ALIAS: sigfillset int __sigfillset14 ( sigset_t* set )
FUNCTION-ALIAS: sigismember int __sigismember14 ( sigset_t* set, int signo )
