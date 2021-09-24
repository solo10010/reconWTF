```bash
    dMMMMb     dMMMMMP    .aMMMb    .aMMMb     dMMMMb    dMP dMP dMP  dMMMMMMP     dMMMMMP 
   dMP.dMP    dMP        dMP"VMP   dMP"dMP    dMP dMP   dMP dMP dMP     dMP       dMP      
  dMMMMK"    dMMMP      dMP       dMP dMP    dMP dMP   dMP dMP dMP     dMP       dMMMP     
 dMP"AMF    dMP        dMP.aMP   dMP.aMP    dMP dMP   dMP.dMP.dMP     dMP       dMP        
dMP dMP    dMMMMMP     VMMMP"    VMMMP"    dMP dMP    VMMMPVMMP"     dMP       dMP         
```
#Resume

**ReconWTF** this tool is designed for bug hunters, the main task of reconWTF is to collect the most accessible information possible using the best tools, I developed this tool for myself since the algorithm of reconWTF is my testing methodology!

## installation

    git clone https://github.com/solo10010/reconWTF
    cd reconWTF
    chmod +x install.sh
    sh install.sh

## Config file
    * through the configuration file, you can fine-tune the entire scanning process
    * configure timeout, threads, API token, scanning tools, ports, number of threads, and much more.

## Usage:

    !configure config.conf and fill in the API keys

    ./reconwtf.sh -h

    Usage: ./reconwtf.sh [options...] -d <domain> -m <companu tld>-l <list.txt> -x <scope.txt> -c <cookie> 
                -r -s -p -a -o -v -h

**TARGET OPTIONS**

| Flag | Description |
|------|-------------|
| -d, --domain | domain target 'example.com' |
| -m, --company | copany name 'Tesla inc' |
| -x, --scope | list of domains in the visibility zone |
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
| -g, --config | config file 'dir/config2.conf' |
|-v, --version | reconWTF version |
| -h, --help | help |



## Example Usage:
 
 
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
./reconwtf.sh -d "target.com" -c "PHPSESSIONID=XXXXXXXXX"
```

**Show help section**
 
```bash
./reconwtf.sh -h
