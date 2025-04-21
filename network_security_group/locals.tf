locals {
  target_services = {
    postgresql = {
      port_ranges = [5432, 6432]
      protocol = "tcp"
    }
    redis = {
      port_ranges = [6379]
      protocol = "tcp"
    }
  }
}
