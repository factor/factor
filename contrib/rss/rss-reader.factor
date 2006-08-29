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
USING: kernel html cont-responder namespaces sequences io hashtables sqlite errors tuple-db ;
   
TUPLE: reader-feed url title link ;
TUPLE: reader-entry url link title description pubdate ;

reader-feed default-mapping set-mapping
reader-entry default-mapping set-mapping

SYMBOL: db

: init-db ( -- )
  db get-global [ sqlite-close ] when*
  "rss-reader.db" exists? [
    "rss-reader.db" sqlite-open db set-global
  ] [
    "rss-reader.db" sqlite-open dup db set-global
    dup reader-feed create-tuple-table
    reader-entry create-tuple-table
  ] if ;

: add-feed ( url -- )
  "" "" <reader-feed> db get swap insert-tuple ;

: remove-feed ( url -- )
  f f <reader-feed> db get swap find-tuples [ db get swap delete-tuple ] each ;

: all-urls ( -- urls )
  f f f <reader-feed> db get swap find-tuples [ reader-feed-url ] map ;

: ask-for-url ( -- url )
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

: get-entries ( url -- entries )
  f f f f <reader-entry> db get swap find-tuples ;
  
: display-entries ( url -- )
  [
    <html> 
      <head> <title> "View entries for " write over write </title> </head>
      <body>
        swap get-entries [
         <h2> dup reader-entry-title write </h2>
         <p>
           reader-entry-description write
         </p>        
        ] each        
        <p> <a =href a> "Back" write </a> </p>
      </body>
    </html>
  ] show 2drop ;

: rss>reader-feed ( url rss -- reader-feed )
  [ rss-title ] keep rss-link <reader-feed> ;   

: rss-entry>reader-entry ( url entry -- reader-entry )
  [ rss-entry-link ] keep
  [ rss-entry-title ] keep
  [ rss-entry-description ] keep
  rss-entry-pub-date 
  <reader-entry> ;

: update-feed-database ( url -- )
  dup remove-feed
  dup rss-get 
  2dup rss>reader-feed db get swap save-tuple
  rss-entries [
    dupd rss-entry>reader-entry
    dup >r reader-entry-link f f f <reader-entry> db get swap find-tuples [ db get swap delete-tuple ] each r>
    db get swap save-tuple
  ] each-with ;

: update-feeds ( seq -- )
  [ update-feed-database ] each
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
            all-urls [
              <tr> 
                <td> dup write </td>
                <td> dup [ remove-feed ] curry "Remove" swap quot-href </td>
                <td> [ display-entries ] curry "Database" swap quot-href </td>
              </tr>
            ] each
          </table>
        </p>
        <p> "Add Feed" [ ask-for-url add-feed ] quot-href </p>
        <p> "Update Feeds" [ all-urls update-feeds ] quot-href </p>
      </body>
    </html>
  ] show-final ;

"maintain-feeds" [ init-db maintain-feeds ] install-cont-responder
