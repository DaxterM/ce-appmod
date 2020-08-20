# Open Policy Agent 

## Admission Policies

### Deploy OPA/Gatekeeper

Deploy copy of 

```sh
gatekeeper_release=v3.1.0-beta.11
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/${gatekeeper_release}/deploy/gatekeeper.yaml
```

### Deploy Gatekeeper policy

#### Limit Images to `gcr.io` as the source registry

Deploy gatekeeper policy that only allows the images to be pulled from gcr.io

```sh
kubectl apply -f kubernetes/opa/gatekeeper_policies/registry_validation_template.yaml
kubectl apply -f kubernetes/opa/gatekeeper_policies/registry_validation_constrain.yaml
```

#### Require all namespaces to have `owner` label

Deploy gatekeeper policy that requires all namespaces to have an `owner` label

```sh
kubectl apply -f kubernetes/opa/gatekeeper_policies/require_namespacelabel_template.yaml
kubectl apply -f kubernetes/opa/gatekeeper_policies/require_namespacelabel_constrain.yaml
```

## Mutating Policies

### Deploy Open Policy Agent (Old Version)

Create a namespace for OPA

```sh
kubectl create namespace opa
```

Create Certificates required to enable TLS communication between Kubernetes API and OPA

```sh
openssl genrsa -out ca.key 2048
openssl req -x509 -new -nodes -key ca.key -days 100000 -out ca.crt -subj "/CN=admission_ca"

cat >server.conf <<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, serverAuth
EOF

openssl genrsa -out server.key 2048

openssl req -new -key server.key -out server.csr -subj "/CN=opa.opa.svc" -config server.conf

openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 100000 -extensions v3_req -extfile server.conf
```

Note that above creates a CA that’s valid for 100000 days, which may not be secure. Selecting a smaller number may require some type of certificate rotation/quick re-deployment mechanism in place.

Create secret with TLS assets

```sh
kubectl -n opa create secret tls opa-server --cert=server.crt --key=server.key
```

Use the `opa_deployment.yaml` in this folder;
```sh
kubectl -n opa apply -f ./kubernetes/opa/opa_deployment.yaml
```

Create MutatingWebhookConfiguration as below

```sh
cat > webhook-configuration.yaml <<EOF
kind: MutatingWebhookConfiguration
apiVersion: admissionregistration.k8s.io/v1beta1
metadata:
  name: opa-validating-webhook
webhooks:
  - name: mutating-webhook.openpolicyagent.org
    rules:
      - operations: ["*"]
        apiGroups: ["*"]
        apiVersions: ["*"]
        resources: ["*"]
    clientConfig:
      service:
        namespace: opa
        name: opa
      caBundle: $(cat ca.crt | base64 | tr -d '\n')
EOF
```

Deploy webhook-configuration.yaml
```sh
kubectl -n opa apply -f webhook-configuration.yaml
```

### Deploy Mutating Admission policy

OPA uses the old way of deploying the rego policies i.e. by deploying a configmap from rego file into the OPA namespace.

Deploy a mutating policy and test;

```sh
kubectl -n opa create configmap cmdb --from-file=./kubernetes/opa/mutating_policies/cmdb.rego
```

If you deploy an nginx pod, you should see it mutated
```sh
kubectl run nginx --image=nginx ; \
  kubectl get pods nginx -o json | jq '.spec.containers[].env'
```

#### Deploy a test policy


