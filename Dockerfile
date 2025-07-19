# Global Arguments to be reused within some containers
# need to be defined without value in the image-definition
# ARG wtversion=4.10-release
# ARG wtversion=4.11-release
ARG wtversion=master
ARG projectname=WtApplication.wt

# Using a baseimage to set the same in compiling-container as well as runtime-container
# FROM ubuntu:22.04 AS baseimage (might try expirimenting with different versions, 'ubuntu' doesn't work)
FROM ubuntu:latest AS baseimage

FROM baseimage AS baseessential

LABEL maintainer="Mark Petryk <mark@lorimarksolutions.com>"

RUN export DEBIAN_FRONTEND=noninteractive

# Get started with the build
RUN apt-get update       \
 && apt-get install tzdata -y                                 \
 && ln -fs /usr/share/zoneinfo/America/Chicago /etc/localtime \
 && dpkg-reconfigure --frontend noninteractive tzdata

# Installing build essentials
RUN apt-get update       \
 && apt-get install -y   \
    build-essential      \
    curl                 \
    wget                 \
    tar                  \
    rsync                \
    doxygen              \
    libpci3              \
    libegl1              \
    libcurl4-openssl-dev \
    libssl-dev           \
    libtinyxml2-dev      \
    tzdata               \
    cmake                \
    git                  \
    mc                   \
    graphviz             \
    sqlite3

# Install Howard Hinnant's date library
RUN git clone https://github.com/HowardHinnant/date.git /opt/date \
 && cd /opt/date                                                  \
 && mkdir build                                                   \
 && cd build                                                      \
 && cmake -DBUILD_TZ_LIB=ON -DCMAKE_INSTALL_PREFIX=/usr/local ..  \
 && make -j$(nproc)                                               \
 && make install

FROM baseessential AS essentials
# Installing Wt-Essentials
RUN apt-get update     \
 && apt-get install -y \
    libboost-all-dev

FROM essentials AS optionals
# Installing Optionals, Using Multiline with \
# Both dev and release packages are listed
# Release Package needs to be installed in the runtime container
RUN apt-get update     \
 && apt-get install -y \
 # OpenSSL, which is used to support the HTTPS protocol in the web client,
 # and the HTTPS protocol in the built-in wthttpd connector.
 # Also for other things in Auth
 # As The App will be behind a reverse proxy within the docker network
 # this is not really relevant
 # openssl=1.1.* \
 # libssl-dev=1.1.1* \
 # Haru Free PDF Library, which is used to provide support for painting to PDF (WPdfImage)
 # libhpdf-2.3.* \
   libhpdf-dev=2.3.0* \
 # GraphicsMagick, for supporting painting to raster images (PNG, GIF, ...) (WRasterImage)
   libgraphicsmagick++1-dev \
 # graphicsmagick=1.4* \
 # Pango, for improved font support in the WPdfImage and WRasterImage paint devices.
 # libpangoft2-1.0-0=1.42.* \
 # libpango1.0-dev=1.42.* \
   libpango1.0-dev \
 # PostgreSQL, for the PostgreSQL backend for Wt::Dbo (Dbo::backend::Postgres).
 # Only Dev Libs neccesary for building Wt
 # libpq-dev=11.5* \
   libpq-dev \
 # LibZ for Compressing
 # zliblg=1:1.2.11*
 # zlib1g-dev=1:1.2.11* \
   zlib1g-dev \
 # OpenGL for 2D and or 3D Rendering? There is no information about it in current Install ReadMe
 # Compiling needs dev Package
 # libglu1-mesa=9.0.0* \
 # libglu1-mesa-dev=9.0.0*
   libglu1-mesa-dev
 # Firebird, for the Firebird backend for Wt::Dbo (Dbo::backend::Firebird).
 # No Experience here
 # firebird-dev \
 # the C API for MySQL (mysqlclient), or the MariaDB connector library, 
 # for the MySQL/MariaDB backend for Wt::Dbo (Dbo::backend::MySQL).
 # No Experience here
 # libmariadb-dev \
 # unixODBC, for the SQL Server backend for Wt::Dbo (Dbo::backend::MSSQLServer).
 # No Experience here
 # unixodbc=2.3.6* \
 # libunwind, for the saving of backtraces in exceptions (useful for debugging).
 # No Experience here
 # libunwind-dev=1.2.1*

FROM optionals AS wt-source
ARG wtversion
ENV WT_Version=${wtversion}
WORKDIR /opt/wt-source
RUN git clone --single-branch --branch ${WT_Version} https://github.com/emweb/wt.git wt-${WT_Version}

FROM wt-source AS wt-compiled
ARG wtversion
ENV WT_Version=${wtversion}
WORKDIR /opt/wt-source/wt-${WT_Version}/build

RUN cmake                                           \
    -DCMAKE_INSTALL_PREFIX=/opt/Wt4                 \
    -DWT_WRASTERIMAGE_IMPLEMENTATION=GraphicsMagick \
    -DCONNECTOR_FCGI=OFF                            \
    -DBUILD_EXAMPLES=OFF                            \
    -DENABLE_WTTEST=OFF                             \
    -DENABLE_QT4=OFF                                \
    -DENABLE_QT5=OFF                                \
    -DENABLE_HARU=TRUE                              \
    ..
RUN make -j4
RUN make install

RUN ldconfig

RUN touch /tmp/nocache138
WORKDIR /opt
RUN git clone --single-branch https://github.com/lorimark/gnucashew-dev

WORKDIR /opt/gnucashew-dev/build
RUN ../configure-release.sh
RUN make -j4
WORKDIR /opt/gnucashew-dev/src
RUN ./dox.sh
RUN ln -s /opt/Wt4/share/Wt/resources/ /opt/gnucashew-dev/docroot/resources
RUN ln -s /opt/gnucashew-dev/dox /opt/gnucashew-dev/docroot

WORKDIR /opt/gnucashew-dev/build


