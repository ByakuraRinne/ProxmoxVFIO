#!/bin/bash

# Étape 1: Modifier GRUB
echo "Modification de GRUB..."
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet"/GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on iommu=pt pcie_acs_override=downstream,multifunction nofb nomodeset video=vesafb:off,efifb:off"/' /etc/default/grub

# Étape 2: Mise à jour de GRUB
echo "Mise à jour de GRUB..."
update-grub

# Étape 3: Modifier les fichiers de modules
echo "Ajout des modules VFIO à /etc/modules..."
echo -e "vfio\nvfio_iommu_type1\nvfio_pci\nvfio_virqfd" >> /etc/modules

# Étape 4: Remapping IOMMU
echo "Configuration de l'IOMMU remapping..."

# a) Modifier iommu_unsafe_interrupts.conf
echo "Ajout de 'options vfio_iommu_type1 allow_unsafe_interrupts=1' à /etc/modprobe.d/iommu_unsafe_interrupts.conf..."
echo "options vfio_iommu_type1 allow_unsafe_interrupts=1" > /etc/modprobe.d/iommu_unsafe_interrupts.conf

# b) Modifier kvm.conf
echo "Ajout de 'options kvm ignore_msrs=1' à /etc/modprobe.d/kvm.conf..."
echo "options kvm ignore_msrs=1" > /etc/modprobe.d/kvm.conf

# Étape 5: Blacklister les drivers GPU
echo "Blacklisting des drivers GPU..."
echo -e "blacklist radeon\nblacklist nouveau\nblacklist nvidia\nblacklist nvidiafb" > /etc/modprobe.d/blacklist.conf

# Étape 6: Ajouter le GPU à VFIO
echo "Ajout du GPU à VFIO..."

# a) Lister les périphériques PCIe et demander l'ID PCIe du GPU
echo "Liste des périphériques PCIe:"
lspci | grep -E "VGA|Audio"
echo -n "Veuillez entrer l'ID PCIe de la carte graphique (format 0000:00:00.0): "
read gpu_id
echo -n "Veuillez entrer l'ID PCIe de la partie audio (format 0000:00:00.0): "
read audio_id

# b) Récupérer les identifiants Vendor:Device du GPU et de l'Audio
gpu_vf_id=$(lspci -nns $gpu_id | awk '{print $4}')
audio_vf_id=$(lspci -nns $audio_id | awk '{print $4}')

# c) Modifier vfio.conf
echo "Ajout des IDs GPU et Audio à /etc/modprobe.d/vfio.conf..."
echo "options vfio-pci ids=$gpu_vf_id,$audio_vf_id disable_vga=1" > /etc/modprobe.d/vfio.conf

# Étape 7: Mise à jour et redémarrage
echo "Mise à jour de initramfs..."
update-initramfs -u

echo "VFIO a été configuré avec succès. Un redémarrage est nécessaire pour appliquer les changements."

# Fin du script
