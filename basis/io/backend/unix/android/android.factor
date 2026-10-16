USING: init io.backend io.backend.unix io.backend.unix.linux
io.backend.unix.multiplexers io.backend.unix.multiplexers.epoll
kernel namespaces system ;
IN: io.backend.unix.android

M: android init-io <epoll-mx> mx set-global ;

android set-io-backend

STARTUP-HOOK: start-signal-pipe-thread
