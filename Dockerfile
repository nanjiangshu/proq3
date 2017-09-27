FROM ubuntu:16.04
LABEL maintainer "Nanjiang Shu (nanjiang.shu@nbis.se)"
LABEL version "1.0"

#================================
# Install basics
#===============================
RUN apt-get  update -y
RUN apt-get install -y apt-utils 
RUN apt-get install -y curl wget vim tree bc git
RUN apt-get install -y python python-dev python-pip
RUN apt-get install -y build-essential 
RUN apt-get install -y libxml2-dev libxslt1-dev libsqlite3-dev zlib1g-dev  
RUN apt-get install -y r-base
RUN apt-get install -y cmake 
RUN apt-get install -y qt4-qmake

#================================
#  Add proq3 source code
#===============================
WORKDIR /home/app
# add the source code to WORKDIR/home/app
ADD . ./proq3

RUN mkdir /home/download
RUN mkdir /home/app/proq3/database
#================================
# Install EMBOSS
#===============================
RUN apt-get  install -y emboss-lib
RUN apt-get  install -y emboss

#================================
# Install R packages 
#===============================
RUN R -e "install.packages(c('zoo'), repos='http://ftp.acc.umu.se/mirror/CRAN/')"

#================================
# Install python package 
#===============================
RUN pip install --upgrade pip
RUN pip install biopython==1.70
RUN pip install matplotlib==1.5.3
RUN pip install numpy==1.11.2
RUN pip install scipy==0.18.1
# deep learning packages
RUN pip install keras==2.0.8
RUN pip install Theano==0.8.2
RUN pip install h5py==2.6.0

RUN export LC_ALL="en_US.UTF-8"
