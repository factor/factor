USING: help.markup help.syntax kernel arrays ;
IN: concurrency.mailboxes

HELP: <mailbox>
{ $values { "mailbox" mailbox } }
{ $description "A mailbox is an object that can be used for safe thread communication. Items can be put in the mailbox and retrieved in a FIFO order. If the mailbox is empty when a get operation is performed then the thread will block until another thread places something in the mailbox. If multiple threads are waiting on the same mailbox, only one of the waiting threads will be unblocked to thread the get operation." } ;

HELP: mailbox-empty?
{ $values { "mailbox" mailbox } 
          { "bool" "a boolean" }
}
{ $description "Return true if the mailbox is empty." } ;

HELP: mailbox-put
{ $values { "obj" object } 
          { "mailbox" mailbox } 
}
{ $description "Put the object into the mailbox. Any threads that have a blocking get on the mailbox are resumed. Only one of those threads will successfully get the object, the rest will immediately block waiting for the next item in the mailbox." } ;

HELP: block-unless-pred
{ $values { "pred" "a quotation with stack effect " { $snippet "( X -- bool )" } } 
          { "mailbox" mailbox }
          { "timeout" "a timeout in milliseconds, or " { $link f } }
}
{ $description "Block the thread if there are no items in the mailbox that return true when the predicate is called with the item on the stack." } ;

HELP: block-if-empty
{ $values { "mailbox" mailbox } 
      { "timeout" "a timeout in milliseconds, or " { $link f } }
}
{ $description "Block the thread if the mailbox is empty." } ;

HELP: mailbox-get
{ $values { "mailbox" mailbox } 
          { "obj" object }
}
{ $description "Get the first item put into the mailbox. If it is empty the thread blocks until an item is put into it. The thread then resumes, leaving the item on the stack." } ;

HELP: mailbox-get-all
{ $values { "mailbox" mailbox } 
          { "array" array }
}
{ $description "Blocks the thread if the mailbox is empty, otherwise removes all objects in the mailbox and returns an array containing the objects." } ;

HELP: while-mailbox-empty
{ $values { "mailbox" mailbox } 
          { "quot" "a quotation with stack effect " { $snippet "( -- )" } }
}
{ $description "Repeatedly call the quotation while there are no items in the mailbox." } ;

HELP: mailbox-get?
{ $values { "pred" "a quotation with stack effect " { $snippet "( X -- bool )" } }
          { "mailbox" mailbox } 
          { "obj" object }
}
{ $description "Get the first item in the mailbox which satisfies the predicate. 'pred' will be called repeatedly for each item in the mailbox. When 'pred' returns true that item will be returned. If nothing in the mailbox satisfies the predicate then the thread will block until something does." } ;


ARTICLE: "concurrency.mailboxes" "Mailboxes"
"A " { $emphasis "mailbox" } " is a first-in-first-out queue where the operation of removing an element blocks if the queue is empty, instead of throwing an error."
{ $subsection mailbox }
{ $subsection <mailbox> }
"Removing the first element:"
{ $subsection mailbox-get }
{ $subsection mailbox-get-timeout }
"Removing the first element matching a predicate:"
{ $subsection mailbox-get? }
{ $subsection mailbox-get-timeout? }
"Emptying out a mailbox:"
{ $subsection mailbox-get-all }
"Adding an element:"
{ $subsection mailbox-put }
"Testing if a mailbox is empty:"
{ $subsection mailbox-empty? }
{ $subsection while-mailbox-empty } ;
