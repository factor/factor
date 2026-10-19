USING: init io.backend io.backend.unix io.backend.unix.multiplexers
io.backend.unix.multiplexers.select io.files.unix namespaces system ;
IN: io.backend.unix.illumos

M: illumos init-io <select-mx> mx set-global ;
illumos set-io-backend
STARTUP-HOOK: start-signal-pipe-thread
