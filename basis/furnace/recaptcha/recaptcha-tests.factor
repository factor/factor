USING: furnace.recaptcha.private tools.test urls ;
IN: furnace.recaptcha.tests

{ t f } [ "{\"success\": true, \"challenge_ts\": \"2018-09-14T21:12:17Z\", \"hostname\": \"localhost\"}" parse-recaptcha-response ] unit-test
{ f { "invalid-input-secret" } } [ "{\"success\": false, \"error-codes\": [\"invalid-input-secret\"]}" parse-recaptcha-response ] unit-test
