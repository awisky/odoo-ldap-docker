FROM odoo:17.0
LABEL maintainer="Agustin Wisky. <agustin.wisky@mountrix.com>"

USER root
# Mount Customize /mnt/"addons" folders for users addons
RUN apt-get update && apt-get install --no-install-recommends -y \
    openssh-server \
    git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir /var/run/sshd

WORKDIR /

# Create known_hosts
RUN mkdir -p /root/.ssh && \
    touch /root/.ssh/known_hosts && ssh-keyscan github.com >> /root/.ssh/known_hosts
# Create known_hosts and add github key
RUN printf "Host github.com\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config \
    && chmod -R 600 /root/.ssh/

RUN mkdir -p /mnt/mountrix/addons

# TODO: remove unnecessary addons
WORKDIR /mnt/mountrix/addons/

ARG ODOO_USER_ADMIN_DEFAULT_PASSWORD

RUN mkdir -p /mnt/odoo

# Update aptitude with new repo
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
    procps\
    vim\
    xmlstarlet && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Python basics
RUN apt-get update && apt-get install -y --no-install-recommends \
        apt-utils\
        python3-dev\
        python3-wheel\
        wget\
        less\
        htop\
        j2cli &&\
        apt-get clean && \
        rm -rf /var/lib/apt/lists/*

# Tools for network debugging and ldap utils
RUN apt-get update && apt-get install -y --no-install-recommends \
    nmap\
    ldap-utils\
    iputils-ping &&\
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install debugpy and jupyterlab
RUN pip3 install --no-cache-dir \
        debugpy\
        jupyterlab

#install ohmybash
RUN bash -c "$(wget --progress=dot:giga https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh -O -)"

COPY ./requirements.txt /mnt/odoo/
COPY ./config/* /etc/odoo/
RUN pip3 install --no-cache-dir -r /mnt/odoo/requirements.txt

COPY ./addons /mnt/odoo/addons
COPY ./bootstrap.sh /etc/bootstrap.sh
RUN chmod a+x /etc/bootstrap.sh

COPY ./entrypoint.sh /
RUN chmod a+x /entrypoint.sh

COPY ./config/login.html /usr/local/lib/python3.10/dist-packages/jupyter_server/templates/
COPY ./config/logo.png /usr/local/lib/python3.10/dist-packages/jupyter_server/static/logo/

COPY ./addons_external /mnt/odoo/addons_external
COPY ./addons_customer /mnt/odoo/addons_customer

RUN chown -R odoo /mnt/* && \
     chown -R odoo /var/lib/odoo

RUN mkdir -p /run/sshd; exit 0 && chmod 0755 /run/sshd
COPY ./config/odoo.conf.j2 /etc/odoo/odoo.conf.j2

WORKDIR /

EXPOSE 22
EXPOSE 8888

ENTRYPOINT ["/bin/sh","-c"]
CMD ["sh /etc/bootstrap.sh"]
