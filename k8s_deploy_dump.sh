#!/bin/bash

echo "backup image list"
kubectl get deployment -o yaml|grep image|grep -v 'imagePullPolicy'|grep -v  '\- image'|grep regis|awk '{print $2}'|grep service|sort|uniq > image_list


filter_keyword="dmo"
echo "backup deployment and service yaml"
for dpl in `kubectl get deployment |grep $filter_keyword|awk '{print $1}'`
do
	dpl_name=`echo $dpl|awk -F'-deploy' '{print $1}'`
	mkdir $dpl_name
	kubectl get deployment $dpl -o yaml > $dpl_name/$dpl.yaml
	if [ "$service" != "" ]
	then
		service_file="$service""-svc.yaml"
		kubectl get svc $service -o yaml > $dpl_naame/$service_file
	fi
done
