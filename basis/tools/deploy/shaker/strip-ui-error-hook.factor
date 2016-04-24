USING: continuations namespaces sequences kernel ui
ui.gadgets.worlds system ;

[
    "Error"
    "The application encountered an error it cannot recover from and will now exit."
    [ system-alert ] ignore-errors
    die 1 exit
]
[ ui-error-hook set-global ]
[ callback-error-hook set-global ]
[ [ drop ] prepose thread-error-hook set-global ] tri
