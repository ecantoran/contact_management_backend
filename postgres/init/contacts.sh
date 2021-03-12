#!/bin/bash

# Se cierra inmediatamente si se produce
# algún error durante la ejecución del script.
# Si no se establece, podría ocurrir un error
# y la secuencia de comandos continuaría su ejecución.
set -o errexit


# Creación de un array que define las variables
# de entorno que deben establecerse. Esto puede ser
# consumido más tarde a través de la expansión
# variable del array ${REQUIRED_ENV_VARS[@]}.
readonly REQUIRED_ENV_VARS=(
  "CONTACT_DB_USER"
  "CONTACT_DB_PASSWORD"
  "CONTACT_DB_DATABASE"
  "POSTGRES_USER")


# Main:
# - verifica si todas las variables de entorno están establecidas
# - Ejecuta el código SQL para crear usuario y base de datos.
main() {
  check_env_vars_set
  init_user_and_db
}


# Comprueba si todas las variables de entorno requeridas
# están configuradas. Si uno de ellos no lo está,
# se hace echo de un texto que explica cuál no es
# y el nombre de los que necesitan ser
check_env_vars_set() {
  for required_env_var in ${REQUIRED_ENV_VARS[@]}; do
    if [[ -z "${!required_env_var}" ]]; then
      echo "Error:
    Environment variable '$required_env_var' not set.
    Make sure you have the following environment variables set:
      ${REQUIRED_ENV_VARS[@]}
Aborting."
      exit 1
    fi
  done
}


# Realiza la inicialización en el PostgreSQL ya iniciado utilizando
# el usuario CONTACTS_DB_USER preconfigurado.
init_user_and_db() {
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
     CREATE USER $CONTACT_DB_USER WITH PASSWORD '$CONTACT_DB_PASSWORD';
     CREATE DATABASE $CONTACT_DB_DATABASE;
     GRANT ALL PRIVILEGES ON DATABASE $CONTACT_DB_DATABASE TO $CONTACT_DB_USER;
EOSQL
}

# Ejecuta la rutina principal con las variables de entorno pasadas
# a través de la línea de comando.
main "$@"
