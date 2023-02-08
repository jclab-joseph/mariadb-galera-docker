FROM docker.io/bitnami/minideb:bullseye

LABEL org.opencontainers.image.authors="https://github.com/jclab-joseph" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.source="https://github.com/jclab-joseph/mariadb-galera-docker" \
      org.opencontainers.image.title="mariadb-galera" \
      org.opencontainers.image.vendor="JC-Lab"

RUN apt-get update && \
    apt-get install -y galera-4 galera-arbitrator-4 mariadb-server-10.5

RUN mkdir -p /opt/bitnami && \
    ln -s /usr /opt/bitnami/mariadb

ENV HOME="/" \
    OS_ARCH="${TARGETARCH:-amd64}" \
    OS_FLAVOUR="debian-11" \
    OS_NAME="linux"

COPY b2/prebuildfs /
RUN install_packages ca-certificates iproute2 ldap-utils libaio1 libaudit1 libcap-ng0 libcrypt1 libgcc-s1 libicu67 libldap-common liblzma5 libncurses6 libpam-ldapd libpam0g libssl1.1 libstdc++6 libtinfo6 libxml2 nslcd procps psmisc rsync socat zlib1g

RUN chmod g+rwX /opt/bitnami
RUN mkdir /docker-entrypoint-initdb.d

COPY b2/rootfs /
RUN /opt/bitnami/scripts/mariadb-galera/postunpack.sh
ENV APP_VERSION="10.10.3" \
    BITNAMI_APP_NAME="mariadb-galera" \
    PATH="/opt/bitnami/common/bin:/opt/bitnami/common/sbin:/opt/bitnami/mariadb/bin:/opt/bitnami/mariadb/sbin:$PATH"

EXPOSE 3306 4444 4567 4568

USER 1001
ENTRYPOINT [ "/opt/bitnami/scripts/mariadb-galera/entrypoint.sh" ]
CMD [ "/opt/bitnami/scripts/mariadb-galera/run.sh" ]
