#!/usr/bin/with-contenv bashio

# Créer le fichier de configuration pour mediamtx
CONFIG_FILE="/mediamtx.yml"

bashio::log.info "Génération de la configuration pour mediamtx..."

# Début de la configuration de base
# Tous les flux seront disponibles sur le port 8554
echo "rtspPort: 8554" > ${CONFIG_FILE}
echo "api: yes" >> ${CONFIG_FILE}
echo "webrtc: no" >> ${CONFIG_FILE} # Désactivé pour simplifier
echo "paths:" >> ${CONFIG_FILE}

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
    echo "  ${NAME}:" >> ${CONFIG_FILE}
    echo "    source: ${URL}" >> ${CONFIG_FILE}
    echo "    sourceOnDemand: yes" >> ${CONFIG_FILE}
done

bashio::log.info "Configuration générée. Démarrage du serveur mediamtx..."

# Afficher la configuration générée pour le débogage
cat ${CONFIG_FILE}

# Lancer le serveur mediamtx avec notre fichier de configuration
exec /usr/local/bin/mediamtx /mediamtx.yml
