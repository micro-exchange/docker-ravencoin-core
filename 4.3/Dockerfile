# Build stage for BerkeleyDB
FROM ubuntu as berkeleydb

RUN apt-get update

RUN apt-get install -y wget
RUN apt-get install -y build-essential

ENV BERKELEYDB_VERSION=db-4.8.30.NC
ENV BERKELEYDB_PREFIX=/opt/${BERKELEYDB_VERSION}

RUN update-ca-certificates -f
RUN wget https://download.oracle.com/berkeley-db/${BERKELEYDB_VERSION}.tar.gz
RUN tar -xzf *.tar.gz
RUN sed s/__atomic_compare_exchange/__atomic_compare_exchange_db/g -i ${BERKELEYDB_VERSION}/dbinc/atomic.h
RUN mkdir -p ${BERKELEYDB_PREFIX}

WORKDIR /${BERKELEYDB_VERSION}/build_unix

RUN ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=${BERKELEYDB_PREFIX}
RUN make -j`nproc`
RUN make install
RUN rm -rf ${BERKELEYDB_PREFIX}/docs

# Build stage for Ravencoin Core
FROM ubuntu as ravencoin-core

RUN apt-get update

RUN apt-get install -y git
RUN apt-get install -y build-essential
RUN apt-get install -y libzmq3-dev
RUN apt-get install -y autotools-dev
RUN apt-get install -y automake
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y pkg-config
RUN apt-get install -y libtool
RUN apt-get install -y libboost-all-dev
RUN apt-get install -y libssl-dev
RUN apt-get install -y libevent-dev
RUN apt-get install -y bsdmainutils
RUN apt-get install -y python3

COPY --from=berkeleydb /opt /opt

ENV RAVENCOIN_VERSION=4.3.2.1
ENV RAVENCOIN_PREFIX=/opt/ravencoin-${RAVENCOIN_VERSION}

RUN git clone https://github.com/RavenProject/Ravencoin.git /ravencoin-${RAVENCOIN_VERSION} \
    && cd /ravencoin-${RAVENCOIN_VERSION} \
    && git checkout v${RAVENCOIN_VERSION}

WORKDIR /ravencoin-${RAVENCOIN_VERSION}

# RUN sed -i '/AC_PREREQ/a\AR_FLAGS=cr' src/univalue/configure.ac
# RUN sed -i '/AX_PROG_CC_FOR_BUILD/a\AR_FLAGS=cr' src/secp256k1/configure.ac
# RUN sed -i s:sys/fcntl.h:fcntl.h: src/compat.h
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
RUN strip ${RAVENCOIN_PREFIX}/lib/libravenconsensus.a
RUN strip ${RAVENCOIN_PREFIX}/lib/libravenconsensus.so.0.0.0

# Build stage for compiled artifacts
FROM ubuntu

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata
RUN apt-get install -y libzmq3-dev
RUN apt-get install -y libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-program-options-dev libboost-test-dev libboost-thread-dev
RUN apt-get install -y libevent-dev 
RUN apt-get install -y curl

RUN useradd -r ravencoin

ENV RAVENCOIN_DATA=/home/ravencoin/.ravencoin
ENV RAVENCOIN_VERSION=4.3.2.1
ENV RAVENCOIN_PREFIX=/opt/ravencoin-${RAVENCOIN_VERSION}
ENV PATH=${RAVENCOIN_PREFIX}/bin:$PATH

COPY --from=ravencoin-core /opt /opt
COPY docker-entrypoint.sh /entrypoint.sh

VOLUME ["/home/ravencoin/.ravencoin"]

EXPOSE 8757 18757 8756 18756 

ENTRYPOINT ["/entrypoint.sh"]

RUN ravend -version | grep "Raven Core Daemon version v${RAVENCOIN_VERSION}"

CMD ["ravend"]