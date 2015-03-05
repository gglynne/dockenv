#!/usr/bin/python
# -*- coding: utf-8: -*- 
# vim: foldmethod=marker:foldmarker={{{,}}}:cms=#%s

"""
2015-03-05 13:37

    [[differences  between python 2.7 and 3.x.wiki]]
    
    A curated list of awesome Python frameworks, libraries and software:
        https://github.com/vinta/awesome-python
            
    print string formats:
        http://www.pererikstrandberg.se/blog/index.cgi?page=PythonPrintStringFormatCheatSheet
            
    Useful modules:
        https://wiki.python.org/moin/UsefulModules

    django packages compared
        https://www.djangopackages.com/grids/g/oauth/

"""

from __future__ import with_statement
from fabric.api import *
from fabric.contrib.console import confirm

from fabric.api import local

env.gateway = 'backup_user@server: 65371'
env.hosts = ['docker@192.168.59.103']
env.password= 'tcuser'
env.shell= '/bin/sh -l -c'
code_dir = '~/dockenv'
repo_url = "https://github.com/gglynne/dockenv.git"


def clone():
    run("git clone " + repo_url )


def push():
    local('git add .')
    local('git commit -a -m "`date`"');
    local('git push')
    with cd(code_dir):
        run('git pull')

        #run('ls')
    #print(env)
