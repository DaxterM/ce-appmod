package k8srequirednodeselect

namespace := input.review.object.metadata.namespace

violation[{"msg": msg}] { 
  input.review.object.kind = "Pod"
  #input.review.object.spec.nodeSelector["nodepool"] != input.parameters.namespaceselector[namespace]
  ns := input.review.object.metadata.namespace
  selectors := input.parameters.namespaceselector
  result := get_value(selectors, ns)
  msg := sprintf("test %v", [input.parameters.namespaceselector])
  #msg := sprintf("container has an invalid `nodeselector` : %v ",  [input.review.object.spec.nodeSelector["nodepool"] ])
}

violation[{"msg": msg}] { 
  input.review.object.kind = "Pod"
  not(input.review.object.spec.nodeSelector)
  msg := "container has an empty nodeselector"
}

get_value(parameters, _default) = msg {
  msg := parameters.ns
}