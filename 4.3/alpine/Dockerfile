# Build stage for BerkeleyDB
FROM alpine as berkeleydb

RUN sed -i 's/http\:\/\/dl-cdn.alpinelinux.org/https\:\/\/alpine.global.ssl.fastly.net/g' /etc/apk/repositories
RUN apk --no-cache add autoconf
RUN apk --no-cache add automake
RUN apk --no-cache add build-base
RUN apk --no-cache add libressl

ENV BERKELEYDB_VERSION=db-4.8.30.NC
ENV BERKELEYDB_PREFIX=/opt/${BERKELEYDB_VERSION}

RUN wget https://download.oracle.com/berkeley-db/${BERKELEYDB_VERSION}.tar.gz
RUN tar -xzf *.tar.gz
RUN sed s/__atomic_compare_exchange/__atomic_compare_exchange_db/g -i ${BERKELEYDB_VERSION}/dbinc/atomic.h
RUN mkdir -p ${BERKELEYDB_PREFIX}

WORKDIR /${BERKELEYDB_VERSION}/build_unix

RUN ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=${BERKELEYDB_PREFIX}
RUN make -j`nproc`
RUN make install
RUN rm -rf ${BERKELEYDB_PREFIX}/docs

# Build stage for Bitcoin Core
FROM alpine as ravencoin-core

COPY --from=berkeleydb /opt /opt

RUN sed -i 's/http\:\/\/dl-cdn.alpinelinux.org/https\:\/\/alpine.global.ssl.fastly.net/g' /etc/apk/repositories
RUN apk --no-cache add autoconf
RUN apk --no-cache add automake
RUN apk --no-cache add boost-dev
RUN apk --no-cache add build-base
RUN apk --no-cache add chrpath
RUN apk --no-cache add file
RUN apk --no-cache add gnupg
RUN apk --no-cache add libevent-dev
RUN apk --no-cache add libressl
RUN apk --no-cache add libtool
RUN apk --no-cache add linux-headers
RUN apk --no-cache add zeromq-dev
RUN apk --no-cache add git
RUN apk --no-cache add openssl-dev

ENV RAVENCOIN_VERSION=4.3.2.1
ENV RAVENCOIN_PREFIX=/opt/ravencoin-${RAVENCOIN_VERSION}

RUN git clone https://github.com/RavenProject/Ravencoin.git /ravencoin-${RAVENCOIN_VERSION} \
    && cd /ravencoin-${RAVENCOIN_VERSION} \
    && git checkout v${RAVENCOIN_VERSION}

WORKDIR /ravencoin-${RAVENCOIN_VERSION}

RUN sed -i '/AC_PREREQ/a\AR_FLAGS=cr' src/univalue/configure.ac
RUN sed -i '/AX_PROG_CC_FOR_BUILD/a\AR_FLAGS=cr' src/secp256k1/configure.ac
RUN sed -i s:sys/fcntl.h:fcntl.h: src/compat.h
RUN ./autogen.sh
RUN ./configure LDFLAGS=-L`ls -d /opt/db*`/lib/ CPPFLAGS=-I`ls -d /opt/db*`/include/ \
    --prefix=${RAVENCOIN_PREFIX} \
    --mandir=/usr/share/man \
    --disable-tests \
    --disable-bench \
    --disable-ccache \
    --with-gui=no \
    --with-utils \
    --with-libs \
    --with-daemon
RUN make -j`nproc`
RUN make install
RUN strip ${RAVENCOIN_PREFIX}/bin/raven-cli
#RUN strip ${RAVENCOIN_PREFIX}/bin/raven-tx
RUN strip ${RAVENCOIN_PREFIX}/bin/ravend
#RUN strip ${RAVENCOIN_PREFIX}/lib/libravencoinconsensus.a
#RUN strip ${RAVENCOIN_PREFIX}/lib/libravencoinconsensus.so.0.0.0

# Build stage for compiled artifacts
FROM alpine

RUN adduser -S ravencoin
RUN sed -i 's/http\:\/\/dl-cdn.alpinelinux.org/https\:\/\/alpine.global.ssl.fastly.net/g' /etc/apk/repositories
RUN apk --no-cache add \
  boost-filesystem \
  boost-system \
  boost-thread \
  libevent \
  libzmq \
  su-exec

ENV RAVENCOIN_DATA=/home/ravencoin/.ravencoin
ENV RAVENCOIN_VERSION=4.3.2.1
ENV RAVENCOIN_PREFIX=/opt/ravencoin-${RAVENCOIN_VERSION}
ENV PATH=${RAVENCOIN_PREFIX}/bin:$PATH

COPY --from=ravencoin-core /opt /opt
COPY docker-entrypoint.sh /entrypoint.sh

VOLUME ["/home/ravencoin/.ravencoin"]

EXPOSE 8757 18757 8756 18756 

ENTRYPOINT ["/entrypoint.sh"]

RUN ravend -version | grep "Raven Core version v${RAVENCOIN_VERSION}"

CMD ["ravend"]