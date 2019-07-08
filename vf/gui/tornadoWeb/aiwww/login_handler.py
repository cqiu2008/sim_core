#!/usr/bin/env python
# -*- coding: UTF-8 -*-

import tornado.web
import json
import os
from .utils import get_logger
from .errorcode import *

logger = get_logger()


class LoginRequestHandler(tornado.web.RequestHandler):
    def post(self):
        try:
            data = json.loads(self.request.body.decode('utf-8'))
            userName = data['userName']
            password = data['password']
            current_path = os.path.join(os.path.dirname(__file__), "../data/user.json")
            with open(current_path, 'r') as load_f:
                userList = json.load(load_f)
            for user in userList:
                if user["name"] == userName and user["password"] == password:
                    self.write({
                        "errorcode": SUCCESS,
                        "message": user
                    })
                    return

            self.write({
                "errorcode": ERRORCODE_USER_OR_PASSWORD_FAULT,
                "message": {}
            })
            logger.error(str(ERRORCODE_USER_OR_PASSWORD_FAULT))

        except Exception as e:
            logger.error(str(e))
            self.write({
                "errorcode": ERRORCODE_SYSTEM,
                "message": str(e)
            })
