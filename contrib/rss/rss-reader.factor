! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
! Create a test database like follows:
!
!   sqlite3 history.db
!   > create table rss (url text, title text, link text, primary key (url));
!   > create table entries (url text, link text, title text, description text, pubdate text, primary key(url, link));
!   > [eof]
!
IN: rss
USING: kernel html cont-responder namespaces sequences io hashtables sqlite errors ;
   
SYMBOL: feeds

: init-feeds ( -- )
  V{ } clone feeds set-global ;

: add-feed ( url -- )
  feeds get push ;

: remove-feed ( url -- )
  feeds get remove feeds set-global ;

: get-feed ( -- url )
  [
    <html>
      <head> <title> "Enter a Feed URL" write </title> </head>
      <body>
        <form =action "post" =method form>
          "URL: " write
          <input "text" =type "url" =name "100" =size input/>
          <input "submit" =type input/>
        </form>
      </body>
    </html>
  ] show "url" swap hash ;

: get-entries ( url -- )
  "history.db" sqlite-open  ( db )
  "select * from entries where url='" rot append "'" append dupd sqlite-prepare ( db stmt )
  [ [ [ 2 column-text ] keep 
      [ 1 column-text ] keep 
      [ 3 column-text ] keep 
      4 column-text <rss-entry>
    ] sqlite-map 
  ] keep
  sqlite-finalize
  swap sqlite-close ;  
  
: view-entries ( url -- )
  [
    <html> 
      <head> <title> "View entries for " write over write </title> </head>
      <body>
        swap get-entries [
         <h2> dup rss-entry-title write </h2>
         <p>
           rss-entry-description write
         </p>        
        ] each        
        <p> <a =href a> "Back" write </a> </p>
      </body>
    </html>
  ] show 2drop ;

: rss-delete-statement ( url -- string )
  [
    "delete from rss where url='" % % "';" % ] "" make ;

: rss-insert-statement ( url rss -- string )
  [
    "insert into rss values('" % swap % "','" %
    [ rss-title "'" "''" rot replace % "','" % ] keep
    rss-link % "');" %   
  ] "" make ;

: entry-delete-statement ( url entry -- string )
  [    
    "delete from entries where url='" % swap % "' and link='" %
    rss-entry-link "'" "''" rot replace % "';" % 
  ] "" make ;

: entry-insert-statement ( url entry -- string )
  [    
    "insert into entries values('" % swap % "','" %
    [ rss-entry-link "'" "''" rot replace % "','" % ] keep
    [ rss-entry-title "'" "''" rot replace % "','" % ] keep
    [ rss-entry-description "'" "''" rot replace % "','" % ] keep
    rss-entry-pub-date "'" "''" rot replace % "');" %   
  ] "" make ;
  
: do-update ( string -- )
  "history.db" sqlite-open  ( db )
  dup rot sqlite-prepare [ [ drop ] sqlite-each ] keep
  sqlite-finalize
  sqlite-close ;

: update-feed-database ( url rss -- )
  over rss-delete-statement do-update
  2dup rss-insert-statement do-update ( url rss - )
  rss-entries [ ( url entry )
    2dup entry-delete-statement do-update
    entry-insert-statement do-update
  ] each-with ;

: update-feeds ( seq -- )
  [
    [
      dup rss-get
    ] catch [
      update-feed-database
    ] unless 
  ] each 
  [
    <html>
      <head> <title> "Feeds Updated" write </title> </head>
      <body>
        <p> "Feeds Updated." write </p>
        <p> <a =href a> "Back" write </a> </p>
      </body>
    </html>          
  ] show drop ;
  
: maintain-feeds ( -- )
  [
    <html>
      <head> <title> "Maintain Feeds" write </title> </head>
      <body>
	<p>
          <table "1" =border table>
            feeds get [
              <tr> 
                <td> dup write </td>
                <td> dup [ remove-feed ] curry "Remove" swap quot-href </td>
                <td> [ view-entries ] curry "Database" swap quot-href </td>
              </tr>
            ] each
          </table>
        </p>
        <p> "Add Feed" [ get-feed add-feed ] quot-href </p>
        <p> "Update Feeds" [ feeds get update-feeds ] quot-href </p>
      </body>
    </html>
  ] show-final ;

init-feeds


"maintain-feeds" [ maintain-feeds ] install-cont-responder
