! Copyright (C) 2011 John Benediktsson
! See https://factorcode.org/license.txt for BSD license
USING: combinators.short-circuit io.pathnames kernel ui.operations
urls webbrowser ;
IN: webbrowser.ui

[ pathname? ] \ open-item H{ } define-operation
[ [ url? ] [ url-string? ] bi or ] \ open-url H{ } define-operation
