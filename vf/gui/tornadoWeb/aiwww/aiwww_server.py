#!/usr/bin/env python
# -*- coding: UTF-8 -*-

import logging
import os
import socket
import tornado.ioloop
import tornado.web
from .utils import get_logger
from .index_handler import IndexRequestHandler
from .login_handler import LoginRequestHandler
from .config_handler import ConfigRequestHandler
from .apply_handler import ApplyRequestHandler


class AIWWWServer():

    def __init__(self, name, webpath, ports, cached):
        '''
          :param str name: webserver name
          :param str webpath: package relative path to web page source.
          :param tuple ports: ports to use in webserver. Provides default and scan range (default, start, end)
        '''
        self._name = name
        self._webpath = webpath
        self._ports = ports
        self._cached = cached
        self._logger = get_logger()
        self._application = self._create_webserver()

    def _create_webserver(self):
        class NoCacheStaticFileHandler(tornado.web.StaticFileHandler):
            def set_extra_headers(self, path):
                self.set_header('Cache-Control', 'no-store, no-cache, must-revalidate, max-age=0')

        file_handler = tornado.web.StaticFileHandler if self._cached else NoCacheStaticFileHandler
        current_path = os.path.join(os.path.dirname(__file__), "../" + self._webpath)

        handlers = [(r"/", IndexRequestHandler)]

        # *****************自定义路由***********************
        handlers.append((r"/login", LoginRequestHandler))
        handlers.append((r"/config", ConfigRequestHandler))
        handlers.append((r"/apply", ApplyRequestHandler))
        handlers.append((r"/(.*)", file_handler, {"path": current_path, "default_filename": "index.html"}))

        self._logger.info("Weg Page root : %s" % (self._webpath))
        application = tornado.web.Application(handlers)
        return application

    def _bind_webserver(self):
        default, start, end = self._ports

        """ First, we try the default http port """
        bound = self._bind_to_port(self._application, default)
        if not bound:
            """ Otherwise bind any available port within the specified range """
            bound = self._bind_in_range(self._application, start, end)
        return True

    def _bind_in_range(self, application, start_port, end_port):
        if (end_port > start_port):
            for i in range(start_port, end_port):
                if self._bind_to_port(application, i):
                    return True
        return False

    def _bind_to_port(self, application, portno):
        self._logger.info("Attempting to start webserver on port %s" % portno)
        try:
            application.listen(portno)
            self._logger.info("Webserver successfully started on port %s" % portno)
        except socket.error as err:
            # Socket exceptions get handled, all other exceptions propagated
            if err.errno == 13:
                self._logger.warning("Insufficient priveliges to run webserver " +
                                     "on port %s. Error: %s" % (portno, err.strerror))
                self._logger.info("-- Try re-running as super-user: sudo su; " +
                                  "source ~/.bashrc)")
            elif err.errno == 98:
                self._logger.warning("There is already a webserver running on port %s. " +
                                     "Error: %s" % (portno, err.strerror))
                self._logger.info("-- Try stopping your web server. For example, " +
                                  "to stop apache: sudo /etc/init.d/apache2 stop")
            else:
                self._logger.error("An error occurred attempting to listen on " +
                                   "port %s: %s" % (portno, err.strerror))
            return False
        return True

    def _start_webserver(self):
        try:
            tornado.ioloop.IOLoop.instance().start()
        except KeyboardInterrupt:
            self._logger.info("Webserver shutting down")

    def spin(self):
        try:
            bound = self._bind_webserver()
            if bound:
                self._start_webserver()
            else:
                raise Exception()
        except Exception as exc:
            self._logger.error("Unable to bind webserver.  Exiting.  %s" % exc)

    def loginfo(self, msg):
        self._logger.info(msg)
