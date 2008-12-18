
USING: kernel sequences sets combinators.cleave
       obj obj.view obj.util obj.print ;

IN: obj.examples.todo

SYM: person types adjoin
SYM: todo   types adjoin

SYM: owners properties adjoin
SYM: eta    properties adjoin
SYM: notes  properties adjoin

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYM: slava { type person } define-object
SYM: doug  { type person } define-object
SYM: ed    { type person } define-object

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYM: compiler-bugs
  {
    type todo
    owners { slava }
    notes  {
             "Investitage FEP on Terrorist"
             "Problem with cutler in VirtualBox?"
           }
  }
define-object

SYM: remove-old-accessors-from-core
  {
    type todo
    owners { slava }
  }
define-object

SYM: move-db-and-web-framework-to-basis
  {
   type todo
   owners { slava }
  }
define-object

SYM: remove-old-accessors-from-basis
  {
    type todo
    owners { doug ed }
  }
define-object

SYM: blas-on-bsd
  {
    type todo
    owners { slava doug }
  }
define-object

SYM: multi-methods-backend
  {
    type todo
    owners { slava }
  }
define-object

SYM: update-core-for-multi-methods { type todo owners { slava } } define-object
SYM: update-basis-for-multi-methods { type todo } define-object
SYM: update-extra-for-multi-methods { type todo } define-object


! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: todo-list ( -- )
  objects [ type -> todo = ] filter
    [ { [ self -> ] [ owners -> ] [ eta -> ] } 1arr ]
  map
  { "ITEM" "OWNERS" "ETA" } prefix
  print-table ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

