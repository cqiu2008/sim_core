#!/usr/bin/env python
# -*- coding: UTF-8 -*-
from concurrent.futures import ThreadPoolExecutor
from tornado import gen
from tornado.web import RequestHandler
from tornado.concurrent import run_on_executor
from .utils import *
from .errorcode import *
import json
import os

logger = get_logger()
MAX_WORKERS = 1000

class ApplyRequestHandler(RequestHandler):
    executor = ThreadPoolExecutor(max_workers=MAX_WORKERS)

    def get(self):
        self.post()

    @gen.coroutine
    def post(self):
        try:
            param = json.loads(self.request.body.decode('utf-8'))
            apply_param = param["apply_param"] 
            profile_parm = param["profile_parm"]
            profile_param_path = os.path.join(os.path.dirname(__file__), "../data/profile.json")
            writeJSON(profile_param_path, profile_parm) 
            if not os.path.exists(apply_param["package_path"]):
                self.write({
                    "errorcode": ERRORCODE_FILE_NOT_EXIST,
                    "message": {}
                })
                logger.error(str(ERRORCODE_FILE_NOT_EXIST))
                return
            self.execute_cmd(profile_param_path, apply_param)
            apply_param_path = os.path.join(os.path.dirname(__file__), "../data/apply_param.json")
            writeJSON(apply_param_path, apply_param) 
            self.write({
                "errorcode": SUCCESS,
                "message": {}
            })

        except Exception as e:
            logger.error(str(e))
            self.write({
                "errorcode": ERRORCODE_SYSTEM,
                "message": str(e)
            })

    @run_on_executor
    def execute_cmd(self, param_path, command):
        install_cmd = "../install.sh %s %s %s %s %s" % (
        param_path, command["package_path"], ("true" if command["dry_run"] else "false"), ("true" if command["keep_docker_images"] else "false"),
        command["kubernetes_docker_registry"])
        run_cmd = os.path.join(os.path.dirname(__file__), install_cmd)
        status = os.system(run_cmd)
