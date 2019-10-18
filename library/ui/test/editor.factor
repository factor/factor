USING: gadgets-text test kernel io definitions namespaces
gadgets ;

[ t ] [
    <editor> "editor" set
    "editor" get graft*
    "editor" get <plain-writer> [ \ = see ] with-stream
    "editor" get editor-text [ \ = see ] string-out =
    "editor" get ungraft*
] unit-test
