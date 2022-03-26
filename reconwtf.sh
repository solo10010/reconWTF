#!/bin/bash

# interlaces fix https://github.com/codingo/Interlace/issues/156
eval . ./config.conf # defaul config file

function help(){
	echo ""
	echo " Usage: ./reconwtf.sh [options...] -d <domain> -m <companu tld>-l <list.txt> -x <scope.txt> 
			-c <cookie> -f <config.conf> -u <dir out> -r -s -p -a -o -v -h"
	echo ""
	echo "  -d, --domain 		<domain> 	domain target 'example.com' "
	echo "  -m, --company 	<name>		copany name 'Tesla inc' see https://www.whoxy.com/tesla.com"
	echo "  -x, --scope 		<scope.txt> 	Out of Scope format \.vk.com clear vk subdomain \vk.com clear all vk.com"
	echo "  -g, --config		<config.conf>	config file '-g dir/config2.conf' "
	echo "  -c, --cookie 		<cookie>  	cookie -c 'PHPSESSIONID=qweqweqwe'"
	echo "  -cidr, --cidr		<ip range>	target ip range 192.49,128.0/16"
	echo ""
	echo "  -r, --recon-full	 		full target exploration ( with the use of attacks ) "
	echo "  -s, --subdimain-search	 	only subdomain search, resolution, and subdomain capture "
	echo "  -p, --passive 			only passive methods that do not affect the target "
	echo "  -a, --active				full intelligence with the use of attacks "
	echo "  -o, --osint				minimal exploration with the use of OSINT "
	echo ""
	echo "  -in, --install			Install all tools "
	echo "  -ct, --check-tools			Verify that the tools are installed correctly "
	echo ""
	echo "  -v, --version				reconWTF version "
	echo "  -h, --help 				help"
	echo ""
	echo "Remember set your api keys:"
	echo ""
	echo "subfinder 		|		(~/.config/subfinder/config.yaml)"
	echo "amass 			|		(~/.config/amass/config.ini)"
	echo "GitHub 			|		(~/Tools/.github_tokens)"
	echo "SHODAN 			|		(SHODAN_API_KEY in reconftw.cfg)"
	echo "SSRF Server 		|		(COLLAB_SERVER in reconftw.cfg)"
	echo "Blind XSS Server 	|		(XSS_SERVER in reconftw.cfg) "
	echo "theHarvester 		|		(~/Tools/theHarvester/api-keys.yml)"
	echo "H8mail 			|		(~/Tools/h8mail_config.ini)"
	echo "sigurlfind3r 		|		(~/.config/sigurlfind3r/conf.yaml)"
	echo ""
	exit
}

# парсим аргументы
if [[ -z "$1" ]]
then
	help # вызывает справка
fi

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -d|--domain) # главный домен
    target_domain="$2"
    shift # past argument
    shift # past value
    if [[ -z $target_domain ]]
    then
	    echo " -d, --domain this parameter must have the value!"
	    echo "  -h, --help help to reconWTF"
	    exit
    fi
    ;;
    -m|--company) # название компании
    company="$2"
    shift # past argument
    shift # past value
    if [[ -z $company ]]
    then
	    echo " -c, --company  this parameter must have the value!"
	    echo "  -h, --help help to reconWTF"
	    exit
    fi
    ;;
	    -cidr|--cidr) # диапазон ip цели 192.49,128.0/16
    cidr="$2"
    shift # past argument
    shift # past value
    if [[ -z $cidr ]]
    then
	    echo " -cidr, --cidr  target ip range 192.49,128.0/16"
	    echo "  -h, --help help to reconWTF"
	    exit
    fi
    ;;
    -x|--scope) # список доменов в зоне видимости 
    scope_list="$2"
    shift # past argument
    shift # past value
    if [[ -z $scope_list ]]
    then
	    echo " -x, --scope this parameter must have the value!"
	    echo "  -h, --help help to reconWTF"
	    exit
    else
	    echo " "
    fi
    ;;
	-g|--config) # путь до конфига
    config="$2"
    shift # past argument
    shift # past value
    if [[ -z $config ]]
    then
		eval . ./config.conf
    else
	    
		eval . ./$config
    fi
    ;;
    -r|--recon-full) # полная разведка без атак
    recon_full="$1"
    shift # past argument
    shift # past value
    ;;
    -s|--subdomain-search) # только поиск субдоменов, разрешение и захват субдомена
    subdomain_serch="$1"
    shift # past argument
    shift # past value
    ;;
    -p|--passive) # только пассивные методы не затрагивающие цель
    passive="$1"
    shift # past argument
    shift # past value
    ;;
    -a|--active) # полная разведка с применением атак
    active="$1"
    shift # past argument
    shift # past value
    ;;
    -o|--osint) # минимальная разведка с применение осинта
    osint="$1"
    shift # past argument
    shift # past value
    ;;
    -c|--cookie) # куки 
    cookie="$2"
    shift # past argument
    shift # past value
    if [[ -z $cookie ]]
    then
	    echo " -c, --cookie this parameter must have the value!"
	    echo "  -h, --help help to reconWTF"
	    exit
    fi
    ;;
	-v|--version) # справка
    version="$2"
    shift # past argument
    shift # past value
    if [[ -z $version ]]
    then 
	    printf "\n reconWTF version $reconWTF_version \n\n"
	    exit
    fi
    ;;
	-in|--install) # установка утилит
    install_tools="$1"
    shift # past argument
    #shift # past value
    ;;
	-ct|--check-tools) # установка утилит
    check_all_tools="$1"
    shift # past argument
    #shift # past value
    ;;
    -h|--help) # справка
    help="$2"
    shift # past argument
    shift # past value
    if [[ -n $help ]]
    then 
	    echo " You can't use arguments here!!!"
	    echo "  Usage: reconwtf.sh -h, --help"
	    exit
    else
	help # функция вызывает показ справки
    fi
    ;;
    *)
    echo " flag provided but not defined: ${key}"
    echo "  Usage: reconwtf.sh -h, --help"
    exit
    ;;
esac
done
# проверяем на наличие sudo
#if [[ $(id -u | grep -o '^0$') != "0" ]]; then
#    echo "скрипт должен быть запущен от root!!!"
#	echo "чтобы сохранить домашнюю диркторию запустить sudo -E"
#	echo "запустить sudo -E ./reconWTF.sh"
#    exit
#fi
# проверяем на наличие sudo -E
#if [[ $HOME == "/root" ]]; then
#		echo "sudo должно быть запущен с параметрои -E"
#		echo "запустить sudo -E ./reconWTF.sh"
#		exit
#fi

# определяем глобальные переменные
echo "Version: $reconWTF_version"
if [[ -n $cookie ]]; then # если были переданы куки то записываем куки с хедером
	header_cookie=$(echo "Cooke: $cookie") # записываем куку в переменнуж с Cookie:
fi 

see="sed -r 's/\[.+]//' | sed 's/ //g' | sed '/^$/d'" # убрать и STDIN [] \n \f []
DEBUG_FILE=$recon_dir/$target_domain/.tmp/debug #файл для дебага

# проверяем установлены ли инструменты
function check_tools(){

	printf "\n\n${bgreen}#######################################################################${reset}\n"
	printf "${bblue} Checking installed tools ${reset}\n\n"

	allinstalled=true

	[ -n "$GOPATH" ] || { printf "${bred} [*] GOPATH var		[NO]${reset}\n"; allinstalled=false;}
	[ -n "$GOROOT" ] || { printf "${bred} [*] GOROOT var		[NO]${reset}\n"; allinstalled=false;}
	[ -n "$PATH" ] || { printf "${bred} [*] PATH var		[NO]${reset}\n"; allinstalled=false;}
	[ -f "$tools/degoogle_hunter/degoogle.py" ] || { printf "${bred} [*] degoogle		[NO]${reset}\n"; allinstalled=false;}
	[ -f "$tools/dnsrecon/dnsrecon.py" ] || { printf "${bred} [*] dnsrecon	[NO]${reset}\n"; allinstalled=false;}
	[ -f "$tools/pwndb/pwndb.py" ] || { printf "${bred} [*] fav-up		[NO]${reset}\n"; allinstalled=false;}
	[ -f "$tools/fav-up/favUp.py" ] || { printf "${bred} [*] fav-up		[NO]${reset}\n"; allinstalled=false;}
	[ -f "$tools/Corsy/corsy.py" ] || { printf "${bred} [*] Corsy		[NO]${reset}\n"; allinstalled=false;}
	[ -f "$tools/testssl/testssl.sh" ] || { printf "${bred} [*] testssl		[NO]${reset}\n"; allinstalled=false;}
	[ -f "$tools/CMSeeK/cmseek.py" ] || { printf "${bred} [*] CMSeeK		[NO]${reset}\n"; allinstalled=false;}
	[ -f "$tools/ctfr/ctfr.py" ] || { printf "${bred} [*] ctfr		[NO]${reset}\n"; allinstalled=false;}
	[ -f "$tools/wordlist/fuzz_wordlist.txt" ] || { printf "${bred} [*] OneListForAll	[NO]${reset}\n"; allinstalled=false;}
	[ -f "$tools/LinkFinder/linkfinder.py" ] || { printf "${bred} [*] LinkFinder		[NO]${reset}\n"; allinstalled=false;}
	[ -f "$tools/SecretFinder/SecretFinder.py" ] || { printf "${bred} [*] LinkFinder		[NO]${reset}\n"; allinstalled=false;}
	[ -f "$tools/GitDorker/GitDorker.py" ] || { printf "${bred} [*] GitDorker		[NO]${reset}\n"; allinstalled=false;}
	[ -f "$tools/commix/commix.py" ] || { printf "${bred} [*] commix		[NO]${reset}\n"; allinstalled=false;}
	[ -f "$tools/degoogle_hunter/degoogle_hunter.sh" ] || { printf "${bred} [*] degoogle_hunter	[NO]${reset}\n"; allinstalled=false;}
	[ -f "$tools/single-tools/DownloadJS.py" ] || { printf "${bred} [*] getjswords   	[NO]${reset}\n"; allinstalled=false;}
	[ -f "$tools/JSA/jsa.py" ] || { printf "${bred} [*] JSA		[NO]${reset}\n"; allinstalled=false;}
	[ -f "$tools/cloud_enum/cloud_enum.py" ] || { printf "${bred} [*] cloud_enum		[NO]${reset}\n"; allinstalled=false;}
	[ -f "$tools/DNSCewl/DNScewl" ] || { printf "${bred} [*] DNSCewl		[NO]${reset}\n"; allinstalled=false;}
	[ -f "$tools/h2t/h2t.py" ] || { printf "${bred} [*] h2t		[NO]${reset}\n"; allinstalled=false;}
	[ -f "$tools/webscreenshot/webscreenshot.py" ] || { printf "${bred} [*] webscreenshot		[NO]${reset}\n"; allinstalled=false;}
	[ -f "$tools/brutespray/brutespray.py" ] || { printf "${bred} [*] brutespray		[NO]${reset}\n"; allinstalled=false;}
	type -P dirdar &>/dev/null || { printf "${bred} [*] dirdar		[NO]${reset}\n"; allinstalled=false;}
	type -P github-endpoints &>/dev/null || { printf "${bred} [*] github-endpoints	[NO]${reset}\n"; allinstalled=false;}
	type -P github-subdomains &>/dev/null || { printf "${bred} [*] github-subdomains	[NO]${reset}\n"; allinstalled=false;}
	type -P gospider &>/dev/null || { printf "${bred} [*] gospider		[NO]${reset}\n"; allinstalled=false;}
	type -P wafw00f &>/dev/null || { printf "${bred} [*] wafw00f		[NO]${reset}\n"; allinstalled=false;}
	type -P subfinder &>/dev/null || { printf "${bred} [*] Subfinder		[NO]${reset}\n"; allinstalled=false;}
	type -P assetfinder &>/dev/null || { printf "${bred} [*] Assetfinder	[NO]${reset}\n"; allinstalled=false;}
	type -P dnsvalidator &>/dev/null || { printf "${bred} [*] dnsvalidator	[NO]${reset}\n"; allinstalled=false;}
	type -P gowitness &>/dev/null || { printf "${bred} [*] gowitness		[NO]${reset}\n"; allinstalled=false;}
	type -P findomain &>/dev/null || { printf "${bred} [*] Findomain		[NO]${reset}\n"; allinstalled=false;}
	type -P amass &>/dev/null || { printf "${bred} [*] Amass		[NO]${reset}\n"; allinstalled=false;}
	type -P waybackurls &>/dev/null || { printf "${bred} [*] Waybackurls	[NO]${reset}\n"; allinstalled=false;}
	type -P gauplus &>/dev/null || { printf "${bred} [*] gauplus		[NO]${reset}\n"; allinstalled=false;}
	type -P dnsx &>/dev/null || { printf "${bred} [*] dnsx		[NO]${reset}\n"; allinstalled=false;}
	type -P gotator &>/dev/null || { printf "${bred} [*] gotator		[NO]${reset}\n"; allinstalled=false;}
	type -P cf-check &>/dev/null || { printf "${bred} [*] Cf-check		[NO]${reset}\n"; allinstalled=false;}
	type -P nuclei &>/dev/null || { printf "${bred} [*] Nuclei		[NO]${reset}\n"; allinstalled=false;}
	[ -d ~/nuclei-templates ] || { printf "${bred} [*] Nuclei templates	[NO]${reset}\n"; allinstalled=false;}
	type -P gf &>/dev/null || { printf "${bred} [*] Gf			[NO]${reset}\n"; allinstalled=false;}
	type -P Gxss &>/dev/null || { printf "${bred} [*] Gxss		[NO]${reset}\n"; allinstalled=false;}
	type -P subjs &>/dev/null || { printf "${bred} [*] subjs		[NO]${reset}\n"; allinstalled=false;}
	type -P ffuf &>/dev/null || { printf "${bred} [*] ffuf		[NO]${reset}\n"; allinstalled=false;}
	type -P massdns &>/dev/null || { printf "${bred} [*] Massdns		[NO]${reset}\n"; allinstalled=false;}
	type -P qsreplace &>/dev/null || { printf "${bred} [*] qsreplace		[NO]${reset}\n"; allinstalled=false;}
	type -P interlace &>/dev/null || { printf "${bred} [*] interlace		[NO]${reset}\n"; allinstalled=false;}
	type -P anew &>/dev/null || { printf "${bred} [*] Anew		[NO]${reset}\n"; allinstalled=false;}
	type -P unfurl &>/dev/null || { printf "${bred} [*] unfurl		[NO]${reset}\n"; allinstalled=false;}
	type -P crlfuzz &>/dev/null || { printf "${bred} [*] crlfuzz		[NO]${reset}\n"; allinstalled=false;}
	type -P httpx &>/dev/null || { printf "${bred} [*] Httpx		[NO]${reset}\n${reset}"; allinstalled=false;}
	type -P jq &>/dev/null || { printf "${bred} [*] jq			[NO]${reset}\n${reset}"; allinstalled=false;}
	type -P notify &>/dev/null || { printf "${bred} [*] notify		[NO]${reset}\n${reset}"; allinstalled=false;}
	type -P dalfox &>/dev/null || { printf "${bred} [*] dalfox		[NO]${reset}\n${reset}"; allinstalled=false;}
	type -P puredns &>/dev/null || { printf "${bred} [*] puredns		[NO]${reset}\n${reset}"; allinstalled=false;}
	type -P unimap &>/dev/null || { printf "${bred} [*] unimap		[NO]${reset}\n${reset}"; allinstalled=false;}
	type -P resolveDomains &>/dev/null || { printf "${bred} [*] resolveDomains	[NO]${reset}\n"; allinstalled=false;}
	type -P emailfinder &>/dev/null || { printf "${bred} [*] emailfinder	[NO]${reset}\n"; allinstalled=false;}
	type -P urldedupe &>/dev/null || { printf "${bred} [*] urldedupe	[NO]${reset}\n"; allinstalled=false;}
	type -P analyticsrelationships &>/dev/null || { printf "${bred} [*] analyticsrelationships	[NO]${reset}\n"; allinstalled=false;}
	type -P interactsh-client &>/dev/null || { printf "${bred} [*] interactsh-client	[NO]${reset}\n"; allinstalled=false;}
	type -P cent &>/dev/null || { printf "${bred} [*] cent	[NO]${reset}\n"; allinstalled=false;}
	type -P naabu &>/dev/null || { printf "${bred} [*] naabu	[NO]${reset}\n"; allinstalled=false;}
	type -P sonarbyte &>/dev/null || { printf "${bred} [*] sonarbyte	[NO]${reset}\n"; allinstalled=false;}
	type -P urlhunter &>/dev/null || { printf "${bred} [*] urlhunter	[NO]${reset}\n"; allinstalled=false;}
	type -P webanalyze &>/dev/null || { printf "${bred} [*] webanalyze	[NO]${reset}\n"; allinstalled=false;}
	type -P nmap &>/dev/null || { printf "${bred} [*] nmap	[NO]${reset}\n"; allinstalled=false;}
	type -P dnsgen &>/dev/null || { printf "${bred} [*] dnsgen	[NO]${reset}\n"; allinstalled=false;}
	type -P dig &>/dev/null || { printf "${bred} [*] dig	[NO]${reset}\n"; allinstalled=false;}
	type -P lynx &>/dev/null || { printf "${bred} [*] lynx	[NO]${reset}\n"; allinstalled=false;}
	type -P host &>/dev/null || { printf "${bred} [*] host	[NO]${reset}\n"; allinstalled=false;}
	type -P chromium &>/dev/null || { printf "${bred} [*] chromium	[NO]${reset}\n"; allinstalled=false;}
	type -P wget &>/dev/null || { printf "${bred} [*] wget	[NO]${reset}\n"; allinstalled=false;}
	type -P curl &>/dev/null || { printf "${bred} [*] curl	[NO]${reset}\n"; allinstalled=false;}
	type -P python3 &>/dev/null || { printf "${bred} [*] python3	[NO]${reset}\n"; allinstalled=false;}
	type -P pip3 &>/dev/null || { printf "${bred} [*] pip3	[NO]${reset}\n"; allinstalled=false;}
	type -P hakrevdns &>/dev/null || { printf "${bred} [*] hakrevdns	[NO]${reset}\n"; allinstalled=false;}

	if [ "${allinstalled}" = true ]; then
		printf "${bgreen} Good! All installed! ${reset}\n\n"
	else
		printf "\n${yellow} Try running the installer script again ./install.sh"
		printf "\n${yellow} If it fails for any reason try to install manually the tools missed"
		printf "\n${yellow} Finally remember to set the ${bred}\$tools${yellow} variable at the start of this script"
		printf "\n${yellow} If nothing works and the world is gonna end you can always ping me :D ${reset}\n\n"
	fi

	printf "${bblue} Tools check finished\n"
	printf "${bgreen}#######################################################################\n${reset}"
}

function tools_update_resurce(){
	if [[ $NUCLEI_UPDATE_TEMPLATES == "true" ]]; then
		echo " nuclei update templates "
		eval nuclei -update-templates
	fi
	if [[ $NUCLEI_ADDITIONAL_TEMPLATES == "true" ]]; then
		echo " nuclei update additional templates "
			#eval cent init
			#eval cent -p ~/nuclei-templates/cent-nuclei-templates
	fi
	eval webanalyze -update

}

function install_tools(){
	
	declare -A gotools
	gotools["gf"]="go install -v github.com/tomnomnom/gf@latest"
	gotools["qsreplace"]="go install -v github.com/tomnomnom/qsreplace@latest"
	gotools["Amass"]="go install -v github.com/OWASP/Amass/v3/...@master"
	gotools["ffuf"]="go install -v github.com/ffuf/ffuf@latest"
	gotools["assetfinder"]="go install -v github.com/tomnomnom/assetfinder@latest"
	gotools["github-subdomains"]="go install -v github.com/gwen001/github-subdomains@latest"
	gotools["cf-check"]="go install -v github.com/dwisiswant0/cf-check@latest"
	gotools["waybackurls"]="go install -v github.com/tomnomnom/hacks/waybackurls@latest"
	gotools["nuclei"]="go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest"
	gotools["anew"]="go install -v github.com/tomnomnom/anew@latest"
	gotools["notify"]="go install -v github.com/projectdiscovery/notify/cmd/notify@latest"
	gotools["dirdar"]="go install -v github.com/m4dm0e/dirdar@latest"
	gotools["unfurl"]="go install -v github.com/tomnomnom/unfurl@latest"
	gotools["httpx"]="go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest"
	gotools["github-endpoints"]="go install -v github.com/gwen001/github-endpoints@latest"
	gotools["dnsx"]="go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest"
	gotools["subfinder"]="go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
	gotools["gauplus"]="go install -v github.com/bp0lr/gauplus@latest"
	gotools["subjs"]="go install -v github.com/lc/subjs@latest"
	gotools["Gxss"]="go install -v github.com/KathanP19/Gxss@latest"
	gotools["gospider"]="go install -v github.com/jaeles-project/gospider@latest"
	gotools["crlfuzz"]="go install -v github.com/dwisiswant0/crlfuzz/cmd/crlfuzz@latest"
	gotools["dalfox"]="go install -v github.com/hahwul/dalfox/v2@latest"
	gotools["puredns"]="go install -v github.com/d3mondev/puredns/v2@latest"
	gotools["resolveDomains"]="go install -v github.com/Josue87/resolveDomains@latest"
	gotools["interactsh-client"]="go install -v github.com/projectdiscovery/interactsh/cmd/interactsh-client@latest"
	gotools["analyticsrelationships"]="go install -v github.com/Josue87/analyticsrelationships@latest"
	gotools["gotator"]="go install -v github.com/Josue87/gotator@latest"
	gotools["naabu"]="go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest"
	gotools["hakrawler"]="go install -v github.com/hakluke/hakrawler@latest"
	gotools["httprobe"]="go install -v github.com/tomnomnom/httprobe@@master"
	gotools["webanalyze"]="go install -v github.com/rverton/webanalyze/cmd/webanalyze@latest"
	gotools["cent"]="go install -v github.com/xm1k3/cent@latest"
	gotools["sonarbyte"]="go install -v github.com/channyein1337/sonarbyte@latest"
	gotools["urlhunter"]="go install -v github.com/utkusen/urlhunter@latest"
	gotools["sigurlfind3r"]="go install -v github.com/signedsecurity/sigurlfind3r/cmd/sigurlfind3r@latest"
	gotools["hakrevdns"]="go install -v github.com/hakluke/hakrevdns@latest"

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

	declare -A pip_tools
	pip_tools["dnsgen"]="dnsgen"
	pip_tools["argcomplete"]="argcomplete==1.10.0"
	pip_tools["dnspython"]="dnspython"
	pip_tools["requests"]="requests"
	pip_tools["requests_futures"]="requests_futures"
	pip_tools["dnspython"]="dnspython>=2.0.0"
	pip_tools["netaddr"]="netaddr"
	pip_tools["lxml"]="lxml"
	pip_tools["flake8"]="flake8"
	pip_tools["pytest"]="pytest"
	pip_tools["colorclass"]="colorclass"
	pip_tools["beautifulsoup4"]="beautifulsoup4"
	pip_tools["shodan"]="shodan"
	pip_tools["mmh3"]="mmh3"
	pip_tools["ipwhois"]="ipwhois"
	pip_tools["argparse"]="argparse"
	pip_tools["tqdm"]="tqdm>=4.32.0"
	pip_tools["fake-useragent"]="fake-useragent"
	pip_tools["termcolor"]="termcolor"
	pip_tools["tqdm"]="tqdm"
	pip_tools["certifi"]="certifi==2018.11.29"
	pip_tools["chardet"]="chardet==3.0.4"
	pip_tools["colorama"]="colorama==0.4.1"
	pip_tools["idna"]="idna==2.8"
	pip_tools["urllib3"]="urllib3==1.24.2"
	pip_tools["colorclass"]="colorclass==2.2.0"
	pip_tools["netaddr"]="netaddr==0.7.20"
	pip_tools["tqdm"]="tqdm==4.36.1"
	pip_tools["dnspython"]="dnspython==1.16.0"
	pip_tools["beautifulsoup4"]="beautifulsoup4==4.9.3"
	pip_tools["jsbeautifier"]="jsbeautifier"
	pip_tools["PySocks"]="PySocks==1.6.8"
	pip_tools["requests_file"]="requests_file"
	pip_tools["future"]="future"
	pip_tools["emailfinder"]="emailfinder"
	pip_tools["metafinder"]="metafinder"
	pip_tools["tqdm"]="tqdm==4.62.3"
	pip_tools["aiohttp"]="aiohttp"


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

	if [ -f /etc/debian_version ]; then 
		printf "${bblue} Running: Installing system packages фзе ${reset}\n\n"
		eval $SUDO apt update -y $DEBUG_STD
		eval $SUDO DEBIAN_FRONTEND="noninteractive" apt install chromium-browser -y $DEBUG_STD
		eval $SUDO DEBIAN_FRONTEND="noninteractive" apt install chromium -y $DEBUG_STD
		eval $SUDO DEBIAN_FRONTEND="noninteractive" apt install go python3 python3-pip build-essential gcc cmake ruby git curl libpcap-dev wget zip python3-dev pv dnsutils libssl-dev libffi-dev libxml2-dev libxslt1-dev zlib1g-dev nmap jq apt-transport-https lynx tor medusa xvfb prips -y $DEBUG_STD
		eval $SUDO systemctl enable tor $DEBUG_STD
	elif [ -f /etc/redhat-release ]; then
		printf "${bblue} Running: Installing system packages yum ${reset}\n\n"
		eval $SUDO yum groupinstall "Development Tools" -y $DEBUG_STD
    	eval $SUDO yum install go chromium python3 python3-pip gcc cmake ruby git curl libpcap-dev wget zip python3-devel pv bind-utils libopenssl-devel libffi-devel libxml2-devel libxslt-devel zlib-devel nmap jq lynx tor medusa xorg-x11-server-xvfb prips -y $DEBUG_STD
	elif [ -f /etc/arch-release ]; then
		printf "${bblue} Running: Installing system packages pacman ${reset}\n\n"
		curl -O https://blackarch.org/strap.sh $DEBUG_STD
		chmod +x strap.sh $DEBUG_STD
		sudo ./strap.sh $DEBUG_STD
		rm ./strap.sh

		eval $SUDO pacman -Syu --noconfirm $DEBUG_STD
		eval $SUDO pacman -S --noconfirm --overwrite  python3 parallel go python python-pip base-devel gcc cmake ruby git curl libpcap wget zip nmap chromium lynx pv bind openssl libffi libxml2 libxslt zlib nmap jq tor medusa xorg-server-xvfb -y $DEBUG_STD
    	#eval $SUDO systemctl enable --now tor.service $DEBUG_STD
	elif [ -f /etc/os-release ]; then install_yum;  #/etc/os-release fall in yum for some RedHat and Amazon Linux instances
		printf "${bblue} Running: Installing system packages yum ${reset}\n\n"
		eval $SUDO yum groupinstall "Development Tools" -y $DEBUG_STD
    	eval $SUDO yum install go chromium python3 python3-pip gcc cmake ruby git curl libpcap-dev wget zip python3-devel pv bind-utils libopenssl-devel libffi-devel libxml2-devel libxslt-devel zlib-devel nmap jq lynx tor medusa xorg-x11-server-xvfb prips -y $DEBUG_STD
	fi

	eval git config --global --unset http.proxy $DEBUG_STD
	eval git config --global --unset https.proxy $DEBUG_STD




# Installing latest Golang version
#version=$(curl -L -s https://golang.org/VERSION?m=text)
version="go1.17.6"
printf "${bblue} Running: Installing/Updating Golang ${reset}\n\n"
if [[ $(eval type go $DEBUG_ERROR | grep -o 'go is') == "go is" ]] && [ "$version" = $(go version | cut -d " " -f3) ]
    then
        printf "${bgreen} Golang is already installed and updated ${reset}\n\n"
    else
        eval $SUDO rm -rf /usr/local/go $DEBUG_STD
        if [ "True" = "$IS_ARM" ]; then
            if [ "True" = "$RPI_3" ]; then
                eval wget https://dl.google.com/go/${version}.linux-armv6l.tar.gz $DEBUG_STD
                eval $SUDO tar -C /usr/local -xzf ${version}.linux-armv6l.tar.gz $DEBUG_STD
            elif [ "True" = "$RPI_4" ]; then
                eval wget https://dl.google.com/go/${version}.linux-arm64.tar.gz $DEBUG_STD
                eval $SUDO tar -C /usr/local -xzf ${version}.linux-arm64.tar.gz $DEBUG_STD
            fi
        elif [ "True" = "$IS_MAC" ]; then
            if [ "True" = "$IS_ARM" ]; then
                eval wget https://dl.google.com/go/${version}.darwin-arm64.tar.gz $DEBUG_STD
                eval $SUDO tar -C /usr/local -xzf ${version}.darwin-arm64.tar.gz $DEBUG_STD
            else
                eval wget https://dl.google.com/go/${version}.darwin-amd64.tar.gz $DEBUG_STD
                eval $SUDO tar -C /usr/local -xzf ${version}.darwin-amd64.tar.gz $DEBUG_STD
            fi
        else
            eval wget https://dl.google.com/go/${version}.linux-amd64.tar.gz $DEBUG_STD
            eval $SUDO tar -C /usr/local -xzf ${version}.linux-amd64.tar.gz $DEBUG_STD
        fi
        eval $SUDO ln -sf /usr/local/go/bin/go /usr/local/bin/
        rm -rf $version*
        export GOROOT=/usr/local/go
        export GOPATH=$HOME/go
        export PATH=$GOPATH/bin:$GOROOT/bin:$HOME/.local/bin:$PATH
		
go_text_check=$(cat ~/${profile_shell} | grep "export GOROOT=/usr/local/go")
# проверяем установлен ли голанд в профиле
if [[ $go_text_check == "export GOROOT=/usr/local/go" ]]; then
    echo "go ur exposts install"
else
cat << EOF >> ~/${profile_shell}
# Golang vars
export GOROOT=/usr/local/go
export GOPATH=\$HOME/go
export PATH=\$GOPATH/bin:\$GOROOT/bin:\$HOME/.local/bin:\$PATH
EOF
fi	

fi

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

printf "${bblue} Running: Installing Golang tools (${#gotools[@]})${reset}\n\n"
go env -w GO111MODULE=auto
go_step=0
for gotool in "${!gotools[@]}"; do
    go_step=$((go_step + 1))
    eval ${gotools[$gotool]} #$DEBUG_STD
    exit_status=$?
    if [ $exit_status -eq 0 ]
    then
        printf "${yellow} $gotool installed (${go_step}/${#gotools[@]})${reset}\n"
    else
        printf "${red} Unable to install $gotool, try manually (${go_step}/${#gotools[@]})${reset}\n"
        double_check=true
    fi
done


printf "${bblue}\n Running: Installing pip3 requements (${#pip_tools[@]})${reset}\n\n"
pip_step=0
for pip_tool in "${!pip_tools[@]}"; do
    pip_step=$((pip_step + 1))
    eval pip install ${pip_tools[$pip_tool]} $DEBUG_STD
    exit_status=$?
    if [ $exit_status -eq 0 ]
    then
        printf "${yellow} $pip_tool installed (${pip_step}/${#pip_tools[@]})${reset}\n"
    else
        printf "${red} Unable to install $pip_tool, try manually (${pip_step}/${#pip_tools[@]})${reset}\n"
       double_check=true
    fi
done


printf "${bblue}\n Running: Installing repositories (${#repos[@]})${reset}\n\n"

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
            eval cp examples/*.json ~/.gf $DEBUG_ERROR
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
printf "${bgreen} Check installed utilities${reset}\n\n"
printf "${bgreen} ./reconwtf.sh -ct${reset}\n\n"


printf "\n\n${bgreen}#######################################################################${reset}\n"

#eval sigurlfind3r $DEBUG_STD

#tools_update_resurce
#check_tools

#exit

}




function preliminary_actions(){ # предварительные действия создаем директорию цели итд..

	# проверяем нужено ли собрать dns resolver-ы
	if [[ $update_resolvers == "true" ]]; then
		echo "dnsvalidator gen dnsresolver true"
		exec dnsvalidator \--no-color \-threads $DNS_VALIDATION_THREADS \-o $tools/wordlist/resolvers.txt &> /dev/null
	fi
		if [ -e $recon_dir/README.md ]; then 
			 echo ""
		else
			touch $recon_dir/README.md
		fi
		if [ -e $recon_dir/$target_domain/README.md ]; then 
			 echo ""
		else
			touch $recon_dir/$target_domain/README.md
		fi

		if [ -f $recon_dir/$target_domain/CheckList.md ]; then
			echo ""
		else
			curl https://raw.githubusercontent.com/solo10010/Bagbounty_resources/main/checklist/README.md > $recon_dir/$target_domain/CheckList.md
		fi
	

	# создаем нужные директории если их нет. если есть не создаем
	if ! [ -d $recon_dir/$target_domain/ ]; then
		mkdir -p $recon_dir
		mkdir -p $recon_dir/$target_domain/
		mkdir -p $recon_dir/$target_domain/.tmp
		touch $recon_dir/$target_domain/.tmp/debug
		mkdir -p $recon_dir/$target_domain/subdomain
		mkdir -p $recon_dir/$target_domain/js
		mkdir -p $recon_dir/$target_domain/js/waybackjs
		mkdir -p $recon_dir/$target_domain/webs
		mkdir -p $recon_dir/$target_domain/scan
		mkdir -p $recon_dir/$target_domain/vulns
		mkdir -p $recon_dir/$target_domain/vulns/xss
		mkdir -p $recon_dir/$target_domain/hosts
		mkdir -p $recon_dir/$target_domain/fuzzing
		mkdir -p $recon_dir/$target_domain/scan/webtechnologies
		mkdir -p $recon_dir/$target_domain/gf
		mkdir -p $recon_dir/$target_domain/osint
		mkdir -p $recon_dir/$target_domain/scan/header_sec
		mkdir -p $recon_dir/$target_domain/scan/CMSeeK
		mkdir -p $recon_dir/$target_domain/cidr
		mkdir -p $recon_dir/$target_domain/pentests

		cd $recon_dir/$target_domain # переходим в папку рекона
	else
		cd $recon_dir/$target_domain # переходим в папку рекона
	fi

	if [[ -n $cidr  ]]; then # если передан cidr вычесляем все ip
		
		rm $recon_dir/$target_domain/.tmp/ipcidr_to_ip_list.txt
		rm $recon_dir/$target_domain/.tmp/cidr.txt

		echo $cidr | anew $recon_dir/$target_domain/.tmp/cidr.txt
		nmap -sL "$cidr" | awk '/Nmap scan report/{print $NF}' | grep -o --regexp="[0-9]\{1,3\}[\.][0-9]\{1,3\}[\.][0-9]\{1,3\}[\.][0-9]\{1,3\}" | eval $see | anew $recon_dir/$target_domain/.tmp/ipcidr_to_ip_list.txt
		
	else
		echo " "
	fi

	# обнуляем debug
	echo "start recon to ${target_domain}" > $recon_dir/$target_domain/.tmp/debug
}

function scope_domain(){
	if [[ -n $scope_list ]]; then
		echo " --= scope list =--"
		mv $recon_dir/$target_domain/subdomain/subdomains.txt $recon_dir/$target_domain/subdomain/_subdomains.txt
		cat $recon_dir/$target_domain/subdomain/_subdomains.txt | egrep -i -v -x -f $scope_list | anew $recon_dir/$target_domain/subdomain/subdomains.txt > $DEBUG_FILE
		rm $recon_dir/$target_domain/subdomain/_subdomains.txt
	fi
}

function SubRresult(){
	echo " разрешаем поддомены "
	# в последний раз разрешаем поддомены и записываем в конечный файл
	cat $recon_dir/$target_domain/.tmp/*_subdomains.txt | egrep "\.$target_domain" | egrep -o "[a-z0-9_-]+(\.[a-z0-9_-]+)*\.[a-z]{2,5}" | egrep -v "www." | puredns resolve -r $dns_resolver 2>>"$DEBUG_FILE" | anew $recon_dir/$target_domain/subdomain/subdomains.txt &>>"$DEBUG_FILE"
	echo "$target_domain" | anew $recon_dir/$target_domain/subdomain/subdomains.txt &>>"$DEBUG_FILE"
	scope_domain
}

function Subdomain_enum_passive(){
	if [[ $SUB_ENUM_GENERAL == "true" ]]; then
			echo " запускается sonarbyte "
			sonarbyte -d $target_domain | anew $recon_dir/$target_domain/.tmp/sonarbyte_subdomains.txt &>>"$DEBUG_FILE"
			# запускаем certfinder без dig он не работает
			if [[ $SUB_ENUM_CERT == "true" ]]; then
				echo "запускается cert"
				python3 $tools/ctfr/ctfr.py -d $target_domain | egrep -o "[a-z0-9_-]+(\.[a-z0-9_-]+)*\.[a-z]{2,5}" | anew $recon_dir/$target_domain/.tmp/cert_subdomains.txt &>>"$DEBUG_FILE"
			fi

	fi

}

function Subdomain_enum(){

	if [[ $SUB_ENUM_GENERAL == "true" ]]; then

		if [[ $SUB_ENUM_SYBFINDER == "true" ]]; then
				echo "## запускаем subfinder ##" $debug
				subfinder -d $target_domain -config $SUBFINDER_CONFIG -nc -silent -recursive -nW | anew $recon_dir/$target_domain/.tmp/subfinder_subdomains.txt  &>>"$DEBUG_FILE"
			else
				echo " subfinder false "
		fi

		if [[ $SUB_ENUM_AMASS == "true" ]]; then

			if [[ -n $company && -n $cidr ]]; then
				echo "выполняю -n company && -n cidr "
				amass intel -org $company >  $recon_dir/$target_domain/hosts/asn.txt
				cat $recon_dir/$target_domain/hosts/asn.txt | grep "ASN:" | grep "[0-9]" | awk '{print $2}' | tr '\n' ',' | sed s/,$// > $recon_dir/$target_domain/.tmp/asn_list.txt
				asn_list=$(cat $recon_dir/$target_domain/.tmp/asn_list.txt)

				amass enum -d $target_domain -cidr $cidr -asn $asn_list -nocolor -rf $dns_resolver -active | anew $recon_dir/$target_domain/.tmp/amass_cidr_and_asn_subdomains.txt

			else
				echo "amass no cidr and no company"
			fi

			if [[ -n $cidr && -z $company ]]; then # запускаем amss c cidr если cidr есть а компании нет
				echo "выаолняю -z company && -n cidr "
				amass enum -d $target_domain -cidr $cidr -nocolor -rf $dns_resolver -active | anew $recon_dir/$target_domain/.tmp/amass_cidr_subdomains.txt
			else
				echo " amass cidr false "
			fi

			if [[ -n $company && -z $cidr ]]; then
				echo "выполняю -n company && -z cidr "
				amass intel -org $company >  $recon_dir/$target_domain/hosts/asn.txt
				cat $recon_dir/$target_domain/hosts/asn.txt | grep "ASN:" | grep "[0-9]" | awk '{print $2}' | tr '\n' ',' | sed s/,$// > $recon_dir/$target_domain/.tmp/asn_list.txt
				asn_list=$(cat $recon_dir/$target_domain/.tmp/asn_list.txt)

				amass enum -d $target_domain -asn $asn_list -nocolor -rf $dns_resolver -active | anew $recon_dir/$target_domain/.tmp/amass_cidr_and_asn_subdomains.txt

			else
				echo "amass enum asn false no company name"
			fi

			if [[ -n $target_domain && -z $company && -z $cidr ]]; then
				echo "start -n target_domain && -z company && -z cidr "
				amass enum -d $target_domain -nocolor -rf $dns_resolver -active | anew $recon_dir/$target_domain/.tmp/amass_subdomains.txt
			else
				echo "amass no target name"
			fi


		else
			echo "amss geral false"
		fi
	else
		echo " subdomain enumeration false "
	fi

}


function subdomain_permytation(){
	if [[ $SUB_ENUM_PERMUTATION == "true" ]]; then
		echo "DNScewl"
		$tools/DNSCewl/DNScewl -t $target_domain -p $permutations_list | egrep -o "[a-z0-9_-]+(\.[a-z0-9_-]+)*\.[a-z]{2,5}" | egrep -v "www." | anew $recon_dir/$target_domain/.tmp/dnscewl_subdomains.txt  &>>"$DEBUG_FILE"
		echo "====== dnsgen -l 3 -  ========="
		# сначала разрешаем поддомены для передачи в dnsgen
		touch $recon_dir/$target_domain/.tmp/all_permutation.txt
		cat $recon_dir/$target_domain/.tmp/*_subdomains.txt | egrep -o "[a-z0-9_-]+(\.[a-z0-9_-]+)*\.[a-z]{2,5}" | egrep -v "www." | anew $recon_dir/$target_domain/.tmp/all_permutation.txt &>>"$DEBUG_FILE"
		cat $recon_dir/$target_domain/.tmp/all_permutation.txt | puredns resolve -r $dns_resolver 2>>"$DEBUG_FILE" | anew $recon_dir/$target_domain/.tmp/puredns_subdomain.txt &>>"$DEBUG_FILE"
		# на основе доменов генерируем имена поддомено
		dnsgen -l $SUB_ENUM_PERMUTATION_WORDLEN $recon_dir/$target_domain/.tmp/puredns_subdomain.txt | anew $recon_dir/$target_domain/.tmp/dnsgen_subdomains.txt &>>"$DEBUG_FILE"
		# разрешаем все что сгенерировали
		cat $recon_dir/$target_domain/.tmp/dnsgen_subdomains.txt | puredns resolve -r $dns_resolver 2>>"$DEBUG_FILE" | anew $recon_dir/$target_domain/.tmp/puredns_resolv_subdomains.txt 2>>"$DEBUG_FILE"
		# помещаем весь результат в файл
		cat $recon_dir/$target_domain/.tmp/puredns_resolv_subdomains.txt | anew $recon_dir/$target_domain/.tmp/permytation_subdomains.txt &>>"$DEBUG_FILE"
		rm $recon_dir/$target_domain/.tmp/puredns_resolv_subdomains.txt
		rm $recon_dir/$target_domain/.tmp/all_permutation.txt
	else
		echo " subdomain permutation false"
	fi
	
}

function subdomain_bruteforce(){
	if [[ $SUB_ENUM_BRUTEFORCE == "true" ]]; then
		
		# здесь брутим поддомены
		if [[ $SUB_ENUM_BRUTEFORCE_MINFILE  == "true" ]]; then
			cat $brute_list_min | puredns bruteforce $target_domain --resolvers $dns_resolver | anew $recon_dir/$target_domain/.tmp/min_brute_subdomains.txt
		elif [[ $SUB_ENUM_BRUTEFORCE_MAXFILE == "true" ]]; then
			cat $brute_list_big | puredns bruteforce $target_domain --resolvers $dns_resolver | anew $recon_dir/$target_domain/.tmp/big_brute_subdomains.txt
		fi
	else
		echo " subdomain bruteforce false "
	fi
	
}


function zonetransfer_takeovers(){
	if [[ $ZONETRANSFER == "true" ]]; then
		echo " --= zonetransfer takeovers =--"
		python3 $tools/dnsrecon/dnsrecon.py -d $target_domain -a -j $recon_dir/$target_domain/subdomain/zonetransfer.json &>> $DEBUG_FILE
		cat $recon_dir/$target_domain/webs/webs.txt | nuclei -silent -t ~/nuclei-templates/takeovers/ -r $dns_resolver -o $recon_dir/$target_domain/subdomain/subtakeover.txt &>> $DEBUG_FILE
	else
		echo "zonetransfer false"
	fi
}


function webs(){
	if [[ $WEBS_GENERAL == "true" ]]; then
		echo " subdomain http probing "
		if [[ $WEBS_SUB_HTTPPROBE == "true" ]]; then
			#cat $recon_dir/$target_domain/subdomain/subdomains.txt | httpx -silent -random-agent -t 100 -nc -fr -maxr 2 -fhr -maxhr 10 -p 8080,10000,20000,2222,7080,9009,7443,2087,2096,8443,4100,2082,2083,2086,9999,2052,9001,9002,7000,7001,8082,8084,8085,8010,9000,2078,2080,2079,2053,2095,4000,5280,8888,9443,5800,631,8000,8008,8087,84,85,86,88,10125,9003,7071,8383,7547,3434,10443,8089,3004,81,4567,7081,82,444,1935,3000,9998,4433,4431,4443,83,90,8001,8099,80,300,443,591,593,832,981,1010,1311,2480,3128,3333,4243,4711,4712,4993,5000,5104,5108,6543,7396,7474,8014,8042,8069,8081,8088,8090,8091,8118,8123,8172,8222,8243,8280,8281,8333,8500,8834,8880,8983,9043,9060,9080,9090,9091,9200,9800,9981,12443,16080,18091,18092,20720,28017 | eval $see | anew $recon_dir/$target_domain/webs/webs_uncommon_ports.txt
			cat $recon_dir/$target_domain/subdomain/subdomains.txt | httprobe --prefer-https  | anew $recon_dir/$target_domain/webs/webs.txt
			
		fi	
	else 
		echo " web general false "
	fi
}

function s3bucket(){
	if [[ $S3BUCKET == "true" ]]; then
		echo " start s3bucket enumetration "
		s3scanner scan -f $recon_dir/$target_domain/subdomain/subdomains.txt | grep -iv "not_exist" | grep -iv "Warning:" | anew -q $recon_dir/$target_domain/.tmp/s3buckets.txt
		keyword=${target_domain%%.*}
	
		python3 $tools/cloud_enum/cloud_enum.py -k $keyword -k $target_domain -qs -l $recon_dir/$target_domain/.tmp/output_cloud.txt
		cat $recon_dir/$target_domain/.tmp/output_cloud.txt | sed '/^#/d' | sed '/^$/d' | anew $recon_dir/$target_domain/subdomain/cloud_assets.txt
		cat $recon_dir/$target_domain/.tmp/s3buckets.txt | anew $recon_dir/$target_domain/subdomain/s3buckets.txt
	else
		echo " s3bucket false"
	fi
}

function scan_hosts_passive(){
	shodan init $SHODAN_API_KEY
}

function scan_hosts(){
	if [[ $SCAN_HOST_GENERAL == "true" ]]; then
		echo " start scan host"
		cat $recon_dir/$target_domain/subdomain/subdomains.txt | naabu -silent -p $SCAN_HOST_NAABO_WEBPROBE > $recon_dir/$target_domain/webs/webs_ucommon_ports.txt 
		cat $recon_dir/$target_domain/webs/webs_ucommon_ports.txt | httprobe -prefer-https > $recon_dir/$target_domain/webs/webs_uncommon_ports.txt
		rm $recon_dir/$target_domain/webs/webs_ucommon_ports.txt
	else
		echo " scan host false"
	fi
}

function visual_indentification(){
	if [[ $WEB_VISUAL_INDENTIFICATION == "true" ]]; then
		echo " start visual indentification "
		python3 $tools/webscreenshot/webscreenshot.py -i $recon_dir/$target_domain/webs/webs_uncommon_ports.txt --no-error-file -r chromium --no-xserver
	else
		echo " visual indintification false "
	fi
}

function scope_endpoint(){
	
	cat $recon_dir/$target_domain/.tmp/*_endpoint.txt | eval $see | egrep -Eoi "(http|https)://[a-zA-Z0-9./?=_%:-]*" | anew $recon_dir/$target_domain/.tmp/endpoint_extract.txt
	if [[ -n $scope_list ]]; then
		cat $recon_dir/$target_domain/.tmp/endpoint_extract.txt | egrep -Eoi "(http|https)://[a-zA-Z0-9./?=_%:-]*" | egrep -i -f $scope_list > $recon_dir/$target_domain/webs/url_extract.txt
	else
		cat $recon_dir/$target_domain/.tmp/endpoint_extract.txt | egrep -Eoi "(http|https)://[a-zA-Z0-9./?=_%:-]*" > $recon_dir/$target_domain/webs/url_extract.txt
	fi
}

function endpoint_enum_passive(){
	if [[ $SIGURLFIND3R == "true" ]]; then
		interlace -tL $recon_dir/$target_domain/webs/webs.txt -threads $IN_SIGURLFIND3R -c "sigurlfind3r -d "_target_" -iS | anew $recon_dir/$target_domain/.tmp/sigurlfind3r_endpoint.txt"
		scope_endpoint # функция обедеинения файлов и применение scope
	else
		printf "sigurlfind3r == false"
	fi
}

function endpoint_enum_agressive(){
	if [[ $ENDP_ENUM_GENERAL == "true" ]]; then
		echo "start enpoint enum"
		if [[ $ENDP_ENUM_GAUPLUS == "true" ]]; then
			cat $recon_dir/$target_domain/webs/webs_uncommon_ports.txt | gauplus -random-agent > $recon_dir/$target_domain/.tmp/gauplus_endpoint.txt
		fi
		if [[ $ENDP_ENUM_GITHUB == "true" && $GITHUB_DORKS != "XXXXXXXXXXXXXXXXXXXXXXXX" ]]; then
			python3 $tools/github-search/github-endpoints.py -t $GITHUB_TOKEN -d $target_domain > $recon_dir/$target_domain/.tmp/github_endpoint.txt
		fi	
		if [[ $ENDP_ENUM_GOSPIDER == "true" ]]; then
			cat $recon_dir/$target_domain/webs/webs_uncommon_ports.txt | gospider -u web --cookie $cookie -d $ENDP_ENUM_GOSPIDER_DEPTH -o $recon_dir/$target_domain/webs/endpoint
			cat $recon_dir/$target_domain/webs/endpoint/* | egrep -io "http.*?" > $recon_dir/$target_domain/.tmp/gospider_endpoint.txt
		fi
		# функция обедеинения файлов и применение scope
		scope_endpoint
		# генерация списков слов на основе конечных точек
		if [[ $ENDP_GENERATION_LIST == "true" ]]; then
			cat $recon_dir/$target_domain/webs/url_extract.txt | unfurl -u keys | sed 's/[][]//g' | sed 's/[#]//g' | sed 's/[}{]//g' | anew -q $recon_dir/$target_domain/webs/dict_words.txt
			cat $recon_dir/$target_domain/webs/url_extract.txt | unfurl -u values | sed 's/[][]//g' | sed 's/[#]//g' | sed 's/[}{]//g' | anew -q $recon_dir/$target_domain/webs/dict_words.txt
			cat $recon_dir/$target_domain/webs/url_extract.txt | tr "[:punct:]" "\n" | anew -q $recon_dir/$target_domain/webs/dict_words.txt
		fi
	else
		echo " enpoint enum false "
	fi
}

function jsfind(){
	if [[ $JS_GENERAL == "true" ]]; then
		echo "Start js finds "

		cat $recon_dir/$target_domain/webs/url_extract.txt | grep -i ".js$" > $recon_dir/$target_domain/js/js_links.txt
		if [[ $JS_LIVE_CHECS == "true" ]]; then
			cat $recon_dir/$target_domain/js/js_links.txt | grep -i ".js$" | httpx -silent -no-color -status-code -H $header_cookie | grep "\[200\]$" | eval $see > $recon_dir/$target_domain/js/live_js_links.txt
		fi		
		# download js file
		if [[ $JS_DOWNLOAD == "true" ]]; then
			interlace  -tL $recon_dir/$target_domain/js/live_js_links.txt -threads $IN_JS_DOWNLOAD_FILE -c "echo _target_ | egrep -Eoi '(http|https)://[a-zA-Z0-9./?=_%:-]*' | python3 $tools/single-tools/DownloadJS.py -c "$cookie" -o $recon_dir/$target_domain/js/jsfile"
		fi
		#Gather Endpoints From JsFiles
		if [[ $JS_LINKFIND == "true" ]]; then
			echo "" > $recon_dir/$target_domain/js/js_endpoints.txt
			interlace -tL $recon_dir/$target_domain/js/live_js_links.txt -threads $IN_JS_LINK_FIND -c "echo 'Scanning _target_ Now' ; python3 ~/Tools/LinkFinder/linkfinder.py -d -i _target_ -o cli >> $recon_dir/$target_domain/js/js_endpoints.txt" -v	
		fi
		#Gather Secrets From Js Files
		if [[ $JS_SECRET == "true" ]]; then
			echo "" > $recon_dir/$target_domain/js/jslinksecret.txt
			interlace -tL $recon_dir/$target_domain/js/live_js_links.txt -threads $IN_JS_SECRET_FIND -c "python3 $tools/SecretFinder/SecretFinder.py -i _target_ -o cli >> $recon_dir/$target_domain/js/jslinksecret.txt" -v
		fi
		#Gather JSFilesWordlist	
		if [[ $JS_WORDS == "true" ]]; then
			echo "" > $recon_dir/$target_domain/js/jswordlist.txt
			cat $recon_dir/$target_domain/js/live_js_links.txt | python3 $tools/single-tools/getjswords.py >> $recon_dir/$target_domain/.tmp/temp_jswordlist.txt
			cat $recon_dir/$target_domain/.tmp/temp_jswordlist.txt | sort -u > $recon_dir/$target_domain/js/jswordlist.txt
		fi
		#Gather Variables from JSFiles For Xss
		if [[ $JS_VARS == "true" ]]; then
			echo "" > $recon_dir/$target_domain/js/js_var.txt
			#cat $recon_dir/$target_domain/js/live_js_links.txt | while read url ; do bash $tools/single-tools/jsvar.sh $url | tee -a $recon_dir/$target_domain/js/js_var.txt ; done
			for live_js_links in $(cat $recon_dir/$target_domain/js/live_js_links.txt)
			do
				echo -e "\e[1;33m$live_js_links\n\e[32m";
				result=$(curl -s $live_js_links | grep -Eo "var [a-zA-Z0-9_]+" | sort -u | cut -d" " -f2 | awk 'length($live_js_links) >= 3 {print $live_js_links}')
				if [[ -n $result ]]; then
					echo -e "\e[1;33m$live_js_links\n\e[32m \n $result" >> $recon_dir/$target_domain/js/js_var.txt
				fi
				
			done
		fi	
		#Find DomXSS
		if [[ $JS_FINDOM_XSS == "true" ]]; then
			echo "" > $recon_dir/$target_domain/vulns/domxss_scan.txt
			#scan
			for live_js_links in $(cat $recon_dir/$target_domain/js/live_js_links.txt)
			do
				PATTERN="(document|location|window)\.(URL|documentURI|search|hash|referrer|(location\.)?href|name)"
				BODY=$(curl -sL ${live_js_links})
				SCAN=($(echo ${BODY} | grep -Eoin ${PATTERN}))
				if [[ ! -z "${SCAN}" ]]; then
					echo -en "---\n\033[0;32m[!] ${live_js_links}\033[0m\n${SCAN}\n"
					echo -e "---\n${live_js_links}\n${SCAN}" >> $recon_dir/$target_domain/vulns/domxss_scan.txt
				fi
			done
		fi

		# wayback js find scan
		if [[ $JS_WAYBACK_SCAN == "true" ]]; then
			mkdir -p $recon_dir/$target_domain/js/waybackjs
			touch $recon_dir/$target_domain/js/waybackjs/waybackjs_link.txt
			touch $recon_dir/$target_domain/js/waybackjs/live_waybackjs_link.txt
			for js_links in $(cat $recon_dir/$target_domain/js/js_links.txt)
				do
					status_code=$(echo $js_links | httpx -x HEAD -status-code -silent -no-color | grep -oP '(?<=\[).*(?=\])')
					if [[ $status_code != 200 ]]; then
						echo "https://web.archive.org/web/20060102150405if_/$js_links" >> $recon_dir/$target_domain/js/waybackjs/waybackjs_link.txt
						status_code2=$(echo "https://web.archive.org/web/20060102150405if_/$js_links" | httpx -x HEAD -status-code -silent -no-color | grep -oP '(?<=\[).*(?=\])')
						if [[ $status_code2 == 200 ]]; then
							echo "https://web.archive.org/web/20060102150405if_/$js_links" >> $recon_dir/$target_domain/js/waybackjs/live_waybackjs_link.txt
						
						fi
					fi
				done
			interlace -tL $recon_dir/$target_domain/js/live_waybackjs_link.txt -threads $IN_JS_SECRET_FIND -c "python3 $tools/SecretFinder/SecretFinder.py -i _target_ -o cli >> $recon_dir/$target_domain/js/waybackjs_link_srcrets.txt" -v
		fi
	else
		echo "js find false"
	fi
}

function checkWAF(){
	if [[ $CHECK_WAF == "true" ]]; then
		echo "start check WAF"
		interlace -tL $recon_dir/$target_domain/webs/webs.txt -threads 5 -c "wafw00f  _target_ >> $recon_dir/$target_domain/.tmp/wafw00f.txt" -v
		cat $recon_dir/$target_domain/.tmp/wafw00f.txt | grep "The site" | anew $recon_dir/$target_domain/hosts/waf.txt
	else
		echo "check WAF false"
	fi
}

function ips(){
	if [[ $IPS == "true" ]]; then
		echo "start IPS scan"
		interlace -tL $recon_dir/$target_domain/subdomain/subdomains.txt -threads 5 -c "dig _target_ | egrep  '^_target_' | anew >> $recon_dir/$target_domain/.tmp/ips.txt" -v
		interlace -tL $recon_dir/$target_domain/subdomain/subdomains.txt -threads 5 -c "cat $recon_dir/$target_domain/.tmp/ips.txt | grep '^_target_' | egrep '([0-9]{1,3}[\.]){3}[0-9]{1,3}' | awk '{print \$1,\$5}' | anew >> $recon_dir/$target_domain/.tmp/ips_v4.txt" -v
		cat $recon_dir/$target_domain/.tmp/ips_v4.txt | anew $recon_dir/$target_domain/hosts/sub_ips_v4.txt
		interlace -tL $recon_dir/$target_domain/subdomain/subdomains.txt -threads 5 -c "cat $recon_dir/$target_domain/.tmp/ips.txt | grep '_target_' | egrep '(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-    fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}    |[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9    ])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))' | awk '{print \$1,\$5}' >> $recon_dir/$target_domain/.tmp/ips_v6.txt" -v
		cat $recon_dir/$target_domain/.tmp/ips_v6.txt | anew $recon_dir/$target_domain/hosts/sub_ips_v6.txt
		
		cat $recon_dir/$target_domain/hosts/sub_ips_v4.txt | egrep -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" | anew $recon_dir/$target_domain/hosts/ips_v4.txt
		cat $recon_dir/$target_domain/hosts/sub_ips_v6.txt | egrep -o "(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))" | anew $recon_dir/$target_domain/hosts/ips_v6.txt

		cat $recon_dir/$target_domain/hosts/ips_v4.txt $recon_dir/$target_domain/hosts/ips_v6.txt | anew $recon_dir/$target_domain/hosts/ips.txt
	else
		echo "IPS false "
	fi
}

function cidr_recon(){

	mkdir -p $recon_dir/$target_domain/cidr
	mkdir -p $recon_dir/$target_domain/cidr/nmap

#	for ip_list in $(cat $recon_dir/$target_domain/.tmp/ipcidr_to_ip_list.txt)
#	do
#		result=$(ping -c 2 -W 1 -q $ip_list | grep transmitted)
#		pattern="2 received";
#		
#		 	recived_result=$(echo "$result" | grep "$pattern")
#			#echo $recived_result
#		 	if [[ -n $recived_result ]]; then
#			 	#echo "живой хост $result"
#				echo $ip_list | anew $recon_dir/$target_domain/cidr/live_ip.txt
#			fi
#		
#	done

	ports=$(cat $recon_dir/$target_domain/.tmp/ipcidr_to_ip_list.txt | naabu -silent -p $SCAN_PORT_NAABU_PORTS_LIST | cut -d ':' -f 2 | anew |  tr '\n' ',' | sed s/,$//) && nmap -iL $recon_dir/$target_domain/.tmp/ipcidr_to_ip_list.txt -p $ports -sV -Pn -sC --script='vulners, http-waf-detect, http-security-headers, dns-zone-transfer, http-cross-domain-policy, http-title, whois-ip' --script-args='mincvss=5.0' -oA $recon_dir/$target_domain/cidr/nmap/nmap_scan --stylesheet https://raw.githubusercontent.com/honze-net/nmap-bootstrap-xsl/master/nmap-bootstrap.xsl


}


function testssl(){
	if [[ $TESTSSL == "true" ]]; then
		echo "start TESTSSL "
		mkdir $recon_dir/$target_domain/hosts/testssl
		interlace -tL $recon_dir/$target_domain/hosts/ips.txt -threads 5 -c "$tools/testssl/testssl.sh --quiet --color 0 -U --warnings=batch _target_ >> $recon_dir/$target_domain/hosts/testssl/_target_.txt" -v
	else
		echo "test SSL false"
	fi
}

function scan_port(){
	if [[ $SCAN_PORT_GENERAL == "true" ]]; then
		echo "start scan port"
		mkdir -p $recon_dir/$target_domain/scan/nmap
		ports=$(cat $recon_dir/$target_domain/hosts/ips_v4.txt | naabu -silent -p $SCAN_PORT_NAABU_PORTS_LIST | cut -d ':' -f 2 | anew |  tr '\n' ',' | sed s/,$//) && nmap -iL $recon_dir/$target_domain/hosts/ips_v4.txt -p $ports -sV -Pn -sC --script='vulners, http-waf-detect, http-security-headers, dns-zone-transfer, http-cross-domain-policy, http-title, whois-ip' --script-args='mincvss=5.0' -oA $recon_dir/$target_domain/scan/nmap/$target_domain --stylesheet https://raw.githubusercontent.com/honze-net/nmap-bootstrap-xsl/master/nmap-bootstrap.xsl
	else 
		echo " scan port false "
	fi
}

function ip2provider(){
	if [[ $IP_PROVIDER == "true" ]]; then
		echo " start ip provider"
		cd $tools/ip2provider
		cat $recon_dir/$target_domain/hosts/ips.txt | python3 ip2provider.py | anew $recon_dir/$target_domain/hosts/ip_provider.txt
		cd $recon_dir/$target_domain
	else 
		echo "ip provider false"
	fi
}

function nuclei_check(){
	if [[ $NUCLEI_CHECK == "true" ]]; then
		echo " start nuclei checks"

		mkdir -p $recon_dir/$target_domain/scan/nuclei_output
		
		cat $recon_dir/$target_domain/webs/webs_uncommon_ports.txt | nuclei -silent -t ~/nuclei-templates/ -severity info -r $dns_resolver -o $recon_dir/$target_domain/scan/nuclei_output/info.txt
		cat $recon_dir/$target_domain/webs/webs_uncommon_ports.txt | nuclei -silent -t ~/nuclei-templates/ -severity low -r $dns_resolver -o $recon_dir/$target_domain/scan/nuclei_output/low.txt
		cat $recon_dir/$target_domain/webs/webs_uncommon_ports.txt | nuclei -silent -t ~/nuclei-templates/ -severity medium -r $dns_resolver -o $recon_dir/$target_domain/scan/nuclei_output/medium.txt
		cat $recon_dir/$target_domain/webs/webs_uncommon_ports.txt | nuclei -silent -t ~/nuclei-templates/ -severity high -r $dns_resolver -o $recon_dir/$target_domain/scan/nuclei_output/high.txt
		cat $recon_dir/$target_domain/webs/webs_uncommon_ports.txt | nuclei -silent -t ~/nuclei-templates/ -severity critical -r $dns_resolver -o $recon_dir/$target_domain/scan/nuclei_output/critical.txt
	else
		echo " nuclei false"
	fi
}

function header_sec(){
	if [[ $HEADER_SECURITU_CHECK == "true" ]]; then
		echo " start header sec "
		cat $recon_dir/$target_domain/webs/webs_uncommon_ports.txt | egrep -o '[a-z0-9.-]*[:][0-9]*$' | anew >  $recon_dir/$target_domain/.tmp/header_sec.txt
		cd $tools/h2t
		interlace -tL $recon_dir/$target_domain/.tmp/header_sec.txt -threads 5 -c "./h2t.py scan _target_ -B -k -p description  >  $recon_dir/$target_domain/scan/header_sec/_target_.txt" -v
	
		cd $recon_dir/$target_domain/
	else
		echo "header security false"
	fi
}

function header_grep(){
	
	if [[ $HEADER_GREP == "true" ]]; then
		echo " start header grep "
		mkdir -p $recon_dir/$target_domain/scan/header
		cat $recon_dir/$target_domain/webs/webs_uncommon_ports.txt | egrep -o '[a-z0-9.-]*[:][0-9]*$' > $recon_dir/$target_domain/.tmp/header_grep.txt
		interlace -tL $recon_dir/$target_domain/.tmp/header_grep.txt -threads 5 -c "curl -A '$HEADER' -I _target_  -o $recon_dir/$target_domain/scan/header/_target_.txt" -v
	else
		echo "header grep false"
	fi
}

function webtehnologies(){
	if [[ $CHECK_WEBTEHNOLOGIES == "true" ]]; then
		echo " start check webtechnologies"
		echo "$reconwtf_dir"
		mkdir -p $recon_dir/$target_domain/scan/webtechnologies
		interlace -tL $recon_dir/$target_domain/webs/webs_uncommon_ports.txt -threads 5 -c "webanalyze -host _target_ -apps $reconwtf_dir/technologies.json -silent -redirect -crawl 10 >> $recon_dir/$target_domain/scan/webtechnologies/webtehnologies.txt" -v
		rm $reconwtf_dir/*.json
		echo " start check nuclei webtechnologies"
		#cat $recon_dir/$target_domain/webs/webs_uncommon_ports.txt | nuclei -silent -t ~/nuclei-templates/technologies -r $dns_resolver -o $recon_dir/$target_domain/scan/webtechnologies/nuclei_webtehnologies.txt
	else
		echo "webtechnologies false"
	fi
}

function fuzzing(){
	if [[ $FFUZING == "true" ]]; then
	echo "FFUZING start"
		mkdir -p $recon_dir/$target_domain/fuzzing
		interlace -tL $recon_dir/$target_domain/webs/webs_uncommon_ports.txt -threads $IN_FFUZING -c "ffuf -mc all -fc 404 -ac -t $FFUF_TIME -sf -s -H '$header_cookie' -w ${fuzzing_list} -maxtime $FFUF_MAXTIME -u _target_/FUZZ -of csv -o $recon_dir/$target_domain/fuzzing/_cleantarget_.csv -ac" -o fuzzing
		cat $recon_dir/$target_domain/fuzzing/*.csv | cut -d ',' -f2,5,6 | tr ',' ' ' | awk '{ print $2 " " "" $1}' | tail -n +2 | sort -k1 | anew -q $recon_dir/$target_domain/fuzzing/ffuz_out.txt
		rm -r $recon_dir/$target_domain/fuzzing/*.csv
	else
		echo "ffuzzing false"
	fi
}

function url_gf(){
	if [[ $GF == "true" ]]; then
		echo "start GF"
		gf xss $recon_dir/$target_domain/webs/url_extract.txt | anew -q $recon_dir/$target_domain/gf/xss.txt
		gf ssti $recon_dir/$target_domain/webs/url_extract.txt | anew -q $recon_dir/$target_domain/gf/ssti.txt
		gf ssrf $recon_dir/$target_domain/webs/url_extract.txt | anew -q $recon_dir/$target_domain/gf/ssrf.txt
		gf sqli $recon_dir/$target_domain/webs/url_extract.txt | anew -q $recon_dir/$target_domain/gf/sqli.txt
		gf idor $recon_dir/$target_domain/webs/url_extract.txt | anew -q $recon_dir/$target_domain/gf/idor.txt
		gf base64 $recon_dir/$target_domain/webs/url_extract.txt | anew -q $recon_dir/$target_domain/gf/base64.txt
		gf debug_logic $recon_dir/$target_domain/webs/url_extract.txt | anew -q $recon_dir/$target_domain/gf/debug_logic.txt
		gf s3-buckets $recon_dir/$target_domain/webs/url_extract.txt | anew -q $recon_dir/$target_domain/gf/s3-buckets.txt
		gf interestingparams $recon_dir/$target_domain/webs/url_extract.txt | anew -q $recon_dir/$target_domain/gf/interestingparams.txt
		gf redirect $recon_dir/$target_domain/webs/url_extract.txt | anew -q $recon_dir/$target_domain/gf/redirect.txt && cat $recon_dir/$target_domain/gf/ssrf.txt | anew -q $recon_dir/$target_domain/gf/redirect.txt
		gf rce $recon_dir/$target_domain/webs/url_extract.txt | anew -q $recon_dir/$target_domain/gf/rce.txt
		gf potential $recon_dir/$target_domain/webs/url_extract.txt | cut -d ':' -f3-5 |anew -q $recon_dir/$target_domain/gf/potential.txt
		cat $recon_dir/$target_domain/webs/url_extract.txt | egrep -iv "\.(eot|jpg|jpeg|gif|css|tif|tiff|png|ttf|otf|woff|woff2|ico|pdf|svg|txt|js)$" | unfurl -u format %s://%d%p | anew -q $recon_dir/$target_domain/gf/endpoints.txt
		gf lfi $recon_dir/$target_domain/webs/url_extract.txt | anew -q $recon_dir/$target_domain/gf/lfi.txt
	else
		echo "GF false"
	fi
}


function url_ext_file(){
	if [[ $URL_EXTRACT_FILE == "true" ]]; then
		echo "start URL exctract files"
		cat $recon_dir/$target_domain/webs/url_extract.txt | egrep -Ei "\.(7z|achee|action|adr|apk|arj|ascx|asmx|asp|aspx|axd|backup|bak|bat|bin|bkf|bkp|bok|cab|cer|cfg|cfm|cfml|cgi|cnf|conf|config|cpl|crt|csr|csv|dat|db|dbf|deb|dmg|dmp|doc|docx|drv|email|eml|emlx|env|exe|gadget|gz|html|ica|inf|ini|iso|jar|java|jhtml|json|jsp|key|log|lst|mai|mbox|mbx|md|mdb|msg|msi|nfs|ods|otf|old|ora|ost|pac|passwd|pcf|pdf|pem|pgp|php|php3|php4|php5|phtm|phtml|pkg|pl|plist|pst|pwd|py|rar|rb|rdp|reg|rpm|rtf|sav|sh|shtm|shtml|skr|sql|swf|sys|tar|tar.gz|tmp|toats|tpl|txt|url|vcd|vcf|wml|wpd|wsdl|wsf|xls|xlsm|xlsx|xml|xsd|yaml|yml|z|zip)$" | anew  $recon_dir/$target_domain/webs/urls_by_file.txt
	else
		echo " url files extract false"
	fi
}

function domain_info(){
	if [[ $DOMAIN_INFO == "true" ]]; then
		echo "start domain info"
		lynx -dump "https://domainbigdata.com/${domain}" | tail -n +19 > osint/domain_info_general.txt
		if [ -s "osint/domain_info_general.txt" ]; then
			cat osint/domain_info_general.txt | grep '/nj/' | tr -s ' ' ',' | cut -d ',' -f3 > .tmp/domain_registrant_name.txt
			cat osint/domain_info_general.txt | grep '/mj/' | tr -s ' ' ',' | cut -d ',' -f3 > .tmp/domain_registrant_email.txt
			cat osint/domain_info_general.txt | grep -E "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | grep "https://domainbigdata.com" | tr -s ' ' ',' | cut -d ',' -f3 > .tmp/domain_registrant_ip.txt
		fi
		sed -i -n '/Copyright/q;p' osint/domain_info_general.txt
	else
		echo "domain info false"
	fi
}

function emaifind(){
	if [[ $EMAILFIND == "true" ]]; then
		echo "start email find"
		interlace -tL $recon_dir/$target_domain/subdomain/subdomains.txt -threads 5 -c "emailfinder -d _target_ | anew $recon_dir/$target_domain/.tmp/emailfinder.txt" -v

		interlace -tL $recon_dir/$target_domain/subdomain/subdomains.txt -threads 5 -c "python3 $tools/theHarvester/theHarvester.py -d _target_ -b all | anew $recon_dir/$target_domain/.tmp/theharvester.txt"

		if [ -s "$recon_dir/$target_domain/.tmp/theharvester.txt" ]; then

			cat $recon_dir/$target_domain/.tmp/theharvester.txt | awk '/Emails/,/Hosts/' | sed -e '1,2d' | head -n -2 | sed -e '/Searching /d' -e '/exception has occurred/d' -e '/found:/Q' | anew -q $recon_dir/$target_domain/osint/emails.txt

		cat $recon_dir/$target_domain/.tmp/theharvester.txt | awk '/Users/,/IPs/' | sed -e '1,2d' | head -n -2 | sed -e '/Searching /d' -e '/exception has occurred/d' -e '/found:/Q' | anew -q $recon_dir/$target_domain/osint/users.txt
		
		cat $recon_dir/$target_domain/.tmp/theharvester.txt | awk '/Links/,/Users/' | sed -e '1,2d' | head -n -2 | sed -e '/Searching /d' -e '/exception has occurred/d' -e '/found:/Q' | anew -q $recon_dir/$target_domain/osint/linkedin.txt	
		
		fi
	
		h8mail -t $target_domain -q domain --loose -c $tools/h8mail_config.ini -j $recon_dir/$target_domain/.tmp/h8_results.json
		cat $recon_dir/$target_domain/.tmp/h8_results.json | jq -r '.targets[0] | .data[] | .[]' | cut -d '-' -f2 | anew -q $recon_dir/$target_domain/osint/h8mail.txt
	else
		echo "email find false "
	fi
}

function google_dorks(){
	if [[ $GOOGLE_DORKS == "true" ]]; then
		echo 'start google dorcs'
		$tools/degoogle_hunter/degoogle_hunter.sh $target_domain | tee $recon_dir/$target_domain/osint/google_dorks.txt
		sed -r -i "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" $recon_dir/$target_domain/osint/google_dorks.txt
	else
		echo "google dorcks false"
	fi
}

function github_dorks(){
	if [[ $GITHUB_DORKS == "true" && $GITHUB_DORKS != "XXXXXXXXXXXXXXXXXXXXXXXX" ]]; then
		echo "start github dorcs"
		python3 $tools/GitDorker/GitDorker.py -t $GITHUB_TOKEN -e 5 -q $target_domain -p -ri -d "$tools/GitDorker/Dorks/alldorksv3" | grep "\[+\]" | grep "git" | anew -q $recon_dir/$target_domain/osint/gitdorks.txt

		sed -r -i "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" osint/gitdorks.txt
	else
		echo "git dorcs false"
	fi
}

function metadata(){
	if [[ $METADATA == "true" ]]; then
		echo "start metadata"
		metafinder -d "$target_domain" -l $IN_METADATA -o $recon_dir/$target_domain/osint -go -bi -ba
	else
		echo "metadata false"
	fi
}

function CMSeek(){
	if [[ $CMS_SECURITY == "true" ]]; then
		echo "Cms SEc start"
		mkdir -p $recon_dir/$target_domain/scan/CMSeeK
		interlace -tL $recon_dir/$target_domain/subdomain/subdomains.txt -threads 5 -c "python3 $tools/CMSeeK/cmseek.py -u _target_ --follow-redirect --random-agent" -v
		
		#cat cms.json | jq ".cms_id" | tr -d '"'
		for dirlist in $(ls $tools/CMSeeK/Result/)
		do
			cms_id=$(cat $tools/CMSeeK/Result/$dirlist/cms.json | jq ".cms_id" | tr -d '"')
			if [[ -n $cms_id ]]; then
				mkdir -p $recon_dir/$target_domain/scan/CMSeeK/$dirlist
				cp -r $tools/CMSeeK/Result/$dirlist/cms.json $recon_dir/$target_domain/scan/CMSeeK/$dirlist/cms.json
			fi
		done

		rm -r $tools/CMSeeK/Result/*

	else
		echo "cms security false"
	fi
}


function cors(){
	python3 $tools/Corsy/corsy.py -i $recon_dir/$target_domain/webs/webs.txt > $recon_dir/$target_domain/webs/cors.txt

}

function openreditrct(){
	cat $recon_dir/$target_domain/gf/redirect.txt | qsreplace FUZZ | anew -q $recon_dir/$target_domain/.tmp/tmp_redirect.txt
	python3 $tools/OpenRedireX/openredirex.py -l $recon_dir/$target_domain/.tmp/tmp_redirect.txt --keyword FUZZ -p $tools/OpenRedireX/payloads.txt| grep "^http" > $recon_dir/$target_domain/vulns/redirect.txt

}

function x4xxbypass(){

	cat $recon_dir/$target_domain/fuzzing/*.txt | grep -E '^4' | grep -Ev '^404' | cut -d ' ' -f3 | dirdar -only-ok > $recon_dir/$target_domain/.tmp/dirdar.txt
	cat $recon_dir/$target_domain/.tmp/dirdar.txt | sed -e '1,12d' | sed '/^$/d' | anew -q $recon_dir/$target_domain/vulns/4xxbypass.txt
}


function clearempity(){
	find . -type f -empty -exec rm {} \;
	find . -type d -empty -exec rmdir {} \;
}

function archive_scan(){
	if [ -d $recon_dir/$target_domain/archive ]; then
		# получаем и заполняем количество
		date=$(date +"%Y.%m.%d.%k")

		date_achive_scan=$(cat $recon_dir/$target_domain/archive/date.txt)
		
		echo "# $target_domain : $date_achive_scan : $date" > $recon_dir/$target_domain/README.md # очищаем readme для новых данных
		echo " " >> $recon_dir/$target_domain/README.md

		# попробуем забить циклом
		echo "| $target_domain | $date_achive_scan | $date |" >> $recon_dir/$target_domain/README.md
		echo "|----------------|-------------------|-------|" >> $recon_dir/$target_domain/README.md

		# Массив директорий

		arr[0]=cidr
  		arr[1]=fuzzing
		arr[2]=gf
		arr[3]=hosts
		arr[4]=js
		arr[5]=osint
		arr[6]=subdomain
		arr[7]=vulns
		arr[8]=webs
		arr[9]=scan/nuclei_output/
		arr[10]=scan/webtechnologies/
		#arr[11]=hosts/testssl/

		arr2[0]=screenshots/
		arr2[1]=js/jsfile/
		arr2[2]=scan/header_sec/
		arr2[3]=scan/CMSeeK/

		for item in ${arr[*]}
		do
			
			for i in $(ls -1 -R $item)
			do
				in=$(echo $i | grep -i ":$")
				if [[ $i == $in && $(echo $i | grep -io "jsfile") != "jsfile" ]]; then
					echo " " >> $recon_dir/$target_domain/README.md
					echo "| $in | $date_achive_scan | $date |" >> $recon_dir/$target_domain/README.md
					echo "|-----|-------------------|-------|" >> $recon_dir/$target_domain/README.md
				else
					if [[ $(echo $i) == $(echo $i | grep "\.txt") || $(echo $i | grep "jsfile") != $(echo $i | grep "jsfile") ]]; then
						dir=$(cd $item && pwd)
						dir_al_path=$(echo "$dir/$i")

						dir_a=$(cd archive/$item && pwd)
						dir_al_path_archive=$(echo "$dir_a/$i")
						
						if [[ -f $dir_al_path ]]; then
							count_file1="$(cat $dir_al_path | wc -l)"
							count_file2="$(cat $dir_al_path_archive | wc -l)"
							echo "| $i | $count_file1 | $count_file2 |" >> $recon_dir/$target_domain/README.md
						fi
					
					fi
				fi
			done

		done	

		for item2 in ${arr2[*]}
		do
			dir_path2=$(ls $recon_dir/$target_domain/$item2 | wc -l)
			dir_path2_archive=$(ls $recon_dir/$target_domain/$item2 | wc -l)

			echo " " >> $recon_dir/$target_domain/README.md
			echo "| $item2 | $date_achive_scan | $date |" >> $recon_dir/$target_domain/README.md
			echo "|--------|-------------------|-------|" >> $recon_dir/$target_domain/README.md

			echo "| File count | $dir_path2 | $dir_path2_archive |" >> $recon_dir/$target_domain/README.md

		done	
		

		# начинаем сравнивать через diff

		echo " " >> $recon_dir/$target_domain/README.md
		echo " " >> $recon_dir/$target_domain/README.md
		echo "# diff scaner : $date_achive_scan : $date " >> $recon_dir/$target_domain/README.md
		echo " " >> $recon_dir/$target_domain/README.md
		echo " " >> $recon_dir/$target_domain/README.md

		for item in ${arr[*]}
		do
			for i in $(ls -1 -R $item)
			do

				echo " " >> $recon_dir/$target_domain/README.md
				dir=$(cd $item && pwd)
				dir_al_path=$(echo "$dir/$i")

				dir_a=$(cd archive/$item && pwd)
				dir_al_path_archive=$(echo "$dir_a/$i")
						
				if [[ -f $dir_al_path ]]; then
					echo " " >> $recon_dir/$target_domain/README.md
					count_file1="$(diff $dir_al_path $dir_al_path_archive)"
					#count_file2="$(cat $dir_al_path_archive | wc -l)"
					if [[ $count_file1 == "" ]];then
						echo "" > /dev/null
					else
								
						echo "| $i | $date_achive_scan | $date |" >> $recon_dir/$target_domain/README.md
						echo "|----|-------------------|-------|" >> $recon_dir/$target_domain/README.md
						echo " " >> $recon_dir/$target_domain/README.md
						echo '```bash ' >> $recon_dir/$target_domain/README.md
						echo " $count_file1 " >> $recon_dir/$target_domain/README.md
						echo '``` ' >> $recon_dir/$target_domain/README.md
					fi
				fi
			done

		done

		for item2 in $(ls $recon_dir/$target_domain/js/jsfile)
		do
			js_file=$(cd $recon_dir/$target_domain/js/jsfile/$item2 && ls)
			for i in $js_file
			do	
				diff_to_js=$(diff $recon_dir/$target_domain/js/jsfile/$item2/$i $recon_dir/$target_domain/archive/js/jsfile/$item2/$i)
				if [[ $diff_to_js == "" ]]; then
					echo "" > /dev/null
				else

					echo "| $i | $date_achive_scan | $date |" >> $recon_dir/$target_domain/README.md
					echo "|----|-------------------|-------|" >> $recon_dir/$target_domain/README.md
					echo " " >> $recon_dir/$target_domain/README.md
					echo '```bash ' >> $recon_dir/$target_domain/README.md
					echo " $diff_to_js " >> $recon_dir/$target_domain/README.md
					echo '``` ' >> $recon_dir/$target_domain/README.md
				fi

			done

		done
	
		diff_to_imge=$(diff $recon_dir/$target_domain/screenshots $recon_dir/$target_domain/archive/screenshots)
		if [[ $diff_to_imge == "" ]]; then
			echo "" > /dev/null
		else
			echo " " >> $recon_dir/$target_domain/README.md
			echo "| screenshots | $date_achive_scan | $date |" >> $recon_dir/$target_domain/README.md
			echo "|-------------|-------------------|-------|" >> $recon_dir/$target_domain/README.md
			echo " " >> $recon_dir/$target_domain/README.md
			echo '```bash ' >> $recon_dir/$target_domain/README.md
			echo " $diff_to_imge " >> $recon_dir/$target_domain/README.md
			echo '``` ' >> $recon_dir/$target_domain/README.md
		fi

		# вшатываем папку архива и заново забиваем


		rm -r $recon_dir/$target_domain/archive/cidr
		rm -r $recon_dir/$target_domain/archive/fuzzing
		rm -r $recon_dir/$target_domain/archive/gf
		rm -r $recon_dir/$target_domain/archive/hosts
		rm -r $recon_dir/$target_domain/archive/js
		rm -r $recon_dir/$target_domain/archive/osint
		rm -r $recon_dir/$target_domain/archive/scan
		rm -r $recon_dir/$target_domain/archive/screenshots
		rm -r $recon_dir/$target_domain/archive/subdomain
		rm -r $recon_dir/$target_domain/archive/vulns
		rm -r $recon_dir/$target_domain/archive/webs

		mkdir -p $recon_dir/$target_domain/archive

		cp -r $recon_dir/$target_domain/cidr $recon_dir/$target_domain/archive/cidr
		cp -r $recon_dir/$target_domain/fuzzing $recon_dir/$target_domain/archive/fuzzing
		cp -r $recon_dir/$target_domain/gf $recon_dir/$target_domain/archive/gf
		cp -r $recon_dir/$target_domain/hosts $recon_dir/$target_domain/archive/hosts
		cp -r $recon_dir/$target_domain/js $recon_dir/$target_domain/archive/js
		cp -r $recon_dir/$target_domain/osint $recon_dir/$target_domain/archive/osint
		cp -r $recon_dir/$target_domain/scan $recon_dir/$target_domain/archive/scan
		cp -r $recon_dir/$target_domain/screenshots $recon_dir/$target_domain/archive/screenshots
		cp -r $recon_dir/$target_domain/subdomain $recon_dir/$target_domain/archive/subdomain
		cp -r $recon_dir/$target_domain/vulns $recon_dir/$target_domain/archive/vulns
		cp -r $recon_dir/$target_domain/webs $recon_dir/$target_domain/archive/webs

		date=$(date +"%Y.%m.%d.%k")
		touch $recon_dir/$target_domain/archive/date.txt
		echo "$date" > $recon_dir/$target_domain/archive/date.txt

	else
		
		# создем архив
		mkdir $recon_dir/$target_domain/archive

		cp -r $recon_dir/$target_domain/cidr $recon_dir/$target_domain/archive/cidr
		cp -r $recon_dir/$target_domain/fuzzing $recon_dir/$target_domain/archive/fuzzing
		cp -r $recon_dir/$target_domain/gf $recon_dir/$target_domain/archive/gf
		cp -r $recon_dir/$target_domain/hosts $recon_dir/$target_domain/archive/hosts
		cp -r $recon_dir/$target_domain/js $recon_dir/$target_domain/archive/js
		cp -r $recon_dir/$target_domain/osint $recon_dir/$target_domain/archive/osint
		cp -r $recon_dir/$target_domain/scan $recon_dir/$target_domain/archive/scan
		cp -r $recon_dir/$target_domain/screenshots $recon_dir/$target_domain/archive/screenshots
		cp -r $recon_dir/$target_domain/subdomain $recon_dir/$target_domain/archive/subdomain
		cp -r $recon_dir/$target_domain/vulns $recon_dir/$target_domain/archive/vulns
		cp -r $recon_dir/$target_domain/webs $recon_dir/$target_domain/archive/webs
		# gf hosts js osint scan screenshots subdomain  vulns webs

		date=$(date +"%Y.%m.%d.%k")
		touch $recon_dir/$target_domain/archive/date.txt
		echo "$date" > $recon_dir/$target_domain/archive/date.txt

	fi
}

function archive_md_lists(){

	date=$(date +"%Y.%m.%d.%k")

	mkdir -p $recon_dir/$target_domain/archive/back_md
	mkdir -p $recon_dir/$target_domain/archive/back_md/$date
	cp $recon_dir/$target_domain/README.md $recon_dir/$target_domain/archive/back_md/$date/README.md
	cp $recon_dir/$target_domain/CheckList.md $recon_dir/$target_domain/archive/back_md/$date/CheckList.md

}

function github_get_private_scan(){
	if [[ $git_add == "true" ]]; then
		if [ -f $recon_dir/.git/index ]; then
			cd $recon_dir
			date=$(date)
			echo "**/.tmp" > .gitignore
			git add .
			git commit -m "$date"
			git push  https://$you_git_acces_token@github.com/$you_git_username/$private_git_repos_name.git
			cd $reconwtf_dir
		else
			cd $recon_dir
			git init
			touch .gitignore
			echo "**/.tmp" > .gitignore
			git remote add origin https://github.com/$you_git_username/$private_git_repos_name.git
			git add .
			git commit -m "private recon repo init"
			git push  https://$you_git_acces_token@github.com/$you_git_username/$private_git_repos_name.git
			cd $reconwtf_dir
		fi
	else
		echo "No push recon result to github repositories"
	fi
}



function init(){ # инициализация разведки на основе введенных параметров
	if [[ -n $check_all_tools ]]; then
		check_tools
	fi
	if [[ -n $install_tools ]]; then
		install_tools
	fi
	check_tools
	tools_update_resurce
	preliminary_actions
	if [[ -n $passive  ]]; then # только пасивные методы разведки не трогая цель
		Subdomain_enum_passive
		SubRresult
		webs
		scan_hosts_passive
		endpoint_enum_passive
		domain_info
		emaifind
		google_dorks
		github_dorks
		metadata
		clearempity
	elif [[ -n $active ]]; then # только активные методы сканирования
		Subdomain_enum_passive
		Subdomain_enum
		subdomain_permytation
		subdomain_bruteforce
		SubRresult
		webs
		zonetransfer_takeovers
		s3bucket
		scan_hosts
		visual_indentification
		endpoint_enum_passive
		endpoint_enum_agressive
		jsfind
		checkWAF
		ips
		testssl
		scan_port
		ip2provider
		nuclei_check
		header_sec
		header_grep
		webtehnologies
		fuzzing
		url_gf
		url_ext_file
		domain_info
		emaifind
		google_dorks
		github_dorks
		metadata
		x4xxbypass
		CMSeek
		clearempity
	elif [[ -n $recon_full ]]; then # разведка всеми методами активно пасивно осинт
		
		Subdomain_enum_passive
		Subdomain_enum
		subdomain_permytation
		subdomain_bruteforce
		SubRresult
		webs
		zonetransfer_takeovers
		s3bucket
		scan_hosts
		visual_indentification
		endpoint_enum_passive
		endpoint_enum_agressive
		jsfind
		checkWAF
		ips
		cidr_recon
		testssl
		scan_port
		ip2provider
		nuclei_check
		header_sec
		header_grep
		webtehnologies
		fuzzing
		url_gf
		url_ext_file
		domain_info
		emaifind
		google_dorks
		github_dorks
		metadata
		cors
		openreditrct
		x4xxbypass
		CMSeek
		clearempity
	elif [[ -n $osint ]]; then # запустить только осинт цели трогая ее сканированиями
		Subdomain_enum_passive
		SubRresult
		webs
		ips
		domain_info
		emaifind
		google_dorks
		github_dorks
		metadata
		clearempity
	elif [[ -n $subdomain_serch ]]; then # найти субдомены всеми сканированиями и пасивно и активно
		Subdomain_enum_passive
		Subdomain_enum
		subdomain_permytation
		subdomain_bruteforce
		SubRresult
		zonetransfer_takeovers
		checkWAF
		s3bucket
		clearempity

	fi
	
	archive_scan
	archive_md_lists
	github_get_private_scan
}

init # запуск главной функции
