#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# puppet managed

import os
import sys
import socket
import re
try:
    import collectd
except ImportError:
    pass
import logging
import time

logging.basicConfig(level=logging.INFO)

PLUGIN_NAME = "syslog_ng"
SOURCE_NAMES = [
    "dst.syslog",
    "destination",
]
CFG = {
    "SocketPath": ["/var/lib/syslog-ng/syslog-ng.ctl"],
    "RetryCount": 5,
    "RetryDelays": [1, 3, 5],  # further retries repeat the last delay
}
time.sleep(3)

def log(param):
    """
    Log messages to either collectd or stdout depending on how it was called.

    :param param: the message
    :return:  None
    """

    if __name__ != '__main__':
        collectd.info("Plugin %s: %s" % (PLUGIN_NAME, param))
    else:
        sys.stderr.write("Plugin %s: %s\n" % (PLUGIN_NAME, param))

def config(conf):
    for line in conf.children:
        log("config key='%s', values='%s'" % (line.key,line.values))
        global CFG
        CFG[line.key] = line.values

def init():
    log("initializing...")

def shutdown():
    log("shutting down...")

def read():
    retry_count = CFG['RetryCount']
    retry_delays = CFG['RetryDelays']
    result = ""
    for attempt in range(retry_count):
        # Determine delay for this attempt
        delay = retry_delays[attempt] if attempt < len(retry_delays) else retry_delays[-1]
        try:
            # Attempt to connect and read from the socket
            s = socket.socket(socket.AF_UNIX)
            s.settimeout(1)
            s.connect(CFG["SocketPath"][0])
            s.send("STATS\n".encode())
            result = s.recv(1048576).decode()
        except Exception as e:
            log("failed read stats from socket, error='%s'" % e)
            if attempt < retry_count - 1:
                time.sleep(delay)
        else:
            try:
                result = result.split("\n")[:-2]
            except Exception as e:
                log("failed read stats from socket, error='%s'" % e)
                if attempt < retry_count - 1:
                    time.sleep(delay)
            else:
                break # Success, exit the retry loop

    result.remove("SourceName;SourceId;SourceInstance;State;Type;Number") # removed header

    for line in result:
        line = line.split(";")
        SourceName = line[0]
        # filtering by source name
        if SourceName not in SOURCE_NAMES:
            continue
        SourceId = line[1]
        SourceInstance = line[2]
        State = line[3]
        Type = line[4]
        Number = line[5]
        if SourceInstance != '':
            plugin_instance = SourceName+'_'+SourceId+'_'+SourceInstance
        else:
            plugin_instance = SourceName+'_'+SourceId
        # dst.syslog_remote#0_tcp,syslog.toolpad.org:514
        collectdValues = {
            "plugin": PLUGIN_NAME,
            "plugin_instance": re.sub(r'[#\.,:]',r'_',plugin_instance),
            "type_instance": Type,
            "type": "counter",
            "values": [Number],
        }
        if __name__ != '__main__':
            collectd.Values(
                plugin=collectdValues['plugin'],
                plugin_instance=collectdValues['plugin_instance'],
                type_instance=collectdValues['type_instance'],
                type=collectdValues['type'],
                values=collectdValues['values']
            ).dispatch()
        else:
            print(collectdValues)

if __name__ != "__main__":
    collectd.register_config(config)
    collectd.register_read(read)
    collectd.register_init(init)
    collectd.register_shutdown(shutdown)
else:
    read()
