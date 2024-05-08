#!/bin/bash
#LF Version of the file
echo "HOSTNAME:" $HOSTNAME
echo "DB HOST:" ${DB_PORT_5432_TCP_ADDR}
echo "Override default user admin password"
echo "ODOO_USER_ADMIN_DEFAULT_PASSWORD:" $ODOO_USER_ADMIN_DEFAULT_PASSWORD

ODOO_PATH=/usr/lib/python3/dist-packages/odoo
xmlstarlet edit --inplace --update '//odoo/data/record[@id="user_admin"]/field[@name="password"]/text()' --value "${ODOO_USER_ADMIN_DEFAULT_PASSWORD}" ${ODOO_PATH}/addons/base/data/res_users_data.xml

#Jupyter Lab
jupyter lab --allow-root --no-browser --ip=0.0.0.0 --ServerApp.allow_password_change=False --ServerApp.base_url=/back/ --LabApp.default_url=/back/ & #
/entrypoint.sh odoo &
exec /usr/sbin/sshd -D

