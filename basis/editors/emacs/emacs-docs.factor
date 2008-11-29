USING: help help.syntax help.markup ;
IN: editors.emacs

ARTICLE: "editors.emacs" "Integration with Emacs"
"Put this in your " { $snippet ".emacs" } " file:"
{ $code "(server-start)" }
"If you would like a new window to open when you ask Factor to edit an object, put this in your " { $snippet ".emacs" } " file:"
{ $code "(setq server-window 'switch-to-buffer-other-frame)" }
{ $see-also "editor" } ;

ABOUT: "editors.emacs"