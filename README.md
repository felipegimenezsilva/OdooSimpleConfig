# OdooSimpleConfig
Run a containerd Odoo with connection to containerd Postgres

Requires podman or docker to run scripts.
´´´./reset_containers.sh´´´

Permit change configurations by editting variables inside reset_containers.sh file.
This repo has a 'mock module', just to exemplify the module structure of odoo docker.
The scripts uses oficial docker images for odoo (community) and postgres, check the availability in docker hub.
Do not use this script in production. The script is intended for simple and local tests, to avoid confg erros
in the host, is not prepared for production.
