USING: ui.gadgets.search-tables ui.gadgets.tables ui.gadgets models
arrays sequences tools.test ;

[ [ second ] <search-table> ] must-infer

{ t } [ f <model> trivial-renderer [ second ] <search-table> pref-dim pair? ] unit-test
