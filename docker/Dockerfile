## This Source Code Form is subject to the terms of the Mozilla Public
## License, v. 2.0. If a copy of the MPL was not distributed with this
## file, You can obtain one at https://mozilla.org/MPL/2.0/.

FROM ubuntu:20.04 AS base

ENV TZ="Etc/UTC"

##
##  Pre-download stage (common to all download stages).
##
FROM base AS pre-dl

ENV DEBIAN_FRONTEND="noninteractive"

##  Download stages depend on package info to continue installing stuff.
#   hadolint ignore=DL3009
RUN set -x \
&&  apt-get update \
&&  apt-get install -y --no-install-suggests --no-install-recommends \
    ca-certificates=20210119~20.04.2 \
    wget=1.20.3-1ubuntu2

ENV OPTDIR=/usr/local/lib

WORKDIR /tmp

##
##  SBT download stage.
##
FROM pre-dl AS sbt-dl

ENV PATH="${PATH}:${OPTDIR}/sbt/bin"

RUN apt-get install -y --no-install-suggests --no-install-recommends \
    openjdk-8-jre-headless=8u312-b07-0ubuntu1~20.04

ARG SBT_VER=0.13.17

ENV ARCHIVE="sbt-${SBT_VER}.tgz"
RUN wget --progress=dot:giga "https://github.com/sbt/sbt/releases/download/v${SBT_VER}/${ARCHIVE}"

ARG SBT_SHA=25f782ccb2ad6d54e13ce6cec0afa3d2328874c508d68ee34e2f742e99f2c847

##  printf can't fail and even if, sha256sum would immediately follow.
#   hadolint ignore=DL4006
RUN set -x \
&&  printf '%s  %s' "$SBT_SHA" "$ARCHIVE" | sha256sum -c \
&&  tar -C "$OPTDIR" -xf "$ARCHIVE" \
&&  sbt -V

##
##  Node.js download stage.
##
FROM pre-dl AS node-dl

ENV PATH="${PATH}:${OPTDIR}/node/bin"

RUN apt-get install -y --no-install-suggests --no-install-recommends \
    xz-utils=5.2.4-1ubuntu1

ARG NODE_VER=14.19.0
ARG NODE_ARCH=arm64

ENV DIR="node-v${NODE_VER}-linux-${NODE_ARCH}"
ENV ARCHIVE="${DIR}.tar.xz"
RUN wget --progress=dot:giga "https://nodejs.org/dist/v${NODE_VER}/${ARCHIVE}"

ARG NODE_SHA=73224b331d2bb0f05fd2ff62d1c736460f12f8e8757e8afbbcdf11a7f1464da5

##  printf can't fail and even if, sha256sum would immediately follow.
##  The pre-dl stage already set WORKDIR.
#   hadolint ignore=DL3003,DL4006
RUN set -x \
&&  printf '%s  %s' "$NODE_SHA" "$ARCHIVE" | sha256sum -c \
&&  tar -C "$OPTDIR" -xf "$ARCHIVE" \
&&  ( \
        cd "$OPTDIR" \
    &&  mv "$DIR" "node" \
    )

##  XXX Enable after react is bumped to ^17.0.1 in @ledgerhq/live-common.
#   RUN npm install --global npm
RUN npm install --global yarn@1.22.17

##  Create a directory to be used later for user-local NPM installations.
RUN mkdir -p /.npm/bin

##
## Prompt setup stage.
##
FROM base AS prompt-setup

COPY prompt-setup /
RUN /prompt-setup /etc/skel/.bashrc

##
##  Aggregate stage (aggregates files for copying into the final image).
##
FROM base AS aggregate

ENV DEST_ROOT=/agr \
    OPTDIR=/usr/local/lib
ENV DEST_OPTDIR="${DEST_ROOT}${OPTDIR}"

COPY --from=node-dl --chown=0:0 "$OPTDIR" "${DEST_OPTDIR}"
COPY --from=sbt-dl --chown=0:0 "$OPTDIR" "${DEST_OPTDIR}"

ENV BUNDLE_ROOT="${DEST_ROOT}/.ledobe"
ENV HOME="${BUNDLE_ROOT}/home"

COPY --from=sbt-dl /root/.sbt "${HOME}/.sbt"
COPY --from=sbt-dl /root/.ivy2 "${HOME}/.ivy2"

COPY --from=prompt-setup /etc/skel/.bashrc "${DEST_ROOT}/etc/skel/"
COPY --chown=0:0 npmrc "${DEST_ROOT}/etc/skel/.npmrc"
COPY --chown=0:0 home-npm.sh "${DEST_ROOT}/etc/profile.d/"
COPY --from=node-dl /.npm "${HOME}/.npm"

COPY build "${BUNDLE_ROOT}/build"
COPY entrypoint "${DEST_ROOT}/usr/bin/entrypoint"

##  It's simpler to change dir in the same layer as many times as we need.
#   hadolint ignore=DL3003,DL4006
RUN set -x \
&&  for resource in build home; do \
        cd "${BUNDLE_ROOT}/${resource}" \
    &&  find . -mindepth 1 -print0 | sort -z \
    >   "${BUNDLE_ROOT}/manifest-${resource}" \
;   done \
&&  :

FROM base AS final

RUN set -x \
&&  apt-get update \
&&  DEBIAN_FRONTEND="noninteractive" \
    apt-get install -y --no-install-suggests --no-install-recommends \
##  Essential build tools.
    cmake=3.16.3-1ubuntu1 \
    g++=4:9.3.0-1ubuntu2 \
    git=1:2.25.1-1ubuntu3.2 \
    make=4.2.1-1.2 \
    openjdk-8-jre-headless=8u312-b07-0ubuntu1~20.04 \
    pkg-config=0.29.1-0ubuntu4 \
    python-is-python3=3.8.2-4 \
##  Ledger Live build dependecies.
    libqt5websockets5-dev=5.12.8-0ubuntu1 \
    libudev-dev=245.4-4ubuntu3.15 \
    libusb-1.0-0-dev=2:1.0.23-2build1 \
    qtbase5-dev=5.12.8+dfsg-0ubuntu2.1 \
##  Convenience utils specific to this Docker environment.
    bash-completion=1:2.10-1ubuntu1 \
    gosu=1.10-1ubuntu0.20.04.1 \
    openssh-client=1:8.2p1-4ubuntu0.4 \
&&  rm -rf /var/lib/apt/lists/* \
&&  git config -f /etc/skel/.gitconfig \
    user.name 'Ledger DoBE' \
&&  git config -f /etc/skel/.gitconfig \
    user.email 'ledobe@example.com' \
&&  ssh-keyscan \
    github.com \
    >> /etc/ssh/ssh_known_hosts \
&&  :

COPY --from=aggregate /agr /

ENV PATH="${PATH}:/usr/local/lib/sbt/bin:/usr/local/lib/node/bin"

WORKDIR /build

CMD ["/bin/bash"]

VOLUME \
    /build \
    /mnt/home

ENTRYPOINT ["entrypoint"]
