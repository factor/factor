USING: io.backend ;
IN: io.files.unique.backend

HOOK: (make-unique-file) io-backend ( path -- stream )
HOOK: temporary-path io-backend ( -- path )
