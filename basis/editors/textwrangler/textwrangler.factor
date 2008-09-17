! Copyright (C) 2008 Ben Schlingelhof.
! See http://factorcode.org/license.txt for BSD license.
USING: definitions io.launcher kernel parser words sequences
math math.parser namespaces editors make ;
IN: editors.textwrangler

: tw ( file line -- )
    [ "edit +" % # " " % % ] "" make run-process drop ;

: tw-word ( word -- )
    where first2 tw ;

[ tw ] edit-hook set-global
