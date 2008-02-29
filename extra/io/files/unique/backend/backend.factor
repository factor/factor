USING: io.backend ;
IN: io.files.unique.backend

HOOK: (make-unique-file) io-backend ( prefix suffix -- stream path )
HOOK: temporary-path io-backend ( -- path )
