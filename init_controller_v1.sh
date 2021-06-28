#!/bin/bash
# description: this script is used to build some neceressury files/scripts for init an crd controller

PROJECT=$1
VERSION=$2

GROUP_NAME="l0calh0st.cn"
ShortProjectName=`echo $PROJECT|awk -F'-' '{print $1}'|awk -F'_' '{print $1}'`
CUSTOME_RESOURCE_NAME="$ShortProjectName""Cluster"

# create project directory
mkdir $PROJECT

# init go mod
cd $PROJECT && go mod init $GROUP_NAME/$PROJECT

# create some neceressury dir
mkdir hack

# create boilerplate.go.txt tools.go update-group.sh
cat >> hack/boilerplate.go.txt << EOF
/*
Copyright The $PROJECT Authors.
*/
EOF

cat >> hack/tools.go << EOF
// +build tools

package tools

import _ "k8s.io/code-generator"
EOF


cat >> hack/update-group.sh << EOF
#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_ROOT=\$(dirname \${BASH_SOURCE})


bash ../vendor/k8s.io/code-generator/generate-groups.sh "all" \
  $GROUP_NAME/$PROJECT/pkg/client \
  $GROUP_NAME/$PEOJECT/pkg/apis \
  $PROJECT.$GROUP_NAME:$VERSION \
  --output-base \${SCRIPT_ROOT}/../../../ \
  --go-header-file "\${SCRIPT_ROOT}/boilerplate.go.txt"
EOF

chmod +x hack/update-group.sh

# create apis
mkdir -pv pkg/{apis,client}
mkdir -pv pkg/apis/$ShortProjectName.$GROUP_NAME/$VERSION

# auto generate regisgter.go file
cat >> pkg/apis/$ShortProjectName.$GROUP_NAME/register.go << EOF
package hdfsoperator

const (
	GroupName = "$ShortProjectName.$GROUP_NAME"
)
EOF

# auto generate doc.go
cat >> pkg/apis/$ShortProjectName.$GROUP_NAME/$VERSION/doc.go << EOF
// +k8s:deepcopy-gen=package

// +groupName=$ShortProjectName.$GROUP_NAME
package $VERSION
EOF

# auto geneate types.go
cat >> pkg/apis/$ShortProjectName.$GROUP_NAME/$VERSION/types.go << EOF
package $VERSION
import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)
EOF

# generate regiser.go
cat >> pkg/apis/$ShortProjectName.$GROUP_NAME/$VERSION/register.go << EOF
package $VERSION

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/apimachinery/pkg/runtime/schema"
)

const (
)

var (
	SchemeBuilder = runtime.NewSchemeBuilder(addKnowTypes)
	AddToScheme = SchemeBuilder.AddToScheme
)

var (
	SchemeGroupVersion = schema.GroupVersion{Group:   "", Version: ""}
)

func Resource(resource string)schema.GroupResource{
	return SchemeGroupVersion.WithResource(resource).GroupResource()
}

func Kind(kind string)schema.GroupKind{
	return SchemeGroupVersion.WithKind(kind).GroupKind()
}

func addKnowTypes(scheme *runtime.Scheme)error{
	scheme.AddKnownTypes(SchemeGroupVersion,
		//new(HdfsCluster),
		new(nil))
	metav1.AddToGroupVersion(scheme, SchemeGroupVersion)
	return nil
}
EOF

# go mod vendor
export GOPROXY=https://goproxy.cn && go mod vendor
