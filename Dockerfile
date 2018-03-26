# Base on jupyter/tensorflow-notebook
FROM jupyter/tensorflow-notebook

LABEL maintainer="Onur C. Cakmak <occ@occ.me>"

# Grant sudo by default
ENV GRANT_SUDO yes

# Set up jupyter-scala
USER root

# Install dependencies
RUN apt-get update && \
  apt-get install -y curl

# Install JDK
RUN apt-get install -y openjdk-8-jdk

# Install coursier
RUN curl -L -o coursier https://git.io/vgvpD && \
  chmod +x coursier && \
  mv coursier /usr/local/bin

# Setup jupyter-scala
USER $NB_UID

RUN curl -sSL https://raw.githubusercontent.com/jupyter-scala/jupyter-scala/master/jupyter-scala | bash

# Setup a local bin
RUN mkdir -p ${HOME}/.local/bin
ENV PATH="${PATH}:${HOME}/.local/bin"

# Install iHaskell dependencies
USER root

RUN apt-get install -y git \
  libblas-dev libcairo2-dev liblapack-dev libmagic-dev libpango1.0-dev libtinfo-dev libzmq3-dev \
  python3-pip 

RUN pip install --upgrade pip

# Install Haskell stack
RUN curl -sSL https://get.haskellstack.org/ | sh

USER $NB_UID

RUN git clone https://github.com/gibiansky/IHaskell && \
  cd IHaskell && \
  pip3 install -r requirements.txt && \
  stack install gtk2hs-buildtools && \
  stack install --fast && \
  ihaskell install --stack

# Create a notebook directory, if it doesn't exist
USER root

RUN apt-get clean

RUN mkdir -p /opt/notebooks && \
  fix-permissions /opt/notebooks

# Set CWD to /opt/notebooks
WORKDIR /opt/notebooks

USER $NB_UID

CMD ["start-notebook.sh", "--NotebookApp.token=''", "--NotebookApp.base_url=/"]