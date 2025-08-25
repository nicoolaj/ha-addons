#!/usr/bin/with-contenv bashio

# Définir le chemin du fichier de configuration pour mediamtx
CONFIG_FILE="/mediamtx.yml"

bashio::log.info "Génération de la configuration pour mediamtx..."

# Récupérer le port RTSP configuré par l'utilisateur
RTSP_PORT=$(bashio::addon.port 8554)

# Créer le fichier de configuration YAML de base
cat > ${CONFIG_FILE} <<EOL
rtspPort: ${RTSP_PORT}
api: yes
webrtc: no
paths:
EOL

# Utiliser bashio pour lire la liste des caméras
if bashio::config.has_value 'cameras'; then
    for camera in $(bashio::config 'cameras|keys'); do
        # Extraire le nom et l'URL de chaque caméra
        NAME=$(bashio::config "cameras[${camera}].name")
        URL=$(bashio::config "cameras[${camera}].url")

        if [ -n "$NAME" ] && [ -n "$URL" ]; then
            bashio::log.info "Ajout de la caméra : ${NAME} (${URL})"
            
            # Ajouter la configuration pour cette caméra au fichier
            cat >> ${CONFIG_FILE} <<EOL
  ${NAME}:
    source: ${URL}
    sourceOnDemand: yes
EOL
        else
            bashio::log.warn "Un élément de caméra n'a pas de nom ou d'URL. Il sera ignoré."
        fi
    done
else
    bashio::log.warn "Aucune caméra n'a été trouvée dans la configuration."
fi

bashio::log.info "Configuration générée. Démarrage du serveur mediamtx..."

# Afficher la configuration générée pour le débogage
cat ${CONFIG_FILE}

# Lancer le serveur mediamtx avec le fichier de configuration
exec /usr/local/bin/mediamtx ${CONFIG_FILE}
