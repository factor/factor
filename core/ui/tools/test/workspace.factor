IN: temporary
USING: gadgets-workspace namespaces sequences
gadgets-scrolling test gadgets ;

! Since this is a rarely used feature, it makes sense to unit
! test it to ensure it still works
[ ] [ <workspace> "w" set ] unit-test
[ ] [ "w" get tool-scroll-up ] unit-test
[ ] [ "w" get tool-scroll-down ] unit-test
[ t ] [
    "w" get workspace-book gadget-children
    [ tool-scroller ] map [ ] subset [ scroller? ] all?
] unit-test
