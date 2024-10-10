# Configuring GCP Provider
provider "google" {
  project = "coe-project-team"  
  region  = "us-central1"    
  zone    = "us-central1-a"
}

# Creating the first VM
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

  # Disk and OS
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"  
    }
  }

  # Metadata startup scripts
  metadata_startup_script = <<-EOT
    #!/bin/bash
    echo "Hello, world from my VM!" > /var/tmp/hello_world.txt
  EOT

  # tags
  tags = ["terraform-http-server"]
}

# Creating the second VM (newvm)
resource "google_compute_instance" "new_vm" {
  name         = "newvm"
  machine_type = "e2-medium"  
  zone         = "us-central1-a"

  # network and sub-network
  network_interface {
    network    = "default"
    subnetwork = "default"

    access_config {
      # Public IP
    }
  }

  # Disk and OS
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"  
    }
  }

  # Metadata startup scripts
  metadata_startup_script = <<-EOT
    #!/bin/bash
    echo "Hello, world from VM 2 !" > /var/tmp/hello_newvm.txt
  EOT

  # tags
  tags = ["terraform-http-server"]
}

# Firewall rules
resource "google_compute_firewall" "allow-http-ssh" {
  name    = "allow-http-ssh-1"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22", "80"]  # Permitir SSH (22) y HTTP (80)
  }

  source_ranges = ["0.0.0.0/0"]  # Permitir acceso desde cualquier IP
  target_tags   = ["http-server"]
}
