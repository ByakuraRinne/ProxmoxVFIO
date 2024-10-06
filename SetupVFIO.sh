#!/bin/bash


echo "Modification de GRUB..."
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet"/GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on iommu=pt pcie_acs_override=downstream,multifunction nofb nomodeset video=vesafb:off,efifb:off"/' /etc/default/grub


echo "Mise à jour de GRUB..."
update-grub


echo "Ajout des modules VFIO à /etc/modules..."
echo -e "vfio\nvfio_iommu_type1\nvfio_pci\nvfio_virqfd" >> /etc/modules

echo "Configuration de l'IOMMU remapping..."


echo "Ajout de 'options vfio_iommu_type1 allow_unsafe_interrupts=1' à /etc/modprobe.d/iommu_unsafe_interrupts.conf..."
echo "options vfio_iommu_type1 allow_unsafe_interrupts=1" > /etc/modprobe.d/iommu_unsafe_interrupts.conf


echo "Ajout de 'options kvm ignore_msrs=1' à /etc/modprobe.d/kvm.conf..."
echo "options kvm ignore_msrs=1" > /etc/modprobe.d/kvm.conf


echo "Blacklisting des drivers GPU..."
echo -e "blacklist radeon\nblacklist nouveau\nblacklist nvidia\nblacklist nvidiafb" > /etc/modprobe.d/blacklist.conf


echo "Ajout du GPU à VFIO..."

echo "Liste des périphériques PCIe:"
lspci | grep -E "VGA|Audio"
echo -n "Veuillez entrer l'ID PCIe de la carte graphique (format 0000:00:00.0): "
read gpu_id
echo -n "Veuillez entrer l'ID PCIe de la partie audio (format 0000:00:00.0): "
read audio_id

gpu_vf_id=$(lspci -nns $gpu_id | awk '{print $4}')
audio_vf_id=$(lspci -nns $audio_id | awk '{print $4}')

echo "Ajout des IDs GPU et Audio à /etc/modprobe.d/vfio.conf..."
echo "options vfio-pci ids=$gpu_vf_id,$audio_vf_id disable_vga=1" > /etc/modprobe.d/vfio.conf

echo "Mise à jour de initramfs..."
update-initramfs -u

echo "VFIO a été configuré avec succès. Un redémarrage est nécessaire pour appliquer les changements."

