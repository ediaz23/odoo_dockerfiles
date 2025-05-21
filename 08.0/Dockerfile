FROM debian:jessie-slim
LABEL maintainer="Esteban Diaz"

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

ENV LANG=es_CL.UTF-8 \
    ODOO_VERSION=8.0 \
    ODOO_HOME=/opt/odoo

RUN mkdir -p /usr/share/man/man1
RUN mkdir -p /usr/share/man/man7
    
RUN echo "deb http://archive.debian.org/debian jessie main contrib non-free" > /etc/apt/sources.list \
    && echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until \
    && echo 'APT::Get::AllowUnauthenticated "true";' > /etc/apt/apt.conf.d/99unauth \
    && apt-get update -o Acquire::Check-Valid-Until=false

# Descargar versiones específicas manualmente
RUN mkdir -p /tmp/pkgs \
    && cd /tmp/pkgs \
    && apt-get download perl-base=5.20.2-3+deb8u11 zlib1g=1:1.2.8.dfsg-2+b1 libcomerr2=1.42.12-2+b1 \
    && dpkg -i --force-downgrade *.deb \
    && rm -rf /tmp/pkgs

# Instalar el resto sin versiones específicas
RUN apt-get install -y --force-yes --no-install-recommends \
    gcc-4.9-base=4.9.2-10+deb8u1 \
    cpp-4.9=4.9.2-10+deb8u1 \
    gcc-4.9=4.9.2-10+deb8u1 \
    g++-4.9=4.9.2-10+deb8u1 \
    libstdc++6=4.9.2-10+deb8u1 \
    libgcc1=1:4.9.2-10+deb8u1 \
    libstdc++-4.9-dev \
    libgcrypt20=1.6.3-2+deb8u4 \
    perl=5.20.2-3+deb8u11 \
    zlib1g-dev=1:1.2.8.dfsg-2+b1 \
    libc6 \
    libc6-dev \
    libcloog-isl4 \
    libgmp10 \
    libisl10 \
    libmpc3 \
    libmpfr4 \
    zlib1g \
    binutils \
    libgcc-4.9-dev \
    libasan1 \
    liblsan0 \
    libtsan0 \
    libubsan0 \
    libcilkrts5 \
    gcc \
    g++ \
    libgcrypt20-dev \
    libxmlsec1-dev \
    iproute2

RUN apt-get install -y --force-yes --no-install-recommends \
    postgresql-client \
    liberror-perl \
    libssl-dev \
    comerr-dev \
    krb5-multidev \
    libpq-dev \
    git \
    python \
    python-dev \
    libldap2-dev \
    libsasl2-dev \
    libxml2-dev \
    libxslt1-dev \
    libjpeg-dev \
    libevent-dev \
    node-less \
    make \
    libc6-dev \
    libstdc++6 \
    curl \
    wget \
    xz-utils \
    ca-certificates \
    locales \
    ghostscript \
    pkg-config \
    libffi-dev \
    libmysqlclient-dev

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN sed -i 's/# es_CL.UTF-8 UTF-8/es_CL.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen es_CL.UTF-8 && \
    update-locale LANG=es_CL.UTF-8

# wkhtmltopdf
RUN curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/packaging/releases/download/0.12.1/wkhtmltox-0.12.1_linux-jessie-amd64.deb \
    && dpkg -i wkhtmltox.deb || apt-get -f install -y \
    && rm wkhtmltox.deb

# Usuario y Odoo
RUN useradd -rm -d /home/odoo -s /bin/bash -g root -G sudo -u 1001 odoo

# Eliminar pip roto y reinstalar uno funcional para Python 2.7
RUN apt-get remove -y python-pip || true && \
    curl -sS https://bootstrap.pypa.io/pip/2.7/get-pip.py -o get-pip.py && \
    python get-pip.py "pip==20.3.4" "setuptools<45" "requests==2.21.0" && \
    ln -s /usr/local/bin/pip /usr/bin/pip && \
    rm get-pip.py

RUN git clone --depth=1 --branch ${ODOO_VERSION} https://github.com/odoo/odoo ${ODOO_HOME}
RUN chown -R odoo:root ${ODOO_HOME}
RUN ln -s /opt/odoo/openerp-server /usr/bin/odoo
RUN ln -s /opt/odoo/openerp /usr/lib/python2.7/dist-packages/openerp

RUN pip install -r /opt/odoo/requirements.txt
RUN pip uninstall -y xmlsec lxml
RUN pip install "ofxparse==0.16" "psycogreen==1.0.1" "passlib==1.7.4" "beautifulsoup4<4.7.0"
RUN pip install "pydevd==1.2.0" "inotify==0.2.10" "odoorpc==0.6.0" "pyPdf==1.13" "lxml==4.6.5" "xmlsec==1.3.3"
RUN pip install "fpconst==0.7.2" "SOAPpy==0.12.22"
RUN pip install \
    pycrypto==2.6.1 \
    pyOpenSSL==19.1.0 \
    cryptography==2.5 \
    eight \
    pandas==0.24.2 \
    numpy==1.16.6 \
    pyasn1==0.4.8 \
    dm.xmlsec.binding \
    MySQL-python==1.2.5 \
    pyinotify
RUN pip install git+https://github.com/ehpale/elaphe.git@master#egg=elaphe

COPY ./odoo.conf /etc/odoo/odoo.conf
COPY ./entrypoint.sh /entrypoint.sh
COPY wait-for-psql.py /usr/local/bin/wait-for-psql.py

RUN chmod +x /entrypoint.sh /usr/local/bin/wait-for-psql.py \
    && chown odoo /etc/odoo/odoo.conf \
    && mkdir -p /mnt/extra-addons \
    && chown -R odoo /mnt/extra-addons \
    && mkdir -p /var/lib/odoo \
    && chown -R odoo /var/lib/odoo

VOLUME ["/var/lib/odoo", "/mnt/extra-addons"]

EXPOSE 8069 8071 8072

ENV ODOO_RC=/etc/odoo/odoo.conf

USER odoo

ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]
