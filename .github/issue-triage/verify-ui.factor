USING: accessors io kernel namespaces prettyprint sequences system tools.test vocabs vocabs.loader vocabs.refresh ;
"ui.gestures" reload
"models" reload
"ui.gadgets.menus" reload
"ui.gadgets.presentations" reload
"ui.operations" reload
"ui.operations.syntax" require
"ui.tools.operations" reload
"ui.tools.listener" reload
"ui.gadgets.line-support" reload
"ui.gadgets.tables" reload
{ "ui.gestures" "models" "models.arrow" "models.product"
  "ui.tools.listener" "ui.gadgets.editors" "ui.gadgets.presentations"
  "ui.operations" "ui.gadgets.tables" "ui.gadgets.panes"
  "ui.gadgets.scrollers" "ui.gadgets.viewports" "ui.gadgets.buttons"
  "ui.commands" "ui.tools.operations" "ui.tools.inspector"
  "ui.tools.browser" "models.range" "models.mapping"
  "ui.backend.windows" } [ test ] each
test-failures get empty? [ "UI-FIXES-PASS" print 0 exit ] [ test-failures get [ [ path>> print ] [ error>> . ] bi ] each 1 exit ] if
