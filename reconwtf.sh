#!/bin/bash

eval . ./config.conf # defaul config file

function help(){
	echo ""
	echo " Usage: ./reconwtf.sh [options...] -d <domain> -m <companu tld>-l <list.txt> -x <scope.txt> 
			-c <cookie> -f <config.conf> -u <dir out> -r -s -p -a -o -v -h"
	echo ""
	echo "  -d, --domain 		<domain> 	domain target 'example.com' "
	echo "  -m, --company 	<name>		copany name 'Tesla inc'"
	echo "  -x, --scope 		<scope.txt> 	list of domains in the visibility zone "
	echo "  -g, --config		<config.conf>	config file 'dir/config2.conf' "
	echo "  -c, --cookie 		<cookie>  	cookie -c 'PHPSESSIONID=qweqweqwe'"
	echo ""
	echo "  -r, --recon-full	 		full target exploration ( with the use of attacks ) "
	echo "  -s, --subdimain-search	 	only subdomain search, resolution, and subdomain capture "
	echo "  -p, --passive 			only passive methods that do not affect the target "
	echo "  -a, --active				full intelligence with the use of attacks "
	echo "  -o, --osint				minimal exploration with the use of OSINT "
	echo ""
	echo "  -v, --version				reconWTF version "
	echo "  -h, --help 				help"
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
	[ -f "$tools/single-tools/getjswords.py" ] || { printf "${bred} [*] getjswords   	[NO]${reset}\n"; allinstalled=false;}
	[ -f "$tools/single-tools/DownloadJS.py" ] || { printf "${bred} [*] getjswords   	[NO]${reset}\n"; allinstalled=false;}
	[ -f "$tools/single-tools/findomxss.sh" ] || { printf "${bred} [*] getjswords   	[NO]${reset}\n"; allinstalled=false;}
	[ -f "$tools/single-tools/jsvar.sh" ] || { printf "${bred} [*] getjswords   	[NO]${reset}\n"; allinstalled=false;}
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
	type -P crobat &>/dev/null || { printf "${bred} [*] Crobat		[NO]${reset}\n"; allinstalled=false;}
	type -P mildew &>/dev/null || { printf "${bred} [*] mildew		[NO]${reset}\n"; allinstalled=false;}
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
	#if [[ $NUCLEI_ADDITIONAL_TEMPLATES == "true" ]]; then
	#	echo " nuclei update additional templates "
	#		eval cent init
	#		eval cent -p ~/nuclei-templates/cent-nuclei-templates
	#fi
	eval webanalyze -update

}

function preliminary_actions(){ # предварительные действия создаем директорию цели итд..

	# проверяем нужено ли собрать dns resolver-ы
	if [[ $update_resolvers == "true" ]]; then
		echo "dnsvalidator gen dnsresolver true"
		exec dnsvalidator \--no-color \-threads $DNS_VALIDATION_THREADS \-o $tools/wordlist/resolvers.txt &> /dev/null
	fi
	# создаем нужные директории если их нет. если есть не создаем
	if ! [ -d $recon_dir/$target_domain/ ]; then
		mkdir -p $recon_dir
		mkdir -p $recon_dir/$target_domain/
		mkdir -p $recon_dir/$target_domain/.tmp
		touch $recon_dir/$target_domain/.tmp/debug
		mkdir -p $recon_dir/$target_domain/subdomain
		mkdir -p $recon_dir/$target_domain/js
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
		
		cd $recon_dir/$target_domain # переходим в папку рекона
	else
		cd $recon_dir/$target_domain # переходим в папку рекона
	fi
	# обнуляем debug
	echo "start recon to ${target_domain}" > $recon_dir/$target_domain/.tmp/debug
}

function scope_domain(){
	if [[ -n $scope_list ]]; then
		echo " --= scope list =--"
		mv $recon_dir/$target_domain/subdomain/subdomains.txt $recon_dir/$target_domain/subdomain/_subdomains.txt
		cat $recon_dir/$target_domain/subdomain/_subdomains.txt | egrep -i -x -f $scope_list | anew $recon_dir/$target_domain/subdomain/subdomains.txt > $DEBUG_FILE
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
			echo "$target_domain" | sonarbyte | anew $recon_dir/$target_domain/.tmp/sonarbyte_subdomains.txt &>>"$DEBUG_FILE"
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
			subfinder -d $target_domain -config $SUBFINDER_CONFIG -nC -silent -recursive -nW | anew $recon_dir/$target_domain/.tmp/subfinder_subdomains.txt  &>>"$DEBUG_FILE"
		else
			echo " subfinder false "
		fi
		echo "## запускаем amass ##"
		if [[ $SUB_ENUM_AMASS == "true" ]]; then
			amass enum -d $target_domain -nocolor -rf $dns_resolver -active | anew $recon_dir/$target_domain/.tmp/amass_subdomains.txt
			# разрешаем все поддомены и выкатываем конечный результат
		else
			echo " amass false "
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
			cat $recon_dir/$target_domain/subdomain/subdomains.txt | httprobe -prefer-https > $recon_dir/$target_domain/webs/webs.txt
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
	cat $recon_dir/$target_domain/.tmp/*_endpoint.txt | eval $see | anew $recon_dir/$target_domain/.tmp/endpoint_extract.txt
	if [[ -n $scope_list ]]; then
		cat $recon_dir/$target_domain/.tmp/endpoint_extract.txt | egrep -i -f $scope_list > $recon_dir/$target_domain/webs/url_extract.txt
	else
		cat $recon_dir/$target_domain/.tmp/endpoint_extract.txt > $recon_dir/$target_domain/webs/url_extract.txt
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
		if [[ $ENDP_ENUM_GITHUB == "true" ]]; then
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
			cat webs/url_extract.txt | unfurl -u keys | sed 's/[][]//g' | sed 's/[#]//g' | sed 's/[}{]//g' | anew -q webs/dict_words.txt
			cat webs/url_extract.txt | unfurl -u values | sed 's/[][]//g' | sed 's/[#]//g' | sed 's/[}{]//g' | anew -q webs/dict_words.txt
			cat webs/url_extract.txt | tr "[:punct:]" "\n" | anew -q webs/dict_words.txt
		fi
	else
		echo " enpoint enum false "
	fi
}

function jsfind(){
	if [[ $JS_GENERAL == "true" ]]; then
		echo "Start js finds "

		cat $recon_dir/$target_domain/webs/url_extract.txt | grep -i ".js$" > js/js_links.txt
		if [[ $JS_LIVE_CHECS == "true" ]]; then
			cat $recon_dir/$target_domain/js/js_links.txt | grep -i ".js$" | httpx -silent -no-color -status-code -H $header_cookie | grep "\[200\]$" | eval $see > $recon_dir/$target_domain/js/live_js_links.txt
		fi		
		# download js file
		if [[ $JS_DOWNLOAD == "true" ]]; then
			interlace  -tL $recon_dir/$target_domain/js/live_js_links.txt -threads $IN_JS_DOWNLOAD_FILE -c "echo _target_ | python3 $tools/single-tools/DownloadJS.py -c "$cookie" -o $recon_dir/$target_domain/js/jsfile"
		fi
		#Gather Endpoints From JsFiles
		if [[ $JS_LINKFIND == "true" ]]; then
			interlace -tL $recon_dir/$target_domain/js/live_js_links.txt -threads $IN_JS_LINK_FIND -c "echo 'Scanning _target_ Now' ; python3 ~/Tools/LinkFinder/linkfinder.py -d -i _target_ -o cli >> $recon_dir/$target_domain/js/js_endpoints.txt" -v	
		fi
		#Gather Secrets From Js Files
		if [[ $JS_SECRET == "true" ]]; then
			interlace -tL $recon_dir/$target_domain/js/live_js_links.txt -threads $IN_JS_SECRET_FIND -c "python3 $tools/SecretFinder/SecretFinder.py -i _target_ -o cli >> $recon_dir/$target_domain/js/jslinksecret.txt" -v
		fi
		#Gather JSFilesWordlist	
		if [[ $JS_WORDS == "true" ]]; then
			cat $recon_dir/$target_domain/js/live_js_links.txt | python3 $tools/single-tools/getjswords.py >> $recon_dir/$target_domain/.tmp/temp_jswordlist.txt
			cat $recon_dir/$target_domain/.tmp/temp_jswordlist.txt | sort -u >> $recon_dir/$target_domain/js/jswordlist.txt
		fi
		#Gather Variables from JSFiles For Xss
		if [[ $JS_VARS == "true" ]]; then
			cat $recon_dir/$target_domain/js/live_js_links.txt | while read url ; do bash $tools/single-tools/jsvar.sh $url | tee -a $recon_dir/$target_domain/js/js_var.txt ; done
		fi	
		#Find DomXSS
		if [[ $JS_FINDOM_XSS == "true" ]]; then
			interlace -tL $recon_dir/$target_domain/js/live_js_links.txt -threads 5 -c "bash $tools/single-tools/findomxss.sh _target_" -v
			#scan
			cp $recon_dir/$target_domain/domxss_scan.txt $recon_dir/$target_domain/vulns/xss/domxss_scan.txt
			rm domxss_scan.txt
		fi
	else
		echo "js find false"
	fi
}

checkWAF(){
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
		mkdir $recon_dir/$target_domain/scan/nmap
		#cat $recon_dir/$target_domain/hosts/ips.txt | naabu -p 0-10000 -silent -nmap-cli 'nmap -sV' -o $recon_dir/$target_domain/scan/nmap/nmap.txt
		interlace -tL $recon_dir/$target_domain/hosts/ips.txt -threads $IN_SCAN_PORT_NAABU -c "echo '_target_' | naabu -p $SCAN_PORT_NAABU_PORTS_LIST -silent $SCAN_PORT_NAABU_NAMP_COMMAND >> $recon_dir/$target_domain/scan/nmap/_target_.txt" -v
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

function webtehnologies(){
	if [[ $CHECK_WEBTEHNOLOGIES == "true" ]]; then
		echo " start check webtechnologies"
		
		interlace -tL $recon_dir/$target_domain/webs/webs_uncommon_ports.txt -threads 5 -c "webanalyze -host _target_ -silent -redirect -crawl 10 >> $recon_dir/$target_domain/scan/webtechnologies/webtehnologies.txt" -v
		rm technologies.json
		echo " start check nuclei webtechnologies"
		cat $recon_dir/$target_domain/webs/webs_uncommon_ports.txt | nuclei -silent -t ~/nuclei-templates/technologies -r $dns_resolver -o $recon_dir/$target_domain/scan/webtechnologies/nuclei_webtehnologies.txt
	else
		echo "webtechnologies false"
	fi
}

function fuzzing(){
	if [[ $FFUZING == "true" ]]; then
	echo "FFUZING start"
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
		gf xss webs/url_extract.txt | anew -q gf/xss.txt
		gf ssti webs/url_extract.txt | anew -q gf/ssti.txt
		gf ssrf webs/url_extract.txt | anew -q gf/ssrf.txt
		gf sqli webs/url_extract.txt | anew -q gf/sqli.txt
		gf redirect webs/url_extract.txt | anew -q gf/redirect.txt && cat gf/ssrf.txt | anew -q gf/redirect.txt
		gf rce webs/url_extract.txt | anew -q gf/rce.txt
		gf potential webs/url_extract.txt | cut -d ':' -f3-5 |anew -q gf/potential.txt
		cat webs/url_extract.txt | egrep -iv "\.(eot|jpg|jpeg|gif|css|tif|tiff|png|ttf|otf|woff|woff2|ico|pdf|svg|txt|js)$" | unfurl -u format %s://%d%p | anew -q gf/endpoints.txt
		gf lfi webs/url_extract.txt | anew -q gf/lfi.txt
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
	if [[ $GITHUB_DORKS == "true" ]]; then
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
		metafinder -d "$target_domain" -l 2 -o $recon_dir/$target_domain/osint -go -bi -ba
	else
		echo "metadata false"
	fi
}

function CMSeek(){
	if [[ $CMS_SECURITY == "true" ]]; then
		echo "Cms SEc start"
		interlace -tL $recon_dir/$target_domain/subdomain/subdomains.txt -threads 5 -c "python3 $tools/CMSeeK/cmseek.py -u _target_ --follow-redirect --random-agent" -v
		cp -r $tools/CMSeeK/Result $recon_dir/$target_domain/scan/CMSeek
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

function 4xxbypass(){

	cat $recon_dir/$target_domain/fuzzing/*.txt | grep -E '^4' | grep -Ev '^404' | cut -d ' ' -f3 | dirdar -threads 5 -only-ok > $recon_dir/$target_domain/.tmp/dirdar.txt
	cat $recon_dir/$target_domain/.tmp/dirdar.txt | sed -e '1,12d' | sed '/^$/d' | anew -q $recon_dir/$target_domain/vulns/4xxbypass.txt
}

function clearempity(){
	find . -type f -empty -exec rm {} \;
	find . -type d -empty -exec rmdir {} \;
}



function init(){ # инициализация разведки на основе введенных параметров
	check_tools
	tools_update_resurce
	preliminary_actions
	if [[ -n $passive  ]]; then
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
	elif [[ -n $active ]]; then
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
		webtehnologies
		fuzzing
		url_gf
		url_ext_file
		domain_info
		emaifind
		google_dorks
		github_dorks
		metadata
		4xxbypass
		CMSeek
		clearempity
	elif [[ -n $recon_full ]]; then
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
		4xxbypass
		CMSeek
		clearempity
	elif [[ -n $osint ]]; then
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
	elif [[ -n $subdomain_serch ]]; then
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
}

init # запуск главной функции
