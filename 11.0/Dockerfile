FROM debian:stretch-slim
LABEL org.opencontainers.image.authors="Odoo S.A. <info@odoo.com>"

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

# Generate locale C.UTF-8 for postgres and general locale data
ENV LANG=C.UTF-8

# Use backports to avoid install some libs with pip
RUN echo 'deb http://deb.debian.org/debian stretch-backports main' > /etc/apt/sources.list.d/backports.list

# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        dirmngr \
        fonts-noto-cjk \
        gnupg \
        python3-num2words \
        python3-pip \
        python3-phonenumbers \
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
        libssl-dev \
        g++ \
        build-essential \
        wget \
        python3-venv \
        node-less \
        iproute2 \
        libldap2-dev libsasl2-dev ldap-utils tox \
        lcov valgrind \
        libxmlsec1-dev \
        pkg-config libssl-dev libffi-dev \
    && curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.stretch_amd64.deb \
    && echo '7e35a63f9db14f93ec7feeb0fce76b30c08f2057 wkhtmltox.deb' | sha1sum -c - \
    && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
    && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

# install latest postgresql-client
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
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


COPY odoo/ /usr/lib/python3/dist-packages/odoo
RUN ln -s /usr/lib/python3/dist-packages/odoo/odoo-bin /usr/bin/odoo
RUN rm -rf /usr/lib/python3/dist-packages/odoo/.git/*
RUN rm -rf /usr/lib/python3/dist-packages/odoo/.github/*
RUN rm -rf /usr/lib/python3/dist-packages/odoo/.settings/*
RUN python3 -m pip install --upgrade pip setuptools wheel
RUN pip install pydevd phonenumbers inotify odoorpc zeep pdf417gen pdf2image
RUN pip install -r /usr/lib/python3/dist-packages/odoo/requirements.txt
RUN pip install xmlsec pandas beautifulsoup4 pycrypto pyOpenSSL


COPY python-meli/ /tmp/python-meli
RUN pip install /tmp/python-meli/
RUN rm -rf /tmp/python-meli/

# Install Odoo
ENV ODOO_VERSION=11.0


# Copy entrypoint script and Odoo configuration file
COPY ./entrypoint.sh /
COPY ./odoo.conf /etc/odoo/

RUN useradd -rm -d /home/odoo -s /bin/bash -g root -G sudo -u 1001 odoo

# Set permissions and Mount /var/lib/odoo to allow restoring filestore and /mnt/extra-addons for users addons
RUN chown odoo /etc/odoo/odoo.conf \
    && mkdir -p /mnt/extra-addons \
    && chown -R odoo /mnt/extra-addons
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

