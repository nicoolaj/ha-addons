#!/usr/bin/with-contenv bashio

# Définir le chemin du fichier de configuration pour mediamtx
CONFIG_FILE="/mediamtx.yml"

bashio::log.info "Génération de la configuration pour mediamtx..."

# Créer le fichier de configuration YAML de base
cat > ${CONFIG_FILE} <<EOL
rtspPort: 8554
api: yes
webrtc: no
paths:
EOL

# Récupérer la liste des caméras au format JSON
CAMERAS_JSON=$(bashio::config 'cameras')

# Utiliser jq pour itérer sur le tableau de caméras
echo "$CAMERAS_JSON" | jq -c '.[]' | while read -r camera; do
    # Extraire le nom et l'URL de chaque caméra
    NAME=$(echo "$camera" | jq -r '.name')
    URL=$(echo "$camera" | jq -r '.url')

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

bashio::log.info "Configuration générée. Démarrage du serveur mediamtx..."

# Afficher la configuration générée pour le débogage
cat ${CONFIG_FILE}

# Lancer le serveur mediamtx avec le fichier de configuration
exec /usr/local/bin/mediamtx ${CONFIG_FILE}
