USING: kernel namespaces ;
IN: vim

: vim-command ( file line -- string )
    [
        "\"" % vim-path get % "\" --remote-tab-silent " %
        "+" % # " \"" % % "\"" %
    ] "" make ;
