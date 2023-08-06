packer {
  required_version = "~> 1.9.2"

  required_plugins {
    qemu = {
      version = "~> 1.0.9"
      source  = "github.com/hashicorp/qemu"
    }

    ansible = {
      version = "~> 1.1.0"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

variable "ubuntu_version" {
  type = string
}

variable "ubuntu_iso_file" {
  type = string
}

variable "vm_template_name" {
  type    = string
  default = "ubuntu"
}

variable "packer_user" {
  type    = string
  default = "packer"
}

locals {
  vm_name      = "${var.vm_template_name}-${var.ubuntu_version}"
  output_dir   = "output/${local.vm_name}"
  iso_url      = "https://releases.ubuntu.com/${var.ubuntu_version}/${var.ubuntu_iso_file}"
  iso_checksum = "file:https://releases.ubuntu.com/${var.ubuntu_version}/SHA256SUMS"
}

source "qemu" "ubuntu_2204_amd64" {
  vm_name          = "image.img"
  output_directory = local.output_dir
  headless         = true
  http_directory   = "http"

  # ISO related settings
  iso_url          = local.iso_url
  iso_checksum     = local.iso_checksum
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"

  # Basic Hardware settings
  cpus        = "8"
  memory      = "8192"
  accelerator = "tcg"

  # details of this garbage from here: https://theboreddev.com/run-ubuntu-on-mac-using-qemu/
  # need to investigate these: https://gist.github.com/oznu/ac9efae7c24fd1f37f1d933254587aa4
  efi_boot            = true
  efi_firmware_code   = "OVMF_CODE.fd"
  efi_firmware_vars   = "OVMF_VARS.fd"
  machine_type        = "q35"
  use_default_display = true
  display             = "none"
  vtpm                = true
  tpm_device_type     = "tpm-tis"

  # Network related settings
  net_device   = "virtio-net"
  vnc_port_min = 5900
  vnc_port_max = 5900

  # Disk related settings
  disk_size        = "8G"
  disk_image       = false
  format           = "qcow2"
  disk_interface   = "virtio"
  disk_compression = false

  # SSH related settings
  ssh_username           = var.packer_user
  ssh_timeout            = "60m"
  ssh_handshake_attempts = 1000
  ssh_private_key_file   = "~/.ssh/id_rsa"

  # QEMU related settings
  qemu_binary = "qemu-system-x86_64"
  qemuargs = [
    [
      "-net", "nic,model=virtio"
    ]
  ]

  # Boot related settings
  boot_wait = "5s"
  boot_command = [
    "<spacebar><wait><spacebar><wait><spacebar><wait><spacebar><wait><spacebar><wait>",
    "e<wait>",
    "<down><down><down><end>",
    " autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/",
    "<f10>"
  ]
}

build {
  sources = [
    "sources.qemu.ubuntu_2204_amd64"
  ]

  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done"
    ]
  }

  provisioner "shell" {
    inline = [
      "echo set debconf to Noninteractive",
      "echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections",
      "sudo apt-get update",
      "sudo apt-get install -y python3-pip",
      "sudo pip3 install ansible"
    ]
  }

  provisioner "ansible-local" {
    playbook_file = "../ansible/playbook.yml"
  }
}