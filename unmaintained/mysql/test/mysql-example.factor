! See http://factorcode.org/license.txt for license.
! Simple test for mysql library
! libs/mysql/test/mysql-example.factor

IN: mysql-example
REQUIRES: libs/mysql ;
USING: sequences mysql modules prettyprint kernel io math tools namespaces test ;

"Testing..." print nl

: get-drop-table ( -- s )
       "DROP TABLE if exists DISCUSSION_FORUM" ;

: get-insert-table ( -- s )
    {
        "INSERT INTO DISCUSSION_FORUM(category, full_name, email, title, main_url, keywords, message) "
        "VALUES('none', 'John Doe', 'johndoe@test.com', 'The Message', NULL, NULL, 'Testing')"
    } "" join ;

: get-update-table ( -- s )
    "UPDATE DISCUSSION_FORUM set category = 'my-new-category'" ;
    
: get-delete-table ( -- s )
    "DELETE FROM DISCUSSION_FORUM where id = 2" ;

: get-create-table ( -- s )
    {
        "create table DISCUSSION_FORUM("
        "id                     int(11) NOT NULL auto_increment,"
        "category               varchar(128),"
        "full_name              varchar(128) NOT NULL,"
        "email                  varchar(128) NOT NULL,"
        "title                  varchar(255) NOT NULL,"
        "main_url               varchar(255),"
        "keywords               varchar(255),"
        "message                text NOT NULL,"
        "created_on             DATETIME NOT NULL DEFAULT '0000-00-0000:00:00',"
        "PRIMARY KEY (id));"
    } "" join ;

[ "localhost" "factoruser" "mysqlfactor" "factordb_development" 0 [
    get-drop-table mysql-command drop
    get-create-table mysql-command drop
    get-update-table mysql-command drop
    get-delete-table mysql-command drop
    
    ! Insert multiple records
    20 [
        get-insert-table mysql-command 2drop
    ] each
        
    "select * from discussion_forum order by created_on" mysql-query drop
    mysql-result>seq mysql-print-table

] with-mysql ] time

"Done" print