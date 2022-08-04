
module "vpc_network" {
  source       = "./modules/vpc_network"
  project_id   = var.project_id
  service_name = var.service_name
}

module "compute_instance_template" {
  source     = "./modules/compute_instance_template"
  project_id = var.project_id

  region       = var.region
  zone         = var.zone
  network      = module.vpc_network.vpc_network_id
  machine_type = "e2-micro" # 2 vCPU, 1 GB memory

  service_name = var.service_name
  environment  = var.environment
  tags         = var.tags
  metadata = {
    foo = "bar"
  }
}

module "instance_groups" {
  source       = "./modules/compute_instance_group_manager"
  project_id   = var.project_id
  service_name = var.service_name
  zone         = var.zone

  network              = module.vpc_network.vpc_network_id
  instance_template_id = module.compute_instance_template.google_compute_instance_template_id
}

module "compute_target_http_proxy" {
  source       = "./modules/compute_target_http_proxy"
  project_id   = var.project_id
  service_name = var.service_name
  region       = var.region

  instance_group_id = module.instance_groups.google_compute_instance_group_manager_id
}
