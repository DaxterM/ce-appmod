# Open Policy Agent

## Deploy OPA/Gatekeeper

```sh
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/deploy/gatekeeper.yaml
```

## Deploy Gatekeeper policy

Deploy gatekeeper policy that only allows the images to be pulled from gcr.io

```sh
kubectl apply -f kubernetes/opa/gatekeeper_policies/registry_validation_template.yaml
kubectl apply -f kubernetes/opa/gatekeeper_policies/registry_validation_constrain.yaml
```

