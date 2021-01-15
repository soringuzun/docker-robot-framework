FROM python:3.9.0-alpine3.12
MAINTAINER Paul Podgorsek <ppodgorsek@users.noreply.github.com>
LABEL description Robot Framework in Docker
# Setup X Window Virtual Framebuffer
ENV SCREEN_COLOUR_DEPTH 24
ENV SCREEN_HEIGHT 1080
ENV SCREEN_WIDTH 1920
# Setup the timezone to use, defaults to UTC
ENV TZ UTC
# Set number of threads for parallel execution
# By default, no parallelisation
ENV ROBOT_THREADS 1
# Define the default user who'll run the tests
ENV ROBOT_UID 1000
ENV ROBOT_GID 1000
# Dependency versions
ENV ALPINE_GLIBC 2.31-r0
ENV CHROMIUM_VERSION 86.0
ENV DATABASE_LIBRARY_VERSION 1.2
ENV DATADRIVER_VERSION 1.0.0
ENV DATETIMETZ_VERSION 1.0.6
ENV FAKER_VERSION 5.0.0
ENV FIREFOX_VERSION 78
ENV FTP_LIBRARY_VERSION 1.9
ENV GECKO_DRIVER_VERSION v0.26.0
ENV IMAP_LIBRARY_VERSION 0.3.8
ENV PABOT_VERSION 1.10.0
ENV REQUESTS_VERSION 0.7.2
ENV ROBOT_FRAMEWORK_VERSION 3.2.2
ENV SELENIUM_LIBRARY_VERSION 4.5.0
ENV SSH_LIBRARY_VERSION 3.5.1
ENV XVFB_VERSION 1.20

#Create User
RUN addgroup robot && adduser -D -G robot robot \
  && echo "robot ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
# Prepare binaries to be executed
COPY bin/chromedriver.sh /home/robot/bin/chromedriver
COPY bin/chromium-browser.sh /home/robot/bin/chromium-browser
# Install system dependencies
RUN apk update \
  && apk --no-cache upgrade \
  && apk --no-cache --virtual .build-deps add \
    gcc \
    g++ \
    libffi-dev \
    linux-headers \
    make \
    musl-dev \
    openssl-dev \
    which \
    wget \
    libxml2-dev \
    libxslt-dev \
  && apk --no-cache add \
    "chromium~$CHROMIUM_VERSION" \
    "firefox-esr~$FIREFOX_VERSION" \
    sudo \
    xauth \
    tzdata \
    "xvfb-run~$XVFB_VERSION" \
  && mv /usr/lib/chromium/chrome /usr/lib/chromium/chrome-original \
  && ln -sfv /home/robot/bin/chromium-browser /usr/lib/chromium/chrome \
# Install Robot Framework and Selenium Library
  && pip3 install \
    --no-cache-dir \
    robotframework==$ROBOT_FRAMEWORK_VERSION \
    robotframework-databaselibrary==$DATABASE_LIBRARY_VERSION \
    robotframework-datadriver==$DATADRIVER_VERSION \
    robotframework-datetime-tz==$DATETIMETZ_VERSION \
    robotframework-faker==$FAKER_VERSION \
    robotframework-ftplibrary==$FTP_LIBRARY_VERSION \
    robotframework-imaplibrary2==$IMAP_LIBRARY_VERSION \
    robotframework-pabot==$PABOT_VERSION \
    robotframework-requests==$REQUESTS_VERSION \
    robotframework-seleniumlibrary==$SELENIUM_LIBRARY_VERSION \
    robotframework-sshlibrary==$SSH_LIBRARY_VERSION \
    robotframework-jsonlibrary \
    PyYAML \
# Download the glibc package for Alpine Linux from its GitHub repository
  && wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
    && wget -q "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$ALPINE_GLIBC/glibc-$ALPINE_GLIBC.apk" \
    && wget -q "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$ALPINE_GLIBC/glibc-bin-$ALPINE_GLIBC.apk" \
    && apk add glibc-$ALPINE_GLIBC.apk \
    && apk add glibc-bin-$ALPINE_GLIBC.apk \
    && rm glibc-$ALPINE_GLIBC.apk \
    && rm glibc-bin-$ALPINE_GLIBC.apk \
    && rm /etc/apk/keys/sgerrand.rsa.pub \
# Clean up buildtime dependencies
  && apk del --no-cache --update-cache .build-deps
USER robot
WORKDIR /home/robot
