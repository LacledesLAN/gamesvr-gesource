# escape=`

FROM lacledeslan/steamcmd:linux as gesource-builder

ARG contentServer=content.lacledeslan.net

RUN apt-get update && apt-get install -y dos2unix

# Copy cached build files (if any)
COPY ./build-cache /output

# Download GoldenEye Source server files
RUN echo "Downloading GoldenEye Source from LL public ftp server" &&`
        mkdir --parents /tmp/ &&`
		curl -sSL "http://${contentServer}/fastDownloads/_installers/gesource-5.0.6server.7z" -o /tmp/gesource-server.7z &&`
    echo "Validating download against known hash" &&`
        echo "79643189e9d6549e13ed9545d2277cb34bac05fff645d44d9de1f0ab030610d3 /tmp/gesource-server.7z" | sha256sum -c - &&`
	echo "Extracting GoldenEye Source files" &&`
		7z x -o/output/ /tmp/gesource-server.7z &&`
		rm -f /tmp/*.7z

# Download Source 2007 Dedicated Server
RUN /app/steamcmd.sh +force_install_dir /output/srcds2007 +login anonymous +app_update 310 validate +quit;

COPY dist/linux/linuxify.sh /linuxify.sh

RUN chmod +x /linuxify.sh && /linuxify.sh && /linuxify.sh;

#=======================================================================
FROM debian:stretch-slim

ARG BUILDNODE=unspecified
ARG SOURCE_COMMIT=unspecified

HEALTHCHECK NONE

RUN dpkg --add-architecture i386 &&`
    apt-get update && apt-get install -y `
        ca-certificates lib32gcc1 lib32tinfo5 libcurl4-gnutls-dev:i386 libstdc++6 libstdc++6:i386 libtcmalloc-minimal4:i386 locales locales-all tmux zlib1g:i386 &&`
    apt-get clean &&`
    echo "LC_ALL=en_US.UTF-8" >> /etc/environment &&`
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*;

ENV LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8

LABEL com.lacledeslan.build-node=$BUILDNODE `
      org.label-schema.schema-version="1.0" `
      org.label-schema.url="https://github.com/LacledesLAN/README.1ST" `
      org.label-schema.vcs-ref=$SOURCE_COMMIT `
      org.label-schema.vendor="Laclede's LAN" `
      org.label-schema.description="Goldeneye Source Dedicated Server" `
      org.label-schema.vcs-url="https://github.com/LacledesLAN/gamesvr-gesource"

# Set up Enviornment
RUN useradd --home /app --gid root --system GESource &&`
    mkdir -p /app/gesource/logs &&`
    mkdir -p /app/ll-tests &&`
    chown GESource:root -R /app;

COPY --chown=GESource:root --from=gesource-builder /output/srcds2007 /app

COPY --chown=GESource:root --from=gesource-builder /output/gesource /app/gesource

COPY --chown=GESource:root dist/linux/ll-tests /app/ll-tests

ENV MALLOC_CHECK_=0

RUN chmod +x /app/ll-tests/*.sh

USER GESource

WORKDIR /app

CMD ["/bin/bash"]

ONBUILD USER root
