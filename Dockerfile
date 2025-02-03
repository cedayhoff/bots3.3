FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && apt-get install -y \
        wget \
        build-essential \
        pkg-config \
        libmysqlclient-dev \
        libpq-dev \
        python3.12 \
        python3.12-dev \
        python3.12-venv \
        ca-certificates \
        git && \
    apt-get clean

RUN python3.12 -m ensurepip --upgrade

WORKDIR /app
COPY requirements.txt /app/
RUN python3.12 -m pip install --no-cache-dir -r requirements.txt
RUN mkdir -p /dirmonitor
COPY . /app
RUN python3.12 setup.py install
RUN python3.12 manage.py migrate --fake-initial

EXPOSE 8080

CMD ["sh", "-c", "python3.12 bots-jobqueueserver.py & python3.12 bots-dirmonitor.py & python3.12 bots-webserver.py"]
