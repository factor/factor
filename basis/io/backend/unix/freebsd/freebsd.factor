<<<<<<< HEAD
USING: io.backend io.backend.unix system namespaces kernel accessors assocs continuations unix init io.backend.unix.multiplexers io.backend.unix.multiplexers.kqueue vocabs io.files.unix ;

<< "io.files.unix" require >> ! needed for deploy

M: freebsd init-io ( -- )
   <kqueue-mx> mx set-global ;
   
freebsd set-io-backend

[ start-signal-pipe-thread ] 
"io.backend.unix:signal-pipe-thread" add-startup-hook
=======
USING: io.backend.unix.bsd io.backend system ;

freebsd set-io-backend
>>>>>>> da9226d5b5... Re-add Freebsd Support
