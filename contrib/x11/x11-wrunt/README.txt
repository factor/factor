Most of these files take their content from corresponding C files:
x.factor     -- X.h
xlib.factor  -- Xlib.h
xutil.factor -- Xutil.h
glx.factor   -- glx.h and glxtokens.h
keysymdef.factor -- keysymdef.h

x-events.factor defines x-event predicates (see lesson2.factor for usage)

Not all of these are complete, but they are complete to run lesson 2 of the
nehe opengl tutorials (and the other tutorials with small changes). To see a
demo run from factor's root dir:
  "contrib/x11/x11-wrunt/load.factor" run-file
  ( then wait for everything to compile... )
  USE: nehe
  main

Pressing 'q' or esc, or clicking the mouse will exit. If something goes wrong
you can kill off the window with:
  current-window get kill-gl-window
