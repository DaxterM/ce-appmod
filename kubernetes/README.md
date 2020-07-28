# Kubernetes 

## Create a cluster

Create a new cluster using [gcloud cli](https://cloud.google.com/sdk/gcloud)

```shell
cluster_name="demo"
zone="us-east4-c"
gcloud container clusters create $cluster_name --zone $zone --no-enable-basic-auth --release-channel "rapid"
```

Once the cluster is created, this section contains additional documentation to go through;

- [RBAC](./rbac/README.md)