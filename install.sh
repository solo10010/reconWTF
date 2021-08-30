#!/usr/bin/env bash

. ./config.conf

declare -A gotools
gotools["gf"]="go get -u -v github.com/tomnomnom/gf"
gotools["qsreplace"]="go get -u -v github.com/tomnomnom/qsreplace"
gotools["Amass"]="GO111MODULE=on go get -u -v github.com/OWASP/Amass/v3/..."
gotools["ffuf"]="go get -u github.com/ffuf/ffuf"
gotools["assetfinder"]="go get -u -v github.com/tomnomnom/assetfinder"
gotools["github-subdomains"]="go get -u github.com/gwen001/github-subdomains"
gotools["cf-check"]="go get -u -v github.com/dwisiswant0/cf-check"
gotools["waybackurls"]="go get -u -v github.com/tomnomnom/hacks/waybackurls"
gotools["nuclei"]="GO111MODULE=on go get -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei"
gotools["anew"]="go get -u -v github.com/tomnomnom/anew"
gotools["notify"]="GO111MODULE=on go get -v github.com/projectdiscovery/notify/cmd/notify"
gotools["mildew"]="go get -u github.com/daehee/mildew/cmd/mildew"
gotools["dirdar"]="go get -u github.com/m4dm0e/dirdar"
gotools["unfurl"]="go get -u -v github.com/tomnomnom/unfurl"
gotools["httpx"]="GO111MODULE=on go get -v github.com/projectdiscovery/httpx/cmd/httpx"
gotools["github-endpoints"]="go get -u github.com/gwen001/github-endpoints"
gotools["dnsx"]="GO111MODULE=on go get -v github.com/projectdiscovery/dnsx/cmd/dnsx"
gotools["subfinder"]="GO111MODULE=on go get -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder"
gotools["gauplus"]="GO111MODULE=on go get -v github.com/bp0lr/gauplus"
gotools["subjs"]="GO111MODULE=on go get -v github.com/lc/subjs"
gotools["Gxss"]="go get -u -v github.com/KathanP19/Gxss"
gotools["gospider"]="go get -u github.com/jaeles-project/gospider"
gotools["crlfuzz"]="GO111MODULE=on go get -v github.com/dwisiswant0/crlfuzz/cmd/crlfuzz"
gotools["dalfox"]="GO111MODULE=on go get -v github.com/hahwul/dalfox/v2"
gotools["puredns"]="GO111MODULE=on go get -v github.com/d3mondev/puredns/v2"
gotools["resolveDomains"]="go get -u -v github.com/Josue87/resolveDomains"
gotools["interactsh-client"]="GO111MODULE=on go get -v github.com/projectdiscovery/interactsh/cmd/interactsh-client"
gotools["analyticsrelationships"]="go get -u -v github.com/Josue87/analyticsrelationships"
gotools["gotator"]="go get -u -v github.com/Josue87/gotator"
gotools["naabu"]="GO111MODULE=on go get -u -v github.com/projectdiscovery/naabu/v2/cmd/naabu"
gotools["hakrawler"]="go get -u -v github.com/hakluke/hakrawler"
gotools["httprobe"]="go get -u -v github.com/tomnomnom/httprobe"
gotools["webanalyze"]="GO111MODULE=on go get -v -u github.com/rverton/webanalyze/cmd/webanalyze"
gotools["cent"]="GO111MODULE=on go get -v -u github.com/xm1k3/cent"
gotools["sonarbyte"]="GO111MODULE=on go get -v -u github.com/channyein1337/sonarbyte"
gotools["urlhunter"]"GO111MODULE=on go get -v -u github.com/utkusen/urlhunter"
gotools["sigurlfind3r"]="GO111MODULE=on go get -u -v github.com/signedsecurity/sigurlfind3r/cmd/sigurlfind3r"

declare -A repos
repos["degoogle_hunter"]="six2dez/degoogle_hunter"
repos["pwndb"]="davidtavarez/pwndb"
repos["dnsvalidator"]="vortexau/dnsvalidator"
repos["dnsrecon"]="darkoperator/dnsrecon"
repos["theHarvester"]="laramies/theHarvester"
repos["brutespray"]="x90skysn3k/brutespray"
repos["wafw00f"]="EnableSecurity/wafw00f"
repos["gf"]="tomnomnom/gf"
repos["Gf-Patterns"]="1ndianl33t/Gf-Patterns"
repos["github-search"]="gwen001/github-search"
repos["ctfr"]="UnaPibaGeek/ctfr"
repos["LinkFinder"]="dark-warlord14/LinkFinder"
repos["Corsy"]="s0md3v/Corsy"
repos["CMSeeK"]="Tuhinshubhra/CMSeeK"
repos["fav-up"]="pielco11/fav-up"
repos["Interlace"]="codingo/Interlace"
repos["massdns"]="blechschmidt/massdns"
repos["OpenRedireX"]="devanshbatham/OpenRedireX"
repos["GitDorker"]="obheda12/GitDorker"
repos["testssl"]="drwetter/testssl.sh"
repos["ip2provider"]="oldrho/ip2provider"
repos["commix"]="commixproject/commix"
repos["JSA"]="six2dez/JSA"
repos["urldedupe"]="ameenmaali/urldedupe"
repos["cloud_enum"]="initstring/cloud_enum"
repos["SecretFinder"]="m4ll0k/SecretFinder"
repos["h2t"]="gildasio/h2t"
repos["DNSCewl"]="codingo/DNSCewl"
repos["SecretFinder"]="m4ll0k/SecretFinder"
repos["webscreenshot"]="maaaaz/webscreenshot"
repos["single-tools"]="solo10010/single-tools"
repos["wordlist"]="solo10010/wordlist"

dir=${tools}
double_check=false

if grep -q "ARMv"  /proc/cpuinfo
then
   IS_ARM="True";
else
   IS_ARM="False";
fi

printf "\n\n${bgreen}#######################################################################${reset}\n"
printf "${bgreen} reconFTW installer/updater script ${reset}\n\n"
printf "${yellow} This may take time. So, go grab a coffee! ${reset}\n\n"

if [[ $(id -u | grep -o '^0$') == "0" ]]; then
    SUDO=" "
else
    if sudo -n false 2>/dev/null; then
        printf "${bred} Is strongly recommended to add your user to sudoers${reset}\n"
        printf "${bred} This will avoid prompts for sudo password in the middle of the installation${reset}\n"
        printf "${bred} And more important, in the middle of the scan (needed for nmap SYN scan)${reset}\n\n"
        printf "${bred} echo \"${USERNAME}  ALL=(ALL:ALL) NOPASSWD: ALL\" > /etc/sudoers.d/reconFTW${reset}\n\n"
    fi
    SUDO="sudo"
fi

install_apt(){
    eval $SUDO apt update -y $DEBUG_STD
    eval $SUDO DEBIAN_FRONTEND="noninteractive" apt install chromium-browser -y $DEBUG_STD
    eval $SUDO DEBIAN_FRONTEND="noninteractive" apt install chromium -y $DEBUG_STD
    eval $SUDO DEBIAN_FRONTEND="noninteractive" apt install go python3 python3-pip build-essential gcc cmake ruby git curl libpcap-dev wget zip python3-dev pv dnsutils libssl-dev libffi-dev libxml2-dev libxslt1-dev zlib1g-dev nmap jq apt-transport-https lynx tor medusa xvfb prips -y $DEBUG_STD
    eval $SUDO systemctl enable tor $DEBUG_STD
}

install_yum(){
    eval $SUDO yum groupinstall "Development Tools" -y $DEBUG_STD
    eval $SUDO yum install go chromium python3 python3-pip gcc cmake ruby git curl libpcap-dev wget zip python3-devel pv bind-utils libopenssl-devel libffi-devel libxml2-devel libxslt-devel zlib-devel nmap jq lynx tor medusa xorg-x11-server-xvfb prips -y $DEBUG_STD
}

install_pacman(){
    eval $SUDO pacman -Sy install python3 go parallel python python-pip base-devel host gcc cmake ruby git curl libpcap wget zip nmap massdns chromium lynx pv bind openssl libffi libxml2 libxslt zlib nmap jq tor medusa xorg-server-xvfb prips -y $DEBUG_STD
    eval $SUDO systemctl enable --now tor.service $DEBUG_STD
}

eval git config --global --unset http.proxy $DEBUG_STD
eval git config --global --unset https.proxy $DEBUG_STD


printf "${bblue} Running: Installing system packages ${reset}\n\n"
if [ -f /etc/debian_version ]; then install_apt;
elif [ -f /etc/redhat-release ]; then install_yum;
elif [ -f /etc/arch-release ]; then install_pacman;
elif [ -f /etc/os-release ]; then install_yum;  #/etc/os-release fall in yum for some RedHat and Amazon Linux instances
fi

# Installing latest Golang version
#version=$(curl -s https://golang.org/VERSION?m=text)
#printf "${bblue} Running: Installing/Updating Golang ${reset}\n\n"
#if [[ $(eval type go $DEBUG_ERROR | grep -o 'go is') == "go is" ]] && [ "$version" = $(go version | cut -d " " -f3) ]
#    then
#        printf "${bgreen} Golang is already installed and updated ${reset}\n\n"
#    else
#        eval $SUDO rm -rf /usr/local/go $DEBUG_STD
#        if [ "True" = "$IS_ARM" ]; then
#            eval wget https://dl.google.com/go/${version}.linux-armv6l.tar.gz $DEBUG_STD
#            eval $SUDO tar -C /usr/local -xzf ${version}.linux-armv6l.tar.gz $DEBUG_STD
#        else
#            eval wget https://dl.google.com/go/${version}.linux-amd64.tar.gz $DEBUG_STD
#            eval $SUDO tar -C /usr/local -xzf ${version}.linux-amd64.tar.gz $DEBUG_STD
#        fi
#        eval $SUDO cp /usr/local/go/bin/go /usr/bin
#        rm -rf go$LATEST_GO*
        export GOROOT=/usr/local/go
        export GOPATH=$HOME/go
        export PATH=$GOPATH/bin:$GOROOT/bin:$HOME/.local/bin:$PATH
cat << EOF >> ~/${profile_shell}

# Golang vars
export GOROOT=/usr/local/go
export GOPATH=\$HOME/go
export PATH=\$GOPATH/bin:\$GOROOT/bin:\$HOME/.local/bin:\$PATH
EOF


[ -n "$GOPATH" ] || { printf "${bred} GOPATH env var not detected, add Golang env vars to your \$HOME/.bashrc or \$HOME/.zshrc:\n\n export GOROOT=/usr/local/go\n export GOPATH=\$HOME/go\n export PATH=\$GOPATH/bin:\$GOROOT/bin:\$PATH\n\n"; exit 1; }
[ -n "$GOROOT" ] || { printf "${bred} GOROOT env var not detected, add Golang env vars to your \$HOME/.bashrc or \$HOME/.zshrc:\n\n export GOROOT=/usr/local/go\n export GOPATH=\$HOME/go\n export PATH=\$GOPATH/bin:\$GOROOT/bin:\$PATH\n\n"; exit 1; }

printf "${bblue} Running: Installing requirements ${reset}\n\n"

mkdir -p ~/.gf
mkdir -p $tools
mkdir -p ~/.config/notify/
mkdir -p ~/.config/amass/
mkdir -p ~/.config/nuclei/
touch $dir/.github_tokens

#eval wget -N -c https://bootstrap.pypa.io/get-pip.py $DEBUG_STD && eval python3 get-pip.py $DEBUG_STD
#eval rm -f get-pip.py $DEBUG_STD
#eval ln -s /usr/local/bin/pip3 /usr/bin/pip3 $DEBUG_STD
eval pip3 install -I -r requirements.txt $DEBUG_STD

printf "${bblue} Running: Installing Golang tools (${#gotools[@]})${reset}\n\n"
go env -w GO111MODULE=auto
go_step=0
for gotool in "${!gotools[@]}"; do
    go_step=$((go_step + 1))
    eval ${gotools[$gotool]} $DEBUG_STD
    exit_status=$?
    if [ $exit_status -eq 0 ]
    then
        printf "${yellow} $gotool installed (${go_step}/${#gotools[@]})${reset}\n"
    else
        printf "${red} Unable to install $gotool, try manually (${go_step}/${#gotools[@]})${reset}\n"
        double_check=true
    fi
done

printf "${bblue}\n Running: Installing repositories (${#repos[@]})${reset}\n\n"

# Repos with special configs
eval git clone https://github.com/projectdiscovery/nuclei-templates ~/nuclei-templates $DEBUG_STD
eval git clone https://github.com/geeknik/the-nuclei-templates.git ~/nuclei-templates/extra_templates $DEBUG_STD
eval nuclei -update-templates $DEBUG_STD
cd ~/nuclei-templates/extra_templates && eval git pull $DEBUG_STD
cd "$dir" || { echo "Failed to cd to $dir in ${FUNCNAME[0]} @ line ${LINENO}"; exit 1; }
eval sed -i 's/^#random-agent: false/random-agent: true/' ~/.config/nuclei/config.yaml $DEBUG_ERROR
eval git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git $dir/sqlmap $DEBUG_STD
eval git clone --depth 1 https://github.com/drwetter/testssl.sh.git $dir/testssl.sh $DEBUG_STD

# Standard repos installation
repos_step=0
for repo in "${!repos[@]}"; do
    repos_step=$((repos_step + 1))
    eval git clone https://github.com/${repos[$repo]} $dir/$repo $DEBUG_STD
    eval cd $dir/$repo $DEBUG_STD
    eval git pull $DEBUG_STD
    exit_status=$?
    if [ $exit_status -eq 0 ]
    then
        printf "${yellow} $repo installed (${repos_step}/${#repos[@]})${reset}\n"
    else
        printf "${red} Unable to install $repo, try manually (${repos_step}/${#repos[@]})${reset}\n"
        double_check=true
    fi
    if [ -s "setup.py" ]; then
        eval $SUDO python3 setup.py install $DEBUG_STD
    fi
    if [ "massdns" = "$repo" ]; then
            eval make $DEBUG_STD && strip -s bin/massdns && eval $SUDO cp bin/massdns /usr/bin/ $DEBUG_ERROR
    elif [ "gf" = "$repo" ]; then
            eval cp -r examples ~/.gf $DEBUG_ERROR
    elif [ "Gf-Patterns" = "$repo" ]; then
            eval mv *.json ~/.gf $DEBUG_ERROR
    elif [ "urldedupe" = "$repo" ]; then
            eval cmake CMakeLists.txt $DEBUG_STD
            eval make $DEBUG_STD
            eval $SUDO cp ./urldedupe /usr/bin/ $DEBUG_STD
    elif [ "DNSCewl" = "$repo" ]; then
	    eval makepkg -sri $DEBUG_STD
	    eval cp DNSCewl/DNSCewl /usr/local/bin/DNSCewl $DEBUG_STD
    fi
    cd "$dir" || { echo "Failed to cd to $dir in ${FUNCNAME[0]} @ line ${LINENO}"; exit 1; }
done

if [ "True" = "$IS_ARM" ]
    then
        eval wget -N -c https://github.com/Findomain/Findomain/releases/latest/download/findomain-armv7  $DEBUG_STD
        eval $SUDO mv findomain-armv7 /usr/bin/findomain
    else
        eval wget -N -c https://github.com/Findomain/Findomain/releases/latest/download/findomain-linux $DEBUG_STD
        eval wget -N -c https://github.com/sensepost/gowitness/releases/download/2.3.4/gowitness-2.3.4-linux-amd64 $DEBUG_STD
        eval wget -N -c https://github.com/Edu4rdSHL/unimap/releases/download/0.4.0/unimap-linux $DEBUG_STD
        eval $SUDO mv gowitness-2.3.4-linux-amd64 /usr/bin/gowitness
        eval $SUDO mv findomain-linux /usr/bin/findomain
        eval $SUDO mv unimap-linux /usr/bin/unimap
fi
eval $SUDO chmod 755 /usr/bin/findomain
eval $SUDO chmod 755 /usr/bin/gowitness
eval $SUDO chmod 755 /usr/bin/unimap
eval subfinder $DEBUG_STD
eval subfinder $DEBUG_STD

printf "${bblue}\n Running: Downloading required files ${reset}\n\n"
## Downloads
eval wget -nc -O ~/.config/amass/config.ini https://raw.githubusercontent.com/OWASP/Amass/master/examples/config.ini $DEBUG_STD
eval wget -nc -O ~/.gf/potential.json https://raw.githubusercontent.com/devanshbatham/ParamSpider/master/gf_profiles/potential.json $DEBUG_STD
eval wget -nc -O ~/.config/notify/notify.conf https://gist.githubusercontent.com/six2dez/23a996bca189a11e88251367e6583053/raw/a66c4d8cf47a3bc95f5e9ba84773428662ea760c/notify_sample.conf $DEBUG_STD
mkdir -p wordlist
mkdir -p single-tools

eval wget -nc -O wordlist/subdomains_big.txt https://wordlists-cdn.assetnote.io/data/manual/best-dns-wordlist.txt $DEBUG_STD


## Last check
if [ "$double_check" = "true" ]; then
    printf "${bblue} Running: Double check for installed tools ${reset}\n\n"
    go_step=0
    for gotool in "${!gotools[@]}"; do
        go_step=$((go_step + 1))
        eval type -P $gotool $DEBUG_STD || { eval ${gotools[$gotool]} $DEBUG_STD; }
        exit_status=$?
    done
    repos_step=0
    for repo in "${!repos[@]}"; do
        repos_step=$((repos_step + 1))
        eval cd $dir/$repo $DEBUG_STD || { eval git clone https://github.com/${repos[$repo]} $dir/$repo $DEBUG_STD && cd $dir/$repo; }
        eval git pull $DEBUG_STD
        exit_status=$?
        if [ -s "setup.py" ]; then
            eval $SUDO python3 setup.py install $DEBUG_STD
        fi
        if [ "massdns" = "$repo" ]; then
                eval make $DEBUG_STD && strip -s bin/massdns && eval $SUDO cp bin/massdns /usr/bin/ $DEBUG_ERROR
        elif [ "gf" = "$repo" ]; then
                eval cp -r examples ~/.gf $DEBUG_ERROR
        elif [ "Gf-Patterns" = "$repo" ]; then
                eval mv *.json ~/.gf $DEBUG_ERROR
        fi
        cd "$dir" || { echo "Failed to cd to $dir in ${FUNCNAME[0]} @ line ${LINENO}"; exit 1; }
    done
fi

printf "${bblue} Running: Performing last configurations ${reset}\n\n"
## Last steps
if [ ! -s "wordlist/resolvers.txt" ] || [ $(find "wordlist/resolvers.txt" -mtime +1 -print) ]; then
    printf "${yellow} Resolvers seem older than 1 day\n Generating custom resolvers... ${reset}\n\n"
    eval rm -f wordlist/resolvers.txt &>/dev/null
    eval dnsvalidator -tL https://public-dns.info/nameservers.txt -threads 100 -o wordlist/resolvers.txt $DEBUG_STD
fi
eval h8mail -g $DEBUG_STD

## Stripping all Go binaries
eval strip -s $HOME/go/bin/* $DEBUG_STD

eval $SUDO cp $HOME/go/bin/* /usr/bin/ $DEBUG_STD

printf "${yellow} Remember set your api keys:\n - amass (~/.config/amass/config.ini)\n - subfinder (~/.config/subfinder/config.yaml)\n - GitHub (~/Tools/.github_tokens)\n - SHODAN (SHODAN_API_KEY in reconftw.cfg)\n - SSRF Server (COLLAB_SERVER in reconftw.cfg) \n - Blind XSS Server (XSS_SERVER in reconftw.cfg) \n - notify (~/.config/notify/notify.conf) \n - theHarvester (~/Tools/theHarvester/api-keys.yml)\n - H8mail (~/Tools/h8mail_config.ini)\n sigurlfind3r (~/.config/sigurlfind3r/conf.yaml) \n\n ${reset}"
printf "${bgreen} Finished!${reset}\n\n"
printf "\n\n${bgreen}#######################################################################${reset}\n"

eval sigurlfind3r $DEBUG_STD