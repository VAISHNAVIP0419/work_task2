#!/bin/bash

COMPOSE_FILE="docker-compose.yml"
JSON_FILE="config.json"

stop_services() {
    echo " Stopping existing services..."
    docker compose -f "$COMPOSE_FILE" down
}

build_nginx_image() {
    echo " Building custom nginx image from Dockerfile..."
    docker compose -f "$COMPOSE_FILE" build web
}

update_compose_image() {
    echo " Updating docker-compose.yml with new images..."

    for SERVICE in $(jq -r '.services | keys[]' "$JSON_FILE"); do
        NEW_IMAGE=$(jq -r ".services[\"$SERVICE\"]" "$JSON_FILE")

        if [[ "$NEW_IMAGE" == "nginx"* ]]; then
            echo " Skipping nginx image (already built from Dockerfile)"
            continue
        fi

        echo " Updating $SERVICE to use $NEW_IMAGE"
        sed -i "/$SERVICE:/,/image:/ s|image: .*|image: $NEW_IMAGE|" "$COMPOSE_FILE"
    done
}

start_services() {
    echo " Starting services..."
    docker compose -f "$COMPOSE_FILE" up -d
}

main() {
    stop_services
    build_nginx_image
    update_compose_image
    start_services
    echo " Done. Services are running."
}

main
