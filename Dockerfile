

#https://hub.docker.com/r/bioconductor/bioconductor_docker/tags?page=1&ordering=last_updated
FROM bioconductor/bioconductor_docker:RELEASE_3_18


MAINTAINER Shaojun Xie

# This will make apt-get install without question
ENV DEBIAN_FRONTEND noninteractive

RUN pip3 install jupyterlab==4.1.1  && \
    R -e 'devtools::install_version("IRkernel", version = "1.1.1", repos = "https://cran.rstudio.com/",upgrade = "never", force = TRUE)' && \
    R -e 'IRkernel::installspec(name = "R", displayname = "R", user = FALSE)'
 
RUN R -e 'install.packages("devtools")' && \
    R -e 'install.packages("pkgbuild")' 

ARG STAR_VERSION=2.7.11b

RUN cd /home && \
    wget --no-check-certificate https://github.com/alexdobin/STAR/releases/download/${STAR_VERSION}/STAR_${STAR_VERSION}.zip && \
    unzip STAR_${STAR_VERSION}.zip && \
    mkdir /home/bin && \
    cp STAR_${STAR_VERSION}/Linux_x86_64_static/STAR /home/bin && \
    rm -rf STAR_${STAR_VERSION}* 

RUN useradd -s /bin/bash docker
USER docker
WORKDIR /home/docker/

ENV PATH /home/bin:${PATH}  


########################################################################
## docker build -t rnaseqlab -f Dockerfile .
## docker tag rnaseqlab:latest bix4umd/bioi611:rnaseqlab_1.0.0
## docker push :r1.0.0

## For test
##  docker run -p 8888:8888 -t -d --name rnaseqlab_env rnaseqlab:latest
## docker exec -it rnaseqlab_env bash 
## docker run -e PASSWORD=password -e USERID=$(id -u)  -d scrna.sc20230928:latest
## The command above will generate an ID. 
## docker container ls
## docker exec -it  1884426c3827 python3
##########################################################################   
