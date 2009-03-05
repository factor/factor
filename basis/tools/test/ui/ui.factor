USING: dlists ui.gadgets ui.gadgets.private
kernel ui namespaces io.streams.string io ;
IN: tools.test.ui

! We can't print to output-stream here because that might be a pane
! stream, and our graft-queue rebinding here would be captured
! by code adding children to the pane...
: with-grafted-gadget ( gadget quot -- )
    [
        <dlist> \ graft-queue [
            over
            graft notify-queued
            dip
            ungraft notify-queued
        ] with-variable
    ] with-string-writer print ;
