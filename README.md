# Xmrig - Monero Miner in Docker

[Xmrig](https://xmrig.com/) is an open-source project for mining Monero cryptocurrency. It allows you to mine locally
for a pool and receive Monero for your efforts.

Here, you can launch Xmrig in a Podman or Docker container and to easily run it on Kubernetes, or your local computer
using standard Docker commands.

## Getting Started

To mine for **your wallet**, you need a Monero wallet (see [MyMonero](https://mymonero.com/)) and follow the
instructions below to configure the container accordingly.

### Launching Xmrig

```bash
docker run --rm -it ghcr.io/metal3d/xmrig:latest
# podman
podman run --rm -it ghcr.io/metal3d/xmrig:latest
```

By default, without any options, you will mine for me, which is a way to support the project. To mine for **your wallet**,
modify the options using environment variables:

```bash
export POOL_URL="your pool URL"
export POOL_USER="Your public Monero address"
export POOL_PASS="can be empty for some pools, otherwise use it as miner ID"
export DONATE_LEVEL="Xmrig project donation in percent, default is 5"

# Update the image
docker pull ghcr.io/metal3d/xmrig:latest
# or with podman
podman pull ghcr.io/metal3d/xmrig:latest
# Launch the Docker container
docker run --name miner --rm -it \
    -e POOL_URL=$POOL_URL \
    -e POOL_USER=$POOL_USER \
    -e POOL_PASS=$POOL_PASS \
    -e DONATE_LEVEL=$DONATE_LEVEL \
    ghcr.io/metal3d/xmrig:latest
# or with podman
podman run --name miner --rm -it \
    -e POOL_URL=$POOL_URL \
    -e POOL_USER=$POOL_USER \
    -e POOL_PASS=$POOL_PASS \
    -e DONATE_LEVEL=$DONATE_LEVEL \
    ghcr.io/metal3d/xmrig:latest
```

`DONATE_LEVEL` is **not a donation to me**, it's the donation included in the Xmrig project to support its developers.
Please leave it at the default value of 5 or higher to contribute to the project.

Press `CTRL+C` to stop the container, and it will be automatically removed.

### Environment Variables

- `POOL_USER`: your wallet address (default is mine)
- `POOL_URL`: the pool address (default is `xmr.metal3d.org:8080`)
- `POOL_PASS`: the pool password or worker ID (default for me is "donator" + UUID)
- `DONATE_LEVEL`: percentage of donation to Xmrig.com project (leave the default at 5 or higher)
- `PRIORITY`: CPU priority (0=idle, 1=normal, 2 to 5 for higher priority)
- `THREADS`: number of threads to start (default is number of CPU / 2)
- `ACCESS_TOKEN`: Bearer access token to access the Xmrig API (served on port 3000, default is a generated token (UUID))
- `ALGO`: mining algorithm (default is empty, refer to [Xmrig documentation](https://xmrig.com/docs/algorithms))
- `COIN`: coin option instead of algorithm (default is empty)
- `WORKERNAME`: naming the worker (generated with a random UUID if not specified)
- `CUDA`: activate CUDA (set to "true"). Requires GPU sharing to containers (refer to [Nvidia documentation](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html))
- `NO_CPU`: deactivate computation on CPU (useful for mining only on CUDA)

### Using CUDA

Follow instructions from [Nvidia documentation](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html) and [the page for Podman using CDI](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/cdi-support.html) if you prefer Podman.

To use CUDA devices:

```bash
# Replace podman with docker if you are using Docker
podman run --rm -it \
    --device nvidia.com/gpu=all \
    --security-opt=label=disable \ # podman only
    -e CUDA=true \
    ghcr.io/metal3d/xmrig:latest

# You can compute only on GPU, but it's not recommended due to frequent GPU errors
podman run --rm -it \
    --device nvidia.com/gpu=all \
    --security-opt=label=disable \ # podman only
    -e CUDA=true \
    -e NO_CPU=true \
    ghcr.io/metal3d/xmrig:latest
```

## Notes about MSR (Model Specific Registry)

Xmrig requires setting MSR (Model Specific Registry) to achieve optimal hashrates. If MSR is not allowed, your hashrate
will be low, and a warning will appear in the terminal. To enable MSR inside the container (for Podman), use the
following commands:

```bash
# Basic mining with CPU (replace podman with docker if you are using Docker)
sudo podman run --rm -it \
    --privileged \
    ghcr.io/metal3d/xmrig:latest

# To use CUDA devices
sudo podman run --rm -it \
    --privileged \
    --device nvidia.com/gpu=all \
    -e CUDA=true \
    ghcr.io/metal3d/xmrig:latest
```
