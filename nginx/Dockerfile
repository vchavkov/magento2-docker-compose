FROM debian:buster
LABEL maintainer="vchavkov@assistance.bg"

# ------------------------------------------------------------------------------
COPY ./bin/*.sh /tmp/
RUN LC_ALL=C DEBIAN_FRONTEND=noninteractive /tmp/setup.sh \
  && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------------------------
# copy custom files
COPY ./conf/ /

# ------------------------------------------------------------------------------
# Add volumes
VOLUME ["/var/cache/nginx"]

# ------------------------------------------------------------------------------
EXPOSE 80 443 22

# ------------------------------------------------------------------------------
# ENTRYPOINT ["/entrypoint.sh"]

# CMD ["nginx", "-g", "daemon off;"]

# CMD ["/usr/sbin/sshd", "-D"]
