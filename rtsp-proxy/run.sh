#!/usr/bin/with-contenv bashio

# Définir le chemin du fichier de configuration pour mediamtx
CONFIG_FILE="/mediamtx.json"

bashio::log.info "Génération de la configuration pour mediamtx..."

# Récupérer le port RTSP configuré par l'utilisateur
RTSP_PORT=$(bashio::addon.port 8554)

# Initialiser l'objet JSON pour les chemins (paths)
PATHS_JSON='{}'

# Utiliser bashio pour lire la liste des caméras et construire l'objet JSON
if bashio::config.has_value 'cameras'; then
    for camera in $(bashio::config 'cameras|keys'); do
        # Extraire le nom et l'URL de chaque caméra
        NAME=$(bashio::config "cameras[${camera}].name")
        URL=$(bashio::config "cameras[${camera}].url")

        if [ -n "$NAME" ] && [ -n "$URL" ]; then
            bashio::log.info "Ajout de la caméra : ${NAME} (${URL})"
            
            # Utiliser jq pour ajouter la nouvelle caméra à l'objet JSON
            PATHS_JSON=$(echo "$PATHS_JSON" | jq --arg name "$NAME" --arg url "$URL" '. + {($name): {"source": $url, "sourceOnDemand": true}}')
        else
            bashio::log.warn "Un élément de caméra n'a pas de nom ou d'URL. Il sera ignoré."
        fi
    done
else
    bashio::log.warn "Aucune caméra n'a été trouvée dans la configuration."
fi

# Créer la configuration finale en utilisant l'objet paths généré
FINAL_CONFIG=$(jq -n --argjson paths "$PATHS_JSON" '{"api": true, "webrtc": false, "paths": $paths}')

# Écrire la configuration finale dans le fichier
echo "$FINAL_CONFIG" > "${CONFIG_FILE}"

bashio::log.info "Configuration générée. Démarrage du serveur mediamtx..."

# Afficher la configuration générée pour le débogage
cat ${CONFIG_FILE}

# Lancer le serveur mediamtx avec le fichier de configuration JSON
exec /usr/local/bin/mediamtx "${CONFIG_FILE}"
