FROM nanjiang/common-ubuntu
LABEL maintainer "Nanjiang Shu (nanjiang.shu@nbis.se)"
LABEL version "1.0"


#================================
# Install basics
#===============================
RUN apt-get  update -y
RUN apt-get install -y apt-utils  \
                       curl wget vim tree bc git \
                       python python-dev python-pip \
                       build-essential  \
                       libxml2-dev libxslt1-dev libsqlite3-dev zlib1g-dev   \
                       r-base \
                       cmake  \
                       qt4-qmake  \
                       emboss-lib   \
                       emboss

#================================
# Install R packages 
#===============================
RUN R -e "install.packages(c('zoo'), repos='http://ftp.acc.umu.se/mirror/CRAN/')"

#================================
# Install python package 
#===============================
RUN pip install --upgrade pip
RUN pip install biopython==1.70 \
                matplotlib==1.5.3 \
                numpy==1.11.2 \
                scipy==0.18.1 \
                keras==2.0.8 \
                Theano==0.8.2 \
                h5py==2.6.0

#================================
#  Add proq3 source code
#===============================
WORKDIR /app
# add the source code to WORKDIR/home/app
ADD . ./proq3

RUN cd /app/proq3 &&\
    cp paths_example.sh paths.sh &&\
    ./configure.pl


RUN mkdir -p /app/proq3/database \
          /home/user/.keras

#================================
# Setting keras configuration
#===============================
RUN echo  "{\n  \"backend\": \"theano\",\n  \"epsilon\": 1e-07,\n  \"floatx\": \"float32\" \n}" > /home/user/.keras/keras.json

#================================
# Setting library path for rosetta
#===============================
ENV LD_LIBRARY_PATH "/app/proq3/apps/rosetta/main/source/build/src/release/linux/3.13/64/x86/gcc/4.8/default/:/app/proq3/apps/rosetta/main/source/build/external/release/linux/3.13/64/x86/gcc/4.8/default/"

RUN export LC_ALL="en_US.UTF-8"


CMD ["/bin/bash" ]
