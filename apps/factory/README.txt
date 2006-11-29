----------------------------------------------------------------------
Running factory in Xnest
----------------------------------------------------------------------

In a terminal, run Xnest using an unused display number. Usually you
can use 2 or greater.

  $ Xnest -auth /dev/null :2

Start factor and launch factory on the appropriate display:

  "libs/factory" run-module

In a terminal, start an application on the appropriate display:

  $ DISPLAY=:2 xterm

----------------------------------------------------------------------
The mouse functions
----------------------------------------------------------------------

Root window
Mouse-1		Toggle root menu
Mouse-2		Toggle window list

Window border
Mouse-1		Drag to move window
Mouse-2		Drag to resize window (specify bottom right corner)
Mouse-3		Hide window (use window list to get it back)
