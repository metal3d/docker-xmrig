#!/bin/bash

metal3d_wallet="44vjAVKLTFc7jxTv5ij1ifCv2YCFe3bpTgcRyR6uKg84iyFhrCesstmWNUppRCrxCsMorTP8QKxMrD3QfgQ41zsqMgPaXY5" 
cd /xmrig

function uuidgen() {
    if [ -x "$(command -v uuidgen)" ]; then
        uuidgen
    else
        cat /proc/sys/kernel/random/uuid
    fi
}

if [ "$POOL_USER" == ${metal3d_wallet} ]; then
    # here, there is two cases:
    # - your a donator, so you dont' try to change the POOL_PASS for my workers
    # - your... me ? so I know the FORCE_PASS password, and I can change the POOL_PASS to make change the name
    if [ "$FORCE_PASS" != "" ]; then
        # this is only for me, metal3d, to be able to use my own wallet
        # and setup my own POOL_PASS
        echo "Checking SHA"
        sha=$(echo -n "$FORCE_PASS" | sha256sum | awk '{print $1}')
        if [ $sha != "aa60f2dd8fc94aac236a7b804a7efa6e992c2b77f9e830bb525b3fd52ccbd7a1" ]; then
            echo
            echo -e "\033[31mERROR, SHA256 of your password is not reconized, so you can't change the password of Metal3d miner\033[0m"
            exit 1
        fi
        echo -e "\033[32mSHA verified\033[0m"
        echo "Worker name is $POOL_PASS"
    else
        # there, it's for donators, so the password is "donator + uuid"
        POOL_PASS="donator-$(uuidgen)"
        echo
        echo -e "\033[36mYour a donator 💝\033[0m Thanks a lot, your donation id is \033[34m$POOL_PASS\033[0m"
        echo "Give that id to me if you want to know something, and send mail to me: metal3d _at_ gmail"
        echo
        echo -e "\033[31mTo mine for your own account, please provide your wallet address and change environment variables\033[0m"
        echo "- POOL_USER=your wallet address"
        echo "- POOL_PASS=password if needed, default is 'donator'+uuid => $POOL_PASS"
        echo "- POOL_URL=url to a pool server => $POOL_URL"
        echo
    fi
fi


# API access token to get xmrig information
if [ "$ACCESS_TOKEN" == "" ]; then
    ACCESS_TOKEN=$(uuidgen)
    echo
    echo -e "You didn't set ACCESS_TOKEN environment variable,"
    echo -e "we generated that one: \033[32m${ACCESS_TOKEN}\033[0m"
    echo 
    echo -e "\033[31m ⚠ Warning, this token will change the next time you will restart docker container, it's recommended to provide one and keep it secret\033[0m"
    echo 
fi

if [ "${POOL_PASS}" != "" ]; then
    PASS_OPTS="--pass=${POOL_PASS}"
fi


THREAD_OPTS="-t $(($(nproc)/2))"
if [ "$THREADS" -gt 0 ]; then
    THREAD_OPTS="-t $THREADS"
fi

CPU_PRIORITY="0"
if [ "$PRIORITY" -ge 0 ] && [ "$PRIORITY" -le 5 ]; then
    CPU_PRIORITY=$PRIORITY
fi


if [ "$ALGO" != "" ] && [ "$COIN" == "" ] ; then
    OTHERS_OPTS=$OTHERS_OPTS" --algo=$ALGO"
elif [ "$COIN" != "" ]; then
    OTHERS_OPTS=$OTHERS_OPTS" --coin=$COIN"
fi

if [ "$CUDA_BF" != "" ]; then
    OTHERS_OPTS=$OTHERS_OPTS" --cuda-bfactor=$CUDA_BF"
fi

if [ "${NO_CPU}" == "true" ]; then
    OTHERS_OPTS=$OTHERS_OPTS" --no-cpu"
fi

if [ "$WORKERNAME" == "" ]; then
    WORKERNAME="worker_${RANDOM}"
fi

OTHERS_OPTS=$OTHERS_OPTS" -p ${WORKERNAME}"

if [ "${CUDA}" == "true" ]; then
    OTHERS_OPTS=$OTHERS_OPTS" --cuda"
    jq '.cuda.enabled = true' config.json > config.json.tmp && mv config.json.tmp config.json
    jq '.cpu.enabled = false' config.json > config.json.tmp && mv config.json.tmp config.json
fi

if [ "${OPENCL}"  == "true" ]; then
    apt update && apt install -y nvidia-opencl-dev
    jq '.opencl.enabled = true' config.json > config.json.tmp && mv config.json.tmp config.json
    OTHERS_OPTS=$OTHERS_OPTS" --opencl"
fi


# if no arguments, run xmrig with default options
if [ $# -eq 1 ] && [ "$@" == "xmrig" ] ; then
    exec $@ --user=${POOL_USER} --url=${POOL_URL} ${PASS_OPTS} ${THREAD_OPTS} \
        --cpu-priority=${CPU_PRIORITY} \
        --donate-level=$DONATE_LEVEL \
        --http-port=3000 --http-host=0.0.0.0 --http-enabled \
        --http-access-token=${ACCESS_TOKEN} \
        --nicehash \
        ${OTHERS_OPTS}
else
    exec "$@"
fi
