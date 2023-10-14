USING: accessors ui ui.gadgets.labels ;
IN: hello-ui

MAIN-WINDOW: hello { { title "Hi" } }
    "Hello, world!" <label> >>gadgets ;
