#!/usr/bin/env python
# -*- coding: UTF-8 -*-

import tornado.web
from .utils import get_logger

logger = get_logger()

class IndexRequestHandler(tornado.web.RequestHandler):

    def get(self):
        self.redirect('index.html')
