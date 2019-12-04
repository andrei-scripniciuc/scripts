#!/bin/sh
if [[ ! -d "$1" ]]; then
    echo "No argument specified, using default 'compute/v1'"
fi

DISCOVERY_DOC="https://www.googleapis.com/discovery/v1/apis/$1/rest"
resource_with_method() {
  # load doc contents
  METHOD=$1 curl -s $DISCOVERY_DOC |\
    # get all resources methods
    jq .resources[].methods \|
    jqstruct \|
    egrep '\w+\.methods.'$METHOD'.path' |\
    sed 's/methods.'$METHOD'.path//' | tr -d '".'
}
resource_with_method_better() {
  METHOD=$1
  API=$2
  curl -s https://www.googleapis.com/discovery/v1/apis/$API/rest |\
    jq '.resources[].methods.'$METHOD'.id' |\
    grep -v null |\
    sort |
    uniq
}

# diff(diff(create, update), (delete)
comm -12 <(comm -12 <(resource_with_method_better create) <(resource_with_method_better update)) <(resource_with_method_better delete)
