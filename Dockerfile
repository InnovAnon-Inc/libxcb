FROM innovanon/xorg-base:latest as builder-01
USER root
COPY --from=innovanon/util-macros /tmp/util-macros.txz /tmp/
COPY --from=innovanon/xorgproto   /tmp/xorgproto.txz   /tmp/
COPY --from=innovanon/libxau      /tmp/libXau.txz      /tmp/
COPY --from=innovanon/libxdmcp    /tmp/libXdmcp.txz    /tmp/
COPY --from=innovanon/xcb-proto   /tmp/xcbproto.txz    /tmp/
RUN extract.sh

ARG LFS=/mnt/lfs
WORKDIR $LFS/sources
USER lfs
RUN sleep 31                                                                           \
 && git clone --depth=1 --recursive https://gitlab.freedesktop.org/xorg/lib/libxcb.git \
 && cd                                                                      libxcb     \
 && ./autogen.sh                                                                       \
 && CFLAGS=-Wno-error=format-extra-args ./configure $XORG_CONFIG                       \
      --without-doxygen                                                                \
 && make                                                                               \
 && make DESTDIR=/tmp/libxcb install                                                   \
 && rm -rf                                                                  libxcb     \
 && cd           /tmp/libxcb                                                           \
 && strip.sh .                                                                         \
 && tar  pacf        ../libxcb.txz .                                                     \
 && cd ..                                                                              \
 && rm -rf       /tmp/libxcb

FROM scratch as final
COPY --from=builder-01 /tmp/libxcb.txz /tmp/

