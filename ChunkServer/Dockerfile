FROM ubuntu:20.04

# Install wget and busybox ( for vi )
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y lizardfs-chunkserver moreutils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN echo 'alias ll="ls -l"' >> /root/.bashrc

ARG PUID=9421
ARG PGID=9421

# Ensure the `mfs` user and group has a consistent uid/gid
RUN useradd -u $PUID LizardFS
RUN groupmod -g $PGID LizardFS

RUN mkdir -p /blocks
RUN mkdir -p /home/LizardFS

RUN chown $PUID:$PGID /blocks
RUN chown $PUID:$PGID /home/LizardFS

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod 744 /docker-entrypoint.sh


#ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "/docker-entrypoint.sh", "start" ]
#CMD ["start","stop","reload"]
HEALTHCHECK CMD pgrep lfschunkserver || exit 1
