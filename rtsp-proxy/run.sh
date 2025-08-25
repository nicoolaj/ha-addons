#!/usr/bin/with-contenv bashio

# Définir le chemin du fichier de configuration pour mediamtx
CONFIG_FILE="/mediamtx.json"

bashio::log.info "Génération de la configuration pour mediamtx..."

# Récupérer le port RTSP configuré par l'utilisateur
RTSP_PORT=$(bashio::addon.port 8554)

# Initialiser le tableau de caméras au format JSON
CAMERAS_JSON="[]"

# Utiliser bashio pour lire la liste des caméras et construire le JSON
if bashio::config.has_value 'cameras'; then
    for camera in $(bashio::config 'cameras|keys'); do
        # Extraire le nom et l'URL de chaque caméra
        NAME=$(bashio::config "cameras[${camera}].name")
        URL=$(bashio::config "cameras[${camera}].url")

        if [ -n "$NAME" ] && [ -n "$URL" ]; then
            bashio::log.info "Ajout de la caméra : ${NAME} (${URL})"
            
            # Créer l'objet JSON pour cette caméra
            CAMERA_OBJ=$(jq -n --arg name "$NAME" --arg url "$URL" '{"key": $name, "value": {"source": $url, "sourceOnDemand": "yes"}}')

            # Ajouter l'objet JSON au tableau de caméras
            CAMERAS_JSON=$(echo "$CAMERAS_JSON" | jq ". + [$CAMERA_OBJ]")
        else
            bashio::log.warn "Un élément de caméra n'a pas de nom ou d'URL. Il sera ignoré."
        fi
    done
else
    bashio::log.warn "Aucune caméra n'a été trouvée dans la configuration."
fi

# Créer la configuration de base de mediamtx
BASE_CONFIG=$(jq -n --argjson rtspPort "$RTSP_PORT" '{rtspPort: $rtspPort, api: "yes", webrtc: "no", paths: {}}')

# Fusionner la configuration de base avec le tableau de caméras
FINAL_CONFIG=$(echo "$BASE_CONFIG" | jq --argjson cameras "$CAMERAS_JSON" '(.paths | map(to_entries) | .[0]) = $cameras')

# Écrire la configuration finale dans le fichier
echo "$FINAL_CONFIG" > "${CONFIG_FILE}"

bashio::log.info "Configuration générée. Démarrage du serveur mediamtx..."

# Afficher la configuration générée pour le débogage
cat ${CONFIG_FILE}

# Lancer le serveur mediamtx avec le fichier de configuration JSON
exec /usr/local/bin/mediamtx ${CONFIG_FILE}
