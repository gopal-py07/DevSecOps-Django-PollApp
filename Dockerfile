# Use Python 3.11.3 with Alpine as the base image
FROM python:3.11.3-alpine

# Ensure Python output is not buffered
ENV PYTHONUNBUFFERED 1

RUN apk update && apk upgrade --no-cache && apk add --no-cache \
    bash \
    libssl3 \
    sqlite

# Create a root directory for the project inside the container
RUN mkdir /Poll_APPlication

# Set the working directory to /Poll_APPlication
WORKDIR /Poll_APPlication

COPY requirements.txt /Poll_APPlication/
RUN pip install --no-cache-dir -r requirements.txt

# Copy the current directory contents into the container at /Poll_APPlication
COPY . /Poll_APPlication

# Argument for build-time tag
ARG TAG

# Set environment variable for the tag
ENV TAG=${TAG}

# Uncomment the CMD line to start the application server by default
# CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]