FROM nanjiang/common-ubuntu
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

#================================
#  Add proq3 source code
#===============================
WORKDIR /home/app
# add the source code to WORKDIR/home/app
ADD . ./proq3

RUN cd /home/app/proq3 &&\
    cp paths_example.sh paths.sh &&\
    ./configure.pl


RUN mkdir /home/download
RUN mkdir /home/app/proq3/database

#================================
# Setting keras configuration
#===============================
RUN mkdir -p /home/user/.keras
RUN echo  "{\n  \"backend\": \"theano\",\n  \"epsilon\": 1e-07,\n  \"floatx\": \"float32\" \n}" > /home/user/.keras/keras.json

#================================
# Setting library path for rosetta
#===============================
ENV LD_LIBRARY_PATH "/home/app/proq3/apps/rosetta/main/source/build/src/release/linux/3.13/64/x86/gcc/4.8/default/:/home/app/proq3/apps/rosetta/main/source/build/external/release/linux/3.13/64/x86/gcc/4.8/default/"

ENV USER_DIRS "/home/app"

RUN export LC_ALL="en_US.UTF-8"

CMD ["/bin/bash" ]
