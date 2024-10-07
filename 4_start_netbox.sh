#!/bin/bash
set -euo pipefail

# Check if all required environment variables are set
REQUIRED_VARS=("MY_EXTERNAL_IP" "NETBOX_PORT")

for var in "${REQUIRED_VARS[@]}"; do
  if [ -z "${!var:-}" ]; then
    echo "Error: Required environment variable '$var' is not set."
    exit 0
  fi
done

echo
echo "--- Cloning NetBox Docker ---"
echo

# Clone netbox-docker
git clone -b release https://github.com/netbox-community/netbox-docker.git
pushd netbox-docker

echo
echo "--- Generating configuration files ---"
echo

# Create plugin files
cat <<EOF > plugin_requirements.txt
slurpit_netbox
EOF

cat <<EOF > Dockerfile-Plugins
FROM netboxcommunity/netbox:latest

COPY ./plugin_requirements.txt /opt/netbox/
RUN /opt/netbox/venv/bin/pip install  --no-warn-script-location -r /opt/netbox/plugin_requirements.txt

# These lines are only required if your plugin has its own static files.
#COPY configuration/configuration.py /etc/netbox/config/configuration.py
#COPY configuration/plugins.py /etc/netbox/config/plugins.py
#RUN SECRET_KEY="dummydummydummydummydummydummydummydummydummydummy" /opt/netbox/venv/bin/python /opt/netbox/netbox/manage.py collectstatic --no-input
EOF

cat <<EOF > docker-compose.override.yml
services:
  netbox:
    image: netbox:latest-plugins
    pull_policy: never
    ports:
      - "${NETBOX_PORT}:8080"
    build:
      context: .
      dockerfile: Dockerfile-Plugins
    environment:
      SKIP_SUPERUSER: "false"
      SUPERUSER_API_TOKEN: "1234567890"
      SUPERUSER_EMAIL: ""
      SUPERUSER_NAME: "admin"
      SUPERUSER_PASSWORD: "admin"
  netbox-worker:
    image: netbox:latest-plugins
    pull_policy: never
  netbox-housekeeping:
    image: netbox:latest-plugins
    pull_policy: never
EOF

# Add the Slurpit plugin to configuration.py
cat <<EOF > configuration/plugins.py
PLUGINS = ["slurpit_netbox"]
EOF

# Update the healthcheck in docker-compose.yml
sed -i 's|http://localhost:8080/login/|http://${MY_EXTERNAL_IP}:${NETBOX_PORT}/login/|' docker-compose.yml

echo
echo "--- Building NetBox ---"
echo

docker compose build --no-cache

echo
echo "--- Starting NetBox Docker ---"
echo

docker compose up -d

popd