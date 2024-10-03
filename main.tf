# main.tf

# Configurar el proveedor de GCP
provider "google" {
  project = "my-pagerduty-demo-project-v01"  # Reemplaza con el ID de tu proyecto
  region  = "us-central1"     # Reemplaza con la región deseada
  zone    = "us-central1-a"   # Reemplaza con la zona deseada
}

# Crear una red de VPC
resource "terraform_google_compute_network" "vpc_network" {
  name = "terraform-vpc"
}

# Crear una subred
resource "terraform_google_compute_subnetwork" "subnetwork" {
  name          = "mi-subred"
  region        = "us-central1"    # Reemplaza con la región deseada
  network       = terraform_google_compute_network.vpc_network.id
  ip_cidr_range = "10.0.0.0/24"
}

# Crear una instancia de VM
resource "terraform_google_compute_instance" "Terraform_vm" {
  name         = "Terraform-vm"
  machine_type = "e2-micro"  # Puedes elegir el tipo de máquina que prefieras
  zone         = "us-central1-a"

  # Conectar la instancia a la red
  network_interface {
    network    = terraform_google_compute_network.vpc_network.name
    subnetwork = terraform_google_compute_subnetwork.subnetwork.name

    access_config {
      # Esto asigna una IP pública
    }
  }

  # Especificar la imagen del sistema operativo
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"  # Puedes cambiar la imagen por la que prefieras
    }
  }

  # Metadata opcional, como startup scripts
  metadata_startup_script = <<-EOT
    #!/bin/bash
    echo "Hola, mundo desde mi VM!" > /var/tmp/hola_mundo.txt
  EOT

  # Etiquetas de red para el firewall
  tags = ["http-server"]
}

# Crear reglas de firewall para permitir el tráfico HTTP y SSH
resource "google_compute_firewall" "default" {
  name    = "allow-http-ssh"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22", "80"]  # Permitir SSH (22) y HTTP (80)
  }

  source_ranges = ["0.0.0.0/0"]  # Permitir acceso desde cualquier IP
  target_tags   = ["http-server"]
}
