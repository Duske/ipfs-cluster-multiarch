# IPFS-Cluster - Multiarch Images

> IPFS Cluster provides data orchestration across a swarm of IPFS daemons by allocating, replicating and tracking a global pinset distributed among multiple peers.

If you need a multiarch docker image, this repository is for you.

## Image

### Docker Hub

You can find the image on the docker hub: [https://hub.docker.com/r/theduske/ipfs-cluster-multi](https://hub.docker.com/r/theduske/ipfs-cluster-multi)

### Build

Please enable docker experimental features, to use `buildx`.
See https://engineering.docker.com/2019/04/multi-arch-images/.

Then, after you created a builder, use the `buildx` command like this:

```
docker buildx build --platform <your-platforms> -t <yourrepo/path:tag>  --push .
```

**Example**: 

```
# Example for linux/amd64,linux/arm64,linux/arm:
docker buildx build --platform linux/amd64,linux/arm64,linux/arm -t theduske/ipfs-cluster-multi:v0.11.0  --push .

```

### Configuration
You can choose the version of the following tools by using these environment variables:
* IPFS Cluster: `IPFS_CLUSTER_VERSION`
* Suexec: `SUEXEC_VERSION`
* Tini: `TINI_VERSION`