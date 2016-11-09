! (c)2012 Joe Groff bsd license
USING: environment io.files.temp io.pathnames sequences system
xdg ;
IN: io.files.temp.unix

M: unix default-temp-directory
    "TMPDIR" os-env [ "/tmp" ] when-empty "factor-temp" append-path ;

M: unix default-cache-directory xdg-cache-home ".factor" append-path ;
