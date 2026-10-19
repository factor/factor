USING: init io.backend io.backend.unix io.backend.unix.multiplexers
io.backend.unix.multiplexers.select.haiku io.files.unix namespaces system vocabs ;
<< "io.files.unix" require >>
IN: io.backend.unix.haiku
M: haiku init-io <haiku-select-mx> mx set-global ;
haiku set-io-backend
STARTUP-HOOK: start-signal-pipe-thread
