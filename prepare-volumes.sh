#!/bin/bash -x

# The purpose of this script is to extract VM images from Docker images into
# Docker volumes. These volumes must be present on a host for RancherVM to use.

# set KEEPIMAGES=true to keep the Docker images upon creation of the volume.

make_local_volume() {
  local name
  name=temp-$RANDOM

  docker volume inspect $1 &> /dev/null
  if [ "$?" == "0" ]; then
    echo WARNING: Volume $1 already exists. Deleting.
    docker volume rm -f $1
  fi
  
  docker create --name $name --volume $1:/base_image $2 nil
  docker rm -f $name

  if [ -z $KEEPIMAGES ]; then
    docker rmi $2
  fi
}

# Named volume (K8s can't use these)
# make_local_volume ranchervm-android-x86 llparse/vm-android-x86
# make_local_volume ranchervm-centos llparse/vm-centos
# make_local_volume ranchervm-rancheros llparse/vm-rancheros
# make_local_volume ranchervm-ubuntu llparse/vm-ubuntu
# make_local_volume ranchervm-windows7 llparse/vm-windows7

# HostPath volume
make_local_volume /base_images/android-x86 llparse/vm-android-x86
make_local_volume /base_images/centos llparse/vm-centos
make_local_volume /base_images/rancheros llparse/vm-rancheros
make_local_volume /base_images/ubuntu llparse/vm-ubuntu
make_local_volume /base_images/windows7 llparse/vm-windows7
