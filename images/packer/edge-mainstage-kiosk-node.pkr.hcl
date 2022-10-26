variable "project_id" {
    type    = string
    default = "red-hat-mbu"
}

variable "zone" {
    type    = string
    default = "us-east1-b"
}

variable "image_name" {
    type    = string
    default = "edge-kiosk-node"
}

variable "ansible_vars_file" {
    type    = string
    default = null
}

local "extra_args" {
    expression = var.ansible_vars_file != null ? ["-e", "@${path.root}/../ansible/extra-vars.yml", "-e", "ansible_python_interpreter=/usr/bin/python3", "-e", var.ansible_vars_file] : ["-e", "@${path.root}/../ansible/extra-vars.yml", "-e", "ansible_python_interpreter=/usr/bin/python3"]
}

source "googlecompute" "edge-mainstage-kiosk-node" {
    project_id          = var.project_id
    # source_image_family = "rhel-8"
    source_image        = "rhel8"
    ssh_username        = "rhel"
    wait_to_add_ssh_keys = "60s"
    zone                = var.zone
    machine_type        = "n1-standard-4"
    image_name          = var.image_name
}

build {
    sources = ["sources.googlecompute.edge-mainstage-kiosk-node"]
    provisioner "ansible" {
      command = "ansible-playbook"
      playbook_file = "${path.root}/../ansible/edge-mainstage-kiosk-node-setup.yml"
      user = "rhel"
      extra_arguments = local.extra_args
    }
}