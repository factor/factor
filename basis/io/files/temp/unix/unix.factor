! Copyright (C) 2012 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: environment io.files.temp io.pathnames kernel sequences
system vocabs xdg ;
IN: io.files.temp.unix

M: unix default-temp-directory
    "TMPDIR" os-env [ "/tmp" ] when-empty "factor-temp" append-path ;

M: unix default-cache-directory
    xdg-cache-home "factor" append-path absolute-path ;

os macos? [ "io.files.temp.macos" require ] when
