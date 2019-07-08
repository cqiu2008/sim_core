#!/usr/bin/env python

import subprocess
import logging
import json

logger = {}

def get_logger():
    global logger
    if logger:
        return logger
        
    logging.basicConfig(format="[%(asctime)s] - %(filename)s:%(lineno)d - %(levelname)s - %(message)s",
                    level=logging.WARN)
    logger = logging.getLogger(__name__)

    return logger

def readJSON(path):
    data = {}
    with open(path, 'r') as f:
        data = json.load(f)
    return data

def writeJSON(path,data):
    with open(path, 'w') as f:
        json.dump(data, f)

