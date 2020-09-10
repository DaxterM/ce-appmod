# Require Node Selector

This is a gatekeeper policy set that requires all pods, deployments, replicasets, daemonsets, replicationcontrollers to have a `nodeSelector` property attached in their Pod Spec

Key/Value pairs in the `constraints.yaml` file :

```yaml
    namespaceselector: 
        example-nodeselector-fail-team: "team1"
        example-nodeselector-pass: "team1"
        example-nodeselector-fail-empty: "team1"
```

describe the matching of namespace to a nodeselector tag. i.e. based on above example all pods deployed to `example-nodeselector-pass` namespace must have a nodeselector with 

```yaml
nodepool: team1
```

The key `nodepool` is static and hardcoded in the `template.yaml` file