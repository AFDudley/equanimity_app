kgame
=====
More documentation will be forthcoming.

This is a framework for making HTML5 Canvas Games using Kinetic JS.  It was developed by me, Gregg Keithley, in the course of working on a variety of projects.

Some parts of the setup process will be simplified in the future.

For now, some tips:


1) utils/coffee_watch.py is a utility that takes three arguments - a path to watch, a path to compile to, and the web URL to the directory the coffee files exist in.  So, for example, if you want to compile all coffee files in the directory /home/ubuntu/kgame and you want to compile to /home/ubuntu/kgame/build, you would run the following command:

python coffee_watch.py /home/ubuntu/kgame /home/ubuntu/kgame/build &

Run this way, it will continuously monitor the src directory for any changes to .coffee files and automatically compile the JavaScript files and create the .map files along with them.

Note: This takes an optional third parameter that specifies the web URL of the first parameter (/home/ubuntu/kgame, in this case).It will assume this is at / unless otherwise specified.  This is used to create the URLs to the coffee files in the source maps.


2) To run the Jasmine tests:

a) Create a local web server with its document root pointing at the root of the repository.
b) Build the JavaScript files using the coffee_watch command above.
c) Navigate to http://<address of your webserver>/tests/testApp/index.html
