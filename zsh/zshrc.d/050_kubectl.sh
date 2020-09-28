# Kubernetes
alias k="kubectl"

kns() {
    kubectl config set-context "$(kubectl config current-context)" --namespace="$1"
}
