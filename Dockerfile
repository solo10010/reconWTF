############################################################
# Dockerfile to build reconWTF
# Based on Debian
############################################################

FROM debian

MAINTAINER solo10010

# update repository

RUN apt update

##################-WORKDIR-################################

RUN mkdir -p /home/recon

COPY . /home/recon/

WORKDIR /home/recon 

RUN chmod +x reconwtf.sh

##################-BEGIN-INSTALATION-#######################

RUN bash reconwtf.sh --install

RUN bash reconwtf.sh -ct
