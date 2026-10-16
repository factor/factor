USING: io.files.types kernel ;
IN: io.directories.unix

! illumos dirent has no d_type field. The caller resolves unknown entries
! through link-info after extracting the name.
: dirent-file-type ( dirent -- file-type ) drop +unknown+ ; inline
