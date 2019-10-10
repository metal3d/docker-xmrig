# Xmrig - Monero minner in Docker

[Xmrig](https://xmrig.com/) is an opensource project to mine Monero cryptocurrency. It allow you to mine locally for a "pool", and to get back Monero for your effort.

Here, you can launch xmrig in a docker container to make it easy to launch it on Kubernetes, Swarm, or on local computer using standard docker command.

- Note: To make the container mining for **your wallet**, you'll need to have a monero wallet (see https://mymonero.com/) and follow instructions. Then change options for the container as explained in the following section
- Note: this is a CPU version of Xmrig, nvidia version will be proposed later, but that's a bit more complex

## Launch it

Simple as a pie:

```bash
docker run --rm -it metal3d/xmrig:latest
```

You can set up the container to **mine for your wallet** (see below), by default (withtout any option) you will mine for me.
That's a nice way to help me, and to pay me a beer **without any cost for you. So thanks ! 🍻** - it's like a donation, thanks if you do it.

To make Xmrig running **for you** (to let you win some XMR on **your** wallet), simply change following options using environment variables:

```bash
export POOL_URL="here, pool url"
export POOL_USER="Your public monero address"
export POOL_PASS="can be empty for some pool, other use that as miner id"
export DONATE_LEVEL="xmrig project donation in percent, default is 5"

# launch docker container
docker run --name miner --rm -it \
    -e POOL_URL=$POOL_URL \
    -e POOL_USER=$POOL_USER \
    -e POOL_PASS=$POOL_PASS \
    -e DONATE_LEVEL=$DONATE_LEVEL \ 
    metal3d/xmrig
```
`DONATE_LEVEL` is **not a donation to me**, it's the donation included in xmrig project to help developers to continue the project. Please, to help them, let the donation to 5.

Press CTRL+C to stop container, and it will be removed.

# Default

By default:

- pool server is `gulf.moneroocean.stream:10001`
- user is mine
- password is "donator" + uuid
- donation level to xmrig project is "5" (5%)

