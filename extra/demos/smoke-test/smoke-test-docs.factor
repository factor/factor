USING: help.markup help.syntax ;
IN: demos.smoke-test

ARTICLE: "demo-smoke-tests" "Checking the demos"
"Run the graphical smoke suite with a display available:"
{ $code "./factor -no-user-init -run=demos.smoke-test" }
"The suite checks every Demos menu entry against its inventory, runs the self-contained graphical and console demos, and loads entries that need external resources. It reports those entries as runtime untested, rather than counting them as passing. Raylib libraries, arcade ROM files, and physical controllers need separate runtime verification; the TTY servers are loaded without starting network listeners."
"Each runnable demo is checked for new compilation and linkage errors before it can pass. Graphical checks cover nonblank frames, resizing, native macOS WASD and Terrain controls, input capture, and closing. Existing core-profile windows are drawn between compatibility-profile frames. The suite also checks Bunny's three rendering modes, the NeHe and Bubble Chamber submenus, all UI Demo sections, controller indicator widgets without hardware, and the OpenGL triangle."
"To check a subset of graphical demos:"
{ $code "./factor -no-user-init -run=demos.smoke-test bunny terrain pong" }
"To render the graphical demos, submenu scenes, and UI sections in both light and dark themes:"
{ $code "./factor -no-user-init -run=demos.smoke-test --themes" }
"The theme option also accepts a subset, such as periodic-table boids game-of-life."
"A failure exits with status 1. Successful checks exit with status 0. macOS cannot run the OpenGL 4.5 compute example; its launcher explains the unsupported requirement before allocating resources." ;

ABOUT: "demo-smoke-tests"
