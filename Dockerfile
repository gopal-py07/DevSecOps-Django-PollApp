# Use Python 3.11.3 with Alpine as the base image
FROM python:3.11.3-alpine

# Ensure Python output is not buffered
ENV PYTHONUNBUFFERED 1

# Create a root directory for the project inside the container
RUN mkdir /Poll_APPlication

# Set the working directory to /Poll_APPlication
WORKDIR /Poll_APPlication

# Copy the current directory contents into the container at /Poll_APPlication
COPY . /Poll_APPlication

# Install dependencies from requirements.txt without caching
RUN pip install --no-cache-dir -r requirements.txt

# Argument for build-time tag
ARG TAG

# Set environment variable for the tag
ENV TAG=${TAG}

# Uncomment the CMD line to start the application server by default
# CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]