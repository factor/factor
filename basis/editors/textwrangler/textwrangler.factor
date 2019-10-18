! Copyright (C) 2008 Ben Schlingelhof.
! See http://factorcode.org/license.txt for BSD license.
USING: definitions io.launcher kernel parser words sequences
math math.parser namespaces editors make ;
IN: editors.textwrangler

SINGLETON: textwrangler
textwrangler editor-class set-global

M: textwrangler editor-command ( file line -- command )
    [ "edit +" % # " " % % ] "" make ;
