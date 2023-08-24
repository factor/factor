USING: tokencase tools.test ;

{ "myNameIsFactor" } [ "My-name.Is_Factor" >camelcase ] unit-test
{ "MyNameIsFactor" } [ "My-name.Is_Factor" >pascalcase ] unit-test
{ "my_name_is_factor" } [ "My-name.Is_Factor" >snakecase ] unit-test
{ "My_Name_Is_Factor" } [ "My-name.Is_Factor" >adacase ] unit-test
{ "MY_NAME_IS_FACTOR" } [ "My-name.Is_Factor" >macrocase ] unit-test
{ "my-name-is-factor" } [ "My-name.Is_Factor" >kebabcase ] unit-test
{ "My-Name-Is-Factor" } [ "My-name.Is_Factor" >traincase ] unit-test
{ "MY-NAME-IS-FACTOR" } [ "My-name.Is_Factor" >cobolcase ] unit-test
{ "my name is factor" } [ "My-name.Is_Factor" >lowercase ] unit-test
{ "MY NAME IS FACTOR" } [ "My-name.Is_Factor" >uppercase ] unit-test
{ "My Name Is Factor" } [ "My-name.Is_Factor" >titlecase ] unit-test
{ "My name is factor" } [ "My-name.Is_Factor" >sentencecase ] unit-test
{ "my.name.is.factor" } [ "My-name.Is_Factor" >dotcase ] unit-test
