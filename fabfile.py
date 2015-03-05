#!/usr/bin/python
# -*- coding: utf-8: -*- 
# vim: foldmethod=marker:foldmarker={{{,}}}:cms=#%s

"""
fab script to set up a docker container on server machine

http://docs.fabfile.org/en/latest/api/core/operations.html
http://docs.fabfile.org/en/1.5/api/core/context_managers.html#fabric.context_managers.shell_env
https://fabric.readthedocs.org/en/1.8/usage/env.html#gateway
https://www.digitalocean.com/community/tutorials/how-to-use-fabric-to-automate-administration-tasks-and-deployments

"""

from __future__ import with_statement
from fabric.api import *
from fabric.contrib.console import confirm
from fabric.context_managers import settings, shell_env
from fabric.api import local
from fabric.operations import run as runfabric

# gateway is a windows box with boot2docker installed: it has localhost ssh access to boot2docker
env.gateway = 'backup_user@server: 65371'

# boot2docker running on gateway
env.hosts = ['docker@192.168.59.103']
env.password= 'tcuser'
env.shell= '/bin/sh -l -c'
code_dir = '~/dockenv'
repo_url = "https://github.com/gglynne/dockenv.git"

dry=True
dry=False

def run(*args,**kwargs):
    if dry:
        print args, kwargs
    else:
        runfabric(*args, **kwargs)

def clone():
    """
    re-clone repo in home
    """

    run("""
        if [[ -d %s ]]; then 
            rm -rf %s; 
        fi
    """ % ( code_dir,code_dir ))

    run("git clone " + repo_url )


def push():
    """
    push changes from localdir onto github, then pull them onto the server
    """
    local('git add .')
    local('git commit -a -m "`date`"');
    local('git push')
    with cd(code_dir):
        run('git pull')

        #run('ls')
    #print(env)

#global WINHOME
#with settings(host_string=GATEWAY):
    #WINHOME=run('cygpath ${USERPROFILE}')

#def test():
    #with settings(host_string=GATEWAY):
        #with shell_env(HOME = WINHOME, BOOT2DOCKER = BOOT2DOCKER):
            #run('"$BOOT2DOCKER" ip')

        #with shell_env(NAME='tester'):
            #run('echo $NAME')

    #@$(eval IP := $(shell export HOME=${WINHOME};${BOOT2DOCKER} ip 2> /dev/null) )



