#!/bin/bash -ex

#########################################
#
#  Usage
#
#########################################
Usage(){
    echo "Function: this script is used to install ESXi by RackHD "
    echo "usage: $0 [arguments]"
    echo "    Optional Arguments:"
    echo "      --VERSION"
    echo "      --ROOT_PASSWORD"
}


###################################################################
#
#  Parse and check Arguments
#
##################################################################
parseArguments(){
    while [ "$1" != "" ]; do
        case $1 in
            --JSON_FILE )                   shift
                                            JSON_FILE=$1
                                            ;;
            --VERSION )                     shift
                                            VERSION=$1
                                            ;;
            --ROOT_PASSWORD )               shift
                                            ROOT_PASSWORD=$1
                                            ;;                                            
            * )
                                            Usage
                                            exit 1
        esac
        shift
    done
    if [ ! -n "${VERSION}" ]; then
        echo "[Error]Arguments VERSION is required"
        exit 1
    fi 
    NODE_ID=59ccb8c03b98cc1b589e0179
    BMC_USER=root
    BMC_PASSWORD=1234567
    BMC_HOST=192.168.128.61
    RACKHD_IP=192.168.128.1:8080
    

}


#########################################################
#
# buildJson
#
########################################################
buildJson(){
    sed -i extension "s/{version}/${VERSION}/g" ${JSON_FILE}
    sed -i extension "s/{rootPassword}/${ROOT_PASSWORD}/g" ${JSON_FILE}


}
setBmc(){
    obmData='{ "nodeId": "{nodeId}", "service": "ipmi-obm-service", "config": { "user": "{bmcUser}", "password": "{bmcPassword}", "host": "{bmcHost}" } }'	
    obmDataDone=$(echo "${obmData}" | sed -e "s/{nodeId}/${NODE_ID}/" -e "s/{bmcUser}/${BMC_USER}/" -e "s/{bmcPassword}/${BMC_PASSWORD}/" -e "s/{bmcHost}/${BMC_HOST}/")
    echo "obmDataDone:${obmDataDone}"
    curl -k -X PUT -H 'Content-Type: application/json' -d ${obmDataDone} {RACKHD_IP}/api/2.0/obms	
}

postRequest(){
    curl -X POST -H 'Content-Type: application/json' -d @payload.json ${RACKHD_IP}/api/2.0/nodes/${NODE_ID}/workflows?name=Graph.InstallESXi
}

getProgress(){
}

#######################################################
#
# Main
#
########################################################

main(){
    echo "Install OS start to parse arguments."
    parseArguments "$@"

    echo "Build json file for install os."
    buildJson
    
    echo "Set bmc."
    setBmc
    
    echo "Post a http request to RackHD."
    postRequest

    echo "Get OS install progress."
    getProgress
    

#    if [ -n "$MANIFEST_FILE" ]; then
#         cloneCodeFromManifest "$on_build_config_dir"  "$MANIFEST_FILE"  $CLONE_DIR
#    fi

    echo "$0 done."
}

main "$@"
