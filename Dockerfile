FROM ubuntu:22.04

RUN apt-get update && apt-get install -y python3 cmake git xz-utils bzip2 autoconf libtool automake bison

WORKDIR /opt
RUN git clone --depth 1 https://github.com/emscripten-core/emsdk.git
RUN cd emsdk && ./emsdk install latest && ./emsdk activate latest
