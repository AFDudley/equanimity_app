import os
import sys
import shlex
import subprocess

here = os.path.dirname(os.path.abspath(__file__))
sys.path.append(here)

from utils.coffee_watch import coffee_watch


def main():
    # Compile all of the coffee script files
    watch = here
    compile_to = here + "/build"
    compile_url = "/"
    coffee_watch(watch, compile_to, compile_url, True)
    # Install bower dependencies
    subprocess.Popen(shlex.split("bower install"))


if __name__ == '__main__':
    main()
