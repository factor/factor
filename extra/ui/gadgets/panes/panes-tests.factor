IN: temporary
USING: alien ui.gadgets.panes ui.gadgets namespaces
kernel sequences io io.streams.string tools.test prettyprint
definitions help help.syntax help.markup splitting ;

: #children "pane" get gadget-children length ;

[ ] [ <pane> "pane" set ] unit-test

[ ] [ #children "num-children" set ] unit-test

[ ] [
    "pane" get <pane-stream> [ 10000 [ . ] each ] with-stream*
] unit-test

[ t ] [ #children "num-children" get = ] unit-test

: test-gadget-text
    dup make-pane gadget-text
    swap string-out "\n" ?tail drop "\n" ?tail drop = ;

[ t ] [ [ "hello" write ] test-gadget-text ] unit-test
[ t ] [ [ "hello" pprint ] test-gadget-text ] unit-test
[ t ] [ [ [ 1 2 3 ] pprint ] test-gadget-text ] unit-test
[ t ] [ [ \ = see ] test-gadget-text ] unit-test
[ t ] [ [ \ = help ] test-gadget-text ] unit-test

ARTICLE: "test-article" "This is a test article"
"Hello world, how are you today."
{ $table { "a" "b" } { "c" "d" } } ;

[ t ] [ [ "test-article" help ] test-gadget-text ] unit-test

<pane> [ \ = see ] with-pane
<pane> [ \ = help ] with-pane
