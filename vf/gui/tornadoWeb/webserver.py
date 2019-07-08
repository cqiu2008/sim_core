#!/usr/bin/env python
# -*- coding: UTF-8 -*-

import argparse
import sys
from aiwww.aiwww_server import AIWWWServer

def parse_argument(argv):
    """
    argument parser for AIConfigWWW server configuration
    """
    parser = argparse.ArgumentParser(description="AIConfigWWW Server")
    parser.add_argument('-n', '--name', default='AIConfigServer', help='Webserver name')
    parser.add_argument('-p', '--port', default=8888, type=int, help='Webserver Port number')
    parser.add_argument('-w', '--webpath', default='web', help='package relative path to web pages')
    parser.add_argument('--cached', default='true', help='static file is cached')
    parser.add_argument('--start_port', default=8000, type=int, help='setting up port scan range')
    parser.add_argument('--end_port', default=9000, type=int, help='setting up port scan range')

    parsed_args = parser.parse_args(argv)
    cached = False if parsed_args.cached in [0, False, 'false', 'False'] else True
    return parsed_args.name, parsed_args.webpath, (parsed_args.port, parsed_args.start_port, parsed_args.end_port), cached


if __name__ == '__main__':
    name, webpath, port, cached = parse_argument(sys.argv[1:])
    webserver = AIWWWServer(name, webpath, port, cached)
    webserver.loginfo("Initialised")
    webserver.spin()
