# Factor

Factor is a [concatenative](http://www.concatenative.org), stack-based
programming language with [high-level
features](http://concatenative.org/wiki/view/Factor/Features/The%20language)
including dynamic types, extensible syntax, macros, and garbage collection.
On a practical side, Factor has a [full-featured
library](http://docs.factorcode.org/content/article-vocab-index.html),
supports many different platforms, and has been extensively documented. 

The implementation is [fully
compiled](http://concatenative.org/wiki/view/Factor/Optimizing%20compiler)
for performance, while still supporting [interactive
development](http://concatenative.org/wiki/view/Factor/Interactive%20development).
Factor applications are portable between all common platforms.  Factor can
[deploy stand-alone
applications](http://concatenative.org/wiki/view/Factor/Deployment) on all
platforms.  Full source code for the Factor project is available under a BSD
license.

## Getting Started

### Building Factor from source

If you have a build environment set up, then you can build Factor from git.
These scripts will attempt to compile the Factor binary and bootstrap from
a boot image stored on factorcode.org.

To check out Factor:

* `git clone git://factorcode.org/git/factor.git`
* `cd factor`

To build the latest complete Factor system from git:

* Windows: `build-support\factor.cmd`
* Unix: `./build-support/factor.sh update`

Now you should have a complete Factor system ready to run.

More information on [building factor](http://concatenative.org/wiki/view/Factor/Building%20Factor)
and [system requirements](http://concatenative.org/wiki/view/Factor/Requirements).

### To run a Factor binary:

You can download a Factor binary from the grid on [http://factorcode.org](http://factorcode.org).
The nightly builds are usually a better experience than the point releases.

* Windows: Double-click `factor.exe`, or run `.\factor.com` in a command prompt
* Mac OS X: Double-click `Factor.app` or run `open Factor.app` in a Terminal
* Unix: Run `./factor` in a shell

### Learning Factor

A tutorial is available that can be accessed from the Factor environment:

```factor
"first-program" help
```

Some other simple things you can try in the listener:

```factor
"Hello, world" print

{ 4 8 15 16 23 42 } [ 2 * ] map .

1000 [1,b] sum .

4 iota  [
    "Happy Birthday " write
    2 = "dear NAME" "to You" ? print
] each
```

For more tips, see [Learning Factor](http://concatenative.org/wiki/view/Factor/Learning).

## Documentation

The Factor environment includes extensive reference documentation and a
short "cookbook" to help you get started. The best way to read the
documentation is in the UI; press F1 in the UI listener to open the help
browser tool. You can also [browse the documentation
online](http://docs.factorcode.org).

## Command Line Usage

Factor supports a number of command line switches:

```
Usage: factor [Factor arguments] [script] [script arguments]

Common arguments:
    -help            print this message and exit
    -i=<image>       load Factor image file <image> (default factor.image)
    -run=<vocab>     run the MAIN: entry point of <vocab>
        -run=listener    run terminal listener
        -run=ui.tools    run Factor development UI
    -e=<code>        evaluate <code>
    -no-user-init    suppress loading of .factor-rc

Enter
    "command-line" help
from within Factor for more information.
```

You can also write scripts that can be run from the terminal, by putting
``#!/path/to/factor`` at the top of your scripts and making them executable.

## Source Organization

The Factor source tree is organized as follows:

* `build-support/` - scripts used for compiling Factor (not present in binary packages)
* `vm/` - Factor VM source code (not present in binary packages)
* `core/` - Factor core library
* `basis/` - Factor basis library, compiler, tools
* `extra/` - more libraries and applications
* `misc/` - editor modes, icons, etc
* `unmaintained/` - unmaintained contributions, please help!

## Community

Factor developers meet in the `#concatenative` channel on
[irc.freenode.net](http://freenode.net). Drop by if you want to discuss
anything related to Factor or language design in general.

* [Factor homepage](http://factorcode.org)
* [Concatenative languages wiki](http://concatenative.org)

Have fun!
