docker-compose -f postgresql/docker-compose.yaml down
rm -rf ~/.dbt logs
read -p 'dbt project name: ' DBT_PROJECT_NAME
rm -rf $DBT_PROJECT_NAME
