! Copyright (C) 2010 Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.libraries io.pathnames io.pathnames.private kernel
system vocabs ;
IN: tools.deploy.libraries

HOOK: find-library-file os ( file -- path )

os windows?
"tools.deploy.libraries.windows"
"tools.deploy.libraries.unix" ? require
