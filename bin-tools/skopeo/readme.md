
# Skopeo binaries for Windows x64
* scope: Skopeo Windows x64 binaries build
* mailto: dami.sirbu@gmail.com
* original: https://github.com/containers/skopeo
* version: 1.6.0

# Installation
Just unzip somewhere and add directory to path

# Usage:
$ sudo skopeo --tls-verify=false login --username xxxxx --password yyyyy mirror-reg.cloud.transfond.ro:5000
$ sudo skopeo --tls-verify=false inspect docker://mirror-reg.cloud.transfond.ro:5000/transfond/ips-websphere:transfond-factory-latest
$ sudo skopeo --tls-verify=false delete docker://mirror-reg.cloud.transfond.ro:5000/transfond/ips-websphere:transfond-factory-latest

# Notes
TLS can be disabled with "--tls-verify-false" but it NEEDS to be placed at the end of the command, else a false warning and crash will occur. This is a bug from original version 1.6.0 which is not fixed yet.
