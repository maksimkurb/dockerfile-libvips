FROM ubuntu:20.04
LABEL maintainer="Maxim Kurbatov <max@cubly.ru>"

ENV LIBVIPS_VERSION_MAJOR 8
ENV LIBVIPS_VERSION_MINOR 10
ENV LIBVIPS_VERSION_PATCH 1
ENV LIBVIPS_VERSION $LIBVIPS_VERSION_MAJOR.$LIBVIPS_VERSION_MINOR.$LIBVIPS_VERSION_PATCH

RUN \
  # Install dependencies
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y \
  automake build-essential curl \
  gobject-introspection gtk-doc-tools libglib2.0-dev libjpeg-turbo8-dev libpng-dev \
  libwebp-dev libtiff5-dev libgif-dev libexif-dev libxml2-dev libpoppler-glib-dev \
  swig libmagickwand-dev libpango1.0-dev libmatio-dev libcfitsio-dev \
  libgsf-1-dev fftw3-dev liborc-0.4-dev librsvg2-dev libmagickcore-6.q16-6 openexr \
  git cmake libsqlite3-dev libgtk2.0-dev libjpeg-dev liblcms2-dev libtiff-dev libtool \
  pkg-config python3-pip sqlite3
  # Download openslide
RUN cd /tmp && \
  # Build OpenJPEG
  git clone https://github.com/uclouvain/openjpeg.git && \
  cd openjpeg && \
  mkdir build && \
  cd build && cmake ../ -DCMAKE_BUILD_TYPE=Release && \
  make -j16 && \
  make install && \
  make clean && \
  # Download OpenSlide
  git clone https://github.com/openslide/openslide.git && \
  cd openslide && \
  # Openslide MIRAX patch
  curl -L https://github.com/openslide/openslide/pull/293.patch > /tmp/239.patch && \
  git apply --check /tmp/239.patch && \
  git apply /tmp/239.patch && \
  # Build openslide
  autoreconf -i && \
  ./configure && \
  make -j16 && \
  make install && \
  # Build libvips
  cd /tmp && \
  curl -L -O https://github.com/libvips/libvips/releases/download/v$LIBVIPS_VERSION/vips-$LIBVIPS_VERSION.tar.gz && \
  tar zvxf vips-$LIBVIPS_VERSION.tar.gz && \
  cd /tmp/vips-$LIBVIPS_VERSION && \
  ./configure --enable-debug=no --without-python $1 && \
  make -j16 && \
  make install && \
  ldconfig && \
  # Clean up
  apt-get remove -y curl automake build-essential && \
  apt-get autoremove -y && \
  apt-get autoclean && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
