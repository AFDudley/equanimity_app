#!/usr/bin/env python
import os
import time
import sys
import shlex
import subprocess
import shutil
from json import dumps, loads


def coffee_watch(watch_path, compile_path, coffee_url='/', just_once=False):
    if not os.path.exists(watch_path):
        raise Exception('Watch path %s does not exist.' % watch_path)
    while True:
        try:
            time.sleep(.25)
            # Find all .coffee files in directory
            for dirname, dirnames, files in os.walk(watch_path):
                for f in files:
                    if not f.endswith('.coffee'):
                        continue

                    source_path = '%s/%s' % (dirname, f)
                    # Figure out the output paths.
                    coffee_url_base = coffee_url + dirname[
                        len(watch_path) + 1:]

                    output_dir = dirname.replace(watch_path, compile_path)
                    output_file = f.replace('.coffee', '.js')
                    output_path = '%s/%s' % (output_dir, output_file)
                    output_url = output_file

                    source_map_file = output_file.replace('.js', '.map')
                    source_map_path = '%s/%s' % (output_dir, source_map_file)
                    source_map_url = source_map_file

                    coffee_file = f
                    coffee_file_url = '%s/%s' % (coffee_url_base, coffee_file)

                    if (not os.path.exists(output_path) or
                            (os.path.getmtime(source_path) >
                                os.path.getmtime(output_path))):
                        # Make sure output_dir exists:
                        if not os.path.exists(output_dir):
                            os.makedirs(output_dir)
                        # Rebuild
                        cmd = 'coffeelint %s' % source_path
                        subprocess.call(shlex.split(cmd))
                        cmd = (
                            'coffee --compile --map --output %(output_dir)s'
                            ' %(source_path)s' % {'source_path': source_path,
                            'output_dir': output_dir,
                            'source_map_path': source_map_path})
                        subprocess.call(shlex.split(cmd))
                        # We have to modify the map file and the the JS file
                        # to have the right path.
                        with open(source_map_path) as f:
                            source_map_content = f.read()
                        with open(source_map_path, 'w') as f:
                                content = loads(source_map_content)
                                content["file"] = output_url
                                content["sources"] = [coffee_file_url]
                                f.write(dumps(content))

                        with open(output_path) as f:
                            output_content = f.read()
                        with open(output_path, 'w') as f:
                            f.write(
                                output_content.replace(
                                    source_map_file, source_map_url
                                )
                            )

        except KeyboardInterrupt:
            break
        if just_once:
            break

here = os.path.dirname(os.path.abspath(__file__))
watch = here + "/app/coffeescript"
compile_to = here + "/app/build"
compile_url = "/coffeescript"


def build(just_once=True):
    # Compile all of the coffee script files
    coffee_watch(watch, compile_to, compile_url, just_once)


def clean():
    # Remove current compiled files.
    shutil.rmtree(compile_to)


def install_dependencies():
    # Install bower dependencies
    subprocess.Popen(
        shlex.split("bower install"),
        cwd=(here + "/app")
    )


if __name__ == '__main__':
    if sys.argv[1] == "build":
        clean()
        build()
        install_dependencies()
    elif sys.argv[1] == "watch":
        build(False)
    elif sys.argv[1] == "reset":
        clean()
        build()
    elif sys.argv[1] == "clean":
        clean()
    elif sys.argv[1] == "deps":
        install_dependencies()
