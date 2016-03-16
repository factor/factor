! (c)2012 Joe Groff bsd license
USING: io.files.temp io.pathnames system ;
IN: io.files.temp.unix

M: unix default-temp-directory "/tmp/factor-temp" ;

M: unix default-cache-directory home ".factor-cache" append-path ;
