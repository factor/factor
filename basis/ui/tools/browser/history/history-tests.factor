USING: namespaces ui.tools.browser.history sequences tools.test
accessors kernel ;
IN: ui.tools.browser.history.tests

TUPLE: dummy obj ;

M: dummy history-value obj>> ;
M: dummy set-history-value obj<< ;

dummy new <history> "history" set

"history" get add-history

{ t } [ "history" get back>> empty? ] unit-test
{ t } [ "history" get forward>> empty? ] unit-test

"history" get add-history
3 "history" get owner>> set-history-value

{ t } [ "history" get back>> empty? ] unit-test
{ t } [ "history" get forward>> empty? ] unit-test

"history" get add-history
4 "history" get owner>> set-history-value

{ f } [ "history" get back>> empty? ] unit-test
{ t } [ "history" get forward>> empty? ] unit-test

"history" get go-back

{ 3 } [ "history" get owner>> history-value ] unit-test

{ t } [ "history" get back>> empty? ] unit-test
{ f } [ "history" get forward>> empty? ] unit-test

"history" get go-forward

{ 4 } [ "history" get owner>> history-value ] unit-test

{ f } [ "history" get back>> empty? ] unit-test
{ t } [ "history" get forward>> empty? ] unit-test
