
USING: kernel parser namespaces threads arrays sequences unix unix.process
       combinators.cleave bake ;

IN: raptor

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: boot-hook
SYMBOL: reboot-hook
SYMBOL: shutdown-hook
SYMBOL: networking-hook

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: reload-raptor-config ( -- )
  "/etc/raptor/config.factor" run-file
  "/etc/raptor/cronjobs.factor" run-file ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: fork-exec-wait ( pathname args -- )
  fork dup 0 = [ drop exec drop ] [ 2nip wait-for-pid drop ] if ;

: fork-exec-args-wait ( args -- ) [ first ] [ ] bi fork-exec-wait ;

: fork-exec-arg ( arg -- ) 1array [ fork-exec-args-wait ] curry in-thread ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: forever ( quot -- ) [ call ] [ forever ] bi ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: start-service ( name -- ) "/etc/init.d/" swap " start" 3append system drop ;
: stop-service  ( name -- ) "/etc/init.d/" swap " stop"  3append system drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: getty ( tty -- ) `{ "/sbin/getty" "38400" , } fork-exec-args-wait ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

USING: io io.files io.streams.lines io.streams.plain io.streams.duplex
       listener ;

: tty-listener ( tty -- )
  [ <file-reader> ] [ <file-writer> ] bi <duplex-stream>
  [ listener ] with-stream ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

USING: unix.linux.swap unix.linux.fs ;

SYMBOL: root-device
SYMBOL: swap-devices

: activate-swap ( -- ) swap-devices get [ 0 swapon drop ] each ;

: mount-root ( -- ) root-device get "/" "ext3" MS_REMOUNT f mount drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: start-networking ( -- ) networking-hook  get call ;

: set-hostname ( name -- ) `{ "/bin/hostname" , } fork-exec-args-wait ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: boot     ( -- ) boot-hook     get call ;
: reboot   ( -- ) reboot-hook   get call ;
: shutdown ( -- ) shutdown-hook get call ;

MAIN: boot

