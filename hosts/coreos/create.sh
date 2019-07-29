#!/bin/bash
VERSION=$1
LOCATION=$2
NETWORK=$3
HOSTNAME=$4
MEMORY=$5
IGNITION_FILE=$6

DATASTORE="nyb1-dat-ssd-001"
ESXI_HOST="10.0.0.9"
USER="root"
PASSWORD="LalleOdro02."
VM_HARDWARE_VERSION="14"
OVFTOOL=/usr/local/bin/ovftool
VM_NAME="$HOSTNAME"
BASE64="$(base64 $IGNITION_FILE)"

function __DOWNLOAD__ {

  if [ ! -f coreos_production_vmware_ova.ova ]; then

    echo "Downloading vmx and disk..."
    wget -O coreos_production_vmware_ova.ova https://stable.release.core-os.net/amd64-usr/$VERSION/coreos_production_vmware_ova.ova

  fi

}

function __EXPORT__ {

  echo "Exporting ovf to ESXi host..."
  echo "Using VMware hardware version $VM_HARDWARE_VERSION"

  OVF_COMMAND="$OVFTOOL \
  -ds=$DATASTORE \
  --name=$VM_NAME \
  --network=$NETWORK \
  --acceptAllEulas \
  --overwrite \
  --skipManifestCheck \
  --allowExtraConfig \
  --X:noPrompting \
  --noSSLVerify \
  -dm=thin \
  --numberOfCpus:$VM_NAME=4 \
  --memorySize:$VM_NAME=$MEMORY \
  --extraConfig:guestinfo.coreos.config.data.encoding=base64 \
  --extraConfig:guestinfo.coreos.config.data=$BASE64 \
  --overwrite \
  coreos_production_vmware_ova.ova \
  vi://$USER:$PASSWORD@$ESXI_HOST"

  exec $OVF_COMMAND

}

function __START__ {

  if [ ! -d "builds/$VM_NAME" ]; then

      echo "Build dir not found, creating..."

      mkdir -p "builds/$VM_NAME"

  else
    echo "Directory already found..."
  fi

  cd "builds/$VM_NAME"

  __DOWNLOAD__

  __EXPORT__

  # Back to root
  cd ../../

}

__START__

echo "Done..."

exit 0