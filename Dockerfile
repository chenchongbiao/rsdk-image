FROM ubuntu:jammy AS builder

ENV DEBIAN_FRONTEND=noninteractive

# Copy rsdk from local, install build-deps, build deb; leave rsdk.deb in the image (not installed)
COPY rsdk /tmp/rsdk
RUN cd /tmp/rsdk && \
  apt-get update && \
  apt-get build-dep -y . && \
  make deb && \
  mv ../rsdk_*.deb /opt/rsdk.deb && \
  cd externals/librtui && \
  apt-get build-dep -y . && \
  make deb && \
  mv ../librtui_*.deb /opt/librtui.deb

FROM ubuntu:jammy

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
  apt-get install -y --no-install-recommends \
    ca-certificates sudo bash-completion curl && \
  rm -rf /var/lib/apt/lists/*

# Install Radxa archive keyring package (latest release)
RUN keyring="$(mktemp)" \
  && version="$(curl -fsSL https://github.com/radxa-pkg/radxa-archive-keyring/releases/latest/download/VERSION)" \
  && curl -fsSL -o "$keyring" "https://github.com/radxa-pkg/radxa-archive-keyring/releases/latest/download/radxa-archive-keyring_${version}_all.deb" \
  && dpkg -i "$keyring" \
  && rm -f "$keyring"

COPY --from=builder /opt/rsdk.deb /opt/librtui.deb /opt/

# Optional runtime installer helper (provided externally in repo)
COPY scripts/install-rsdk.sh /usr/local/bin/install-rsdk.sh
RUN chmod 0755 /usr/local/bin/install-rsdk.sh

RUN groupadd --gid 1000 rsdk && \
  useradd --uid 1000 --gid 1000 -m -s /bin/bash rsdk && \
  echo 'rsdk ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/rsdk

USER rsdk
WORKDIR /home/rsdk
