```bash
    dMMMMb     dMMMMMP    .aMMMb    .aMMMb     dMMMMb    dMP dMP dMP  dMMMMMMP     dMMMMMP 
   dMP.dMP    dMP        dMP"VMP   dMP"dMP    dMP dMP   dMP dMP dMP     dMP       dMP      
  dMMMMK"    dMMMP      dMP       dMP dMP    dMP dMP   dMP dMP dMP     dMP       dMMMP     
 dMP"AMF    dMP        dMP.aMP   dMP.aMP    dMP dMP   dMP.dMP.dMP     dMP       dMP        
dMP dMP    dMMMMMP     VMMMP"    VMMMP"    dMP dMP    VMMMPVMMP"     dMP       dMP         
```
# RESUME

**ReconWTF** This tool is intended for bounty hunters, the script installs and launches the best set of tools for expanding the attack surface, for Web Sites, portals, and Organizations.

**Thanks six2dez for scripts and ideas for the tool, although reconftw and reconWTF are similar, mine works better. at least for me.** 

# INSTALLATION

```bash
git clone https://github.com/solo10010/reconWTF
cd reconWTF
chmod +x *.sh
sh reconWTF --install
```

# CONFIG FILE

    * through the configuration file, you can fine-tune the entire scanning process
    * configure timeout, threads, API token, scanning tools, ports, number of threads, and much more.

# USAGE:

    !configure config.conf and fill in the API keys

    ./reconwtf.sh -h

    Usage: ./reconwtf.sh [options...] -d <domain> -m <companu tld>-l <list.txt> -x <scope.txt> -c <cookie> -cidr <cidr>
                -r -s -p -a -o -v -h

# OPTIONS

| Flag | Description |
|------|-------------|
| -d, --domain | domain target 'example.com' |
| -m, --company | copany name 'Tesla inc' see https://www.whoxy.com/tesla.com |
| -cidr, --cidr | target ip range '192.49,128.0/16' |
| -x, --scope | Out of Scope format egrep \.vk.com clear vk subdomain \vk.com clear all vk.com |
| -c, --cookie | cookie -c 'PHPSESSIONID=qweqweqwe' |

**SCANNING METHODS**

| Flag | Description |
|------|-------------|
| -r, --recon-full | full target exploration ( with the use of attacks ) |
| -s, --subdomain-search | only subdomain search, resolution, and subdomain capture |
| -p, --passive | only passive methods that do not affect the target |
| -a, --active | full intelligence with the use of attacks |
| -o, --osint | minimal exploration with the use of OSINT |


**GENERAL OPTIONS**

| Flag | Description |
|------|-------------|
| -in, --install | Install all tools |
| -ct, --check-tools | Verify that the tools are installed correctly |
| -g, --config | config file '-g dir/config2.conf' |
|-v, --version | reconWTF version |
| -h, --help | help |



# EXAMPLE USAGE:

**conduct a full reconnaissance of the target**

```bash
./reconwtf.sh -d "target.com" -a
```
 
**conduct a full reconnaissance of the target. using the scope file**
 
```bash
cat scope_domain.txt
    
    example.com
    *.api.example.com
    dev.example.com

./reconwtf.sh -d "target.com" --scope /scope_domain.txt -a 
```
 
**conduct only OSINT exploration**
 
```bash
./reconwtf.sh -d "target.com" -o
```
**conduct a full reconnaissance of the target. using the cookie**
 
```bash
./reconwtf.sh -d "target.com" -m "Target INC" -cidr "192.168.0.1/16" -c "PHPSESSIONID=XXXXXXXXX"
```

**launch example with all important settings**

```bash
./reconwtf.sh -d "target.com" -m "Target INC" -cidr "192.168.0.1/16" -c "PHPSESSIONID=XXXXXXXXX" -x /home/OutOfScope.txt --config config/config.conf --recon-full
```

**Show help section**
 
```bash
./reconwtf.sh -h
```
**Upload intelligence to github**

* create a repository called recon
* Get a github token
* fill in your config.conf file with this information
* Start checking the repository initializes itself


# UTILITES AND RECONNAISSANCE METHODS USED

## COLLECTION OF INFORMATION

* get ip addresses of subdomains dig
* Resolves an IP address to the cloud provider it is hosted on ip2provider
* domain information domainbigdata.com, lynx Browser
* Check WAF wafw00f
* finding the weak link in the endpoints gf template

## SUBDOMAIN ENUMERATION

* Subdomain enum passive amass, ctfr.py, sonarbyte
* Subdomain enum active amass, subfinder, sonarbyte
* Subdomain enum brute puredns
* Subdomain enum permytation DNScewl, puredns

## ENDPOINT ENUMERATION

* Endpoint enumeration passive sigurlfind3r, gauplus, github-endpoints
* Endpoint enumeration active gospider

## WEB PROBE

* visual indentification webscreenshot.py
* WEB probe httprobe, httpx

## JAVASCRIPT RECON

* js links linkfinder.py
* js sicrets SecretFinder.py
* js download DownloadJS.py
* js vars jsvar.sh

## SCAN

* header security h2t.py
* scan ip:port nmap, naabu
* technologies nuclei templates, webanalyze

## SEARCH VULNS

* vulnerability scanning nuclei templates, nmap nse script, searchsploit, cent
* CMS search vulners CMSeek
* vulnerability fuzzing ffuf
* CORS corsy.py
* openredirect openredirex.py
* 4xx Bypass dirdar
* 

## OSINT

* collecting emails and checking for leaked passwords emailfinder, theHarvester.py
* information leaks Github dorks, google dorks, metafinder, s3scanner

# EXAMPLES OF HOW MAKE FILES

1. Out of scope

```bash
cat scope.txt

\.tesla.com # all subdomains will be removed from the visibility zone *.tesla.com
\example.com # all domains will be removed from the visibility zone example.com including subdomains
```

# SOLVING POSSIBLE PROBLEMS

* required program not found or installed -> 
**try installing the program manually, the script installs all the necessary programs in $HOME/Tools/**
**try to install the dependencies yourself pip3 install -r requerements.txt**


# RECONWTF HAS BEEN TESTED ON OPERATING SYSTEMS (install.sh and reconwtf.sh)

1. Arch linux

# TO BE DONE

- [x] improve documentation
- [x] Make it possible to save the scan result to a private repository on github
- [x] The ability to create or download a checklist to help the pentester
- [ ] exploration of company acquisitions
- [x] Test the script on other operating systems including on the server
- [ ] Add bbrf support
- [x] make the installation script one with the main script
- [ ] Add burp proxy support
- [x] make a separate key to check installed utilities
- [x] Add a way to check the current scan with the previous one and detect what has changed
- [ ] Add scan status notifications to ntfy.sh
- [ ] Add feature to scan github repositories
- [ ] Add a function to scan a list of domains specifying the name of the scan
- [ ] Add a function to scan the list of ip addresses and ranges
- [ ] Make a beautiful conclusion
- [ ] Scanning mobile apps