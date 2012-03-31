! (c)2012 Joe Groff bsd license
USING: io.directories io.files.temp io.pathnames kernel memoize
system ;
IN: io.files.temp.unix

MEMO: (temp-directory) ( -- path )
    "/tmp/factor-temp" dup make-directories ;

M: unix temp-directory (temp-directory) ;

MEMO: (cache-directory) ( -- path )
    home ".factor-cache" append-path dup make-directories ;

M: unix cache-directory (cache-directory) ;
