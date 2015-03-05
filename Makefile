#@ssh ${VM} "
#  initialize a docker instance
# , 2015-01-29 11:39
#

GITHUB = git@github.com:gglynne/dockenv.git
PROJECTDIR = dockenv
WINHOME = `cygpath $${USERPROFILE}`# /cygdrive/c/Users/ets
BACKUPS=/c/Users/ets/.dockerimagebackups
BOOT2DOCKER = /cygdrive/c/Program\ Files/Boot2Docker\ for\ Windows/boot2docker.exe
VBOX=/cygdrive/c/Program Files/Oracle/VirtualBox/VBoxManage.exe

# build fig.yml in the currentdir
FIG='docker run --rm -it -v \`pwd\`:/app -v /var/run/docker.sock:/var/run/docker.sock -e FIG_PROJECT_NAME=\`pwd\` dduportal/fig'

# if you want to run FIG in an interactive shell, paste this one into the terminal:
#FIG='docker run --rm -it -v /home/docker/dockenv:/app -v /var/run/docker.sock:/var/run/docker.sock -e FIG_PROJECT_NAME=/home/docker/dockenv dduportal/fig'



# fetch docker vm ip address

upgrade:
	-@(export HOME=${WINHOME}; ${BOOT2DOCKER} upgrade)


# delete any existing boot2docker-vm and build a new one
devup1: 
	@echo Recreating VM...
	-@(export HOME=${WINHOME}; ${BOOT2DOCKER} down  ) 2> /dev/null
	-@(export HOME=${WINHOME}; ${BOOT2DOCKER} delete ) 2> /dev/null
	-@(export HOME=${WINHOME}; ${BOOT2DOCKER} init ) 2> /dev/null
	@echo Adding shared folder ${PROJECTDIR}...
	@(export HOME=${WINHOME}; "${VBOX}" sharedfolder add "boot2docker-vm" --name "${PROJECTDIR}" --hostpath "C:\cygwin\home\ets\mandrake\study\docker\dockenv")
	@echo Starting VM...
	@(export HOME=${WINHOME}; ${BOOT2DOCKER} up )
	@echo Getting boot2docker IP address...
	@$(eval IP := $(shell export HOME=${WINHOME};${BOOT2DOCKER} ip 2> /dev/null) )
	grep -v  ${IP} ~/.ssh/known_hosts > ~/.ssh/tmp
	cat ~/.ssh/tmp > ~/.ssh/known_hosts
	rm ~/.ssh/tmp
	sshpass.exe -ptcuser ssh -o StrictHostKeyChecking=no docker@${IP} ls
	@sshpass.exe -ptcuser ssh-copy-id docker@${IP}
	@echo Mounting vbox shared folder as /home/docker/${PROJECTDIR}...
	@ssh docker@${IP} "[ -d /home/docker/${PROJECTDIR} ] || mkdir /home/docker/${PROJECTDIR}"
	@ssh docker@${IP} "sudo mount -t vboxsf /home/docker/${PROJECTDIR} ${PROJECTDIR}"
	@echo now run 'make ssh' and run fig commands!


nenex:
	@echo Restoring backed-up images...
	@ssh docker@${IP} 'if [ -d ${BACKUPS} ]; then for f in  ${BACKUPS}/* ; do docker load -i $$f; done; fi'

	@# note single quotes to stop expressions being evaluated client side

test:
	@$(eval STATUS := $(shell export HOME=${WINHOME};${BOOT2DOCKER} status 2> /dev/null) )
	@if [[ ${STATUS} != "running" ]]; then (export HOME=${WINHOME}; ${BOOT2DOCKER} up); fi


# start/stop an existing boot2docker-vm  (vm disk is memory based, 'down' command will delete config)
vmup:
	(export HOME=${WINHOME}; ${BOOT2DOCKER} up)

vmdown:
	(export HOME=${WINHOME}; ${BOOT2DOCKER} save)

# ssh into the docker vm
ssh:
	(export HOME=${WINHOME}; ${BOOT2DOCKER} ssh)

.PHONY: ip
ip:
	@$(eval IP := $(shell export HOME=${WINHOME};${BOOT2DOCKER} ip 2> /dev/null) )

# backup all images from docker vm to windows host
backup: ip
	ssh docker@${IP} '[[ -d ${BACKUPS} ]] || mkdir ${BACKUPS}'
	ssh docker@${IP} 'for id in $$(docker images -q | sort -u); do FP=${BACKUPS}/$${id}.tgz; [[ -f $$FP ]] ||  docker save $${id} | gzip -c > $$FP ; done'

restore:
	@ssh docker@${IP} 'for FP in  ${BACKUPS}/* ; do docker load -i $$FP; done'

# build base python image
buildpython: ip
	@ssh docker@${IP} 'docker build -t python ${PROJECTDIR}'

# test the base python image
testpython: ip
	@echo ssh docker@${IP}
	@echo 'docker run -it --rm -v $${HOME}/dockenv:/usr/src/dockenv python'

# run bash in the python image to test: readline doesn't work unless you run these commands manually
testbash: ip
	@echo ssh docker@${IP}
	@echo docker run -it --rm -v $${HOME}/dockenv:/usr/src/dockenv python /bin/bash

# run fig build
figbuild: ip
	#echo do this manually:
	@echo ssh docker@${IP} 'cd ${PROJECTDIR}; ${FIG} build'

# --------------------------------------------------- scratch 2015-02-09 ------------------------







# start data volume detached
testdata: ip
	@ssh docker@${IP} 'cd ${PROJECTDIR}; ${FIG} up -d data'



# scratch ------------------------------

asdfsdaas:
	@ssh docker@${IP} 'cd ${PROJECTDIR}; ${FIG} up'


asfasfsad3:
	@ssh docker@${IP} '${FIG} build'

web:
	@ssh docker@${IP} '${FIG} run web'


study:
	@ssh docker@${IP} 'docker run -it --privileged --net host crosbymichael/make-containers'


asdfs:
	@ssh docker@${IP} '(alias fig='"\'"'ls -la'"\'"';fig)'
	@ssh docker@${IP} 'cd dockenv; ${FIG} run web /bin/bash'


# adds a fig alias (nightmare escaping). unfortunately his won't work with ssh commands, see ${FIG}
addfigtoprofile:
	@ssh ${VM} 'echo alias fig='"\'"'docker run --rm -it \
	-v $(pwd):/app \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-e FIG_PROJECT_NAME=$(basename $(pwd))\
	dduportal/fig'"\'"'>> ~/.profile'
	

asdfa:
	@ssh ${VM} "alias fig='docker run --rm -it \
	-v $(pwd):/app \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-e FIG_PROJECT_NAME=$(basename $(pwd)) \
	dduportal/fig' >> ~/.profile"
	@ssh ${VM} 'echo echo hi >> ~/.profile'




asdf:
	@ssh ${VM} 'docker build -t python ${PROJECTDIR}'
	sudo /bin/sh -c 'curl -L https://github.com/docker/fig/releases/download/1.0.1/fig-`uname -s`-`uname -m` > /usr/local/bin/fig; sudo chmod +x /usr/local/bin/fig'
	(export HOME=${WINHOME}; ${BOOT2DOCKER} --help)
	# busybox shell with repo mounted locally on /usr/src
	#docker run -it --rm -v $HOME/dockenv:/usr/src/dockenv busybox



scratch:
	-@ssh ${VM} "[ -d /home/docker/${PROJECTDIR} ] || mkdir /home/docker/${PROJECTDIR}"
	@ssh ${VM} "a=$(sudo mount -t vboxsf /home/docker/${PROJECTDIR} ${PROJECTDIR}); [[ $$? > 0 ]] && echo failed to mount! "
	# add a custo, shared folder to the bootdocker vim
	#@(export HOME=${WINHOME}; ${BOOT2DOCKER} down )
	#"${VBOX}" sharedfolder add "boot2docker-vm" --name "${PROJECTDIR}" --hostpath "C:\cygwin\home\ets\mandrake\study\docker\dockenv"
	@ssh ${VM} 'tmp=$(ls 2>/dev/null); [[ $$? > 0 ]] && echo error'
	@ssh ${VM} "[ -d /home/docker/${PROJECTDIR} ] || mkdir /home/docker/${PROJECTDIR}"
	@ssh ${VM} "a=$(sudo mount -t vboxsf /home/docker/${PROJECTDIR} ${PROJECTDIR}); [[ $$? > 0 ]] && echo error "
	@ssh ${VM} "mkdir /home/docker/${PROJECTDIR}"



# 2>/dev/null pipes any error message to /dev/null - so you won't see any errors
# the - in front of the command makes sure that make ignores a non-zero return code





# push local to github repo
githubpush:
	git add . ; git commit -a -m "`date`"; git push

# clone ${PROJECTDIR} from github into docker VMs
githubinit:
	@scp ~/.ssh/id_rsa ${VM}:~/.ssh/
	@ssh ${VM} "git clone ${GITHUB}"




# pull from github to docker VM
githubpull:
	@ssh ${VM} "(cd ${PROJECTDIR}; git pull)"

# list contents of project dir
vmls:
	@ssh ${VM} "(cd ${PROJECTDIR}; ls)"





todo:

	# launch a busybox instance with access to the repo on local disk (viminit or viminitgit must be run first)
	docker run -it --rm -v $HOME/dockenv:/usr/src busybox

	# Dockerfile to provision an image :python + django
	
	# docker commands to set up ports and run the server

	# mount windows shared folder
	sudo mount -t vboxsf dockenv $HOME/dockenv
	#  create a persistent volume in a container
	docker run -d -v /share --name share busybox
	# inspect the share contents in an interactive shell
	docker run -it --rm --volumes-from share busybox

	@ssh ${VM} "(mount | grep -q dockenv); [[ $$? == 0 ]] && sudo umount ${PROJECTDIR}"
	@ssh ${VM} "sudo umount ${PROJECTDIR}; rm -rf ${PROJECTDIR}; fi; mkdir ${PROJECTDIR}"
	@ssh ${VM} "if [[ -d ${PROJECTDIR} ]]; then sudo umount ${PROJECTDIR}; rm -rf ${PROJECTDIR}; fi; mkdir ${PROJECTDIR}"
	ssh-copy-id docker@192.168.59.103
	@ssh ${VM} "rm ~/.ssh/id_rsa; rm -rf ${PROJECTDIR}; fi"

# vim:ft=make
#

