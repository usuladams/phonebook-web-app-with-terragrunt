terraform {
  source = "../../../../modules/db"

extra_arguments "custom_vars" {
    commands = [
      "apply",
      "plan",
      "import",
      "push",
      "destroy",
      "refresh"
    ]

    required_var_files = ["${get_terragrunt_dir()}/../../../configuration/dev/us-east-1/db/db.tfvars"]
    #required_var_files = ["${get_terragrunt_dir()}/../../configuration/dev/us-east-1/basename(${get_terragrunt_dir()})/terraform.fvars"]
  }
}

dependency "subnet" {
  config_path = "../subnet"

}

dependency "secgroup" {
  config_path = "../secgroup"
}


# 🔧 Network çıktıları, modüle değişken olarak aktarılıyor
inputs = {
  rds-sg-id  = dependency.secgroup.outputs.rds-sg.id
  subnet_ids = dependency.subnet.outputs.private-subnet
}