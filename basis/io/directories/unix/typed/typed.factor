USING: accessors ;
IN: io.directories.unix
: dirent-file-type ( dirent -- file-type ) d_type>> dirent-type>file-type ; inline
