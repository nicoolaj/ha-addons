# Dockerfile
ARG BUILD_FROM
FROM ${BUILD_FROM}

# Utiliser l'image officielle de mediamtx
FROM bluenviron/mediamtx:latest

# Copier notre script de démarrage dans le conteneur
COPY run.sh /
RUN chmod a+x /run.sh

# Exécuter le script lorsque le conteneur démarre
CMD [ "/run.sh" ]

