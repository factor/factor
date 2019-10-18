USING: ui.gadgets.lists models prettyprint math tools.test
kernel ;

{ } [
    [ drop ] [ 3 + . ] f <model> <list> invoke-value-action
] unit-test
