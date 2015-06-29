USING: namespaces debugger io.files io.directories
bootstrap.image update.util ;
IN: update.backup

: backup-boot-image ( -- )
  my-boot-image-name
  { "boot." my-arch "-" [ "datestamp" get ] ".image" } to-string
  move-file ;

: backup-image ( -- )
  "factor.image"
  { "factor" "-" [ "datestamp" get ] ".image" } to-string
  move-file ;

: backup-vm ( -- )
  "factor"
  { "factor" "-" [ "datestamp" get ] } to-string
  move-file ;

: backup ( -- )
  datestamp "datestamp" set
    [
      backup-boot-image
      backup-image
      backup-vm
    ]
  try ;
