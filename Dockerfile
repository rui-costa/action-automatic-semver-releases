# Container image that runs your code
FROM alpine:3.18.6
RUN apk update
RUN apk add git
RUN apk add curl

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh
COPY src /src/

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]