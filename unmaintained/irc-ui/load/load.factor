! Copyright (C) 2008 William Schlieper
! See http://factorcode.org/license.txt for BSD license.

USING: kernel io.files io.pathnames parser editors sequences ;

IN: irc.ui.load

: file-or ( path path -- path ) [ [ exists? ] keep ] dip ? ;

: personal-ui-rc ( -- path ) home ".ircui-rc" append-path ;

: system-ui-rc ( -- path ) "extra/irc/ui/ircui-rc" resource-path ;

: ircui-rc ( -- path ) personal-ui-rc system-ui-rc file-or ;

: run-ircui ( -- ) ircui-rc run-file ;
