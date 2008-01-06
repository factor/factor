! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.deploy.backend system vocabs.loader kernel ;
IN: tools.deploy

: deploy ( vocab -- ) deploy* ;

macosx? [ "tools.deploy.macosx" require ] when
winnt? [ "tools.deploy.windows" require ] when
