# Kubernetes
alias k="kubectl"

kns() {
    if [ $# -ne 1 ]; then
        echo "Please provide a new namespace to switch to."
        return 1
    fi

    kubectl config set-context "$(kubectl config current-context)" --namespace="$1"
}
