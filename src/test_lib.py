#!/usr/bin/env python
# -*- coding:utf-8 -*-
##########################################################
# Copyright (c) 2017 All Rights Reserved #
##########################################################

"""description

Filname: join_engine_log_user_profile.py
Authors: bjguofangfang@corp.netease.com
Date: 2017-06-16 17:36:56
"""

import sys
import os
import traceback
import logging
from argparse import ArgumentParser

sys.path.insert(0, "./")
import ifs_grouper


logging.basicConfig(level=logging.DEBUG,
                    format='%(levelname)s: %(asctime)s %(filename)s[line:%(lineno)d]'
                           ' [%(process)d] %(message)s',
                    datefmt='%m-%d %H:%M:%S',
                    filename=None,
                    filemode='a')


def func_mapper():
    """docstring for func_mapper"""
    
    has_print = False
    for line in sys.stdin:
        if has_print:
            continue
        input_path = os.getenv("map_input_file")
        lib_dir=os.getenv("LD_LIBRARY_PATH")
        print "lib_dir: " + "|".join(sys.path)
        print "input_path: " + str(type(input_path))
        cur_dir = os.getcwd()
        print "cur_dir: " + cur_dir

        has_print =True
        file_list = os.listdir(cur_dir)

        for line in file_list:
            print "[" + line + "]"
        


def func_reducer():
    """docstring for func_reducer"""
    pass


if __name__ == "__main__":
    func_mapper()
