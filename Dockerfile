FROM nginx:alpine

# Install extra tools
RUN apk update && apk add curl

# Copy HTML page
COPY index.html /usr/share/nginx/html/index.html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
