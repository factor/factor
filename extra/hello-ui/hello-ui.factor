USING: accessors ui ui.gadgets.labels ;
IN: hello-ui

MAIN-WINDOW: hello { { title "Hi" } }
    "Hello World" <label> >>gadgets ;
