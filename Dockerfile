FROM jupyter/scipy-notebook:65761486d5d3

USER root
RUN apt update && apt install -y rsync
USER $NB_USER

################################
# Set up the conda environment #
################################

COPY environment.yml environment.yml
RUN conda env update -n base -f environment.yml


######################################################
# Build and install the jupyterlab-omnisci extension #
######################################################

WORKDIR $HOME
RUN git clone --branch connection-manager https://github.com/Quansight/jupyterlab-omnisci.git
WORKDIR jupyterlab-omnisci
RUN jlpm install && jlpm build && jupyter labextension install && pip install -e .


######################################################
# Build and install the jupyterlab-immerse extension #
######################################################

WORKDIR $HOME
RUN git clone --branch master https://github.com/Quansight/jupyterlab-immerse.git
WORKDIR jupyterlab-immerse
RUN jlpm install && jlpm build && jupyter labextension install && pip install -e .
# Enable the immerse server.
RUN jupyter serverextension enable jupyter_immerse


##################
#  Build Immerse #
##################

WORKDIR $HOME
COPY immerse immerse
# Workaround for bug in yarn: yarnpkg/yarn#6081.
COPY .git .git
# Copy our custom webpack config and servers into the immerse project.
COPY webpack.config.custom.js immerse/
COPY servers.json immerse/src/
# Fix up permissions so we can edit as user.
USER root
RUN fix-permissions immerse
USER $NB_USER
WORKDIR immerse/
RUN npm install -g yarn
# Use http node urls instead of git since we don't have SSH key.
RUN sed -i -e 's|ssh://git@|https://|g' package.json
RUN yarn install
RUN yarn build:dev


USER root
RUN echo "$NB_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/notebook
USER $NB_USER
