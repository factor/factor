USING: continuations namespaces sequences kernel ui
ui.gadgets.worlds ;

[
    "Error"
    "The application encountered an error it cannot recover from and will now exit."
    system-alert die
]
[ ui-error-hook set-global ]
[ callback-error-hook set-global ]
[ [ drop ] prepose thread-error-hook set-global ] tri
