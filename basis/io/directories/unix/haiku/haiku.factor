USING: accessors alien.strings io.files.info ;
IN: io.directories.unix
! Haiku has no d_type; lstat preserves symbolic links, including broken links.
: dirent-file-type ( dirent -- file-type )
    d_name>> alien>native-string link-info type>> ; inline
