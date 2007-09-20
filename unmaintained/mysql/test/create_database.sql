--
-- Create three databases (development / test / production) 
-- with prefix 'factordb_'
create database factordb_development;
create database factordb_test;
create database factordb_production;

grant all on factordb_development.* to 'factoruser'@'localhost' identified by 'mysqlfactor';
grant all on factordb_test.* to 'factoruser'@'localhost' identified by 'mysqlfactor';
grant all on factordb_production.* to 'factoruser'@'localhost' identified by 'mysqlfactor';

grant all on factordb_development.* to 'factoruser'@'*' identified by 'mysqlfactor';
grant all on factordb_test.* to 'factoruser'@'*' identified by 'mysqlfactor';
grant all on factordb_production.* to 'factoruser'@'*' identified by 'mysqlfactor';

-- End of the Script

