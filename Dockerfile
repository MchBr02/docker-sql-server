FROM mcr.microsoft.com/mssql/server:2019-latest

USER root
WORKDIR /src

# Install SQLCMD tools
RUN apt-get update && \
    ACCEPT_EULA=Y apt-get install -y curl gnupg && \
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && \
    ACCEPT_EULA=Y apt-get install -y mssql-tools unixodbc-dev && \
    echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc

# Set path so sqlcmd is available
ENV PATH="${PATH}:/opt/mssql-tools/bin"

COPY attach_db.sh /db_files/
COPY ./Data/*.mdf /db_files/
COPY ./Data/*.ldf /db_files/

RUN chmod +x /db_files/attach_db.sh
RUN (/opt/mssql/bin/sqlservr --accept-eula & ) | grep -q "Service Broker manager has started"

ENTRYPOINT /db_files/attach_db.sh & /opt/mssql/bin/sqlservr
