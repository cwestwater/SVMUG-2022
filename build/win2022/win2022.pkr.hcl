packer {
  required_version = ">= 1.8.3"

  required_plugins {
    vsphere = {
      version = ">= v1.0.8"
      source  = "github.com/hashicorp/vsphere"
    }
  }

  required_plugins {
    windows-update = {
      version = ">= 0.14.1"
      source  = "github.com/rgl/windows-update"
    }
  }
}

source "vsphere-iso" "win2022std" {

  # vCenter Credentials

  username = "administrator@vsphere.local"
  password = "VMware1!"

  # vCenter Details

  vcenter_server      = "vcsa-01.localdomain"
  insecure_connection = true
  datacenter          = "Datacenter"
  cluster             = "Cluster"
  datastore           = "localssdesxi-01"
  folder              = "Templates"

  # VM Hardware Configuration

  vm_name       = "win2022std"
  guest_os_type = "windows9Server64Guest"
  firmware      = "efi"
  vm_version    = 19
  CPUs          = 2
  cpu_cores     = 1
  RAM           = 4096
  network_adapters {
    network_card = "vmxnet3"
    network      = "VM Network"
  }
  disk_controller_type = ["pvscsi"]
  storage {
    disk_size             = 20480
    disk_thin_provisioned = true
  }
  configuration_parameters = {
    "devices.hotplug"                         = "FALSE",
    "guestInfo.svga.wddm.modeset"             = "FALSE",
    "guestInfo.svga.wddm.modesetCCD"          = "FALSE",
    "guestInfo.svga.wddm.modesetLegacySingle" = "FALSE",
    "guestInfo.svga.wddm.modesetLegacyMulti"  = "FALSE"
  }

  # Removable Media Configuration

  iso_paths = [
    "[localssdesxi-01] ISO/Microsoft/Windows Server 2022/20348.169.210806-2348.fe_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso",
    "[localssdesxi-01] ISO/VMware/VMware-tools-windows-12.1.0-20219665.iso"
  ]

  floppy_files = [
    "../../bootfiles/win2022/standard/autounattend.xml",
    "../../scripts/common/install-vmtools64.cmd",
    "../../scripts/common/initial-setup.ps1"
  ]

  remove_cdrom        = true
  convert_to_template = false

  # Build Settings

  boot_command = [
    "<spacebar>"
  ]
  boot_wait = "3s"

  ip_wait_timeout  = "30m"
  communicator     = "winrm"
  winrm_timeout    = "8h"
  winrm_username   = "administrator"
  winrm_password   = "VMware1!"
  shutdown_command = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Build Complete\""
  shutdown_timeout = "1h"
}

source "vsphere-iso" "win2022stdcore" {

  # vCenter Credentials

  username = "administrator@vsphere.local"
  password = "VMware1!"

  # vCenter Details

  vcenter_server      = "vcsa-01.localdomain"
  insecure_connection = true
  datacenter          = "Datacenter"
  cluster             = "Cluster"
  datastore           = "localssdesxi-01"
  folder              = "Templates"

  # VM Hardware Configuration

  vm_name       = "win2022std"
  guest_os_type = "windows9Server64Guest"
  firmware      = "efi"
  vm_version    = 19
  CPUs          = 2
  cpu_cores     = 1
  RAM           = 4096
  network_adapters {
    network_card = "vmxnet3"
    network      = "VM Network"
  }
  disk_controller_type = ["pvscsi"]
  storage {
    disk_size             = 20480
    disk_thin_provisioned = true
  }
  configuration_parameters = {
    "devices.hotplug"                         = "FALSE",
    "guestInfo.svga.wddm.modeset"             = "FALSE",
    "guestInfo.svga.wddm.modesetCCD"          = "FALSE",
    "guestInfo.svga.wddm.modesetLegacySingle" = "FALSE",
    "guestInfo.svga.wddm.modesetLegacyMulti"  = "FALSE"
  }

  # Removable Media Configuration

  iso_paths = [
    "[localssdesxi-01] ISO/Microsoft/Windows Server 2022/20348.169.210806-2348.fe_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso",
    "[localssdesxi-01] ISO/VMware/VMware-tools-windows-12.1.0-20219665.iso"
  ]

  floppy_files = [
    "../../bootfiles/win2022/standardcore/autounattend.xml",
    "../../scripts/common/install-vmtools64.cmd",
    "../../scripts/common/initial-setup.ps1"
  ]

  remove_cdrom        = true
  convert_to_template = false

  # Build Settings

  boot_command = [
    "<spacebar>"
  ]
  boot_wait = "3s"

  ip_wait_timeout  = "30m"
  communicator     = "winrm"
  winrm_timeout    = "8h"
  winrm_username   = "administrator"
  winrm_password   = "VMware1!"
  shutdown_command = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Build Complete\""
  shutdown_timeout = "1h"
}


build {
  name = "Windows Server 2022"
  sources = [
    "source.vsphere-iso.win2022std",
    "source.vsphere-iso.win2022stdcore"
  ]

  provisioner "windows-restart" {}

  provisioner "powershell" {
    elevated_user     = "Administrator"
    elevated_password = "VMware1!"
    scripts = [
      "../../scripts/win2022/disable-tls.ps1",
      "../../scripts/win2022/disable-services.ps1",
      "../../scripts/win2022/remove-features.ps1",
      "../../scripts/win2022/config-os.ps1",
    ]
  }

  provisioner "windows-update" {
    pause_before    = "30s"
    search_criteria = "IsInstalled=0"
    filters = ["exclude:$_.Title -like '*VMware*'",
      "exclude:$_.Title -like '*Preview*'",
      "exclude:$_.Title -like '*Defender*'",
      "exclude:$_.InstallationBehavior.CanRequestUserInput",
    "include:$true"]
    restart_timeout = "120m"
  }

}