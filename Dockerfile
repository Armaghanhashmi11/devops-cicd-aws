# Use Nginx as the base image
FROM nginx:alpine

# Copy our website files into the Nginx folder inside the container
COPY ./app /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]