#!/bin/bash -x

download() {
  image_url="$1"
  image="$(basename $image_url)"
  checksum="$2"

  if [ ! -f "$image" ]; then
    echo "Downloading $image"
    curl -LO "$image_url"
  fi

  echo "Verifying $image"
  echo "$checksum  $image" | shasum -c -
  if [ "$?" != "0" ]; then
    rm -f "$image"
    echo "Checksum mismatch, deleted $image."
    exit 1
  fi
}

# http://releases.ubuntu.com/16.04/SHA256SUMS
run() {
  base_image_url="$1"
  base_image="$(basename $base_image_url)"
  base_image_ext="${base_image##*.}"
  checksum="$2"
  image_name="${base_image%.*}.qcow2"
  disk_size=8G

  download "$base_image_url" "$checksum"

  # create empty disk image
  # qemu-img create -f qcow2 $image_name $disk_size

  echo "Starting vm"
  qemu-system-x86_64 \
    -name ubuntu \
    -vnc 0.0.0.0:0 \
    -hda $base_image
}

run "https://cloud-images.ubuntu.com/releases/16.04/release/ubuntu-16.04-server-cloudimg-amd64-disk1.img" ed0a45897cbdcc8e9d695a166b68c884febc7a16c89c604a46599d133d0ebd2e
run "https://cloud-images.ubuntu.com/releases/14.04/release/ubuntu-14.04-server-cloudimg-amd64-disk1.img" f444b0ccab6eb714e660b6510c45665fb4dfbe09c99dd1ad1964111f45ffcfff

# run "http://releases.ubuntu.com/16.04.4/ubuntu-16.04.4-desktop-amd64.iso" 3380883b70108793ae589a249cccec88c9ac3106981f995962469744c3cbd46d
# run "http://releases.ubuntu.com/16.04.4/ubuntu-16.04.4-server-amd64.iso" 0a03608988cfd2e50567990dc8be96fb3c501e198e2e6efcb846d89efc7b89f2
