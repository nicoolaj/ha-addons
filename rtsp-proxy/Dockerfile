# Utiliser une image de base Home Assistant pour les add-ons
# Cela inclut déjà 'bashio' et 'with-contenv'
FROM ghcr.io/home-assistant/amd64-base:latest

# Définir l'étiquette de maintenance
LABEL io.hass.name="RTSP Simple Proxy"
LABEL io.hass.description="Un proxy RTSP léger pour Home Assistant"
LABEL io.hass.arch="amd64"
LABEL io.hass.type="addon"
LABEL io.hass.version="1.0.1"
LABEL io.hass.maintainer="Votre Nom <votre.email@example.com>"

# Installer Mediamtx
# L'image de base de Home Assistant utilise Debian, vous pouvez donc utiliser apt-get
RUN apt-get update \
    && apt-get install -y \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/bluenviron/mediamtx/releases/download/v1.0.1/mediamtx_v1.0.1_linux_amd64.tar.gz && \
    tar -zxvf mediamtx_v1.0.1_linux_amd64.tar.gz -C /usr/local/bin && \
    chmod a+x /usr/local/bin/mediamtx

# Copier notre script de démarrage dans le conteneur
COPY run.sh /
RUN chmod a+x /run.sh

# Exécuter le script lorsque le conteneur démarre
CMD [ "/run.sh" ]
