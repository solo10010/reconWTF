#!/bin/bash

# interlaces fix https://github.com/codingo/Interlace/issues/156
eval . ./config.conf # defaul config file

function help(){
	echo ""
	echo " Применение: ./reconwtf.sh [options...] -d <domain> -m <companu tld>-l <list.txt> -x <scope.txt> 
			-c <cookie> -f <config.conf> -u <dir out> -r -s -p -a -o -v -h"
	echo ""
	echo "  -d, --domain 		<domain> 	целевой домен 'example.com' "
	echo "  -m, --company 	<name>		Название компании 'Tesla inc' Узнать https://www.whoxy.com/tesla.com"
	echo "  -x, --scope 		<scope.txt> 	Формат вне области применения \.vk.com очистить vk домены \vk.com очистить все vk.com"
	echo "  -g, --config		<config.conf>	конфигурационный файл '-g dir/config2.conf' "
	echo "  -c, --cookie 		<cookie>  	куки -c 'PHPSESSIONID=qweqweqwe'"
	echo "  -cidr, --cidr		<ip range>	целевой диапазон IP-адресов 192.49,128.0/16"
	echo "  -n, --name            <trget_name>    целевое имя, например vdp-inmpbi"
	echo ""
	echo "  -r, --recon-full	 		полная разведка цели (с применением атак) "
	echo "  -rs, --recon-speed	 		Быстрая разведка (только быстрые методы) "
	echo "  -s, --subdimain-search	 	только поиск субдоменов, разрешение и захват субдоменов "
	echo "  -p, --passive 			только пассивные методы, не влияющие на цель "
	echo "  -a, --active				полный интеллект с использованием атак "
	echo "  -o, --osint				минимальная разведка с использованием OSINT "
	echo ""
	echo "  -in, --install			Установить все инструменты "
	echo "  -ct, --check-tools			Убедитесь, что инструменты установлены правильно "
	echo ""
	echo "  -v, --version				reconWTF версия "
	echo "  -h, --help 				справка"
	echo ""
	echo "  Remember set your api keys:"
	echo ""
	echo "  subfinder 		|		(~/.config/subfinder/config.yaml)"
	echo "  amass 		|		(~/.config/amass/config.ini)"
	echo "  GitHub 		|		(~/Tools/.github_tokens)"
	echo "  SHODAN 		|		(SHODAN_API_KEY in reconWTF.cfg)"
	echo "  SSRF Server 		|		(COLLAB_SERVER in reconWTF.cfg)"
	echo "  Blind XSS Server 	|		(XSS_SERVER in reconWTF.cfg) "
	echo "  theHarvester 		|		(~/Tools/theHarvester/api-keys.yml)"
	echo "  H8mail 		|		(~/Tools/h8mail_config.ini)"
	echo "  sigurlfind3r 		|		(~/.config/sigurlfind3r/conf.yaml)"
	echo "  GoogleDorker 		|		($tools/GoogleDorker/google_dorker.yaml)"
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
	    echo " -d, --domain этот параметр должен иметь значение!"
	    echo "  -h, --help помощь по reconWTF"
	    exit
    fi
    ;;
    -m|--company) # название компании
    company="$2"
    shift # past argument
    shift # past value
    if [[ -z $company ]]
    then
	    echo " -c, --company  этот параметр должен иметь значение!"
	    echo "  -h, --help помощь по reconWTF"
	    exit
    fi
    ;;
	-cidr|--cidr) # диапазон ip цели 192.49,128.0/16
    cidr="$2"
    shift # past argument
    shift # past value
    if [[ -z $cidr ]]
    then
	    echo " -cidr, --cidr  целевой диапазон IP-адресов 192.49,128.0/16"
	    echo "  -h, --help помощь по reconWTF"
	    exit
    fi
    ;;
    -x|--scope) # список доменов в зоне видимости 
    scope_list="$2"
    shift # past argument
    shift # past value
    if [[ -z $scope_list ]]
    then
	    echo " -x, --scope этот параметр должен иметь значение!"
	    echo "  -h, --help помощь по reconWTF"
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
	-n|--name) # имя нашей прогаммы, если мы сканим много скоупа одной программы проше когда все под одним именем какталога
    name="$2"
    shift # past argument
    shift # past value
    if [[ -z $name ]]
    then
	    echo " -n, --name  имя цели, например target1"
	    echo "  -h, --help помощь по reconWTF"
	    exit
    fi
    ;;
    -r|--recon-full) # полная разведка без атак
    recon_full="$1"
    shift # past argument
    shift # past value
    ;;
	-rs|--recon-speed) # наиболее полная разведка но побыстрее
    recon_speed="$1"
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
	    echo " -c, --cookie этот параметр должен иметь значение!"
	    echo "  -h, --help помощь по reconWTF"
	    exit
    fi
    ;;
	-v|--version) # справка
    version="$2"
    shift # past argument
    shift # past value
    if [[ -z $version ]]
    then 
	    printf "\n reconWTF версия $reconWTF_version \n\n"
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
	    echo " Здесь нельзя использовать аргументы!!!"
	    echo "  Usage: reconwtf.sh -h, --help"
	    exit
    else
	help # функция вызывает показ справки
    fi
    ;;
    *)
    echo " флаг предоставлен, но не определен: ${key}"
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

# переопределяем переменную recon_dir папки рекона если передано имя программы
if [[ $name ]]; then
	    recon_dir="$recon_dir/$name"
	    mkdir -p $recon_dir
fi

see="sed -r 's/\[.+]//' | sed 's/ //g' | sed '/^$/d'" # убрать и STDIN [] \n \f []
DEBUG_FILE=$recon_dir/$target_domain/.tmp/debug #файл для дебага

# проверяем установлены ли инструменты
function check_tools(){

	printf "\n\n${bgreen}#######################################################################${reset}\n"
	printf "${bblue} Проверка установленных инструментов ${reset}\n\n"

	allinstalled=true

	[ -n "$GOPATH" ] || { printf "${bred} [*] GOPATH var		[NO]${reset}\n"; allinstalled=false;}
	[ -n "$GOROOT" ] || { printf "${bred} [*] GOROOT var		[NO]${reset}\n"; allinstalled=false;}
	[ -n "$PATH" ] || { printf "${bred} [*] PATH var		[NO]${reset}\n"; allinstalled=false;}
	[ -f "$tools/degoogle_hunter/degoogle.py" ] || { printf "${bred} [*] degoogle		[NO]${reset}\n"; allinstalled=false;}
	[ -f "$tools/pwndb/pwndb.py" ] || { printf "${bred} [*] fav-up		[NO]${reset}\n"; allinstalled=false;}
	[ -f "$tools/fav-up/favUp.py" ] || { printf "${bred} [*] fav-up		[NO]${reset}\n"; allinstalled=false;}
	[ -f "$tools/Corsy/corsy.py" ] || { printf "${bred} [*] Corsy		[NO]${reset}\n"; allinstalled=false;}
	[ -f "$tools/testssl/testssl.sh" ] || { printf "${bred} [*] testssl		[NO]${reset}\n"; allinstalled=false;}
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
	[ -f "$tools/DHVAdmin/dhv.sh" ] || { printf "${bred} [*] dhv.sh		[NO]${reset}\n"; allinstalled=false;}
	[ -f "$tools/GoogleDorker/dorker/dorker.py" ] || { printf "${bred} [*] GoogleDorker		[NO]${reset}\n"; allinstalled=false;}
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
	type -P gobuster &>/dev/null || { printf "${bred} [*] gobuster	[NO]${reset}\n"; allinstalled=false;}
	type -P httprobe &>/dev/null || { printf "${bred} [*] httprobe	[NO]${reset}\n"; allinstalled=false;}
	type -P mubeng &>/dev/null || { printf "${bred} [*] mubeng [NO]${reset}\n"; allinstalled=false;}
	type -P proxi &>/dev/null || { printf "${bred} [*] proxi  [NO]${reset}\n"; allinstalled=false;}
	type -P fff &>/dev/null || { printf "${bred} [*] fff  [NO]${reset}\n"; allinstalled=false;}
	type -P whatweb &>/dev/null || { printf "${bred} [*] whatweb  [NO]${reset}\n"; allinstalled=false;}
	type -P arjun &>/dev/null || { printf "${bred} [*] arjun  [NO]${reset}\n"; allinstalled=false;}
	type -P smap &>/dev/null || { printf "${bred} [*] smap  [NO]${reset}\n"; allinstalled=false;}
	
	

	if [ "${allinstalled}" = true ]; then
		printf "${bgreen} Хорошо! Все установлено! ${reset}\n\n"
	else
		printf "\n${yellow} Попробуйте запустить скрипт установки снова ./install.sh"
		printf "\n${yellow} Если что-то по какой-либо причине не устанавливается, попробуйте установить отдельно недостающие утилиты вручную"
		printf "\n${yellow} Не забудьте установить переменную ${bred}\$tools${yellow} в начале этого скрипта"
		printf "\n${yellow} Если ничего не помогает и мир готовится к концу, вы всегда можете написать мне :D ${reset}\n\n"
	fi

	printf "${bblue} Проверка инструментов завершена\n"
	printf "${bgreen}#######################################################################\n${reset}"

}

function install_tools(){
	
	declare -A gotools
	gotools["gf"]="go install -v github.com/tomnomnom/gf@latest"
	gotools["qsreplace"]="go install -v github.com/tomnomnom/qsreplace@latest"
	gotools["Amass"]="go install -v github.com/owasp-amass/amass/v4/...@master"
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
	gotools["httprobe"]="go install -v github.com/tomnomnom/httprobe@master"
	gotools["webanalyze"]="go install -v github.com/rverton/webanalyze/cmd/webanalyze@latest"
	gotools["cent"]="go install -v github.com/xm1k3/cent@latest"
	gotools["urlhunter"]="go install -v github.com/utkusen/urlhunter@latest"
	gotools["xurlfind3r"]="go install -v github.com/hueristiq/xurlfind3r/cmd/xurlfind3r@latest"
	gotools["hakrevdns"]="go install -v github.com/hakluke/hakrevdns@latest"
	gotools["gobuster"]="go install github.com/OJ/gobuster/v3@latest"
	gotools["kxss"]="go install github.com/Emoe/kxss@latest"
	gotools["proxi"]="go install github.com/nicksherron/proxi@latest"
	gotools["mubeng"]="go install ktbs.dev/mubeng/cmd/mubeng@latest"
	gotools["fff"]="go install github.com/tomnomnom/fff@latest"
	gotools["smap"]="go install -v github.com/s0md3v/smap/cmd/smap@latest"


	declare -A repos
	repos["degoogle_hunter"]="six2dez/degoogle_hunter"
	repos["pwndb"]="davidtavarez/pwndb"
	repos["dnsvalidator"]="vortexau/dnsvalidator"
	repos["theHarvester"]="laramies/theHarvester"
	repos["brutespray"]="x90skysn3k/brutespray"
	repos["wafw00f"]="EnableSecurity/wafw00f"
	repos["gf"]="tomnomnom/gf"
	repos["Gf-Patterns"]="1ndianl33t/Gf-Patterns"
	repos["github-search"]="gwen001/github-search"
	repos["ctfr"]="UnaPibaGeek/ctfr"
	repos["LinkFinder"]="dark-warlord14/LinkFinder"
	repos["Corsy"]="s0md3v/Corsy"
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
	repos["DHVAdmin"]="solo10010/DHVAdmin"
	repos["wordlist"]="solo10010/wordlist"
	repos["ParamSpider"]="0xKayala/ParamSpider"
	repos["solo-nuclei-templates"]="solo10010/solo-nuclei-templates"
	repos["GoogleDorker"]="sanjai-AK47/GoogleDorker"

	declare -A pip_tools
	pip_tools["dnsgen"]="dnsgen"
	pip_tools["argcomplete"]="argcomplete==1.10.0"
	pip_tools["lxml"]="lxml"
	pip_tools["flake8"]="flake8"
	pip_tools["pytest"]="pytest"
	pip_tools["colorclass"]="colorclass==2.2.0"
	pip_tools["beautifulsoup4"]="beautifulsoup4==4.12.2"
	pip_tools["shodan"]="shodan==1.30.0"
	pip_tools["mmh3"]="mmh3"
	pip_tools["ipwhois"]="ipwhois"
	pip_tools["argparse"]="argparse"
	pip_tools["tqdm"]="tqdm==4.62.3"
	pip_tools["fake-useragent"]="fake-useragent"
	pip_tools["termcolor"]="termcolor"
	pip_tools["certifi"]="certifi==2023.7.22"
	pip_tools["chardet"]="chardet==3.0.4"
	pip_tools["colorama"]="colorama==0.4.1"
	pip_tools["idna"]="idna==2.8"
	pip_tools["urllib3"]="urllib3"
	pip_tools["jsbeautifier"]="jsbeautifier"
	pip_tools["PySocks"]="PySocks==1.6.8"
	pip_tools["requests_file"]="requests_file"
	pip_tools["future"]="future"
	pip_tools["emailfinder"]="emailfinder"
	pip_tools["metafinder"]="metafinder"
	pip_tools["aiodns"]="aiodns==3.1.0"
	pip_tools["aiofiles"]="aiofiles==23.2.1"
	pip_tools["aiohttp"]="aiohttp==3.8.6"
	pip_tools["aiomultiprocess"]="aiomultiprocess==0.9.0"
	pip_tools["aiosqlite"]="aiosqlite==0.19.0"
	pip_tools["ujson"]="ujson==5.8.0"
	pip_tools["pyppeteer"]="pyppeteer==1.0.2"
	pip_tools["PyYAML"]="PyYAML==6.0.1"
	pip_tools["python-dateutil"]="python-dateutil==2.8.2"
	pip_tools["retrying"]="retrying==1.3.4"
	pip_tools["setuptools"]="setuptools==68.2.2"
	pip_tools["slowapi"]="slowapi==0.1.8"
	pip_tools["uvicorn"]="uvicorn==0.23.2"
	pip_tools["fastapi"]="fastapi==0.103.2"
	pip_tools["censys"]="censys==2.2.7"
	pip_tools["arjun"]="arjun"
	pip_tools["google_api_python"]="google_api_python_client==2.98.0"


	dir=${tools}
	double_check=false

	if grep -q "ARMv"  /proc/cpuinfo
	then
	IS_ARM="True";
	else
	IS_ARM="False";
	fi

	printf "\n\n${bgreen}#######################################################################${reset}\n"
	printf "${bgreen} Скрипт установки/обновления reconWTF ${reset}\n\n"
	printf "${yellow} Это может занять некоторое время. Так что возьмите кофе! ${reset}\n\n"

	if [[ $(id -u | grep -o '^0$') == "0" ]]; then
		SUDO=" "
	else
		if sudo -n false 2>/dev/null; then
			printf "${bred} Сильно рекомендуется добавить своего пользователя в sudoers${reset}\n"
			printf "${bred} Это избавит вас от запросов пароля sudo во время установки${reset}\n"
			printf "${bred} И, что более важно, во время сканирования (необходимо для SYN-сканирования nmap)${reset}\n\n"
			printf "${bred} echo \"${USERNAME}  ALL=(ALL:ALL) NOPASSWD: ALL\" > /etc/sudoers.d/reconWTF${reset}\n\n"
		fi
		SUDO="sudo"
	fi

	if [ -f /etc/debian_version ]; then 
		printf "${bblue} Выполняется: Установка системных пакетов apt ${reset}\n\n"
		eval $SUDO apt update -y $DEBUG_STD
		eval $SUDO DEBIAN_FRONTEND="noninteractive" apt install chromium-browser -y $DEBUG_STD
		eval $SUDO DEBIAN_FRONTEND="noninteractive" apt install chromium -y $DEBUG_STD
		eval $SUDO DEBIAN_FRONTEND="noninteractive" apt install python3 whatweb python3-pip build-essential gcc cmake ruby git curl libpcap-dev wget zip python3-dev pv dnsutils libssl-dev libffi-dev libxml2-dev libxslt1-dev zlib1g-dev nmap jq apt-transport-https lynx tor medusa xvfb prips -y $DEBUG_STD
		eval $SUDO systemctl enable tor $DEBUG_STD
	elif [ -f /etc/redhat-release ]; then
		printf "${bblue} Выполняется: Установка системных пакетов yum ${reset}\n\n"
		eval $SUDO yum groupinstall "Development Tools" -y $DEBUG_STD
    	eval $SUDO yum install chromium python3 whatweb python3-pip gcc cmake ruby git curl libpcap-dev wget zip python3-devel pv bind-utils libopenssl-devel libffi-devel libxml2-devel libxslt-devel zlib-devel nmap jq lynx tor medusa xorg-x11-server-xvfb prips -y $DEBUG_STD
	elif [ -f /etc/arch-release ]; then
		printf "${bblue} Выполняется: Установка системных пакетов pacman ${reset}\n\n"
		curl -O https://blackarch.org/strap.sh $DEBUG_STD
		chmod +x strap.sh $DEBUG_STD
		sudo ./strap.sh $DEBUG_STD
		rm ./strap.sh

		eval $SUDO pacman -Syu --noconfirm $DEBUG_STD
		eval $SUDO pacman -S --noconfirm --overwrite  python3 whatweb parallel go python python-pip base-devel gcc cmake ruby git curl libpcap wget zip nmap chromium lynx pv bind openssl libffi libxml2 libxslt zlib nmap jq tor medusa xorg-server-xvfb -y $DEBUG_STD
    	#eval $SUDO systemctl enable --now tor.service $DEBUG_STD
	elif [ -f /etc/os-release ]; then install_yum;  #/etc/os-release fall in yum for some RedHat and Amazon Linux instances
		printf "${bblue} Выполняется: Установка системных пакетов yum ${reset}\n\n"
		eval $SUDO yum groupinstall "Development Tools" -y $DEBUG_STD
    	eval $SUDO yum install chromium python3 python3-pip whatweb gcc cmake ruby git curl libpcap-dev wget zip python3-devel pv bind-utils libopenssl-devel libffi-devel libxml2-devel libxslt-devel zlib-devel nmap jq lynx tor medusa xorg-x11-server-xvfb prips -y $DEBUG_STD
	fi

	eval git config --global --unset http.proxy $DEBUG_STD
	eval git config --global --unset https.proxy $DEBUG_STD




# Installing latest Golang version
version=$(curl -L -s "https://go.dev/VERSION?m=text" | head -n 1)
#version="go1.20.6"
printf "${bblue} Запуск: установка/обновление Golang ${reset}\n\n"
if [[ $(eval type go $DEBUG_ERROR | grep -o 'go is') == "go is" ]] && [ "$version" = $(go version | cut -d " " -f3) ]
    then
        printf "${bgreen} Golang уже установлен и обновлен. ${reset}\n\n"
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

[ -n "$GOPATH" ] || { printf "${bred} Переменная окружения GOPATH не обнаружена, добавьте переменные окружения Golang в свой \$HOME/.bashrc or \$HOME/.zshrc:\n\n export GOROOT=/usr/local/go\n export GOPATH=\$HOME/go\n export PATH=\$GOPATH/bin:\$GOROOT/bin:\$PATH\n\n"; exit 1; }
[ -n "$GOROOT" ] || { printf "${bred} Переменная окружения GOROOT не обнаружена, добавьте переменные окружения Golang в свой \$HOME/.bashrc or \$HOME/.zshrc:\n\n export GOROOT=/usr/local/go\n export GOPATH=\$HOME/go\n export PATH=\$GOPATH/bin:\$GOROOT/bin:\$PATH\n\n"; exit 1; }
printf "${bblue} Выполняется: установка требований ${reset}\n\n"

mkdir -p ~/.gf
mkdir -p $tools
mkdir -p ~/.config/notify/
mkdir -p ~/.config/amass/
mkdir -p ~/.config/nuclei/
touch $dir/.github_tokens

#eval wget -N -c https://bootstrap.pypa.io/get-pip.py $DEBUG_STD && eval python3 get-pip.py $DEBUG_STD
#eval rm -f get-pip.py $DEBUG_STD
#eval ln -s /usr/local/bin/pip3 /usr/bin/pip3 $DEBUG_STD

printf "${bblue} Выполняется: установка инструментов Golang. (${#gotools[@]})${reset}\n\n"
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


printf "${bblue}\n Выполняется: установка требований pip3 (${#pip_tools[@]})${reset}\n\n"
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

# устанавливаем рекурсивно все зависимости из requirements.txt в папке утилиты во всех каталогов (навсякий случай)
printf "\n\n${bgreen}#######################################################################${reset}\n"
printf "${bgreen} reconWTF Устанавливаем рекурсивно все зависимсоти из каталога ${tools} ${reset}\n\n"

find . -name "requirements.txt" -exec readlink -f {} \; | xargs -n 1 -I {} pip3 install -r {} >/dev/null 2>&1

printf "${bblue}\n Выполняется: Установка репозиториев (${#repos[@]})${reset}\n\n"

eval git clone https://github.com/projectdiscovery/nuclei-templates ~/nuclei-templates $DEBUG_STD
eval git clone https://github.com/geeknik/the-nuclei-templates.git ~/nuclei-templates/extra_templates $DEBUG_STD
eval nuclei -update-templates $DEBUG_STD
cd ~/nuclei-templates/extra_templates && eval git pull $DEBUG_STD
cd "$dir" || { echo "Failed to cd to $dir in ${FUNCNAME[0]} @ line ${LINENO}"; exit 1; }
eval sed -i 's/^#random-agent: false/random-agent: true/' ~/.config/nuclei/config.yaml $DEBUG_ERROR
eval git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git $dir/sqlmap $DEBUG_STD

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
        printf "${red} Невозможно установить $repo, попробуйте вручную (${repos_step}/${#repos[@]})${reset}\n"
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
            eval cp *.json ~/.gf $DEBUG_ERROR
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
        eval wget -N -c https://github.com/Findomain/Findomain/releases/download/9.0.0/findomain-armv7.zip  $DEBUG_STD
        eval unzip findomain-armv7.zip
		eval $SUDO mv findomain /usr/bin/findomain
    else
        eval wget -N -c https://github.com/Findomain/Findomain/releases/download/9.0.0/findomain-linux.zip $DEBUG_STD
        eval wget -N -c https://github.com/sensepost/gowitness/releases/download/2.3.4/gowitness-2.3.4-linux-amd64 $DEBUG_STD
        eval wget -N -c https://github.com/Edu4rdSHL/unimap/releases/download/0.4.0/unimap-linux $DEBUG_STD
        eval $SUDO mv gowitness-2.3.4-linux-amd64 /usr/bin/gowitness
		eval unzip findomain-linux.zip
        eval $SUDO mv findomain /usr/bin/findomain
        eval $SUDO mv unimap-linux /usr/bin/unimap
fi
eval $SUDO chmod 755 /usr/bin/findomain
eval $SUDO chmod 755 /usr/bin/gowitness
eval $SUDO chmod 755 /usr/bin/unimap
eval subfinder $DEBUG_STD
eval subfinder $DEBUG_STD

printf "${bblue}\n Выполняется: Загрузка необходимых файлов. ${reset}\n\n"
## Downloads
eval wget -nc -O ~/.config/amass/config.ini https://raw.githubusercontent.com/OWASP/Amass/master/examples/config.ini $DEBUG_STD
eval wget -nc -O ~/.gf/potential.json https://raw.githubusercontent.com/devanshbatham/ParamSpider/master/gf_profiles/potential.json $DEBUG_STD
eval wget -nc -O ~/.config/notify/notify.conf https://gist.githubusercontent.com/six2dez/23a996bca189a11e88251367e6583053/raw/a66c4d8cf47a3bc95f5e9ba84773428662ea760c/notify_sample.conf $DEBUG_STD
mkdir -p wordlist
mkdir -p single-tools

eval wget -nc -O wordlist/subdomains_big.txt https://wordlists-cdn.assetnote.io/data/manual/best-dns-wordlist.txt $DEBUG_STD
eval wget -nc -O wordlist/dir_list_smal.txt https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/Web-Content/directory-list-2.3-small.txt $DEBUG_STD

printf "${bblue}\n Устанавливаем trufflehog ${reset}\n\n"
curl -sSfL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh | sh -s -- -b /usr/local/bin

## Last check
if [ "$double_check" = "true" ]; then
    printf "${bblue} Выполняется: двойная проверка установленных инструментов. ${reset}\n\n"
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
				# Проверяем, существует ли файл .zshrc
				if [ -f "$zshrc_file" ]; then
					# Удаляем плагин git из списка расширений в .zshrc иначе gf не сможет работать
					sed -i '/^plugins=(/{s/ git//;}' "$zshrc_file"
					printf "${bblue} Плагин git был удален из списка расширений в .zshrc ${reset}\n\n"
				fi
        elif [ "Gf-Patterns" = "$repo" ]; then
                eval mv *.json ~/.gf $DEBUG_ERROR
        fi
        cd "$dir" || { echo "Failed to cd to $dir in ${FUNCNAME[0]} @ line ${LINENO}"; exit 1; }
    done
fi

printf "${bblue} Running: Performing last configurations ${reset}\n\n"
## Last steps
if [ ! -s "wordlist/resolvers.txt" ] || [ $(find "wordlist/resolvers.txt" -mtime +1 -print) ]; then
    printf "${yellow} Судя по всему, резолверы старше 1 дня.\n Создание пользовательских резолверов... ${reset}\n\n"
    eval rm -f wordlist/resolvers.txt &>/dev/null
    eval dnsvalidator -tL https://public-dns.info/nameservers.txt -threads 100 -o wordlist/resolvers.txt $DEBUG_STD
fi
eval h8mail -g $DEBUG_STD

## Stripping all Go binaries
eval strip -s $HOME/go/bin/* $DEBUG_STD

eval $SUDO cp $HOME/go/bin/* /usr/bin/ $DEBUG_STD

printf "${yellow} Remember set your api keys:\n - amass (~/.config/amass/config.ini)\n - subfinder (~/.config/subfinder/config.yaml)\n - GitHub (~/Tools/.github_tokens)\n - SHODAN (SHODAN_API_KEY in reconWTF.cfg)\n - SSRF Server (COLLAB_SERVER in reconWTF.cfg) \n - Blind XSS Server (XSS_SERVER in reconWTF.cfg) \n - notify (~/.config/notify/notify.conf) \n - theHarvester (~/Tools/theHarvester/api-keys.yml)\n - H8mail (~/Tools/h8mail_config.ini)\n sigurlfind3r (~/.config/sigurlfind3r/conf.yaml) \n\n ${reset}"
printf "${bgreen} Finished!${reset}\n\n"
printf "${bgreen} Check installed utilities${reset}\n\n"
printf "${bgreen} ./reconwtf.sh -ct${reset}\n\n"


printf "\n\n${bgreen}#######################################################################${reset}\n"

#eval sigurlfind3r $DEBUG_STD

#tools_update_resurce
#check_tools

#exit

# пример многострочного коментария

<< 'MULTILINE-COMMENT'

MULTILINE-COMMENT

}




function preliminary_actions(){ # предварительные действия создаем директорию цели итд..

	# проверяем нужено ли собрать dns resolver-ы
	if [[ $update_resolvers == "true" ]]; then
		echo "dnsvalidator gen dnsresolver true"
		exec dnsvalidator \--no-color \-threads $DNS_VALIDATION_THREADS \-o $tools/wordlist/resolvers.txt &> /dev/null
	fi
}
# запускаем обновление некоторых инструментов которым это нужно

function tools_update_resurce(){
	# обновляем шаблоны nuclei
	if [[ $NUCLEI_UPDATE_TEMPLATES == "true" && -n $install_tools ]]; then
		printf "\n\n${bgreen}#######################################################################${reset}\n"
		printf "${bblue} Обновление стандартных шаблонов nuclei ${reset}\n\n"
		eval nuclei -update-templates
	fi
	# устанавливаем или обновляем шаблоны написанные сообществом
	if [[ $COMUNITY_ADDITIONAL_NUCLEI_TEMPLATES == "true" && -n $install_tools ]]; then
		printf "\n\n${bgreen}#######################################################################${reset}\n"
		printf "${bblue} Обновление шаблонов от сообщества nuclei ${reset}\n\n"
		mkdir -p ~/nuclei-templates/
		eval target_directory="~/nuclei-comunitu-template/"
		# Список URL-ов репозиториев
		# взято от сюда https://github.com/xm1k3/cent
		repositories=(
			"https://github.com/0x727/ObserverWard"
			"https://github.com/0xAwali/Virtual-Host"
			"https://github.com/0xPugazh/my-nuclei-templates"
			"https://github.com/0xmaximus/final_freaking_nuclei_templates"
			"https://github.com/1in9e/my-nuclei-templates"
			"https://github.com/wr00t/templates"
			"https://github.com/ARPSyndicate/kenzer-templates"
			"https://github.com/Akokonunes/Private-Nuclei-Templates"
			"https://github.com/Arvinthksrct/alltemplate"
			"https://github.com/AshiqurEmon/nuclei_templates"
			"https://github.com/CharanRayudu/Custom-Nuclei-Templates"
			"https://github.com/DoubleTakes/nuclei-templates"
			"https://github.com/Elsfa7-110/mynuclei-templates"
			"https://github.com/ExpLangcn/NucleiTP"
			"https://github.com/Harish4948/Nuclei-Templates"
			"https://github.com/Hunt2behunter/nuclei-templates"
			"https://github.com/Jagomeiister/nuclei-templates"
			"https://github.com/JoshMorrison99/url-based-nuclei-templates"
			"https://github.com/Kaue-Navarro/Templates-kaue-nuclei"
			"https://github.com/KeepHowling/all_freaking_nuclei_templates"
			"https://github.com/Lopseg/nuclei-c-templates"
			"https://github.com/MR-pentestGuy/nuclei-templates"
			"https://github.com/NightRang3r/misc_nuclei_templates"
			"https://github.com/NitinYadav00/My-Nuclei-Templates"
			"https://github.com/Odayex/Random-Nuclei-Templates"
			"https://github.com/PedroF-369/nuclei_templates"
			"https://github.com/R-s0n/Custom_Vuln_Scan_Templates"
			"https://github.com/Saimonkabir/Nuclei-Templates"
			"https://github.com/Saptak9983/Nuclei-Template"
			"https://github.com/ShangRui-hash/my-nuclei-templates"
			"https://github.com/freakyclown/Nuclei_templates"
			"https://github.com/SirAppSec/nuclei-template-generator-log4j"
			"https://github.com/Str1am/my-nuclei-templates"
			"https://github.com/SumedhDawadi/Custom-Nuclei-Template"
			"https://github.com/System00-Security/backflow"
			"https://github.com/adampielak/nuclei-templates"
			"https://github.com/aels/CVE-2022-37042"
			"https://github.com/alexrydzak/rydzak-nuclei-templates"
			"https://github.com/ayadim/Nuclei-bug-hunter"
			"https://github.com/badboy-sft/badboy_17-Nuclei-Templates-Collection"
			"https://github.com/binod235/nuclei-templates-and-reports"
			"https://github.com/blazeinfosec/nuclei-templates"
			"https://github.com/brinhosa/brinhosa-nuclei-templates"
			"https://github.com/c-sh0/nuclei_templates"
			"https://github.com/cipher387/juicyinfo-nuclei-templates"
			"https://github.com/clarkvoss/Nuclei-Templates"
			"https://github.com/coldrainh/nuclei-ByMyself"
			"https://github.com/d3sca/Nuclei_Templates"
			"https://github.com/daffainfo/my-nuclei-templates"
			"https://github.com/damon-sec/Nuclei-templates-Collection"
			"https://github.com/dk4trin/templates-nuclei"
			"https://github.com/drfabiocastro/certwatcher-templates"
			"https://github.com/ekinsb/Nuclei-Templates"
			"https://github.com/erickfernandox/nuclei-templates"
			"https://github.com/esetal/nuclei-bb-templates"
			"https://github.com/ethicalhackingplayground/erebus-templates"
			"https://github.com/geeknik/nuclei-templates-1"
			"https://github.com/geeknik/the-nuclei-templates"
			"https://github.com/glyptho/templatesallnuclei"
			"https://github.com/im403/nuclei-temp"
			"https://github.com/javaongsan/nuclei-templates"
			"https://github.com/justmumu/SpringShell"
			"https://github.com/kabilan1290/templates"
			"https://github.com/kh4sh3i/CVE-2022-23131"
			"https://github.com/luck-ying/Library-YAML-POC"
			"https://github.com/mastersir-lab/nuclei-yaml-poc"
			"https://github.com/mbskter/Masscan2Httpx2Nuclei-Xray"
			"https://github.com/medbsq/ncl"
			"https://github.com/meme-lord/Custom-Nuclei-Templates"
			"https://github.com/n1f2c3/mytemplates"
			"https://github.com/notnotnotveg/nuclei-custom-templates"
			"https://github.com/obreinx/nuceli-templates"
			"https://github.com/optiv/mobile-nuclei-templates"
			"https://github.com/panch0r3d/nuclei-templates"
			"https://github.com/peanuth8r/Nuclei_Templates"
			"https://github.com/pentest-dev/Profesional-Nuclei-Templates"
			"https://github.com/pikpikcu/nuclei-templates"
			"https://github.com/ping-0day/templates"
			"https://github.com/praetorian-inc/chariot-launch-nuclei-templates"
			"https://github.com/ptyspawnbinbash/template-enhancer"
			"https://github.com/rafaelcaria/Nuclei-Templates"
			"https://github.com/rafaelwdornelas/my-nuclei-templates"
			"https://github.com/rahulkadavil/nuclei-templates"
			"https://github.com/randomstr1ng/nuclei-sap-templates"
			"https://github.com/redteambrasil/nuclei-templates"
			"https://github.com/ree4pwn/my-nuclei-templates"
			"https://github.com/ricardomaia/nuclei-template-generator-for-wordpress-plugins"
			"https://github.com/sadnansakin/my-nuclei-templates"
			"https://github.com/securitytest3r/nuclei_templates_work"
			"https://github.com/sharathkramadas/k8s-nuclei-templates"
			"https://github.com/shifa123/detections"
			"https://github.com/sl4x0/NC-Templates"
			"https://github.com/smaranchand/nuclei-templates"
			"https://github.com/soapffz/myown-nuclei-poc"
			"https://github.com/soumya123raj/Nuclei"
			"https://github.com/souzomain/mytemplates"
			"https://github.com/tamimhasan404/Open-Source-Nuclei-Templates-Downloader"
			"https://github.com/test502git/log4j-fuzz-head-poc"
			"https://github.com/th3r4id/nuclei-templates"
			"https://github.com/thebrnwal/Content-Injection-Nuclei-Script"
			"https://github.com/thecyberneh/nuclei-templatess"
			"https://github.com/thelabda/nuclei-templates"
			"https://github.com/boobooHQ/private_templates"
			"https://github.com/rix4uni/BugBountyTips"
			"https://github.com/Lu3ky13/Authorization-Nuclei-Templates"
			"https://github.com/bug-vs-me/nuclei"
			"https://github.com/topscoder/nuclei-wordfence-cve"
			"https://github.com/toramanemre/apache-solr-log4j-CVE-2021-44228"
			"https://github.com/toramanemre/log4j-rce-detect-waf-bypass"
			"https://github.com/trickest/log4j"
			"https://github.com/wasp76b/nuclei-templates"
			"https://github.com/wr00t/templates"
			"https://github.com/xinZa1/template"
			"https://github.com/yarovit-developer/nuclei-templates"
			"https://github.com/yavolo/nuclei-templates"
			"https://github.com/z3bd/nuclei-templates"
			"https://github.com/zer0yu/Open-PoC"
			"https://github.com/bhataasim1/PersonalTemplates"
			"https://github.com/pikpikcu/my-nuclei-templates"
			"https://github.com/SirBugs/Priv8-Nuclei-Templates"
		)
		
		# Перебираем каждый URL и клонируем репозиторий в целевую директорию
		for repo_url in "${repositories[@]}"; do
			# Извлекаем имя репозитория из URL-а
			repo_name=$(basename "$repo_url")
			
			# Формируем полный путь к целевой директории
			destination="$target_directory/$repo_name"
			
			# Клонируем репозиторий
			git clone "$repo_url" "$destination"
			
			# Проверяем статус выполнения команды git clone
			if [ $? -eq 0 ]; then
				printf "Репозиторий %s успешно склонирован в %s\n" "$repo_name" "$destination"
			else
				printf "Ошибка при клонировании репозитория %s\n" "$repo_name"
			fi
		done
	fi
	# загружаем файл с технологиями для инструмента webanalyze
	wget --no-clobber -P $tools "https://raw.githubusercontent.com/rverton/webanalyze/master/technologies.json" &>>"$DEBUG_FILE"
}

if [ -n $target_domain ]; then
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
		mkdir -p $recon_dir/$target_domain/hosts
		mkdir -p $recon_dir/$target_domain/fuzzing
		mkdir -p $recon_dir/$target_domain/scan/webtechnologies
		mkdir -p $recon_dir/$target_domain/gf
		mkdir -p $recon_dir/$target_domain/osint
		mkdir -p $recon_dir/$target_domain/scan/header_sec
		mkdir -p $recon_dir/$target_domain/cidr
		mkdir -p $recon_dir/$target_domain/directories

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
	echo "start recon to ${target_domain}" >| "$recon_dir/$target_domain/tmp/debug"
fi

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
	cat $recon_dir/$target_domain/.tmp/*_subdomains.txt | grep -E ".$target_domain$" | egrep -o "[a-z0-9_-]+(\.[a-z0-9_-]+)*\.[a-z]{2,5}" | egrep -v "www." | puredns resolve -r $dns_resolver 2>>"$DEBUG_FILE" | anew $recon_dir/$target_domain/subdomain/subdomains.txt &>>"$DEBUG_FILE"
	echo "$target_domain" | anew $recon_dir/$target_domain/subdomain/subdomains.txt &>>"$DEBUG_FILE"
	scope_domain

	# ntfy
	if [[ $ntfy_end_modules == "true" ]]; then
		
		ntfy_count1=$(cat $recon_dir/$target_domain/subdomain/subdomains.txt | wc -l)
		ntfy_count2=$(cat $recon_dir/$target_domain/archive/subdomain/subdomains.txt | wc -l)

		curl \
		-H "Title: $ntfy_title subdomain result! $(date +'%Y.%m.%d.%k')" \
		-H "Priority: $ntfy_priority" \
		-H "Tags: $ntfy_tags" \
		-d "Scan Result Collected quantity: $ntfy_count1 It was before: $ntfy_count2 " \
		$ntfy
	fi

}

function Subdomain_enum_passive(){
	if [[ $SUB_ENUM_GENERAL == "true" ]]; then
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

		cat $recon_dir/$target_domain/webs/webs.txt | nuclei -silent -t ~/nuclei-templates/takeovers/ -r $dns_resolver -o $recon_dir/$target_domain/subdomain/subtakeover.txt &>> $DEBUG_FILE
	
		if [[ $ntfy_end_modules == "true" ]]; then

			curl \
			-H "Title: $ntfy_title zonetransfer_takeovers scan result!" \
			-H "Priority: $ntfy_priority" \
			-H "Tags: $ntfy_tags" \
			-d "Scan Result zonetransfer_takeovers done " \
			$ntfy
		fi

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
	
		if [[ $ntfy_end_modules == "true" ]]; then

			curl \
			-H "Title: $ntfy_title s3bucket scan result!" \
			-H "Priority: $ntfy_priority" \
			-H "Tags: $ntfy_tags" \
			-d "Scan Result s3bucket done " \
			$ntfy
		fi
	
	else
		echo " s3bucket false"
	fi
}

function scan_hosts_passive() {
    while IFS= read -r line_smap; do
        # Выполнение smap и awk для каждой строки
        smap_output=$(smap "$line_smap" | awk '/^[0-9]/ {print $1, $2, $3, $4}')

        # Проверить, что $smap_output не пуст
        if [ -n "$smap_output" ]; then
            # Разбить результат на строки и обработать каждую строку отдельно
            while read -r port_info; do
                # Отфильтровать цифры порта и вывести результат
                port_info=$(echo "$port_info" | grep -oP '^[0-9]+')
                # Проверить, что $port_info не пуст
                if [ -n "$port_info" ]; then
                    # Вывести результат и сохранить в файл
                    echo "$line_smap:$port_info" | anew "$recon_dir/$target_domain/.tmp/passive_scan_hosts.txt"
                else
                    echo "No valid port info for $line_smap"
                fi
            done <<< "$smap_output"
        else
            echo "No port info for $line_smap"
        fi
    done < "$recon_dir/$target_domain/subdomain/subdomains.txt"

    cat "$recon_dir/$target_domain/.tmp/passive_scan_hosts.txt" | httprobe -prefer-https > "$recon_dir/$target_domain/webs/webs_uncommon_ports.txt"
}

function scan_hosts(){
	if [[ $SCAN_HOST_GENERAL == "true" ]]; then
		echo " start scan host"
		cat $recon_dir/$target_domain/subdomain/subdomains.txt | naabu -silent -p $SCAN_HOST_NAABO_WEBPROBE > $recon_dir/$target_domain/webs/webs_ucommon_ports.txt 
		cat $recon_dir/$target_domain/webs/webs_ucommon_ports.txt | httprobe -prefer-https > $recon_dir/$target_domain/webs/webs_uncommon_ports.txt
		rm $recon_dir/$target_domain/webs/webs_ucommon_ports.txt
	
		if [[ $ntfy_end_modules == "true" ]]; then

			curl \
			-H "Title: $ntfy_title scan_hosts scan result!" \
			-H "Priority: $ntfy_priority" \
			-H "Tags: $ntfy_tags" \
			-d "Scan Result scan_hosts done " \
			$ntfy
		fi
	else
		echo " scan host false"
	fi
}

function visual_indentification(){
	if [[ $WEB_VISUAL_INDENTIFICATION == "true" ]]; then
		echo " start visual indentification "
		python3 $tools/webscreenshot/webscreenshot.py -i $recon_dir/$target_domain/subdomain/subdomains.txt --no-error-file -r chromium --no-xserver
	
		if [[ $ntfy_end_modules == "true" ]]; then

			curl \
			-H "Title: $ntfy_title visual_indentification scan result!" \
			-H "Priority: $ntfy_priority" \
			-H "Tags: $ntfy_tags" \
			-d "Scan Result visual_indentification done " \
			$ntfy
		fi

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

	# ntfy
	if [[ $ntfy_end_modules == "true" ]]; then
		
		ntfy_count1=$(cat $recon_dir/$target_domain/webs/url_extract.txt | wc -l)
		ntfy_count2=$(cat $recon_dir/$target_domain/archive/webs/url_extract.txt | wc -l)

		curl \
		-H "Title: $ntfy_title endpoint result! $(date +'%Y.%m.%d.%k')" \
		-H "Priority: $ntfy_priority" \
		-H "Tags: $ntfy_tags" \
		-d "Scan Result Collected quantity: $ntfy_count1 It was before: $ntfy_count2 " \
		$ntfy
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
		if [[ $ENDP_ENUM_PARAMSPIDER == "true" ]]; then
			interlace -tL $recon_dir/$target_domain/subdomain/subdomains.txt -threads $IN_PARAMSPIDER -c "python3 $tools/ParamSpider/paramspider.py --level high -d _target_ | egrep -io 'http.*?' >> $recon_dir/$target_domain/.tmp/paramspider_endpoint.txt" -v
			mv $recon_dir/$target_domain/output/ $recon_dir/$target_domain/webs/output_paramspider
		fi
		if [[ $ARJUN_PARAMETR_DISCOVERY == "true" ]]; then
			cat $recon_dir/$target_domain/.tmp/gauplus_endpoint.txt | grep -Eo 'https?://[^ ]+[^] ]' | grep -vE '\.(png|jpg|jpeg|gif|swf|woff|gif|svg|js|css|html|ico)' | grep -vE '/$|[:;{}[\]+,]' |  grep -vE ';$' | anew > $recon_dir/$target_domain/.tmp/preparing_parameters_for_arjun.txt
			#interlace -tL $recon_dir/$target_domain/.tmp/preparing_parameters_for_arjun.txt -threads $IN_ARJUN -c "arjun -u "_target_" -oT $recon_dir/$target_domain/.tmp/arjun_parametr_endpoint.txt"
			arjun -i $recon_dir/$target_domain/.tmp/preparing_parameters_for_arjun.txt -oT $recon_dir/$target_domain/.tmp/arjun_parametr_endpoint.txt
			cp $recon_dir/$target_domain/.tmp/arjun_parametr_endpoint.txt $recon_dir/$target_domain/webs/arjun_parametr_url.txt
			rm $recon_dir/$target_domain/.tmp/preparing_parameters_for_arjun.txt
		fi
		# функция обедеинения файлов и применение scope
		scope_endpoint
		# генерация списков слов на основе конечных точек
		if [[ $ENDP_GENERATION_LIST == "true" ]]; then
			cat $recon_dir/$target_domain/webs/url_extract.txt | unfurl -u keys | sed 's/[][]//g' | sed 's/[#]//g' | sed 's/[}{]//g' | anew -q $recon_dir/$target_domain/webs/dict_words.txt
			cat $recon_dir/$target_domain/webs/url_extract.txt | unfurl -u values | sed 's/[][]//g' | sed 's/[#]//g' | sed 's/[}{]//g' | anew -q $recon_dir/$target_domain/webs/dict_words.txt
			cat $recon_dir/$target_domain/webs/url_extract.txt | tr "[:punct:]" "\n" | anew -q $recon_dir/$target_domain/webs/dict_words.txt
		fi
		if [[ $ENDP_ALLOW_HTTPX == "true" ]]; then
			cat $recon_dir/$target_domain/webs/url_extract.txt | httpx -random-agent -t 100 -nc -fr -maxr 2 -fhr -maxhr 10 --silent -sc -cl -ct -title -server -td -method -websocket -cname -cdn -probe | anew $recon_dir/$target_domain/webs/allow_url_extract.txt
		fi
	else
		echo " enpoint enum false "
	fi
}

function dirbuster(){

	if [[ $DIR_ENUM_GENERAL == "true" ]]; then
		mkdir -p $recon_dir/$target_domain/directories
		interlace -tL $recon_dir/$target_domain/subdomain/subdomains.txt -threads 5 -c "gobuster dir -w $tools/wordlist/dir_list_smal.txt --url _target_ --follow-redirect --status-codes-blacklist '404, 400, 526, 502, 503' --expanded --random-agent --no-tls-validation --quiet -o $recon_dir/$target_domain/directories/_target_.txt" -v
	
		if [[ $ntfy_end_modules == "true" ]]; then

			curl \
			-H "Title: $ntfy_title dirbuster scan result!" \
			-H "Priority: $ntfy_priority" \
			-H "Tags: $ntfy_tags" \
			-d "Scan Result dirbuster done " \
			$ntfy
		fi
	else
		echo " dir enum false "
	fi
}


function jsfind(){
	if [[ $JS_GENERAL == "true" ]]; then
		echo "Start js finds "

		cat $recon_dir/$target_domain/webs/url_extract.txt | grep -i ".js$" > $recon_dir/$target_domain/js/js_links.txt
		if [[ $JS_LIVE_CHECS == "true" ]]; then
			cat $recon_dir/$target_domain/js/js_links.txt | grep -i ".js$" | httpx -silent -random-agent -follow-redirects -no-color -status-code -H "$header_cookie" | grep "\[200\]$" | eval $see > $recon_dir/$target_domain/js/live_js_links.txt
		fi		
		# download js file
		if [[ $JS_DOWNLOAD == "true" ]]; then
			interlace  -tL $recon_dir/$target_domain/js/live_js_links.txt -threads $IN_JS_DOWNLOAD_FILE -c "echo _target_ | egrep -Eoi '(http|https)://[a-zA-Z0-9./?=_%:-]*' | python3 $tools/single-tools/DownloadJS.py -c '$cookie' -o $recon_dir/$target_domain/js/jsfile"
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
			echo "" > $recon_dir/$target_domain/vulns/potential_domxss_scan.txt
			#scan
			for live_js_links in $(cat $recon_dir/$target_domain/js/live_js_links.txt)
			do
				PATTERN="(document|location|window)\.(URL|documentURI|search|hash|referrer|(location\.)?href|name)"
				BODY=$(curl -sL ${live_js_links})
				SCAN=($(echo ${BODY} | grep -Eoin ${PATTERN}))
				if [[ ! -z "${SCAN}" ]]; then
					echo -en "---\n\033[0;32m[!] ${live_js_links}\033[0m\n${SCAN}\n"
					echo -e "---\n${live_js_links}\n${SCAN}" >> $recon_dir/$target_domain/vulns/potential_domxss_scan.txt
				fi
			done
		fi

		# wayback js find scan
		if [[ $JS_WAYBACK_SCAN == "true" ]]; then
			mkdir -p $recon_dir/$target_domain/js/waybackjs
			touch $recon_dir/$target_domain/js/waybackjs/waybackjs_link.txt

			for js_links in $(cat $recon_dir/$target_domain/js/js_links.txt)
				do
					status_code=$(echo $js_links | httpx -x HEAD -status-code -silent -no-color | grep -oP '(?<=\[).*(?=\])')
					if [[ $status_code != 200 ]]; then

						wayback_machine_js_links=$(curl https://web.archive.org/cdx/search/cdx?url=$js_links)

						while IFS= read -r line; do
							parts=($line)
							timestamp="${parts[1]}"
							url="${parts[2]}"

							wayback_url="https://web.archive.org/web/${timestamp}if_/${url}"
							echo "$wayback_url"

						done < "$wayback_machine_js_links" >> "$recon_dir/$target_domain/js/waybackjs/waybackjs_link.txt"

					fi
				done

			interlace -tL $recon_dir/$target_domain/js/waybackjs/waybackjs_link.txt -threads $IN_JS_SECRET_FIND -c "python3 $tools/SecretFinder/SecretFinder.py -i _target_ -o cli >> $recon_dir/$target_domain/js/waybackjs/waybackjs_link_srcrets.txt" -v
			interlace -tL $recon_dir/$target_domain/js/waybackjs/waybackjs_link.txt -threads $IN_JS_LINK_FIND -c "echo 'Scanning _target_ Now' ; python3 ~/Tools/LinkFinder/linkfinder.py -d -i _target_ -o cli >> $recon_dir/$target_domain/js/waybackjs/endpoint_waybackjs_link.txt" -v

			if [[ $JS_WAYBACK_FIND_VARS == "true" ]]; then
				touch $recon_dir/$target_domain/js/waybackjs/waybackjs_vars.txt
				
				for waybackjs_link in $(cat $recon_dir/$target_domain/js/waybackjs/waybackjs_link.txt)
					do
						echo -e "\e[1;33m$waybackjs_link\n\e[32m";
						result=$(curl -s $waybackjs_link | grep -Eo "var [a-zA-Z0-9_]+" | sort -u | cut -d" " -f2 | awk 'length($waybackjs_link) >= 3 {print $waybackjs_link}')
						if [[ -n $result ]]; then
							echo -e "\e[1;33m$waybackjs_link\n\e[32m \n $result" >> $recon_dir/$target_domain/js/waybackjs/waybackjs_vars.txt
						fi
					done
		    fi

			if [[ $ntfy_end_modules == "true" ]]; then

				curl \
				-H "Title: $ntfy_title Javascript scan result!" \
				-H "Priority: $ntfy_priority" \
				-H "Tags: $ntfy_tags" \
				-d "Scan Result JavaScrit done " \
				$ntfy
			fi
		fi
	else
		echo "js find false"
	fi
}

function checkWAF(){
	if [[ $CHECK_WAF == "true" ]]; then
		echo "start check WAF"
		interlace -tL $recon_dir/$target_domain/webs/webs.txt -threads 5 -c "wafw00f  _target_ | sed -r 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g' >> $recon_dir/$target_domain/.tmp/wafw00f.txt" -v
		cat $recon_dir/$target_domain/.tmp/wafw00f.txt | grep "The site" | anew $recon_dir/$target_domain/hosts/waf.txt
	
		if [[ $ntfy_end_modules == "true" ]]; then

			curl \
			-H "Title: $ntfy_title checkWAF scan result!" \
			-H "Priority: $ntfy_priority" \
			-H "Tags: $ntfy_tags" \
			-d "Scan Result checkWAF done " \
			$ntfy
		fi

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
	
		if [[ $ntfy_end_modules == "true" ]]; then

			curl \
			-H "Title: $ntfy_title ips scan result!" \
			-H "Priority: $ntfy_priority" \
			-H "Tags: $ntfy_tags" \
			-d "Scan Result ips done " \
			$ntfy
		fi
	
	else
		echo "IPS false "
	fi
}

function cidr_recon(){

	if [[ -n $cidr ]]; then
		echo "cidr recon"
		mkdir -p $recon_dir/$target_domain/cidr
		mkdir -p $recon_dir/$target_domain/cidr/nmap

		#ports=$(cat $recon_dir/$target_domain/.tmp/ipcidr_to_ip_list.txt | naabu -silent -p $SCAN_PORT_NAABU_PORTS_LIST | cut -d ':' -f 2 | anew |  tr '\n' ',' | sed s/,$//) && nmap -iL $recon_dir/$target_domain/.tmp/ipcidr_to_ip_list.txt -p $ports -sV -Pn -sC --script='vulners, http-waf-detect, http-security-headers, dns-zone-transfer, http-cross-domain-policy, http-title, whois-ip' --script-args='mincvss=5.0' -oA $recon_dir/$target_domain/cidr/nmap/nmap_scan --stylesheet https://raw.githubusercontent.com/honze-net/nmap-bootstrap-xsl/master/nmap-bootstrap.xsl

			if [[ $ntfy_end_modules == "true" ]]; then

				curl \
				-H "Title: $ntfy_title cidr_recon scan result!" \
				-H "Priority: $ntfy_priority" \
				-H "Tags: $ntfy_tags" \
				-d "Scan Result cidr_recon done " \
				$ntfy
			fi
	else
		echo "cidr false"
	fi

}


function testssl(){
	if [[ $TESTSSL == "true" ]]; then
		echo "start TESTSSL "
		mkdir $recon_dir/$target_domain/hosts/testssl
		interlace -tL $recon_dir/$target_domain/hosts/ips.txt -threads 5 -c "$tools/testssl/testssl.sh --quiet --color 0 -U --warnings=batch _target_ >> $recon_dir/$target_domain/hosts/testssl/_target_.txt" -v
	
		if [[ $ntfy_end_modules == "true" ]]; then

			curl \
			-H "Title: $ntfy_title testssl scan result!" \
			-H "Priority: $ntfy_priority" \
			-H "Tags: $ntfy_tags" \
			-d "Scan Result testssl done " \
			$ntfy
		fi
	
	else
		echo "test SSL false"
	fi
}

function scan_port(){
	if [[ $SCAN_PORT_GENERAL == "true" ]]; then
		echo "start scan port"
		mkdir -p $recon_dir/$target_domain/scan/nmap
		ports=$(cat $recon_dir/$target_domain/hosts/ips_v4.txt | naabu -silent -p $SCAN_PORT_NAABU_PORTS_LIST | cut -d ':' -f 2 | anew |  tr '\n' ',' | sed s/,$//) && nmap -iL $recon_dir/$target_domain/hosts/ips_v4.txt -p $ports -sV -Pn -sC --script='vulners, http-waf-detect, http-security-headers, dns-zone-transfer, http-cross-domain-policy, http-title, whois-ip' --script-args='mincvss=5.0' -oA $recon_dir/$target_domain/scan/nmap/$target_domain --stylesheet https://raw.githubusercontent.com/honze-net/nmap-bootstrap-xsl/master/nmap-bootstrap.xsl
	
		if [[ $ntfy_end_modules == "true" ]]; then

			curl \
			-H "Title: $ntfy_title scan_port scan result!" \
			-H "Priority: $ntfy_priority" \
			-H "Tags: $ntfy_tags" \
			-d "Scan Result scan_port done " \
			$ntfy
		fi

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
	
		if [[ $ntfy_end_modules == "true" ]]; then

			curl \
			-H "Title: $ntfy_title ip2provider scan result!" \
			-H "Priority: $ntfy_priority" \
			-H "Tags: $ntfy_tags" \
			-d "Scan Result ip2provider done " \
			$ntfy
		fi

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
	
		if [[ $ntfy_end_modules == "true" ]]; then

			curl \
			-H "Title: $ntfy_title nuclei_check scan result!" \
			-H "Priority: $ntfy_priority" \
			-H "Tags: $ntfy_tags" \
			-d "Scan Result nuclei_check done " \
			$ntfy
		fi
	
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

		if [[ $ntfy_end_modules == "true" ]]; then

			curl \
			-H "Title: $ntfy_title header_sec scan result!" \
			-H "Priority: $ntfy_priority" \
			-H "Tags: $ntfy_tags" \
			-d "Scan Result header_sec done " \
			$ntfy
		fi



	else
		echo "header security false"
	fi
}

function header_grep(){
	
	if [[ $HEADER_GREP == "true" ]]; then
		echo " start header grep "
		mkdir -p $recon_dir/$target_domain/scan/header/
		#cat $recon_dir/$target_domain/subdomain/subdomains.txt | egrep -o '[a-z0-9.-]*[:][0-9]*$' > $recon_dir/$target_domain/.tmp/header_grep.txt
		cat $recon_dir/$target_domain/subdomain/subdomains.txt | fff --save -o $recon_dir/$target_domain/scan/header/
	else
		echo "header grep false"
	fi
}

function webtehnologies(){

	if [[ $CHECK_WEBTEHNOLOGIES == "true" ]]; then
		echo " start check webtechnologies"
		echo "$reconwtf_dir"
		mkdir -p $recon_dir/$target_domain/scan/webtechnologies

		curl -O https://raw.githubusercontent.com/rverton/webanalyze/master/technologies.json

		# для просто субдоменов
		interlace -tL $recon_dir/$target_domain/subdomain/subdomains.txt -threads 5 -c "nuclei -u _target_ -silent -t $tools/solo-nuclei-templates/technologies/ -r $dns_resolver -o $recon_dir/$target_domain/scan/webtechnologies/_target_.txt" -v
		interlace -tL $recon_dir/$target_domain/subdomain/subdomains.txt -threads 5 -c "webanalyze -host _target_ -apps technologies.json -silent -redirect -crawl 10 >> $recon_dir/$target_domain/scan/webtechnologies/_target_.txt" -v

		rm $reconwtf_dir/*.json
		rm technologies.json
	
		if [[ $ntfy_end_modules == "true" ]]; then

			curl \
			-H "Title: $ntfy_title webtehnologies scan result!" \
			-H "Priority: $ntfy_priority" \
			-H "Tags: $ntfy_tags" \
			-d "Scan Result webtehnologies done " \
			$ntfy
		fi
	
	
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
	
		if [[ $ntfy_end_modules == "true" ]]; then

			curl \
			-H "Title: $ntfy_title fuzzing scan result!" \
			-H "Priority: $ntfy_priority" \
			-H "Tags: $ntfy_tags" \
			-d "Scan Result fuzzing done " \
			$ntfy
		fi
	
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
	
		if [[ $ntfy_end_modules == "true" ]]; then

			curl \
			-H "Title: $ntfy_title url_gf scan result!" \
			-H "Priority: $ntfy_priority" \
			-H "Tags: $ntfy_tags" \
			-d "Scan Result url_gf done " \
			$ntfy
		fi
	
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
		echo "$domain"
		mkdir -p $recon_dir/$target_domain/osint/dns
		mkdir -p $recon_dir/$target_domain/osint/whois

		#lynx -dump "https://viewdns.info/whois/?domain=$target_domain" | tail -n +20 > osint/domain_info_general.txt
	
		file="$recon_dir/$target_domain/subdomain/subdomains.txt"

		# Чтение файла построчно и выполнение команды для каждой строки
		for subdomain_osint in $(cat "$file"); do
			if [ -n "$subdomain_osint" ]; then
				bash $tools/DHVAdmin/dhv.sh -d $subdomain_osint -whois > "$recon_dir/$target_domain/osint/whois/whois_$subdomain_osint.txt"
				bash $tools/DHVAdmin/dhv.sh -d $subdomain_osint -dns > "$recon_dir/$target_domain/osint/dns/dns_$subdomain_osint.txt"
			fi
		done

		if [[ $ntfy_end_modules == "true" ]]; then

			curl \
			-H "Title: $ntfy_title domain_info scan result!" \
			-H "Priority: $ntfy_priority" \
			-H "Tags: $ntfy_tags" \
			-d "Scan Result domain_info done " \
			$ntfy
		fi
	
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

		if [[ $ntfy_end_modules == "true" ]]; then

			curl \
			-H "Title: $ntfy_title emaifind scan result!" \
			-H "Priority: $ntfy_priority" \
			-H "Tags: $ntfy_tags" \
			-d "Scan Result emaifind done " \
			$ntfy
		fi
	
	else
		echo "email find false "
	fi
}

function google_dorks(){
	if [[ $GOOGLE_DORKS == "true" ]]; then
		echo 'start google dorcs'
		$tools/degoogle_hunter/degoogle_hunter.sh $target_domain | tee $recon_dir/$target_domain/osint/google_dorks.txt
		sed -r -i "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" $recon_dir/$target_domain/osint/google_dorks.txt
	
		if [[ $ntfy_end_modules == "true" ]]; then

			curl \
			-H "Title: $ntfy_title google_dorks scan result!" \
			-H "Priority: $ntfy_priority" \
			-H "Tags: $ntfy_tags" \
			-d "Scan Result google_dorks done " \
			$ntfy
		fi
	
	else
		echo "google dorcks false"
	fi
}

function github_dorks(){
	if [[ $GITHUB_DORKS == "true" && $GITHUB_DORKS != "XXXXXXXXXXXXXXXXXXXXXXXX" ]]; then
		echo "start github dorcs"
		python3 $tools/GitDorker/GitDorker.py -t $GITHUB_TOKEN -e 5 -q $target_domain -p -ri -d "$tools/GitDorker/Dorks/alldorksv3" | grep "\[+\]" | grep "git" | anew -q $recon_dir/$target_domain/osint/gitdorks.txt

		sed -r -i "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" osint/gitdorks.txt

		if [[ $ntfy_end_modules == "true" ]]; then

			curl \
			-H "Title: $ntfy_title github_dorks scan result!" \
			-H "Priority: $ntfy_priority" \
			-H "Tags: $ntfy_tags" \
			-d "Scan Result github_dorks done " \
			$ntfy
		fi

	else
		echo "git dorcs false"
	fi
}

function metadata(){
	if [[ $METADATA == "true" ]]; then
		echo "start metadata"
		metafinder -d "$target_domain" -l $IN_METADATA -o $recon_dir/$target_domain/osint -go -bi -ba
	
		if [[ $ntfy_end_modules == "true" ]]; then

			curl \
			-H "Title: $ntfy_title metadata scan result!" \
			-H "Priority: $ntfy_priority" \
			-H "Tags: $ntfy_tags" \
			-d "Scan Result metadata done " \
			$ntfy
		fi
	
	else
		echo "metadata false"
	fi
}


function cors(){
	python3 $tools/Corsy/corsy.py -i $recon_dir/$target_domain/webs/webs.txt | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g" > $recon_dir/$target_domain/webs/cors.txt
	
		if [[ $ntfy_end_modules == "true" ]]; then

			curl \
			-H "Title: $ntfy_title cors scan result!" \
			-H "Priority: $ntfy_priority" \
			-H "Tags: $ntfy_tags" \
			-d "Scan Result cors done " \
			$ntfy
		fi
}

function openreditrct(){
	cat $recon_dir/$target_domain/gf/redirect.txt | qsreplace FUZZ | anew -q $recon_dir/$target_domain/.tmp/tmp_redirect.txt
	python3 $tools/OpenRedireX/openredirex.py -l $recon_dir/$target_domain/.tmp/tmp_redirect.txt --keyword FUZZ -p $tools/OpenRedireX/payloads.txt| grep "^http" > $recon_dir/$target_domain/vulns/redirect.txt

		if [[ $ntfy_end_modules == "true" ]]; then

			curl \
			-H "Title: $ntfy_title openreditrct scan result!" \
			-H "Priority: $ntfy_priority" \
			-H "Tags: $ntfy_tags" \
			-d "Scan Result openreditrct done " \
			$ntfy
		fi

}

function nucleifuzzer(){
		if [[ $NUCLEI_FUZZING == "true" ]]; then
		echo "start nucleifuzzing"
		
			cat $recon_dir/$target_domain/gf/xss.txt | nuclei -silent -t $tools/solo-nuclei-templates/fuzzing-templates-endpoint/xss/ -r $dns_resolver -o $recon_dir/$target_domain/vulns/xss.txt
			cat $recon_dir/$target_domain/gf/ssti.txt | nuclei -silent -t $tools/solo-nuclei-templates/fuzzing-templates-endpoint/ssti/ -r $dns_resolver -o $recon_dir/$target_domain/vulns/ssti.txt
			cat $recon_dir/$target_domain/gf/ssrf.txt | nuclei -silent -t $tools/solo-nuclei-templates/fuzzing-templates-endpoint/ssrf/ -r $dns_resolver -o $recon_dir/$target_domain/vulns/ssrf.txt
			cat $recon_dir/$target_domain/gf/sqli.txt | nuclei -silent -t $tools/solo-nuclei-templates/fuzzing-templates-endpoint/sqli/ -r $dns_resolver -o $recon_dir/$target_domain/vulns/sqli.txt

			cat $recon_dir/$target_domain/webs/url_extract.txt | nuclei -silent -t $tools/solo-nuclei-templates/fuzzing-templates-endpoint/xxe/ -r $dns_resolver -o $recon_dir/$target_domain/vulns/xxe.txt
			cat $recon_dir/$target_domain/webs/url_extract.txt | nuclei -silent -t $tools/solo-nuclei-templates/fuzzing-templates-endpoint/rfi/ -r $dns_resolver -o $recon_dir/$target_domain/vulns/rfi.txt
			cat $recon_dir/$target_domain/webs/url_extract.txt | nuclei -silent -t $tools/solo-nuclei-templates/fuzzing-templates-endpoint/redirect/ -r $dns_resolver -o $recon_dir/$target_domain/vulns/nuclei_redirect.txt
			cat $recon_dir/$target_domain/webs/url_extract.txt | nuclei -silent -t $tools/solo-nuclei-templates/fuzzing-templates-endpoint/lfi/ -r $dns_resolver -o $recon_dir/$target_domain/vulns/lfi.txt
			cat $recon_dir/$target_domain/webs/url_extract.txt | nuclei -silent -t $tools/solo-nuclei-templates/fuzzing-templates-endpoint/csti/ -r $dns_resolver -o $recon_dir/$target_domain/vulns/csti.txt
			cat $recon_dir/$target_domain/webs/url_extract.txt | nuclei -silent -t $tools/solo-nuclei-templates/fuzzing-templates-endpoint/crlf/ -r $dns_resolver -o $recon_dir/$target_domain/vulns/crlf.txt
			cat $recon_dir/$target_domain/webs/url_extract.txt | nuclei -silent -t $tools/solo-nuclei-templates/fuzzing-templates-endpoint/cmdi/ -r $dns_resolver -o $recon_dir/$target_domain/vulns/cmdi.txt

		if [[ $ntfy_end_modules == "true" ]]; then

			curl \
			-H "Title: $ntfy_title nucleifuzzing scan result!" \
			-H "Priority: $ntfy_priority" \
			-H "Tags: $ntfy_tags" \
			-d "Scan Result nucleifuzzing done " \
			$ntfy
		fi

	else
		echo "nucleifuzzing false"
	fi
}

function apikey_check(){
		if [[ $APIKEY_CHECK == "true" ]]; then
		echo "start APIKEY_CHECK"

			trufflehog filesystem $recon_dir/$target_domain/js/ >> $recon_dir/$target_domain/vulns/trufflehog_js_api_disclosure.txt

		if [[ $ntfy_end_modules == "true" ]]; then

			curl \
			-H "Title: $ntfy_title APIKEY_CHECK scan result!" \
			-H "Priority: $ntfy_priority" \
			-H "Tags: $ntfy_tags" \
			-d "Scan Result APIKEY_CHECK done " \
			$ntfy
		fi

	else
		echo "nucleifuzzing false"
	fi
}


function x4xxbypass(){

	cat $recon_dir/$target_domain/fuzzing/*.txt | grep -E '^4' | grep -Ev '^404' | cut -d ' ' -f3 | dirdar -only-ok > $recon_dir/$target_domain/.tmp/dirdar.txt
	cat $recon_dir/$target_domain/.tmp/dirdar.txt | sed -e '1,12d' | sed '/^$/d' | anew -q $recon_dir/$target_domain/vulns/4xxbypass.txt

		if [[ $ntfy_end_modules == "true" ]]; then

			curl \
			-H "Title: $ntfy_title 4xxbypass scan result!" \
			-H "Priority: $ntfy_priority" \
			-H "Tags: $ntfy_tags" \
			-d "Scan Result 4xxbypass done " \
			$ntfy
		fi

}


function clearempity(){
	find . -type f -empty -exec rm {} \;
	find . -type d -empty -exec rmdir {} \;
}

function archive_scan(){
	

	if [ -d $recon_dir/$target_domain/archive ]; then

		
		echo "" > $recon_dir/$target_domain/README.md

		# получаем и заполняем количество
		date=$(date +"%Y.%m.%d.%k")

		date_achive_scan=$(cat $recon_dir/$target_domain/archive/date.txt)
		
		# Сохраняем настройки сканирования

		echo "# Parametr scanning $target_domain " >> $recon_dir/$target_domain/README.md

		echo "* Command: $0 -d $target_domain -m $company -cidr $cidr -c $cookie -g $config -x $scope_list" >> $recon_dir/$target_domain/README.md

		if [[ -n $target_domain ]]; then
			echo "* Target Domain: $target_domain " >> $recon_dir/$target_domain/README.md
		fi
		if [[ -n $company ]]; then
			echo "* Company Name: $company " >> $recon_dir/$target_domain/README.md
		fi
		if [[ -n $cidr ]]; then
			echo "* CIDR: $cidr " >> $recon_dir/$target_domain/README.md
		fi
		if [[ -n $cookie ]]; then
			echo "* Cookies: $cookie " >> $recon_dir/$target_domain/README.md
		fi
		if [[ -n $config ]]; then
			echo "* Config File: $config " >> $recon_dir/$target_domain/README.md
			
			cp $reconwtf_dir/$config $recon_dir/$target_domain/archive/back_md/$date/config.conf
		
		fi
		
		if [[ -n $scope_list ]]; then
			scpe_listing_red=$(cat $reconwtf_dir/$scope_list)
			
			cp $reconwtf_dir/$scope_list $recon_dir/$target_domain/archive/back_md/$date/scope.txt
			cp $reconwtf_dir/$scope_list $recon_dir/$target_domain/scope.txt

			echo "* Scope File: $scope_list " >> $recon_dir/$target_domain/README.md
			echo "" >> $recon_dir/$target_domain/README.md
			echo '```bash' >> $recon_dir/$target_domain/README.md
			echo "$scpe_listing_red" >> $recon_dir/$target_domain/README.md
			echo '```' >> $recon_dir/$target_domain/README.md
		fi

		echo " " >> $recon_dir/$target_domain/README.md

		echo "# $target_domain : $date_achive_scan : $date" >> $recon_dir/$target_domain/README.md # очищаем readme для новых данных
		echo " " >> $recon_dir/$target_domain/README.md

		# попробуем забить циклом
		echo "| $target_domain | $date_achive_scan | $date |" >> $recon_dir/$target_domain/README.md
		echo "|----------------|-------------------|-------|" >> $recon_dir/$target_domain/README.md

		# Массив директорий

		cd $recon_dir/$target_domain

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
		arr[11]=directories
		#arr[11]=hosts/testssl/

		arr2[0]=screenshots/
		arr2[1]=js/jsfile/
		arr2[2]=scan/header_sec/
		

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

		# Сравниваем эндпоинты от goobaster
		echo " " >> $recon_dir/$target_domain/README.md
		echo "| Endpoint subdomain | $date_achive_scan | $date |" >> $recon_dir/$target_domain/README.md
		echo "|--------|-------------------|-------|" >> $recon_dir/$target_domain/README.md
		for endpoint_file in $(ls $recon_dir/$target_domain/webs/endpoint)
		do

			endpoint_file1=$(cat $recon_dir/$target_domain/webs/endpoint/$endpoint_file | wc -l)
			endpoint_file2=$(cat $recon_dir/$target_domain/archive/webs/endpoint/$endpoint_file | wc -l)
			#echo $endpoint_file
			echo "| $endpoint_file | $endpoint_file1 | $endpoint_file2 |" >> $recon_dir/$target_domain/README.md
		done		



		if [[ $ntfy_end_count_script == "true" ]]; then
			
			scan_ntfy_allow_result=$(cat $recon_dir/$target_domain/README.md)

			curl \
			-H "Title: $ntfy_title all scan result!" \
			-H "Priority: $ntfy_priority" \
			-H "Tags: tada" \
			-d "$scan_ntfy_allow_result" \
			$ntfy
		fi


		echo " " >> $recon_dir/$target_domain/DIFF_RESULT.md
		# начинаем сравнивать через diff

		echo " " >> $recon_dir/$target_domain/DIFF_RESULT.md
		echo " " >> $recon_dir/$target_domain/DIFF_RESULT.md
		echo "# diff scaner : $date_achive_scan : $date " >> $recon_dir/$target_domain/DIFF_RESULT.md
		echo " " >> $recon_dir/$target_domain/DIFF_RESULT.md
		echo " " >> $recon_dir/$target_domain/DIFF_RESULT.md

		# сравниваем ендпоинты дифом

		
		for endpoint_file in $(ls $recon_dir/$target_domain/webs/endpoint)
		do

			endpoint_file1=$(diff $recon_dir/$target_domain/webs/endpoint/$endpoint_file $recon_dir/$target_domain/archive/webs/endpoint/$endpoint_file)
			#echo $endpoint_file
			if [[ $endpoint_file1 == "" ]];then
				echo "" > /dev/null
			else
				echo "| $endpoint_file | $date_achive_scan | $date |" >> $recon_dir/$target_domain/DIFF_RESULT.md
				echo "|----|-------------------|-------|" >> $recon_dir/$target_domain/DIFF_RESULT.md
				echo " " >> $recon_dir/$target_domain/DIFF_RESULT.md
				echo '```bash ' >> $recon_dir/$target_domain/DIFF_RESULT.md
				echo " $endpoint_file1 " >> $recon_dir/$target_domain/DIFF_RESULT.md
				echo '``` ' >> $recon_dir/$target_domain/DIFF_RESULT.md
			fi
		done		
		echo " " >> $recon_dir/$target_domain/DIFF_RESULT.md



		for item in ${arr[*]}
		do
			for i in $(ls -1 -R $item)
			do

				echo " " >> $recon_dir/$target_domain/DIFF_RESULT.md
				dir=$(cd $item && pwd)
				dir_al_path=$(echo "$dir/$i")

				dir_a=$(cd archive/$item && pwd)
				dir_al_path_archive=$(echo "$dir_a/$i")
						
				if [[ -f $dir_al_path ]]; then
					echo " " >> $recon_dir/$target_domain/DIFF_RESULT.md
					count_file1="$(diff $dir_al_path $dir_al_path_archive)"
					#count_file2="$(cat $dir_al_path_archive | wc -l)"
					if [[ $count_file1 == "" ]];then
						echo "" > /dev/null
					else
								
						echo "| $i | $date_achive_scan | $date |" >> $recon_dir/$target_domain/DIFF_RESULT.md
						echo "|----|-------------------|-------|" >> $recon_dir/$target_domain/DIFF_RESULT.md
						echo " " >> $recon_dir/$target_domain/DIFF_RESULT.md
						echo '```bash ' >> $recon_dir/$target_domain/DIFF_RESULT.md
						echo " $count_file1 " >> $recon_dir/$target_domain/DIFF_RESULT.md
						echo '``` ' >> $recon_dir/$target_domain/DIFF_RESULT.md
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

					echo "| $i | $date_achive_scan | $date |" >> $recon_dir/$target_domain/DIFF_RESULT.md
					echo "|----|-------------------|-------|" >> $recon_dir/$target_domain/DIFF_RESULT.md
					echo " " >> $recon_dir/$target_domain/DIFF_RESULT.md
					echo '```bash ' >> $recon_dir/$target_domain/DIFF_RESULT.md
					echo " $diff_to_js " >> $recon_dir/$target_domain/DIFF_RESDIFF_RESULT.mdREADME.md
				fi

			done

		done
	
		diff_to_imge=$(diff $recon_dir/$target_domain/screenshots $recon_dir/$target_domain/archive/screenshots)
		if [[ $diff_to_imge == "" ]]; then
			echo "" > /dev/null
		else
			echo " " >> $recon_dir/$target_domain/DIFF_RESULT.md
			echo "| screenshots | $date_achive_scan | $date |" >> $recon_dir/$target_domain/DIFF_RESULT.md
			echo "|-------------|-------------------|-------|" >> $recon_dir/$target_domain/DIFF_RESULT.md
			echo " " >> $recon_dir/$target_domain/DIFF_RESULT.md
			echo '```bash ' >> $recon_dir/$target_domain/DIFF_RESULT.md
			echo " $diff_to_imge " >> $recon_dir/$target_domain/DIFF_RESULT.md
			echo '``` ' >> $recon_dir/$target_domain/DIFF_RESULT.md
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
		
		rm -r $recon_dir/$target_domain/archive/directories

		mkdir -p $recon_dir/$target_domain/archive

		mkdir -p $recon_dir/$target_domain/archive/back_md/$date/config_tools

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
		
		cp -r $recon_dir/$target_domain/directories $recon_dir/$target_domain/archive/directories

		date=$(date +"%Y.%m.%d.%k")
		touch $recon_dir/$target_domain/archive/date.txt
		echo "$date" > $recon_dir/$target_domain/archive/date.txt

		# загружаем в архив конфиги

		cp ~/.config/subfinder/config.yaml $recon_dir/$target_domain/archive/back_md/$date/config_tools &> /dev/null
		cp ~/.config/amass/config.ini $recon_dir/$target_domain/archive/back_md/$date/config_tools &> /dev/null
		cp ~/.config/sigurlfind3r/conf.yaml $recon_dir/$target_domain/archive/back_md/$date/config_tools &> /dev/null
		cp $tools/.github_tokens $recon_dir/$target_domain/archive/back_md/$date/config_tools &> /dev/null
		cp $tools/theHarvester/api-keys.yaml $recon_dir/$target_domain/archive/back_md/$date/config_tools &> /dev/null
		cp $tools/h8mail_config.ini $recon_dir/$target_domain/archive/back_md/$date/config_tools &> /dev/null

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
		
		cp -r $recon_dir/$target_domain/directories $recon_dir/$target_domain/archive/directories
		# gf hosts js osint scan screenshots subdomain  vulns webs

		date=$(date +"%Y.%m.%d.%k")
		touch $recon_dir/$target_domain/archive/date.txt
		echo "$date" > $recon_dir/$target_domain/archive/date.txt

	fi
	cd $reconwtf_dir
}

function archive_md_lists(){

	date=$(date +"%Y.%m.%d.%k")

	mkdir -p $recon_dir/$target_domain/archive/back_md
	mkdir -p $recon_dir/$target_domain/archive/back_md/$date
	cp $recon_dir/$target_domain/README.md $recon_dir/$target_domain/archive/back_md/$date/README.md
	cp $recon_dir/$target_domain/DIFF_RESULT.md $recon_dir/$target_domain/archive/back_md/$date/DIFF_RESULT.md
	cp $recon_dir/$target_domain/CheckList.md $recon_dir/$target_domain/archive/back_md/$date/CheckList.md
	

}

function github_get_private_scan(){
	if [[ $git_add == "true" ]]; then
		if [ -f $recon_dir/.git/index ]; then
			cd $recon_dir
			cd ..
			date=$(date)
			echo "**/.tmp" > .gitignore
			git add .
			git commit -m "$date"
			git pull git@github.com:$you_git_username/$private_git_repos_name.git
			git push git@github.com:$you_git_username/$private_git_repos_name.git
			cd $reconwtf_dir
		else
			cd $recon_dir
			cd ..
			git init
			touch .gitignore
			echo "**/.tmp" > .gitignore
			git remote add origin https://github.com/$you_git_username/$private_git_repos_name.git
			git add .
			git commit -m "private recon repo init"
			git push  git@github.com:$you_git_username/$private_git_repos_name.git
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
		dirbuster
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
		clearempity
	elif [[ -n $recon_full ]]; then # разведка всеми методами активно пасивно осинт атаки
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
		dirbuster
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
		# тут идут активные атаки
		openreditrct
		x4xxbypass
		nucleifuzzer
		apikey_check
		# тут заканчиваюся атаки
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
		webs
		zonetransfer_takeovers
		checkWAF
		s3bucket
		clearempity
	elif [[ -n $recon_speed ]]; then # Быстрое сканирование только самые быстрые методы
		Subdomain_enum_passive
		Subdomain_enum
		subdomain_permytation
		subdomain_bruteforce
		SubRresult
		zonetransfer_takeovers
		s3bucket
		scan_hosts_passive
		visual_indentification
		checkWAF
		ips
		ip2provider
		webtehnologies
		domain_info
		clearempity
	fi
	
	if [[ -n $check_all_tools || -n $install_tools ]]; then
		echo ""
	else
		archive_scan
		archive_md_lists
		github_get_private_scan
	fi
}

init # запуск главной функции
