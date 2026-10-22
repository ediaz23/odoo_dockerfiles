FROM debian:bullseye-slim
LABEL org.opencontainers.image.authors="Odoo S.A. <info@odoo.com>"

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

# Generate locale C.UTF-8 for postgres and general locale data
ENV LANG=C.UTF-8

# Para imagen que se mueve a archivadas
# bullseye salio de LTS: el indice de bullseye-security sigue publicado pero el pool
# ya no tiene los .deb, por eso se apunta al snapshot de la fecha de la imagen base.
RUN echo "" > /etc/apt/sources.list
RUN echo "deb http://deb.debian.org/debian bullseye main" >> /etc/apt/sources.list
RUN echo "deb http://deb.debian.org/debian bullseye-updates main" >> /etc/apt/sources.list
RUN echo "deb http://snapshot.debian.org/archive/debian-security/20260824T000000Z bullseye-security main" >> /etc/apt/sources.list
RUN echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until

# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        dirmngr \
        fonts-noto-cjk \
        gnupg \
        python3-num2words \
        python3-pdfminer \
        python3-pip \
        python3-pyldap \
        python3-qrcode \
        python3-renderpm \
        python3-setuptools \
        python3-slugify \
        python3-vobject \
        python3-watchdog \
        python3-xlrd \
        python3-xlwt \
        xz-utils \
        python3-dev \
        libxml2-dev \
        libxslt1-dev \
        libldap2-dev \
        libssl-dev \
        libsasl2-dev \
        libpq-dev \
        libjpeg-dev \
        zlib1g-dev \
        g++ \
        build-essential \
        wget \
        python3-venv \
        python3-wheel libfreetype6-dev \
        libtiff5-dev libjpeg62-turbo-dev libopenjp2-7-dev \
        liblcms2-dev libwebp-dev libharfbuzz-dev libfribidi-dev libxcb1-dev \
        libssl-dev \
        node-less \
        npm \
        iproute2 \
    && curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.buster_amd64.deb \
    && echo 'ea8277df4297afc507c61122f3c349af142f31e5 wkhtmltox.deb' | sha1sum -c - \
    && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
    && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

# install latest postgresql-client
RUN echo 'deb http://apt-archive.postgresql.org/pub/repos/apt/ bullseye-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
    && GNUPGHOME="$(mktemp -d)" \
    && export GNUPGHOME \
    && repokey='B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8' \
    && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "${repokey}" \
    && gpg --batch --armor --export "${repokey}" > /etc/apt/trusted.gpg.d/pgdg.gpg.asc \
    && gpgconf --kill all \
    && rm -rf "$GNUPGHOME" \
    && apt-get update  \
    && apt-get install --no-install-recommends -y postgresql-client \
    && rm -f /etc/apt/sources.list.d/pgdg.list \
    && rm -rf /var/lib/apt/lists/*

# Install rtlcss (on Debian buster)
RUN npm install -g rtlcss

# El source de Odoo NO va en la imagen: se monta en /usr/lib/python3/dist-packages/odoo
# El symlink queda colgando hasta que se monta el volumen.
RUN ln -s /usr/lib/python3/dist-packages/odoo/odoo-bin /usr/bin/odoo
RUN python3 -m pip install --upgrade pip setuptools wheel
RUN pip install pydevd==2.10.0 phonenumbers inotify odoorpc zeep pdf417gen pyOpenSSL pysaml2 pydub openpyxl
COPY requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt && rm /tmp/requirements.txt

# Install Odoo
ENV ODOO_VERSION=16.0


# Copy entrypoint script and Odoo configuration file
COPY ./entrypoint.sh /
COPY ./odoo.conf /etc/odoo/

RUN useradd -rm -d /home/odoo -s /bin/bash -g root -G sudo -u 1001 odoo

# Set permissions and Mount /var/lib/odoo to allow restoring filestore and /mnt/extra-addons for users addons
RUN chown odoo /etc/odoo/odoo.conf \
    && mkdir -p /mnt/extra-addons /var/lib/odoo \
    && chown -R odoo /mnt/extra-addons /var/lib/odoo
VOLUME ["/var/lib/odoo", "/mnt/extra-addons"]

# Expose Odoo services
EXPOSE 8069 8071 8072

# Set the default config file
ENV ODOO_RC=/etc/odoo/odoo.conf

COPY wait-for-psql.py /usr/local/bin/wait-for-psql.py

# Set default user when running the container
USER odoo

ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]
