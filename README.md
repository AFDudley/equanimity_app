# Binary Tactics

A turn-based, hex-based tactical combat game.

## Game spec

See mockup [here](https://cacoo.com/diagrams/X54xvo0qrP4OVQBr).

## Installation

1. chmod +x helper.py (or you can just run it with python helper.py)
2. Run helper.py build
3. Create a web server with document root as app

Done!

## helper.py

In addition to build, helper.py has a few other commands:

1. helper.py watch - This will check for any coffee file updates continuously and compile them into the build directory.  Very useful for development.  The console output also doubles a linter.

2. helper.py reset - This clears out the build directory and then re-builds it.  This cleans out orphaned files (e.g. files that were created from CoffeeScript files that no longer exists).

3. helper.py clean - This just clears out the build directory.  If helper.py watch is running, this can be used to achieve the same result as helper.py reset

4. helper.py deps - This will re-run the bower installation process for dependencies.