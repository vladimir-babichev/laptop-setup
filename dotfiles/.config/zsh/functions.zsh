function sp() {
    ssh -o ProxyCommand="ssh bastion.host -p 18473 -W %h:%p" $@
}

function getTTL() {
    sysctl net.inet.ip.ttl
}

function increaseTTL() {
    sudo sysctl -w net.inet.ip.ttl=$(sysctl net.inet.ip.ttl | awk '{print $NF+1}')
}

function decreaseTTL() {
    sudo sysctl -w net.inet.ip.ttl=$(sysctl net.inet.ip.ttl | awk '{print $NF-1}')
}

function kh() {
    cat ~/.ssh/known_hosts | cut -f1 -d' ' | tr ',' '\n' | sort -n | grep --color $1
}

function dkh() {
    sed -i '.bak' '/[[:<:]]'$1'[[:>:]]/d' ~/.ssh/known_hosts
}

# Retrieve Virtual Host certificate
function getHostCert() {
    # getHostCert api.domain.com 1.1.1.1 443
    # getHostCert api.domain.com 1.1.1.1:443
    # getHostCert api.domain.com 1.1.1.1
    # getHostCert api.domain.com:443
    # getHostCert api.domain.com
    local virtual_host=$1
    local server_addr=$2
    local server_port=$3
    [ "$server_addr" = "" ] && server_addr=$virtual_host
    [ "$server_port" = "" ] && server_port=$(echo $server_addr| awk -F':' '{print $2}')
    [ "$server_port" = "" ] && server_port=443

    virtual_host=$(echo $virtual_host| awk -F':' '{print $1}')
    server_addr=$(echo $server_addr| awk -F':' '{print $1}')

    (set -x && \
        openssl s_client -showcerts -servername $virtual_host -connect $server_addr:$server_port </dev/null)
}

# Retrieve Virtual Host certificate
function getHostCertDates() {
    # getHostCertDates api.domain.com 1.1.1.1 443
    # getHostCertDates api.domain.com 1.1.1.1:443
    # getHostCertDates api.domain.com 1.1.1.1
    # getHostCertDates api.domain.com:443
    # getHostCertDates api.domain.com

    getHostCert "$@" 2>/dev/null | openssl x509 -noout -dates
}

# Get Certificate Dates from K8s Secret
function getTLSSecretDetails() {
    local secret=$1
    local key=${2:=tls.crt}

    kg secret $secret -o yaml | \
        yq ".data.\"$key\"" | \
        base64 -d | \
        openssl x509 -subject -noout -dates
}


# Curl VirtualHost on IP
function curlHost() {
    # curlHost https://api.domain.com/status 1.1.1.1 443
    # curlHost https://api.domain.com 1.1.1.1:443
    # curlHost https://api.domain.com 1.1.1.1
    # curlHost https://api.domain.com
    local url=$1
    local server_host_port=$2
    local server_port=$3

    local virtual_host_port=$(echo "$url" | sed -E 's|^https?://||' | awk -F'/' '{print $1}')
    local virtual_host=$(echo "$virtual_host_port" | awk -F ':' '{print $1}')

    [ "$server_host_port" = "" ] && server_host_port=$virtual_host_port
    local server_addr=$(echo "$server_host_port" | awk -F ':' '{print $1}')

    [ "$server_port" = "" ] && server_port=$(echo "$server_host_port" | awk -F ':' '{print $2}')
    [ "$server_port" = "" ] && server_port=443

    (set -x && \
        curl -vso /dev/null --resolve $virtual_host:$server_port:$server_addr $url)
}



# SSH Port forwarding
function pfwd() {
    if [ $# -eq 3 ]; then
        # pfwd 192.168.1.133:9200 11.12.13.14:9200 192.168.1.3
        # pfwd :9200 11.12.13.14:9200 192.168.1.3
        # pfwd :9200 :9200 192.168.1.3
        shost=$3
        rhost=$(echo $2 | cut -f1 -d':')
        rport=$(echo $2 | cut -f2- -d':')
        lhost=$(echo $1 | cut -f1 -d':')
        lport=$(echo $1 | cut -f2- -d':')
        [ "x$rhost" = "x" ] && rhost='127.0.0.1'
        [ "x$rport" = "x" ] && echo "require port" && break
        [ "x$lhost" = "x" ] && lhost='127.0.0.1'
        [ "x$lport" = "x" ] && lport=$rport
    elif [ $# -eq 2 ]; then
        if [ $(echo $2 | grep ':' | wc -l) -eq 0 ]; then
            # pfwd 11.12.13.14:9200 192.168.1.3
            # pfwd :9200 192.168.1.3
            shost=$2
            rhost=$(echo $1 | cut -f1 -d':')
            rport=$(echo $1 | cut -f2- -d':')
            [ "x$rhost" = "x" ] && rhost='127.0.0.1'
            [ "x$rport" = "x" ] && echo "require port" && break
            lhost='127.0.0.1'
            lport=$rport
        else
            # pfwd 192.168.1.133:9200 192.1268.1.3:9200
            # pfwd :9200 192.1268.1.3:9200
            rhost=$(echo $2 | cut -f1 -d':')
            rport=$(echo $2 | cut -f2- -d':')
            lhost=$(echo $1 | cut -f1 -d':')
            lport=$(echo $1 | cut -f2- -d':')
            [ "x$rhost" = "x" ] && echo "require host" && break
            [ "x$rport" = "x" ] && echo "require port" && break
            [ "x$lhost" = "x" ] && lhost='127.0.0.1'
            [ "x$lport" = "x" ] && lport=$rport
            shost=$rhost
        fi
    elif [ $# -eq 1 ]; then
        # pfwd 192.168.1.3:9200
        rhost=$(echo $1 | cut -f1 -d':')
        rport=$(echo $1 | cut -f2- -d':')
        [ "x$rhost" = "x" ] && echo "require host" && break
        [ "x$rport" = "x" ] && echo "require port" && break
        shost=$rhost
        lhost='127.0.0.1'
        lport=$rport
    fi
    echo ssh -f -N -L $lhost:$lport:$rhost:$rport $shost
}


# List SSH tunnels
function pls() {
    local clNorm="\e[0m"
    local clRed="\x1B[01;91m"
    local clGreen="\x1B[01;32m"
    local clYellow="\x1B[01;93m"

    local lst=$(ps auxww | grep ssh | grep '\-L' | sed -e 's/^[a-zA-Z.]*[[:blank:]]*\([0-9]*\).*-L \([0-9a-zA-Z.-]*:[0-9a-z.-]*:[0-9a-z.-]*:[0-9a-z.-]*\) \([a-zA-Z0-9@.-]*\).*/\1 \2 \3/g')
    echo -e "${clRed}PID\t${clGreen}Forwarded Ports\t\t\t${clYellow}Remote Host${clNorm}"
    while read PID FRWD HOST; do
        echo -e "${clRed}${PID}\t${clGreen}${FRWD}\t${clYellow}${HOST}${clNorm}"
    done <<< "$lst"
}


# Searches command history for pattern.
function hgrep() {
    fc -Dlim "*$@*" 1
}
