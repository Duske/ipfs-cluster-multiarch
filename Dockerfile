FROM golang:1.12-stretch AS builder

# This dockerfile builds and runs ipfs-cluster-service.
ENV SUEXEC_VERSION v0.2
ENV TINI_VERSION v0.16.1
ENV IPFS_CLUSTER_VERSION v0.11.0
ARG TARGETARCH

RUN set -x \
  && cd /tmp \
  && git clone https://github.com/ncopa/su-exec.git \
  && cd su-exec \
  && make \
  && git checkout -q $SUEXEC_VERSION \
  && cd /tmp \
  && wget -q -O tini https://github.com/krallin/tini/releases/download/$TINI_VERSION/tini \
  && chmod +x tini

RUN wget https://dist.ipfs.io/ipfs-cluster-ctl/${IPFS_CLUSTER_VERSION}/ipfs-cluster-ctl_${IPFS_CLUSTER_VERSION}_linux-${TARGETARCH}.tar.gz  && \
    wget https://dist.ipfs.io/ipfs-cluster-service/${IPFS_CLUSTER_VERSION}/ipfs-cluster-service_${IPFS_CLUSTER_VERSION}_linux-${TARGETARCH}.tar.gz && \
    tar -xzf ipfs-cluster-ctl_${IPFS_CLUSTER_VERSION}_linux-${TARGETARCH}.tar.gz && \
    tar -xzf ipfs-cluster-service_${IPFS_CLUSTER_VERSION}_linux-${TARGETARCH}.tar.gz && \
    mv ipfs-cluster-ctl/ipfs-cluster-ctl /ipfs-cluster-ctl && \
    mv ipfs-cluster-service/ipfs-cluster-service /ipfs-cluster-service && \
    chmod +x  /ipfs-cluster-service /ipfs-cluster-ctl

# Get the TLS CA certificates, they're not provided by busybox.
RUN apt-get update && apt-get install -y ca-certificates

FROM busybox:1-glibc

# This is the container which just puts the previously
# built binaries on the go-ipfs-container.

ENV IPFS_CLUSTER_PATH /data/ipfs-cluster
ENV IPFS_CLUSTER_CONSENSUS crdt

EXPOSE 9094
EXPOSE 9095
EXPOSE 9096


#COPY load.sh load.sh
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY --from=builder /ipfs-cluster-service /usr/local/bin/ipfs-cluster-service
COPY --from=builder /ipfs-cluster-ctl /usr/local/bin/ipfs-cluster-ctl
COPY --from=builder /tmp/su-exec/su-exec /sbin/su-exec
COPY --from=builder /tmp/tini /sbin/tini
COPY --from=builder /etc/ssl/certs /etc/ssl/certs

RUN mkdir -p $IPFS_CLUSTER_PATH && \
    adduser -D -h $IPFS_CLUSTER_PATH -u 1000 -G users ipfs && \
    chown ipfs:users $IPFS_CLUSTER_PATH

VOLUME $IPFS_CLUSTER_PATH
ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/entrypoint.sh"]

# Defaults for ipfs-cluster-service go here
CMD ["daemon"]