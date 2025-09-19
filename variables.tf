
variable "region" { type = string; default = "eu-central-1" }
variable "project_name" { type = string; default = "bookwish-ms" }
variable "cluster_name" { type = string; default = "bookwish-eks-ms" }
variable "k8s_version" { type = string; default = "1.27" }

variable "node_desired_count" { type = number; default = 3 }
variable "node_min_count"     { type = number; default = 2 }
variable "node_max_count"     { type = number; default = 4 }
variable "node_instance_types" { type = list(string); default = ["t3.medium"] }

variable "db_allocated_storage" { type = number; default = 20 }
variable "db_engine_version"   { type = string; default = "15.3" }
variable "db_instance_class"   { type = string; default = "db.t3.micro" }
variable "db_name"             { type = string; default = "bookwish" }
variable "db_username"         { type = string; default = "postgres" }
variable "db_password"         { type = string; default = "ChangeMe123!" }
