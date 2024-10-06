# ProxmoxVFIO


VFIO Configuration Script for Proxmox

This script automates the configuration of VFIO (Virtual Function I/O) on a Proxmox server, allowing you to pass through a GPU to a virtual machine (VM). The script handles all necessary configurations, including modifying GRUB, loading required kernel modules, and blacklisting GPU drivers.
Prerequisites

    Proxmox VE installed on your server.
    Root or sudo access to the server.

What the Script Does

    Modifies GRUB Configuration:
        Adds necessary IOMMU and VFIO-related parameters to the GRUB configuration.

    Updates GRUB:
        Applies the changes made to the GRUB configuration.

    Configures Kernel Modules:
        Ensures the VFIO-related modules are loaded at boot.

    Configures IOMMU Remapping:
        Adds options to allow unsafe interrupts and ignore certain MSR errors.

    Blacklists GPU Drivers:
        Prevents the host system from loading the default GPU drivers, which allows the GPU to be used exclusively by a VM.

    Configures VFIO for GPU Passthrough:
        Prompts you to input the PCIe IDs of your GPU and its audio device and configures VFIO accordingly.

    Updates Initramfs and Recommends a Reboot:
        Finalizes the configuration and suggests rebooting the server to apply all changes.

How to Use the Script

    chmod +x SetupVFIO.sh

    sudo ./SetupVFIO.sh

Follow the Prompts:

    The script will display a list of PCIe devices on your system.
    It will prompt you to enter the PCIe ID of your GPU and its associated audio device.
    The script will automatically apply the necessary configuration changes.

Reboot the Server:

  After the script completes, it is recommended to reboot your server to apply all changes



Important Notes

    AMD CPUs: If you are using an AMD CPU, ensure that the script is configured to use amd_iommu=on instead of intel_iommu=on. You can manually adjust this in the script or directly in the /etc/default/grub file before running the script.

    Ensure Correct PCIe IDs: Make sure you correctly identify the PCIe IDs of your GPU and its audio device when prompted. Incorrect entries can cause issues with GPU passthrough.

Troubleshooting

If the server does not boot properly after running the script, you can boot into Proxmox's recovery mode and revert the changes made to the GRUB and module configuration files. This can be done by editing /etc/default/grub and removing the VFIO-specific options.
