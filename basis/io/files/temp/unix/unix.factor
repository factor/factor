! (c)2012 Joe Groff bsd license
USING: io.files.temp io.pathnames system xdg ;
IN: io.files.temp.unix

M: unix default-temp-directory "/tmp/factor-temp" ;

M: unix default-cache-directory xdg-cache-home ".factor" append-path ;
