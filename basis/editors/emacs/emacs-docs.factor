USING: help help.syntax help.markup ;
IN: editors.emacs

ARTICLE: "editors.emacs" "Integration with Emacs"
"Full Emacs integration with Factor requires the use of two executable files -- " { $snippet "emacs" } " and " { $snippet "emacsclient" } ", which act as a client/server pair. To start the server, run the " { $snippet "emacs" } " binary and run " { $snippet "M-x server-start" } " or start " { $snippet "emacs" } " with the following line in your " { $snippet ".emacs" } " file:"
{ $code "(server-start)" }
"On Windows, if you install Emacs to " { $snippet "Program Files" } " or " { $snippet "Program Files(x86)" } ", Factor will automatically detect the path to " { $snippet "emacsclient.exe" } ". On Unix systems, make sure that " { $snippet "emacsclient" } " is in your path. To set the path manually, use the following snippet:"
{ $code "USE: edtiors.emacs"
        "\"/my/crazy/bin/emacsclient\" emacsclient-path set-global"
}

"If you would like a new window to open when you ask Factor to edit an object, put this in your " { $snippet ".emacs" } " file:"
{ $code "(setq server-window 'switch-to-buffer-other-frame)" }

"To quickly scaffold a " { $snippet ".emacs" } " file, run the following code:"
{ $code "USE: tools.scaffold"
    "scaffold-emacs"
}

{ $see-also "editor" }

;

ABOUT: "editors.emacs"
