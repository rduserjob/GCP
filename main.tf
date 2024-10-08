# main.tf

# Configuring GCP Provider
provider "google" {
  project = "coe-project-team"  
  region  = "us-central1"    
  zone    = "us-central1-a"   #
}

# Creating vm
resource "google_compute_instance" "mi_vm" {
  name         = "terraform-vm"
  machine_type = "e2-micro"  
  zone         = "us-central1-a"

  # network and sub-network
  network_interface {
    network    = "default"
    subnetwork = "default"

    access_config {
      # Public IP
    }
  }

  # Disk and SO
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"  
    }
  }

  # Metadata startup scripts
  metadata_startup_script = <<-EOT
    #!/bin/bash
    echo "Hello,world since my VM!" > /var/tmp/hello_world.txt
  EOT

  # tags
  tags = ["terraform-http-server"]
}

# firewall tools
resource "google_compute_firewall" "allow-http-ssh" {
  name    = "allow-http-ssh-4"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22", "80"]  # Permitir SSH (22) y HTTP (80)
  }

  source_ranges = ["0.0.0.0/0"]  # Permitir acceso desde cualquier IP
  target_tags   = ["http-server"]
}
