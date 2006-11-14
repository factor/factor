USING: gadgets-panes hashtables help io kernel namespaces
prettyprint sequences test threads words ;

[
    all-articles [
        stdio get duplex-stream-out pane-stream-pane pane-clear
        dup global [ . flush ] bind
        [ dup help ] assert-depth drop
        1 sleep
    ] each
] time
