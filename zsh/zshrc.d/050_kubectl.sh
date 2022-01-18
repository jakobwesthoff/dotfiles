# Kubernetes

##
# Internals
##

__kubectl_select_container() {
    local podName="$1"
    local containerCount="$(kubectl get pods "$podName" -o=jsonpath='{range .spec.containers[*]}{.name}{"\n"}{end}'|wc -l)"

    if [ $containerCount -eq 1 ]; then
        kubectl get pods "$podName" -o=jsonpath='{range .spec.containers[*]}{.name}{end}'
    else
        kubectl get pods "$podName" -o=jsonpath='{range .spec.containers[*]}{.name}{"\n"}{end}'|fzf
    fi
}


##
# Public
##
alias kubectl="kubecolor"
alias k="kubectl"
alias kns="kubens"
alias kctx="kubectx"

# kns() {
#     if [ $# -ne 1 ]; then
#         echo "Please provide a new namespace to switch to."
#         return 1
#     fi
#
#     kubectl config set-context "$(kubectl config current-context)" --namespace="$1"
# }

krsh() {
    if [ $# -ne 1 ]; then
        echo "Please provide a pod name to rsh into."
        return 1
    fi

    local container="$(__kubectl_select_container "$1")"
    kubectl exec --stdin --tty "$1" -c "$container" -- /bin/bash
}

klog() {
    if [ $# -lt 1 ]; then
        echo "Please provide a pod name acquire log from."
        return 1
    fi

    local pod="$1"
    shift 1

    local container="$(__kubectl_select_container "$pod")"
    kubectl logs "$pod" -c "$container" "$@"
}
