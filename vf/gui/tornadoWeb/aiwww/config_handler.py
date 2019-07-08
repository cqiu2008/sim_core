#!/usr/bin/env python
# -*- coding: UTF-8 -*-
# encoding=utf8  
import sys 
reload(sys)
sys.setdefaultencoding('utf8')
from concurrent.futures import ThreadPoolExecutor
from tornado import gen
from tornado.web import RequestHandler
from tornado.concurrent import run_on_executor
from .utils import *
from .errorcode import *
import json
import os
import re
import numpy as np

logger = get_logger()
cfg_path = os.path.join(os.path.dirname(__file__), "../data/")

class ConfigRequestHandler(RequestHandler):

    def message_read(self,cfg_path,json_file,messageId,message):
        read_path = os.path.join(cfg_path , json_file)
        if os.path.exists(read_path) == False:
            read_path = os.path.join(os.path.dirname(__file__), "../data/")
            read_path = os.path.join(read_path,json_file)
        parm = readJSON(read_path)
        message[messageId] = parm

    def get(self):
        global cfg_path
        message = {}
        self.message_read(cfg_path,"public.json","ethPublicPckTable",message)
        self.message_read(cfg_path,"private.json","ethPrivatePckTable",message)
        self.write({
            "errorcode": SUCCESS,
            "message": message
        })
        return

    def write_sim_data(self):
        pattern_begin = re.compile('^\[')
        pattern_end = re.compile(']$')
        data = self.get_body_argument("sim")
        data = re.sub(pattern_begin,'',data)
        data = re.sub(pattern_end,'',data)
        data = data.replace('",','\r\n')
        data = data.replace('"','')
        write_path = self.get_body_argument("filePath")
        fp = open(write_path,'w')
        fp.write(data)
        fp.close()

    def write_json_file(self,cfg_path,json_file,json_id):
        write_path = self.get_body_argument(cfg_path)+json_file
        json_data = self.get_body_argument(json_id)
        writeJSON(write_path, json_data)

    @gen.coroutine
    def post(self):
        try:
            global cfg_path
            mode = int(self.get_body_argument("mode"))
            if mode:
                self.write_sim_data()
                self.write_json_file("cfgPath","public.json","jsonPublic")
                self.write_json_file("cfgPath","private.json","jsonPrivate")
            else:
                cfg_path = self.get_body_argument("cfgPath")
                print "only set cfg_path"
                print cfg_path
            self.write({
                "errorcode": SUCCESS,
                "message":{}
            })

        except Exception as e:
            logger.error(str(e))
            self.write({
                "errorcode": ERRORCODE_SYSTEM,
                "message":str(e)
            })
