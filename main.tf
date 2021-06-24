terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  token     = "AQAAAAAVYfbHAATuwVtkYVYIQUxyg2YcpEzFYUY"
  cloud_id  = "b1gna86k5nfpb693gn8u"
  folder_id = "b1gah9daaqvrbcism5fa"
  zone      = "ru-central1-a"
}

resource "yandex_compute_instance" "vm-1" {
  name = "production"

  resources {
    core_fraction = 20
    cores         = 2
    memory        = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd83869rbingor0in0ui"
      size     = 8
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    #    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    user-data = "${file("~/sf_module_12.1/meta1.txt")}"
  }
}


resource "yandex_compute_instance" "vm-2" {
  name = "stating"

  resources {
    core_fraction = 20
    cores         = 2
    memory        = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd83869rbingor0in0ui"
      size     = 8
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    #    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    user-data = "${file("~/sf_module_12.1/meta2.txt")}"
  }
}

resource "yandex_compute_instance" "vm-3" {
  name = "jenkins"

  resources {
    core_fraction = 20
    cores         = 2
    memory        = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd83869rbingor0in0ui"
      size     = 8
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    #    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    user-data = "${file("~/sf_module_12.1/meta3.txt")}"
  }
}

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.ip_address
}
output "internal_ip_address_vm_2" {
  value = yandex_compute_instance.vm-2.network_interface.0.ip_address
}
output "internal_ip_address_vm_3" {
  value = yandex_compute_instance.vm-3.network_interface.0.ip_address
}
output "external_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
}
output "external_ip_address_vm_2" {
  value = yandex_compute_instance.vm-2.network_interface.0.nat_ip_address
}
output "external_ip_address_vm_3" {
  value = yandex_compute_instance.vm-3.network_interface.0.nat_ip_address
}

### The Ansible inventory file
resource "local_file" "AnsibleInventory" {
  content = templatefile("${path.module}/inventory.tmpl",
    {
      production-ip = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address,
      stating-ip    = yandex_compute_instance.vm-2.network_interface.0.nat_ip_address,
      jenkins-ip    = yandex_compute_instance.vm-3.network_interface.0.nat_ip_address
    }
  )
  filename = "${path.module}/inventory.yml"
}
### The Ansible Jenkins User ADD
resource "null_resource" "ansible" {
  provisioner "local-exec" {
    command = "sleep 120; ansible-playbook -i ${path.module}/inventory.yml Role_playlist.yml"
  }
  depends_on = [local_file.AnsibleInventory]
}
