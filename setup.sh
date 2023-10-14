#!/bin/bash

info() {
  echo -e "\033[0;32m$1\033[0m"
}

warn() {
  echo -e "\033[0;93m$1\033[0m"
}

error() {
  echo -e "\033[0;91m$1\033[0m" >&2
}

function install_docker(){
    if [[ "$(command -v docker)" == "" ]]; then
        mkdir -p ./script/docker/
        curl -fsSL https://get.docker.com -o ./script/docker/get-docker.sh
        sudo sh ./script/docker/get-docker.sh
        sudo groupadd docker
        sudo usermod -aG docker $USER
        sudo chmod 666 /var/run/docker.sock
    else
        info "[Check] Passed checking: docker."
    fi
}

function install_docker_compose(){
    if [[ "$(command -v docker-compose)" == "" ]]; then
        sudo apt-get update
        sudo apt install docker-compose -y
        sudo chmod +x $(command -v docker-compose)
    else
        info "[Check] Passed checking: docker-compose."
    fi
}


function install_python_and_postgresqlDB(){
    if [[ "$(command -v python3)" == "" ]]; then
        sudo apt-get update
        sudo apt-get install python3 -y
    else
        info "[Check] Passed checking: python3."
    fi

    if [[ "$(command -v pip)" == "" ]]; then
        sudo apt-get update
        sudo apt-get install python3-pip -y
    else
        info "[Check] Passed checking: python pip."
    fi
    
    pip3 install sqlalchemy pandas psycopg2-binary
}

function install_dbt(){
    if [[ "$(command -v dbt)" == "" ]]; then
        sudo apt install python3.10-venv -y
        python3 -m pip install --user --upgrade pip
        python3 -m pip install --user virtualenv
    else
        info "[Check] Passed checking: dbt."
    fi
    python3 -m venv env
    source env/bin/activate
    pip3 install dbt-postgres
}

function setting_dbt_profile(){
    if [ -d "~/.dbt/" ]; then
        info "[Check] Finish clone the cpbl-opendata."
    else
        dbt init
        read -p 'dbt project name: ' DBT_PROJECT_NAME
        sed -i 's/\[1 or more\]/1/g' ~/.dbt/profiles.yml
        sed -i 's/\[host\]/localhost/g' ~/.dbt/profiles.yml
        sed -i 's/\[port\]/5432/g' ~/.dbt/profiles.yml
        sed -i 's/\[dev_username\]/dbtuser/g' ~/.dbt/profiles.yml
        sed -i 's/\[prod_username\]/dbtuser/g' ~/.dbt/profiles.yml
	sed -i 's/pass\:/password\:/g' ~/.dbt/profiles.yml
        sed -i 's/\[dev_password\]/dbtpass/g' ~/.dbt/profiles.yml
        sed -i 's/\[prod_password\]/dbtpass/g' ~/.dbt/profiles.yml
        sed -i 's/\[dbname\]/dbtuser/g' ~/.dbt/profiles.yml
        sed -i 's/\[dev_schema\]/public/g' ~/.dbt/profiles.yml
        sed -i 's/\[prod_schema\]/public/g' ~/.dbt/profiles.yml
	cp ~/.dbt/profiles.yml $PWD/$DBT_PROJECT_NAME
    fi
}


echo "Step 1: Install docker."
install_docker
echo "Step 2: Install docker-compose."
install_docker_compose
echo "Step 3: start postgresql service."
docker-compose -f postgresql/docker-compose.yaml down
docker-compose -f postgresql/docker-compose.yaml up -d
echo "Step 4: Install postgresql database."
read -p 'PostgreSQL database IP address: ' POSTGRESQL_IP
echo $POSTGRESQL_IP
install_python_and_postgresqlDB
echo "Step 5: Install dbt"
install_dbt
echo "Step 6: Initial dbt and setting dbt profile."
setting_dbt_profile
