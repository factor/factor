! As reported in #1691 and #1692
USING: ui ui.gadgets.labels ui.gadgets.scrollers ;
IN: tools.deploy.test.23

: (main) ( -- )
  "test" <label> <scroller> "test" open-window ;

: main ( -- )
  [ (main) ] with-ui ;

MAIN: main
