```bash
    dMMMMb     dMMMMMP    .aMMMb    .aMMMb     dMMMMb    dMP dMP dMP  dMMMMMMP     dMMMMMP 
   dMP.dMP    dMP        dMP"VMP   dMP"dMP    dMP dMP   dMP dMP dMP     dMP       dMP      
  dMMMMK"    dMMMP      dMP       dMP dMP    dMP dMP   dMP dMP dMP     dMP       dMMMP     
 dMP"AMF    dMP        dMP.aMP   dMP.aMP    dMP dMP   dMP.dMP.dMP     dMP       dMP        
dMP dMP    dMMMMMP     VMMMP"    VMMMP"    dMP dMP    VMMMPVMMP"     dMP       dMP         
```

# ATTENTION raw alpha version

**it works well at the moment** 
1. active scan ./reconwtf.sh -d "target.com" -a
2. passive scan ./reconwtf.sh -d "target.com" -p
3. osint ./reconwtf.sh -d "target.com" -o
4. subdomain enumeration ./reconwtf.sh -d "target.com" --subdomain-search
5. cookies ./reconwtf.sh -d "target.com" -c "this ccokie"
6. scope domain ./reconwtf.sh --scope /scope.tst

**ReconFTW** this tool is designed for bug hunters, the main task of reconWTF is to collect the most accessible information possible using the best tools, I developed this tool for myself since the algorithm of reconwtf is my testing methodology!

# installation

    git clone https://github.com/solo10010/reconWTF
    cd reconWTF
    chmod +x install.sh
    sh install.sh

# config-file

    carefully read and configure config.cfg for yourself

## enter your api tokens

    GITHUB_TOKEN=XXXXXXXXXXXXXXXXXXXXXXXX
    SHODAN_API_KEY=XXXXXXXXXXXXXXXXXXXXXXXX
    XSS_SERVER=XXXXXXXXXXXXXXXXXXXXXXXX
    virustotal_token=XXXXXXXXXXXXXXXXXXXXXXXX
    spyse_token=XXXXXXXXXXXXXXXXXXXXXXXX
    securitytrails_token=XXXXXXXXXXXXXXXXXXXXXXXX

# Usage:

    ./reconwtf.sh -h

    Usage: ./reconwtf.sh [options...] -d <domain> -l <list.txt> -x <scope.txt> -c <cookie>
                                        -r -s -p -a -o -h
**OPTIONS**

| Flag | Description |
|------|-------------|
| -d, --domain | domain target 'example.com' |
| -l, --list | list of goals in a file one by one |
| -x, --scope | list of domains in the visibility zone |
| -c, --cookie | cookie -c 'PHPSESSIONID=qweqweqwe' |
| -r, --recon-full | full target exploration ( with the use of attacks ) |
| -s, --subdomain-search | only subdomain search, resolution, and subdomain capture |
| -p, --passive | only passive methods that do not affect the target |
| -a, --active | full intelligence with the use of attacks |
| -o, --osint | minimal exploration with the use of OSINT |
| -h, --help | help to reconWTF |

# Example Usage:
 
 
**conduct a full reconnaissance of the target**

```bash
./reconwtf.sh -d "target.com" -a
```
 
**conduct a full reconnaissance of the target. using the scope file**
 
```bash
./reconwtf.sh -d "target.com" --scope /scope_domain.txt -a 
```
 
**conduct only OSINT exploration**
 
```bash
./reconwtf.sh -d "target.com" --osint
```
**conduct a full reconnaissance of the target. using the cookie**
 
```bash
./reconwtf.sh -d "target.com" -c "PHPSESSIONID=XXXXXXXXX"
```

**Show help section**
 
```bash
./reconwtf.sh -h
