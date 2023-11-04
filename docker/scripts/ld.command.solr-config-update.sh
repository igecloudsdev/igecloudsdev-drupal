#!/usr/bin/env bash
# File
#
# This file contains solr-config-update -command for local-docker script ld.sh.

function ld_command_solr-config-update_exec() {
    CONT_ID=$(find_container ${CONTAINER_SOLR:-solr})
    if [ "$?" -eq "1" ]; then
      echo -e "${Red}ERROR: Trying to locate a container with empty name.${Color_Off}"
      return 1
    fi
    if [ -z "$CONT_ID" ]; then
      echo -e "${Red}ERROR: Solr container ('${CONTAINER_SOLR:-solr}') is not up.${Color_Off}"
      return 2
    fi
    if [ -z "$SOLR_CORE" ]; then
      echo -e "${Red}ERROR: Solr core name is missing. Please try again after you have added a valid value for 'SOLR_CORE' via .env, for example:${Color_Off}"
      echo -e "${Yellow}SOLR_CORE=drupal${Color_Off}"
      return 3
    fi

    [ "$LD_VERBOSE" -ge "2" ] && echo -e "${Cyan}Next: docker-compose exec ${CONTAINER_SOLR:-solr} bash -c \"cp /solr-config/conf/* /var/solr/data/${SOLR_CORE}/conf\"${Color_Off}"
    docker-compose exec ${CONTAINER_SOLR:-solr} bash -c "cp /solr-config/conf/* /var/solr/data/${SOLR_CORE}/conf"

    [ "$LD_VERBOSE" -ge "2" ] && echo -e "${Cyan}Next: Restarting Solr container, please wait...${Color_Off}"
    docker-compose restart ${CONTAINER_SOLR:-solr}
}

function ld_command_solr-config-update_help() {
    echo -e "Copies fresh configuration files into the solr container and restarts solr container. Solr core name is '${BYellow}${SOLR_CORE:-**CORE NAME MISSING**}${Color_Off}'."
}

function ld_command_solr-config-update_extended_help() {
    echo "Source of the configuration is in directory ./docker/configs/solr/conf/."
    echo "Target directory inside the Solr container is /var/solr/data/${SOLR_CORE:-**CORE NAME MISSING**}/conf."
}
