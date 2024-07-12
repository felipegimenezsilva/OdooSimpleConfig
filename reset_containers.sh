# [OBSERVAÇÕES] ==========================================================

# O script atual apenas configura de modo simples uma versão do odoo e
# postgres. Não deve ser utilizado em produção, apenas para testes em
# ambiente local.

# Os dados do odoo (filestore) e os dados do postgres são mantidos apenas
# dentro dos containers. Ao remover o container, os dados serão perdidos.
# A remoção do container não afeta o código dos módulos (estes continuam 
# a existir).

# Este script faz um reset dos containers criados aqui. Sempre que 
# executar, será removido e recriado o odoo e postgres, como uma install
# completamente nova.

# [CONFIGURAÇÕES] ========================================================

# Container Manager: [podman/docker]
# utilizei o nome como DOCKER apenas para
# facilitar a compreensão, mas é um pouco
# tricky, eu admito 
# OBSERVAÇÃO: Se precisar de sudo: $DOCKER="sudo docker"
export DOCKER=podman

# configurações de versão do Odoo e Postgres.
# Verificar se existe disponível as mesmas versões
# de imagem no docker hub
export ODOO_VERSION=15 
export POSTGRES_VERSION=15

# configuração Utilizadores do POSTGRES
# O odoo utilizará isto para se conectar com o database
export USER_NAME=toor
export USER_PASS=toor

# mapeamento das portas do Odoo e Host
# o ODOO_HOST_PORT +e a porta que utilizamos para acessar o serviço;
#     - Exemplo: localhost:9090
# o ODOO_OFICIAL_PORT é a porta 'padrão' do odoo, que apenas é acessivel
# dentro do container.
#     - Exemplo: localhost:9090 --> meucontainer:8069
#     - tudo recebido na localhost:9090 é repassado para meucontainer:8069
export ODOO_HOST_PORT=9090
export ODOO_OFICIAL_PORT=8069

# mapenado o diretório modulos para os addons do container
export ODOO_LOCAL_FOLDER_ADDONS=$(pwd)/modulos
export ODOO_OFICIAL_FOLDER_ADDONS=/mnt/extra-addons

# apenas configurações dos nomes de cada recurso (containers, network).
export CONTAINER_NETWORK_NAME=network_odoo_$ODOO_VERSION
export CONTAINER_POSTGRES_NAME=postgres_odoo_$POSTGRES_VERSION
export CONTAINER_ODOO_NAME=container_odoo_$ODOO_VERSION

# parando 'execuções antigas', e removendo o container
# WARNING: possivel perda de informação, só remova se não houver problemas
$DOCKER stop $CONTAINER_POSTGRES_NAME $CONTAINER_ODOO_NAME
$DOCKER rm $CONTAINER_POSTGRES_NAME $CONTAINER_ODOO_NAME

# criando uma network isolada para esta versão do odoo
$DOCKER network rm $CONTAINER_NETWORK_NAME
$DOCKER network create $CONTAINER_NETWORK_NAME

# [CRIANDO CONTAINERS] ===================================================

# criando instância do postgres com configurações basicas apenas
$DOCKER run -d \
    --net $CONTAINER_NETWORK_NAME \
    -e POSTGRES_USER=$USER_NAME \
    -e POSTGRES_PASSWORD=$USER_PASS \
    -e POSTGRES_DB=postgres\
    --name $CONTAINER_POSTGRES_NAME \
    docker.io/library/postgres:$POSTGRES_VERSION

# criando instância do odoo, conectada ao postgres
$DOCKER run -d \
    -p $ODOO_HOST_PORT:$ODOO_OFICIAL_PORT \
    --net $CONTAINER_NETWORK_NAME \
    --name $CONTAINER_ODOO_NAME \
    -v $ODOO_LOCAL_FOLDER_ADDONS:$ODOO_OFICIAL_FOLDER_ADDONS \
    -e HOST=$CONTAINER_POSTGRES_NAME \
    -e USER=$USER_NAME \
    -e PASSWORD=$USER_PASS \
    docker.io/library/odoo:$ODOO_VERSION \


