# Use the official Nginx image
FROM nginx:latest

# Copy the custom Nginx configuration file
COPY nginx.conf /etc/nginx/nginx.conf

# Copy all HTML files into the Nginx document root
COPY *.html /usr/share/nginx/html/

# Expose Nginx port
EXPOSE 80
