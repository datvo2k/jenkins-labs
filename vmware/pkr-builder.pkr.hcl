packer {
  required_version = ">= 1.7.0"
  required_plugins {
    vmware = {
      version = ">= 1.0.9"
      source  = "github.com/hashicorp/vmware"
    }
  }
}

locals {
  scripts = var.scripts == null ? (
    var.os_name == "ubuntu" || var.os_name == "debian" ? [
      "${path.root}/scripts/${var.os_name}/update_${var.os_name}.sh",
      "${path.root}/scripts/_common/motd.sh",
      "${path.root}/scripts/_common/sshd.sh",
      "${path.root}/scripts/${var.os_name}/networking_${var.os_name}.sh",
      "${path.root}/scripts/${var.os_name}/sudoers_${var.os_name}.sh",
      "${path.root}/scripts/_common/vagrant.sh",
      "${path.root}/scripts/${var.os_name}/systemd_${var.os_name}.sh",
      "${path.root}/scripts/_common/virtualbox.sh",
      "${path.root}/scripts/_common/vmware_debian_ubuntu.sh",
      "${path.root}/scripts/_common/parallels.sh",
      "${path.root}/scripts/${var.os_name}/hyperv_${var.os_name}.sh",
      "${path.root}/scripts/${var.os_name}/cleanup_${var.os_name}.sh",
      "${path.root}/scripts/_common/parallels_post_cleanup_debian_ubuntu.sh",
      "${path.root}/scripts/_common/minimize.sh"
    ]
  ) : var.scripts
  source_names = [for source in var.sources_enabled : trimprefix(source, "source.")]
}

# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  sources = var.sources_enabled
}