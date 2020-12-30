#!/bin/bash
# description: this script is used to build some neceressury files/scripts for init an crd controller

PROJECT=$1
VERSION=$2

# create project directory
mkdir $PROJECT

# init go mod 
cd $PROJECT && go mod init l0calh0st.cn/$PROJECT

# create some neceressury dir
mkdir hack

# create boilerplate.go.txt tools.go update-group.sh
cd hack
cat >> boilerplate.go.txt << EOF
/*
Copyright The $PROJECT Authors.
*/
EOF

cat >> tools.go << EOF
// +build tools

package tools

import _ "k8s.io/code-generator"
EOF


cat >> update-group.sh << EOF
#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_ROOT=\$(dirname \${BASH_SOURCE})


bash ../vendor/k8s.io/code-generator/generate-groups.sh "all" \
  l0calh0st.cn/$PROJECT/pkg/client \
  l0calh0st.cn/$PEOJECT/pkg/apis \
  $PROJECT.l0calh0st.cn:$VERSION \
  --output-base \${SCRIPT_ROOT}/../../../ \
  --go-header-file "\${SCRIPT_ROOT}/boilerplate.go.txt"
EOF

chmod +x update-group.sh

# go mod vendor
cd .. && export GOPROXY=https://goproxy.cn && go mod vendor

