# Use the official Python image
FROM python:3.9

# Set the working directory
WORKDIR /app

# Copy the current directory contents into the container
COPY . /app

# Install the dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose port 5500 for the Flask app
EXPOSE 5500

# Set environment variables - #NB we remove the DB host from here and moved it to the compose 
ENV FLASK_APP=app.py
ENV MYSQL_ROOT_PASSWORD=rootpassword
ENV MYSQL_DATABASE=tecvinson_registration

# Run the application
CMD ["flask", "run", "--host=0.0.0.0","--port=5500"]
