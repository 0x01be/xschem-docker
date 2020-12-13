FROM 0x01be/gaw as gaw

FROM 0x01be/base as build

WORKDIR /xschem
ENV REVISION=master
RUN apk add --no-cache --virtual xschem-build-dependencies \
    git \
    build-base \
    gawk \
    flex \
    bison \
    tcl-dev \
    tk-dev \
    cairo-dev \
    libx11-dev \
    libxpm-dev &&\
    git clone --depth 1 --branch ${REVISION} https://github.com/StefanSchippers/xschem.git /xschem &&\
    ./configure --prefix=/opt/xschem &&\
    make
RUN make install &&\
    git clone https://github.com/StefanSchippers/xschem_sky130.git /opt/xschem/sky130

FROM 0x01be/xpra

COPY --from=gaw /opt/gaw/ /opt/gaw/
COPY --from=build /opt/xschem/ /opt/xschem/

RUN apk add --no-cache --virtual xschem-runtime-dependencies \
    tcl \
    tk \
    libxpm && apk add --no-cache --virtual xschem-sim-dependencies \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
    ngspice

USER ${USER}
ENV PATH=${PATH}:/opt/gaw/bin/:/opt/xschem/bin/ \
    COMMAND=xschem

