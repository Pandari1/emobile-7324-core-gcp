output "vpc_name" {
  value = module.networking.vpc_name
}

output "vpc_self_link" {
  value = module.networking.vpc_self_link
}

output "subnet_name" {
  value = module.networking.subnet_name
}

output "subnet_self_link" {
  value = module.networking.subnet_self_link
}

output "pods_range_name" {
  value = module.networking.pods_range_name
}

output "services_range_name" {
  value = module.networking.services_range_name
}
