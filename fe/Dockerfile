# Use the official Nginx image
FROM 861276076873.dkr.ecr.us-east-1.amazonaws.com/nginx:v1

# Copy the custom Nginx configuration file
COPY nginx.conf /etc/nginx/nginx.conf

# Copy all HTML files into the Nginx document root
COPY *.html /usr/share/nginx/html/
