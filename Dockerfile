# Generated by: Neurodocker version 0.7.0+0.gdc97516.dirty
# Latest release: Neurodocker version 0.9.5
# Timestamp: 2023/06/28 17:31:12 UTC
#
# Thank you for using Neurodocker. If you discover any issues
# or ways to improve this software, please submit an issue or
# pull request on our GitHub repository:
#
#     https://github.com/ReproNim/neurodocker

FROM debian:bullseye

USER root

ARG DEBIAN_FRONTEND="noninteractive"

ENV LANG="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8" \
    ND_ENTRYPOINT="/neurodocker/startup.sh"
RUN export ND_ENTRYPOINT="/neurodocker/startup.sh" \
    && apt-get update -qq \
    && apt-get install -y -q --no-install-recommends \
           apt-utils \
           bzip2 \
           ca-certificates \
           curl \
           jq \
           locales \
           unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG="en_US.UTF-8" \
    && chmod 777 /opt && chmod a+s /opt \
    && mkdir -p /neurodocker \
    && if [ ! -f "$ND_ENTRYPOINT" ]; then \
         echo '#!/usr/bin/env bash' >> "$ND_ENTRYPOINT" \
    &&   echo 'set -e' >> "$ND_ENTRYPOINT" \
    &&   echo 'export USER="${USER:=`whoami`}"' >> "$ND_ENTRYPOINT" \
    &&   echo 'if [ -n "$1" ]; then "$@"; else /usr/bin/env bash; fi' >> "$ND_ENTRYPOINT"; \
    fi \
    && chmod -R 777 /neurodocker && chmod a+s /neurodocker

ENTRYPOINT ["/neurodocker/startup.sh"]

ENV ANTSPATH="/opt/ants-2.3.1" \
    PATH="/opt/ants-2.3.1:$PATH"
RUN echo "Downloading ANTs ..." \
    && mkdir -p /opt/ants-2.3.1 \
    && curl -fsSL --retry 5 https://dl.dropbox.com/s/1xfhydsf4t4qoxg/ants-Linux-centos6_x86_64-v2.3.1.tar.gz \
    | tar -xz -C /opt/ants-2.3.1 --strip-components 1

ENV FSLDIR="/opt/fsl-6.0.7.6" \
    PATH="/opt/fsl-6.0.7.6/bin:$PATH" \
    FSLOUTPUTTYPE="NIFTI_GZ" \
    FSLMULTIFILEQUIT="TRUE" \
    FSLTCLSH="/opt/fsl-6.0.7.6/bin/fsltclsh" \
    FSLWISH="/opt/fsl-6.0.7.6/bin/fslwish" \
    FSLLOCKDIR="" \
    FSLMACHINELIST="" \
    FSLREMOTECALL="" \
    FSLGECUDAQ="cuda.q"
RUN apt-get update -qq \
    && apt-get install -y -q --no-install-recommends \
           bc \
           ca-certificates \
           curl \
           dc \
           file \
           libfontconfig1 \
           libfreetype6 \
           libgl1-mesa-dev \
           libgl1-mesa-dri \
           libglu1-mesa-dev \
           libgomp1 \
           libice6 \
           libopenblas-base \
           libxcursor1 \
           libxft2 \
           libxinerama1 \
           libxrandr2 \
           libxrender1 \
           libxt6 \
           nano \
           python3 \
           sudo \
           wget \
    && rm -rf /var/lib/apt/lists/*

RUN echo "Installing FSL ..." \
    && curl -fsSL https://fsl.fmrib.ox.ac.uk/fsldownloads/fslconda/releases/fslinstaller.py | python3 - -d /opt/fsl-6.0.7.6 -V 6.0.7.6

ENV C3DPATH="/opt/convert3d-1.0.0" \
    PATH="/opt/convert3d-1.0.0/bin:$PATH"
RUN echo "Downloading Convert3D ..." \
    && mkdir -p /opt/convert3d-1.0.0 \
    && curl -fsSL --retry 5 https://sourceforge.net/projects/c3d/files/c3d/1.0.0/c3d-1.0.0-Linux-x86_64.tar.gz/download \
    | tar -xz -C /opt/convert3d-1.0.0 --strip-components 1

RUN apt-get update -qq \
    && apt-get install -y -q --no-install-recommends \
           gcc \
           libc6-dev \
           libopenblas-base \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.9 \
    python3-pip \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/bin/python3.9 /usr/bin/python

RUN echo '{ \
    \n  "pkg_manager": "apt", \
    \n  "instructions": [ \
    \n    [ \
    \n      "base", \
    \n      "debian:bullseye" \
    \n    ], \
    \n    [ \
    \n      "ants", \
    \n      { \
    \n        "version": "2.3.1", \
    \n        "method": "binaries" \
    \n      } \
    \n    ], \
    \n    [ \
    \n      "fsl", \
    \n      { \
    \n        "version": "6.0.7.6, \
    \n        "method": "binaries" \
    \n      } \
    \n    ], \
    \n    [ \
    \n      "convert3d", \
    \n      { \
    \n        "version": "1.0.0", \
    \n        "method": "binaries" \
    \n      } \
    \n    ], \
    \n    [ \
    \n      "install", \
    \n      [ \
    \n        "gcc", \
    \n        "libc6-dev" \
    \n      ] \
    \n    ] \
    \n  ] \
    \n}' > /neurodocker/neurodocker_specs.json

WORKDIR /app
COPY . /app
