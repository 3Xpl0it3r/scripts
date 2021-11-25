# scripts
个人常用一些脚本

### 0x00 `init_controller.sh`
description:
  `init_controller.sh` is used to build some dir/file that needed by crd
Usage:
```bash
# example project_name is example_project version is alpha1
init_controller.sh  example_project version author

➜  Go bash controller_init.sh example-operator v1alpha1 l0calh0st
go: creating new go.mod: module exampleoperator.l0calh0st.cn
go: to add module requirements and sums:
	go mod tidy
go: finding module for package k8s.io/apimachinery/pkg/runtime/schema
go: finding module for package k8s.io/apimachinery/pkg/runtime
go: finding module for package k8s.io/apimachinery/pkg/apis/meta/v1
go: finding module for package k8s.io/code-generator
go: found k8s.io/code-generator in k8s.io/code-generator v0.22.4
go: found k8s.io/apimachinery/pkg/apis/meta/v1 in k8s.io/apimachinery v0.22.4
go: found k8s.io/apimachinery/pkg/runtime in k8s.io/apimachinery v0.22.4
go: found k8s.io/apimachinery/pkg/runtime/schema in k8s.io/apimachinery v0.22.4
➜  Go cd example-operator/hack
➜  hack bash update-group.sh
Generating deepcopy funcs
Generating clientset for exampleoperator.l0calh0st.cn
Generating listers for exampleoperator.l0calh0st.cn
Generating informers for exampleoperator.l0calh0st.cn
➜  hack
```
