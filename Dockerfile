FROM 0x01be/gaw as gaw

FROM alpine as build

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
    libxpm-dev

ENV REVISION=master
RUN git clone --depth 1 --branch ${REVISION} https://github.com/StefanSchippers/xschem.git /xschem

WORKDIR /xschem

RUN ./configure --prefix=/opt/xschem
RUN make
RUN make install

RUN git clone https://github.com/StefanSchippers/xschem_sky130.git /opt/xschem/sky130

FROM 0x01be/xpra

RUN apk add --no-cache --virtual xschem-runtime-dependencies \
    tcl \
    tk \
    libxpm && apk add --no-cache --virtual xschem-sim-dependencies \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
    ngspice

COPY --from=gaw /opt/gaw/ /opt/gaw/
COPY --from=build /opt/xschem/ /opt/xschem/

USER ${USER}
ENV PATH=${PATH}:/opt/gaw/bin/:/opt/xschem/bin/ \
    COMMAND=xschem

