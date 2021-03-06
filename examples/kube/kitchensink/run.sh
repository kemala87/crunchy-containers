#!/bin/bash
# Copyright 2016 Crunchy Data Solutions, Inc.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

source $BUILDBASE/examples/envvars.sh

LOC=$BUILDBASE/examples/kube/kitchensink

echo "create services for master and slaves..."
kubectl create -f $LOC/kitchensink-master-service.json
kubectl create -f $LOC/kitchensink-slave-service.json
kubectl create -f $LOC/kitchensink-pgpool-service.json

echo "create PVs for master and sync slave..."
envsubst < $LOC/kitchensink-sync-slave-pv.json | kubectl create -f -
envsubst < $LOC/kitchensink-master-pv.json | kubectl create -f -

echo "create PVCs for master and sync slave..."
kubectl create -f $LOC/kitchensink-sync-slave-pvc.json
kubectl create -f $LOC/kitchensink-master-pvc.json

echo "create master pod.."
envsubst < $LOC/kitchensink-master-pod.json | kubectl create -f -
echo "sleeping 20 secs before creating slaves..."
sleep 20
echo "create slave pod.."
envsubst < $LOC/kitchensink-slave-dc.json | kubectl create -f -
echo "create sync slave pod.."
envsubst < $LOC/kitchensink-sync-slave-pod.json | kubectl create -f -
echo "create pgpool rc..."
envsubst < $LOC/kitchensink-pgpool-rc.json | kubectl create -f -

echo "create watch service account and pod"
kubectl create -f $LOC/kitchensink-watch-sa.json
envsubst <  $LOC/kitchensink-watch-pod.json | kubectl create -f -
