FROM ghcr.io/gothenburgbitfactory/taskchampion-sync-server:0.7.1

USER root

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
