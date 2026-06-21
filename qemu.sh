#!/bin/bash
rm arch_test_dish.qcow2
qemu-img create -f qcow2 arch_test_disk.qcow2 20G
qemu-system-x86_64     -enable-kvm     -cpu host     -smp 4     -m 4G     -bios /usr/share/edk2/ovmf/OVMF_CODE.fd     -device nvme,serial=DEADBEEF,id=nvme0     -device nvme-ns,drive=disk0,bus=nvme0,nsid=1     -drive file=arch_test_disk.qcow2,if=none,id=disk0,format=qcow2     -cdrom out/*.iso     -boot d     -net nic,netdev=net0 -netdev user,id=net0

