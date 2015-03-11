#!/usr/bin/python
# -*- coding: utf-8: -*- 
# vim: foldmethod=marker:foldmarker={{{,}}}:cms=#%s

"""
fab script to set up a docker container on server machine.

keywords: automation of bash commands over ssh, containerization, provisioning

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

#[ dev machine ] -- ssh --- [ gateway machine ] 
#                                |
#                                ssh
#                                |
#                           [ boot2docker VM ]
#                                |
#                           [ containers ]


# gateway is a windows box with boot2docker installed: it has localhost ssh access to boot2docker
env.gateway = 'backup_user@server:65371'

# boot2docker running on gateway
env.hosts = ['docker@192.168.59.103']
env.password= 'tcuser'
env.shell= '/bin/sh -l -c'
code_dir = '~/dockenv'
repo_url = "https://github.com/gglynne/dockenv.git"

# http proxy on devmachine port 
http_proxy='http://192.168.1.109:8123'

cachedir='~/.proxycache'

#dry=True
dry=False

def run(*args,**kwargs):
    if dry:
        print args, kwargs
    else:
        runfabric(*args, **kwargs)

def restart():
    sudo('/etc/init.d/docker restart')

def copykeys():
    with settings(host_string=env.gateway):
        run("ssh-copy-id %s" % env.hosts[0])

def cache():
    #local("if [[ ! -d %s ]]; then mkdir %s; fi" % (cachedir, cachedir) )
    #local("../http-replicator/http-replicator -r %s -p 8888 --daemon /tmp/replicator.log" % cachedir)
    sudo('echo export HTTP_PROXY=%s > /var/lib/boot2docker/profile' % http_proxy);
    sudo('echo export http_proxy=%s >> /var/lib/boot2docker/profile' % http_proxy)
    sudo('echo export HTTPS_PROXY=%s >> /var/lib/boot2docker/profile' % http_proxy)
    sudo('echo export https_proxy=%s >> /var/lib/boot2docker/profile' % http_proxy)
    sudo('echo export NO_PROXY=localhost,127.0.0.0/8,::1,/var/run/docker.sock >> /var/lib/boot2docker/profile')
    sudo('echo export no_proxy=localhost,127.0.0.0/8,::1,/var/run/docker.sock  >> /var/lib/boot2docker/profile')
    sudo('/etc/init.d/docker restart')

def testcache():
    run(". /var/lib/boot2docker/profile")
    run("env | grep -i http")
    run("curl http://google.com")

def pullimages():
    run("docker pull busybox")
    run("docker pull python:3.4.2")
    run("docker pull postgres:9.3")

def fig(cmd):
    return run(""" docker run --rm -it -v %s:/app -v /var/run/docker.sock:/var/run/docker.sock \
        -e FIG_PROJECT_NAME=%s dduportal/fig \
        %s \
    """ % ( code_dir,code_dir, cmd ) ) 



def up():
    fig("up")

def clone():
    """ re-clone repo in home """

    run("""
        if [[ -d %s ]]; then 
            rm -rf %s; 
        fi
    """ % ( code_dir,code_dir ) )

    run("git clone " + repo_url )


def push():
    """ push changes from localdir onto github, then pull them onto the server """

    local('git add .')
    with settings(warn_only=True):
        local('git commit -a -m "`date`"');
    local('git push')
    with cd(code_dir):
        run('git pull')




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

