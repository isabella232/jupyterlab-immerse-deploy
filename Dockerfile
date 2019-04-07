FROM jupyter/scipy-notebook:65761486d5d3

USER root
RUN apt update && apt install -y rsync

################################
# Set up the conda environment #
################################

COPY environment.yml /tmp/environment.yml
RUN conda env update -n base -f /tmp/environment.yml


######################################################
# Build and install the jupyterlab-omnisci extension #
######################################################

RUN git clone --branch connection-manager https://github.com/Quansight/jupyterlab-omnisci.git
WORKDIR jupyterlab-omnisci
RUN jlpm install && jlpm build && jupyter labextension install && pip install -e .
WORKDIR /


######################################################
# Build and install the jupyter-immerse extension #
######################################################

RUN git clone --branch master https://github.com/Quansight/jupyter-immerse.git
WORKDIR jupyter-immerse
RUN jlpm install && jlpm build && jupyter labextension install && pip install -e .
# Enable the immerse server.
RUN jupyter serverextension enable jupyter_immerse
WORKDIR /


##################
#  Build Immerse #
##################

COPY . .
# Copy our custom webpack config and servers into the 
RUN mv webpack.config.custom.js immerse/
RUN mv servers.json immerse/src/
WORKDIR immerse/
RUN npm install -g yarn
# use http node urls instead of git since we don't have key
RUN sed -i -e 's|ssh://git@|https://|g' package.json
RUN yarn install
RUN yarn build:dev
WORKDIR /


RUN echo "$NB_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/notebook
USER $NB_USER
