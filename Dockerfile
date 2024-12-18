# Dockerfile

FROM python:3.11.3-alpine


# Allows docker to cache installed dependencies between builds

# The enviroment variable ensures that the python output is set straight
# to the terminal with out buffering it first
ENV PYTHONUNBUFFERED 1

# create root directory for our project in the container
RUN mkdir /Poll_APPlication

# Set the working directory to /Poll_APPlication
WORKDIR /Poll_APPlication


# Copy the current directory contents into the container at /Poll_APPlication
ADD . /Poll_APPlication
RUN pip install --no-cache-dir -r requirements.txt
ARG TAG
ENV TAG=${TAG}

# CMD ["python", "manage.py" ,"runserver 0.0.0.0:8000" ]