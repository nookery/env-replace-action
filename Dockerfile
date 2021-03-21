# Container image that runs your code
FROM alpine:3.10

RUN apk add bash gettext openssh-client --no-cache --update

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.bash /entrypoint.bash

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.bash"]
