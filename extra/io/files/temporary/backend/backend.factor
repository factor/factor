USING: io.backend ;
IN: io.files.temporary.backend

HOOK: (temporary-file) io-backend ( path -- stream path )
HOOK: temporary-path io-backend ( -- path )
