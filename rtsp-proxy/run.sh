#!/usr/bin/with-contenv bashio

# Créer le fichier de configuration pour mediamtx
CONFIG_FILE="/mediamtx.yml"

bashio::log.info "Génération de la configuration pour mediamtx..."

# Utiliser un heredoc pour créer le fichier de configuration YAML avec la bonne indentation
cat > ${CONFIG_FILE} <<EOL
rtspPort: 8554
api: yes
webrtc: no
paths:
EOL

# Lire la liste des caméras depuis les options de l'add-on
# et boucler dessus pour les ajouter à la configuration
for camera in $(bashio::config 'cameras|keys'); do
    # Récupérer le nom et l'URL de la caméra
    NAME=$(bashio::config "cameras[${camera}].name")
    URL=$(bashio::config "cameras[${camera}].url")

    bashio::log.info "Ajout de la caméra : ${NAME} (${URL})"

    # Ajouter la configuration pour cette caméra au fichier
    # Le nom est utilisé comme "path" (chemin)
    # ex: rtsp://<home-assistant-ip>:8554/jardin
    cat >> ${CONFIG_FILE} <<EOL
  ${NAME}:
    source: ${URL}
    sourceOnDemand: yes
EOL
done

bashio::log.info "Configuration générée. Démarrage du serveur mediamtx..."

# Afficher la configuration générée pour le débogage
cat ${CONFIG_FILE}

# Lancer le serveur mediamtx avec notre fichier de configuration
exec /usr/local/bin/mediamtx /mediamtx.yml
