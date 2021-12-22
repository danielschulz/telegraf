ARG GOLANG_VERSION="1.17.5"
FROM golang:${GOLANG_VERSION}

ARG APPS_HOME="/apps"
ARG APPS_SW_HOME="${APPS_HOME}/sw"
ARG TELEGRAF_HOME="${APPS_SW_HOME}/metrics/telegraf"

# prepare filesystem and its permissions
RUN chmod -R 755 "${GOPATH}" && \
    mkdir -p ${TELEGRAF_HOME}

# update existing OS dependencies, add new ones and remove cache files after that
RUN DEBIAN_FRONTEND=noninteractive \
	apt update && \
    apt install -qq -y --no-install-recommends \
        autoconf \
	    git \
        libtool \
        locales \
        make \
        awscli \
        rpm \
        ruby \
        ruby-dev \
        zip && \
    apt clean all && \
	rm -rf /var/lib/apt/lists/*

# set environment settings
RUN ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime
RUN locale-gen C.UTF-8 || true
ENV LANG="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8" \
    TZ="CET" \
    PATH=${PATH}:${TELEGRAF_HOME}

# install dependency fpm
RUN gem install fpm

# add the pre-compiled Telegraf binary to its prepared home path
COPY --chown=root:root --chmod=500 ./telegraf ${TELEGRAF_HOME}/
