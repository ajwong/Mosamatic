FROM python:3.9

RUN apt-get update -y && \
    apt-get install -y vim libpq-dev pkg-config cmake openssl wget git dos2unix && \
    apt-get install -y libgl1 libxrender1 && \
    apt-get install -y libffi-dev && \
    apt-get install -y pigz && \
    wget https://github.com/rordenlab/dcm2niix/releases/latest/download/dcm2niix_lnx.zip && \
    apt-get install -y unzip && \
    unzip dcm2niix_lnx.zip -d /usr/local/bin && \
    chmod +x /usr/local/bin/dcm2niix && \
    rm dcm2niix_lnx.zip && \
    mkdir -p /data/static && \
    mkdir -p /data/filesets && \
    mkdir -p /data/uploads/{0..9} && chmod 777 -R /data/uploads

# Run these steps separately, otherwise the large RUN will execute always
COPY requirements.txt /requirements.txt
RUN pip install --upgrade pip setuptools wheel && pip install -r /requirements.txt --verbose

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN dos2unix /docker-entrypoint.sh && chmod +x /docker-entrypoint.sh

COPY mosamatic/src/mosamatic /src
COPY mosamatic/src/models.py /src/models.py

WORKDIR /src

# Make sure models.py can be found
ENV PYTHONPATH="${PYTHONPATH}:/src"

RUN apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD ["/docker-entrypoint.sh"]
