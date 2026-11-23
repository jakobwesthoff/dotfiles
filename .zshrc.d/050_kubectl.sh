# INCLUDE GUARD BEGIN
if which kubectl &>/dev/null; then

# Kubernetes

## Completion taken from and modified:
## https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/kubectl/kubectl.plugin.zsh

KUBECTL_COMPLETION_CACHEDIR="${XDG_CACHE_HOME:-$HOME/.cache}/kubectl/completions"
mkdir -p "$KUBECTL_COMPLETION_CACHEDIR" >/dev/null 2>&1

# Generate and source if not existant or source and regenerate in the
# background
if [[ ! -f "$KUBECTL_COMPLETION_CACHEDIR/_kubectl" ]]; then
  kubectl completion zsh >| "$KUBECTL_COMPLETION_CACHEDIR/_kubectl"
  source "$KUBECTL_COMPLETION_CACHEDIR/_kubectl"
else
  source "$KUBECTL_COMPLETION_CACHEDIR/_kubectl"
  kubectl completion zsh >| "$KUBECTL_COMPLETION_CACHEDIR/_kubectl" &|
fi

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

## Useful aliases taken from
## https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/kubectl/kubectl.plugin.zsh

# Execute a kubectl command against all namespaces
alias kca='_kca(){ kubectl "$@" --all-namespaces;  unset -f _kca; }; _kca'

# Apply a YML file
alias kaf='kubectl apply -f'

# Drop into an interactive terminal on a container
alias keti='kubectl exec -ti'

# Manage configuration quickly to switch contexts between local, dev ad staging.
alias kcuc='kubectl config use-context'
alias kcsc='kubectl config set-context'
alias kcdc='kubectl config delete-context'
alias kccc='kubectl config current-context'

# List all contexts
alias kcgc='kubectl config get-contexts'

# General aliases
alias kdel='kubectl delete'
alias kdelf='kubectl delete -f'

# Pod management.
alias kgp='kubectl get pods'
alias kgpa='kubectl get pods --all-namespaces'
alias kgpw='kgp --watch'
alias kgpwide='kgp -o wide'
alias kep='kubectl edit pods'
alias kdp='kubectl describe pods'
alias kdelp='kubectl delete pods'
alias kgpall='kubectl get pods --all-namespaces -o wide'

# get pod by label: kgpl "app=myapp" -n myns
alias kgpl='kgp -l'

# get pod by namespace: kgpn kube-system"
alias kgpn='kgp -n'

# Service management.
alias kgs='kubectl get svc'
alias kgsa='kubectl get svc --all-namespaces'
alias kgsw='kgs --watch'
alias kgswide='kgs -o wide'
alias kes='kubectl edit svc'
alias kds='kubectl describe svc'
alias kdels='kubectl delete svc'

# Ingress management
alias kgi='kubectl get ingress'
alias kgia='kubectl get ingress --all-namespaces'
alias kei='kubectl edit ingress'
alias kdi='kubectl describe ingress'
alias kdeli='kubectl delete ingress'

# Namespace management
alias kgns='kubectl get namespaces'
alias kens='kubectl edit namespace'
alias kdns='kubectl describe namespace'
alias kdelns='kubectl delete namespace'
alias kcn='kubectl config set-context --current --namespace'

# ConfigMap management
alias kgcm='kubectl get configmaps'
alias kgcma='kubectl get configmaps --all-namespaces'
alias kecm='kubectl edit configmap'
alias kdcm='kubectl describe configmap'
alias kdelcm='kubectl delete configmap'

# Secret management
alias kgsec='kubectl get secret'
alias kgseca='kubectl get secret --all-namespaces'
alias kdsec='kubectl describe secret'
alias kdelsec='kubectl delete secret'

# Deployment management.
alias kgd='kubectl get deployment'
alias kgda='kubectl get deployment --all-namespaces'
alias kgdw='kgd --watch'
alias kgdwide='kgd -o wide'
alias ked='kubectl edit deployment'
alias kdd='kubectl describe deployment'
alias kdeld='kubectl delete deployment'
alias ksd='kubectl scale deployment'
alias krsd='kubectl rollout status deployment'

function kres(){
  kubectl set env $@ REFRESHED_AT=$(date +%Y%m%d%H%M%S)
}

# Rollout management.
alias kgrs='kubectl get rs'
alias krh='kubectl rollout history'
alias kru='kubectl rollout undo'

# Statefulset management.
alias kgss='kubectl get statefulset'
alias kgssa='kubectl get statefulset --all-namespaces'
alias kgssw='kgss --watch'
alias kgsswide='kgss -o wide'
alias kess='kubectl edit statefulset'
alias kdss='kubectl describe statefulset'
alias kdelss='kubectl delete statefulset'
alias ksss='kubectl scale statefulset'
alias krsss='kubectl rollout status statefulset'

# Port forwarding
alias kpf="kubectl port-forward"

# Tools for accessing all information
alias kga='kubectl get all'
alias kgaa='kubectl get all --all-namespaces'

# Logs
#
# `kl` forwards arguments to `kubectl logs`. Positional (non-flag)
# arguments are treated as pod names; flag arguments are shared across
# all invocations. With a single pod the logs stream in the current
# pane. With multiple pods a new tmux window is opened, the first pod
# streams in its initial pane, and each additional pod gets a new
# full-width split below, rebalanced to equal height.
kl() {
    local -a pods flags
    local arg
    for arg in "$@"; do
        if [[ "$arg" == -* ]]; then
            flags+=("$arg")
        else
            pods+=("$arg")
        fi
    done

    if [ ${#pods[@]} -eq 0 ]; then
        echo "Please provide at least one pod name to acquire logs from."
        return 1
    fi

    if [ ${#pods[@]} -eq 1 ]; then
        kubectl logs "${flags[@]}" "${pods[@]}"
        return
    fi

    if [ -z "$TMUX" ]; then
        echo "Multi-pod log streaming requires an active tmux session."
        return 1
    fi

    # Build a reusable `kubectl logs <flags> <pod>` command string to
    # type into each pane. Each value is shell-quoted so pod names or
    # flag values containing whitespace round-trip safely. We launch
    # each pane as an interactive shell and then send the command via
    # `send-keys`, so the shell stays alive after `kubectl logs` exits
    # instead of the pane closing on us.
    local flag_str=""
    for arg in "${flags[@]}"; do
        flag_str+=" $(printf '%q' "$arg")"
    done

    # Propagate KUBECONFIG to every new pane via tmux's `-e` flag.
    # tmux otherwise reuses the server's environment, which can differ
    # from the calling shell (e.g. after `kcfg` switched configs).
    local -a env_args
    if [ -n "$KUBECONFIG" ]; then
        env_args=(-e "KUBECONFIG=$KUBECONFIG")
    fi

    local window_id
    window_id="$(tmux new-window "${env_args[@]}" -P -F '#{window_id}')"

    local -a pane_ids
    pane_ids+=("$(tmux display-message -p -t "$window_id" '#{pane_id}')")

    local pod
    for pod in "${pods[@]:1}"; do
        pane_ids+=("$(tmux split-window -v -t "$window_id" \
            "${env_args[@]}" -P -F '#{pane_id}')")
    done

    tmux select-layout -t "$window_id" even-vertical

    local i pane
    for (( i = 1; i <= ${#pods[@]}; i++ )); do
        pane="${pane_ids[$i]}"
        pod="${pods[$i]}"
        tmux send-keys -t "$pane" \
            "kubecolor logs${flag_str} $(printf '%q' "$pod")" Enter
    done
}
alias kl1h='kl --since 1h'
alias kl1m='kl --since 1m'
alias kl1s='kl --since 1s'
alias klf='kl -f'
alias klf1h='kl --since 1h -f'
alias klf1m='kl --since 1m -f'
alias klf1s='kl --since 1s -f'

# File copy
alias kcp='kubectl cp'

# Node Management
alias kgno='kubectl get nodes'
alias keno='kubectl edit node'
alias kdno='kubectl describe node'
alias kdelno='kubectl delete node'

# PVC management.
alias kgpvc='kubectl get pvc'
alias kgpvca='kubectl get pvc --all-namespaces'
alias kgpvcw='kgpvc --watch'
alias kepvc='kubectl edit pvc'
alias kdpvc='kubectl describe pvc'
alias kdelpvc='kubectl delete pvc'

# Service account management.
alias kdsa="kubectl describe sa"
alias kdelsa="kubectl delete sa"

# DaemonSet management.
alias kgds='kubectl get daemonset'
alias kgdsw='kgds --watch'
alias keds='kubectl edit daemonset'
alias kdds='kubectl describe daemonset'
alias kdelds='kubectl delete daemonset'

# CronJob management.
alias kgcj='kubectl get cronjob'
alias kecj='kubectl edit cronjob'
alias kdcj='kubectl describe cronjob'
alias kdelcj='kubectl delete cronjob'

# Only run if the user actually has kubectl installed
if (( ${+_comps[kubectl]} )); then
  compdef kubecolor=kubectl
fi

## Watch kubecolor commands with color
kw(){
  hwatch -n 1 --color -t -d -- kubecolor --force-colors $@
}

alias kwp="kw get pods"

# Point KUBECONFIG at a config file in ~/.kube and select its namespace.
#
# Without arguments both the config and the namespace are picked with fzf.
# The namespace picker reads $configfile.namespaces as a static list when
# that file exists, for clusters whose namespaces can't be listed, and falls
# back to kubens otherwise.
kcfg() {
    local kube_dir="$HOME/.kube"
    local usage="Usage: kcfg [CONFIG [NAMESPACE]]

Point KUBECONFIG at CONFIG in ${kube_dir} and switch to NAMESPACE.
CONFIG may omit its .yaml or .yml extension. Without NAMESPACE the
config keeps its stored namespace. Without arguments both are picked
with fzf.

  -h, --help  show this help"

    local arg
    local -a positional
    for arg in "$@"; do
        case "$arg" in
            -h|--help)
                printf '%s\n' "$usage"
                return 0
                ;;
            -*)
                printf 'kcfg: unknown option %s\n\n%s\n' "$arg" "$usage" >&2
                return 1
                ;;
            *)
                positional+=("$arg")
                ;;
        esac
    done

    if (( ${#positional[@]} > 2 )); then
        printf 'kcfg: too many arguments\n\n%s\n' "$usage" >&2
        return 1
    fi

    local config namespace

    if (( ${#positional[@]} > 0 )); then
        # Naming the config means the destination is known, so there is no
        # namespace picker on this path.
        local candidate
        for candidate in "${positional[1]}" "${positional[1]}.yaml" "${positional[1]}.yml"; do
            if [[ -f "$kube_dir/$candidate" ]]; then
                config="$candidate"
                break
            fi
        done
        if [[ -z "$config" ]]; then
            printf 'kcfg: no config named %s in %s\n' "${positional[1]}" "$kube_dir" >&2
            return 1
        fi
        export KUBECONFIG="$kube_dir/$config"
        namespace="${positional[2]}"
    else
        # The active config is highlighted in the picker. fzf --ansi strips
        # the escape codes again from the line it prints.
        local current="" magenta normal file
        local -a configs
        if [[ "${KUBECONFIG:h}" == "$kube_dir" ]]; then
            current="${KUBECONFIG:t}"
        fi
        magenta=$(tput setaf 5 || true)
        normal=$(tput sgr0 || true)
        for file in "$kube_dir"/*.(yaml|yml)(N.:t); do
            if [[ "$file" == "$current" ]]; then
                configs+=("$magenta$file$normal")
            else
                configs+=("$file")
            fi
        done

        config="$(printf '%s\n' "${configs[@]}" \
            | fzf --ansi --preview "yq '.contexts[].context' ${(q)kube_dir}/{}" --preview-window up)"
        if [[ -z "$config" ]]; then
            return 0
        fi
        export KUBECONFIG="$kube_dir/$config"

        local namespace_file="$KUBECONFIG.namespaces"
        if [[ ! -f "$namespace_file" ]]; then
            kubens
            return
        fi
        namespace="$(fzf < "$namespace_file")"
    fi

    # The namespace goes straight into the context instead of through
    # `kubens NAME`, because kubens checks it against the cluster and fails
    # where namespaces can't be listed.
    if [[ -n "$namespace" ]]; then
        kubectl config set-context --current --namespace="$namespace"
    fi
}


# INCLUDE GUARD END
fi
