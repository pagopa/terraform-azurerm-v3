locals {
  target_services = {
    postgresql = {
      port_ranges = ["5432", "6432"]
      protocol    = "tcp"
    }
    redis = {
      port_ranges = ["6379"]
      protocol    = "tcp"
    }
    cosmos = {
      port_ranges = ["443", "10255", "10256"]
      protocol    = "tcp"
    }
    eventhub = {
      port_ranges = ["5671-5672", "443", "9093"]
      protocol    = "tcp"
    }
    storage = {
      port_ranges = ["443"]
      protocol    = "tcp"
    }
  }
}
