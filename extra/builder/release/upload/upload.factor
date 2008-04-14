
USING: kernel namespaces io io.files
       builder.util
       builder.common
       builder.release.archive ;

IN: builder.release.upload

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: remote-location ( -- dest )
  "factorcode.org:/var/www/factorcode.org/newsite/downloads"
  platform
  append-path ;

: (upload) ( -- )
  { "scp" archive-name remote-location } to-strings
  [ "Error uploading binary to factorcode" print ]
  run-or-bail ;

: upload ( -- )
  upload-to-factorcode get
    [ (upload) ]
  when ;
