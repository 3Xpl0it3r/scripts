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
UpperCustomeResurce=`echo $CUSTOME_RESOURCE_NAME | sed -e "s/\b\(.\)/\u\1/g"`
Spec=$UpperCustomeResurce"Spec"
Status=$UpperCustomeResurce"Status"
Items=$UpperCustomeResurce"Itemm"
cat >> pkg/apis/$ShortProjectName.$GROUP_NAME/$VERSION/types.go << EOF
package v1alpha1

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)



// +genclient
// +k8s:defaulter-gen=true
// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object

// HdfsCluster represent the hdfs cluster
type $UpperCustomeResurce struct {
	metav1.TypeMeta \`json:",inline"\`
	metav1.ObjectMeta \`json:"metadata,omitempty"\`

	Spec $Spec \`json:"spec"\`
	Status $Status \`json:"status"\`
}


type $Spec struct {

}

// $Status represent the current status of hdfs cluster resource
type $Status struct {

}

// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object

// $Items represent a list of hdfs cluster
type $Items struct {
	metav1.TypeMeta \`json:",inline"\`
	metav1.ListMeta \`json:"metadata,omitempty"\`

	Items []$UpperCustomeResurce \`json:"items"\`
}
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
		new($UpperCustomeResurce),
        new($Items),
	metav1.AddToGroupVersion(scheme, SchemeGroupVersion)
	return nil
}
EOF

# go mod vendor
export GOPROXY=https://goproxy.cn && go mod vendor
