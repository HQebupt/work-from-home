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
    # 非用户输入: 从何处得到这些值
    NODE_ARRAY=("5a42662ea52ab966184b2378")
    BMC_USER=root
    BMC_PASSWORD=1234567
    BMC_HOST=192.168.128.61
    RACKHD_IP=192.168.128.60:8080
    JSON_FILE=payload.json
}


#########################################################
#
# buildJson
#
########################################################
buildJson(){
    sed -i "s/{version}/${VERSION}/g" ${JSON_FILE}
    sed -i "s/{rootPassword}/${ROOT_PASSWORD}/g" ${JSON_FILE}

}

setBmc(){
    obmData='{ "nodeId": "{nodeId}", "service": "ipmi-obm-service", "config": { "user": "{bmcUser}", "password": "{bmcPassword}", "host": "{bmcHost}" } }'
    for NODE_ID in ${NODE_ARRAY[@]}
    do
        obmDataDone=$(echo "${obmData}" | sed -e "s/{nodeId}/${NODE_ID}/" -e "s/{bmcUser}/${BMC_USER}/" -e "s/{bmcPassword}/${BMC_PASSWORD}/" -e "s/{bmcHost}/${BMC_HOST}/")
        echo "obmDataDone:${obmDataDone}"
        curl -k -X PUT -H 'Content-Type: application/json' -d ${obmDataDone} ${RACKHD_IP}/api/2.0/obms
    done
}

declare -A GRAPH_MAP=()
postRequest(){
    for NODE_ID in ${NODE_ARRAY[@]}
    do
        GRAPH_ID=$(curl -X POST -H 'Content-Type: application/json' -d @${JSON_FILE} ${RACKHD_IP}/api/2.0/nodes/${NODE_ID}/workflows?name=Graph.InstallESXi | jq '. | {instanceId: .instanceId}' |grep "instanceId" | awk -F '"' '{print $(NF-1)}')
        GRAPH_MAP[${NODE_ID}]=${GRAPH_ID}
    done
}

getProgress(){
    echo "Get os progress."
    for NODE_ID in ${NODE_ARRAY[@]}
    do
        GRAPH_ID=${GRAPH_MAP[${NODE_ID}]}
        sudo node sniff-progress.js "on.events" graph.progress.updated.information.${GRAPH_ID}.${NODE_ID} > graph-progress-${NODE_ID}.log 2>&1 &
    done
    tail -f graph-progress-*.log
}

#######################################################
#
# Main
#
########################################################

main(){
    echo "Install OS start to parse arguments."
    parseArguments "$@"

    echo "Build json file for install os. Nodes has the same payload.json"
    buildJson

    echo "Set bmc. Nodes has the same bmc settings."
    #setBmc

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
