#/bin/bash

# Define the host variable
host="localhost:8080"

# Use the host variable in the sed command
sed -i "s|\$CFG->wwwroot   = 'http://' . \$_SERVER\['HTTP_HOST'\];|\$CFG->wwwroot   = 'http://$host';|" /bitnami/moodle/config.php

sed -i '/$CFG->directorypermissions = 02775;/a $CFG->reverseproxy = true;' /bitnami/moodle/config.php
# sed -i '/$CFG->reverseproxy = true;/a $CFG->sslproxy = true;' /bitnami/moodle/config.php # This depends if you want to use SSL or not