# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.synced_folder '.', '/vagrant', disabled: true

  config.vm.provider "qemu" do |qe, override|
    override.ssh.username = "packer"

    qe.memory = 4096
    qe.smp = "cpus=4,sockets=1,cores=4,threads=1"
    qe.arch = "x86_64"
    qe.cpu = "max"

    qe.machine = "q35,accel=tcg"
    qe.net_device = "virtio-net"

    qe.qemu_dir = "/opt/homebrew/bin"

    # qe.extra_qemu_args = [
    #   "-net", "nic,model=virtio"
    # ]
    # qe.extra_qemu_args = %w(
    #   -accel tcg,
    #   -net nic,model=virtio,
    #   thread=multi,
    #   tb-size=512,
    # )
    # qe.extra_qemu_args = %w(-accel tcg,thread=multi,tb-size=512)

    qe.image_path = "/Users/justinpopa/Development/personal/home/packer/output/ubuntu-22.04.2/ubuntu-22.04.2"
  end
end
