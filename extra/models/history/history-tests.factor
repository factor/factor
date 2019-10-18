USING: arrays generic kernel math models namespaces sequences assocs
tools.test models.history accessors ;

f <history> "history" set

"history" get add-history

{ t } [ "history" get back>> empty? ] unit-test
{ t } [ "history" get forward>> empty? ] unit-test

"history" get add-history
3 "history" get set-model

{ t } [ "history" get back>> empty? ] unit-test
{ t } [ "history" get forward>> empty? ] unit-test

"history" get add-history
4 "history" get set-model

{ f } [ "history" get back>> empty? ] unit-test
{ t } [ "history" get forward>> empty? ] unit-test

"history" get go-back

{ 3 } [ "history" get value>> ] unit-test

{ t } [ "history" get back>> empty? ] unit-test
{ f } [ "history" get forward>> empty? ] unit-test

"history" get go-forward

{ 4 } [ "history" get value>> ] unit-test

{ f } [ "history" get back>> empty? ] unit-test
{ t } [ "history" get forward>> empty? ] unit-test
