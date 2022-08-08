USING: tools.test vin ;

{ t } [ "11111111111111111" valid-vin? ] unit-test
{ t } [ "1M8GDM9AXKP042788" valid-vin? ] unit-test
{ f } [ "1M8GDM9A_KP042788" valid-vin? ] unit-test
