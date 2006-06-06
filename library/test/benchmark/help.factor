USING: gadgets-panes help io kernel namespaces prettyprint
sequences test threads words ;

[
    all-articles [
        stdio get pane-clear
        dup global [ . flush ] bind
        [ dup help ] assert-depth drop
        1 sleep
    ] each
] time
