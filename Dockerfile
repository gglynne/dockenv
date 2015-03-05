#FROM python:3.4.2
FROM python:3.3.6-wheezy
MAINTAINER ennylg

# move to this dir on the image
WORKDIR /usr/src/dockenv

# <source relative to dir relative to path given in build command> <dest on image>
ADD ./requirements.txt /usr/src/dockenv/requirements.txt
RUN pip install -r requirements.txt

# from here on in, we'll use fig http://www.fig.sh/django.html


###################################

# run this command and exit
#CMD [ "python", "/usr/src/dockenv/test.py"]

#links:
# http://crosbymichael.com/dockerfile-best-practices.html
# https://docs.docker.com/reference/builder/
