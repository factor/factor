
USING: kernel parser namespaces threads unix.process combinators.cleave ;

IN: raptor

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: boot-hook
SYMBOL: reboot-hook
SYMBOL: shutdown-hook
SYMBOL: networking-hook

: reload-raptor-config ( -- )
  "/etc/raptor/config.factor" run-file
  "/etc/raptor/cronjobs.factor" run-file ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

USING: sequences unix ;

: start-service ( name -- ) "/etc/init.d/" swap " start" 3append system drop ;
: stop-service  ( name -- ) "/etc/init.d/" swap " stop"  3append system drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: fork-exec-wait ( pathname args -- )
  fork dup 0 = [ drop exec drop ] [ 2nip wait-for-pid ] if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: respawn ( pathname args -- ) [ fork-exec-wait ] [ respawn ] 2bi ;

: start-gettys ( -- )
  [ "/sbin/getty" { "getty" "38400" "tty5" } respawn ] in-thread
  [ "/sbin/getty" { "getty" "38400" "tty6" } respawn ] in-thread ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

USING: io io.files io.streams.lines io.streams.plain io.streams.duplex
       listener ;

: tty-listener ( tty -- )
  [ <file-reader> ] [ <file-writer> ] bi <duplex-stream>
  [ listener ] with-stream ;

: forever ( quot -- ) [ call ] [ forever ] bi ;

: start-listeners ( -- )
  [ [ "/dev/tty2" tty-listener ] forever ] in-thread
  [ [ "/dev/tty3" tty-listener ] forever ] in-thread
  [ [ "/dev/tty4" tty-listener ] forever ] in-thread ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: start-networking ( -- ) networking-hook  get call ;

: boot     ( -- ) boot-hook     get call ;
: reboot   ( -- ) reboot-hook   get call ;
: shutdown ( -- ) shutdown-hook get call ;

MAIN: boot
