###
#   Kubernetes
###

# Kubecolor
alias k='kubecolor'
alias kubectl='kubecolor'
compdef _kubectl kubecolor

# Get
alias kg='k get'
alias kgy='kgy_f() { k get -o yaml "$@" | cy; }; kgy_f'
alias kgyy='kgyy_f() { k get -o yaml "$@" | cat -l yaml; }; kgyy_f'
alias kga='k get all'
alias kgp='k get pod'
alias kgpy='kgpy_f() { k get pod -o yaml "$@" | cy; }; kgpy_f'
alias kgpyy='kgpyy_f() { k get pod -o yaml "$@" | cat -l yaml; }; kgpyy_f'
alias kgj='k get job'
alias kgjy='kgjy_f() { k get job -o yaml "$@" | cy; }; kgjy_f'
alias kgjyy='kgjyy_f() { k get job -o yaml "$@" | cat -l yaml; }; kgjyy_f'
alias kgs='k get svc'
alias kgsy='kgsy_f() { k get svc -o yaml "$@" | cy; }; kgsy_f'
alias kgsyy='kgsyy_f() { k get svc -o yaml "$@" | cat -l yaml; }; kgsyy_f'
alias kgd='k get deployment'
alias kgdy='kgdy_f() { k get deployment -o yaml "$@" | cy; }; kgdy_f'
alias kgdyy='kgdyy_f() { k get deployment -o yaml "$@" | cat -l yaml; }; kgdyy_f'
alias kgn='k get node'
alias kgny='kgny_f() { k get node -o yaml "$@" | cy; }; kgny_f'
alias kgnyy='kgnyy_f() { k get node -o yaml "$@" | cat -l yaml; }; kgnyy_f'
alias kgns='k get ns'
alias kgnsy='kgnsy_f() { k get ns -o yaml "$@" | cy; }; kgnsy_f'
alias kgnsyy='kgnsyy_f() { k get ns -o yaml "$@" | cat -l yaml; }; kgnsyy_f'
alias kgi='k get ingress'
alias kgiy='kgiy_f() { k get ingress -o yaml "$@" | cy; }; kgiy_f'
alias kgiyy='kgiyy_f() { k get ingress -o yaml "$@" | cat -l yaml; }; kgiyy_f'
alias kgsec='k get secret'
alias kgsecy='kgsecy_f() { k get secret -o yaml "$@" | cy; }; kgsecy_f'
alias kgsecyy='kgsecyy_f() { k get secret -o yaml "$@" | cat -l yaml; }; kgsecyy_f'
alias kgpv='k get pv'
alias kgpvc='k get pvc'
alias kgpsc='k get sc'

# Describe
alias kd='k describe'
alias kdp='k describe pod'
alias kdj='k describe job'
alias kdd='k describe deployment'
alias kds='k describe svc'
alias kdn='k describe node'
alias kdns='k describe namespace'
alias kdi='k describe ingress'
alias kdsec='k describe secret'
alias kdpv='k describe pv'
alias kdpvc='k describe pvc'
alias kdpsc='k describe sc'

# Edit
alias ke='k edit'
alias kep='k edit pod'
alias kej='k edit job'
alias ked='k edit deployment'
alias kes='k edit svc'
alias kens='k edit ns'
alias kei='k edit ingress'
alias kesec='k edit secret'

# Delete
alias kdel='k delete'
alias kdelf='k delete -f'
alias kdelp='k delete pod'
alias kdelj='k delete job'
alias kdeld='k delete deployment'
alias kdels='k delete svc'
alias kdelns='k delete ns'
alias kdeli='k delete ingress'
alias kdelsec='k delete secret'
alias kdelfin='k patch -p "{\"metadata\":{\"finalizers\":null}}" --type=merge'

# Other
alias kv='k version --short'
alias kar='k api-resources --sort-by name'
alias kac='k auth can-i'
alias ktn='k top node'
alias ktp='k top pod'
alias kex='k expose'
alias kexpl='k explain'
alias kexplr='k explain --recursive=true'
alias kc='k create'
alias kcd='k create --dry-run=client -o yaml'
alias kx='k exec -ti'
alias kl='k logs'
alias klf='k logs -f'
alias ka='k apply'
alias kaf='k apply -f'
alias krun='k run'
alias krund='k run --dry-run=client -o yaml'
alias kshell='k shell'
alias kgansr='k api-resources --verbs=list --namespaced -o name | xargs -n 1 kubectl get --show-kind --ignore-not-found'

alias cleanyaml="yq e '"'del(.. | select(tag == "!!map") | (.status, .creationTimestamp, .generation, .selfLink, .uid, .resourceVersion, .managedFields, ."kubectl.kubernetes.io/last-applied-configuration"))'"' -"
alias cleanjson="jq '"'del(.. | select(. == "" or . == null)) | walk(if type == "object" then del(.status, .creationTimestamp, .generation, .selfLink, .uid, .resourceVersion, .managedFields, ."kubectl.kubernetes.io/last-applied-configuration") else . end) | del(.. | select(. == {}))'"'"
alias cy='cleanyaml | cat -l yaml'
alias cyy="cleanyaml | yq e '"'del(.. | select((. == "" and tag == "!!str") or tag == "!!null")) | del(... | select(tag == "!!map" and length == 0))'"' - | cat -l yaml"
alias cj='cleanjson | cat -l json'
