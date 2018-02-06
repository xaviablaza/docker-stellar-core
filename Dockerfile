FROM debian:stretch

# git tag from https://github.com/stellar/stellar-core
ARG STELLAR_CORE_VERSION="v9.1.0"
ARG STELLAR_CORE_BUILD_DEPS="git build-essential pkg-config autoconf automake libtool bison flex libpq-dev wget"
ARG STELLAR_CORE_DEPS="curl libpq5"
ARG CONFD_VERSION="0.12.0"

LABEL maintainer="hello@satoshipay.io"

# install stellar core and confd
ADD install.sh /
RUN /install.sh

# # install gcloud and gsutil
# RUN apt-get update -qq && apt-get install lsb-release -y
# RUN export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && \
#   echo "CLOUD_SDK_REPO: $CLOUD_SDK_REPO" && \
#   echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
# RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
# RUN apt-get update -qq
# RUN apt-get install google-cloud-sdk -qqy
#
VOLUME /data

# peer port
EXPOSE 11625

# HTTP port (do NOT expose publicly)
EXPOSE 11626

# configuration options, see here for docs:
# https://github.com/stellar/stellar-core/blob/master/docs/stellar-core_example.cfg
ENV \
  DATABASE="sqlite3:///data/stellar.db" \
  HTTP_MAX_CLIENT="128" \
  NETWORK_PASSPHRASE="Public Global Stellar Network ; September 2015"

ADD confd /etc/confd

# There was an issue where if gsutil is called without the wrapper, it would not have
# any environment variables set. Until that is resolved, wrap with script that loads the env.
ADD bin/gsutil /
RUN chmod +x /gsutil

ADD entry.sh /
ENTRYPOINT ["/entry.sh"]

CMD ["/usr/local/bin/stellar-core", "--conf", "/stellar-core.cfg"]
