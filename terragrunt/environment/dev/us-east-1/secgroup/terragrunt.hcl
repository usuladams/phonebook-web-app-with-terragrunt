terraform {
  source = "../../../../modules/secgroup"

extra_arguments "custom_vars" {
    commands = [
      "apply",
      "plan",
      "import",
      "push",
      "destroy",
      "refresh"
    ]

    required_var_files = ["${get_terragrunt_dir()}/../../../configuration/dev/us-east-1/secgroup/secgroup.tfvars"]
    #required_var_files = ["${get_terragrunt_dir()}/../../configuration/dev/us-east-1/basename(${get_terragrunt_dir()})/terraform.fvars"]
  }
}

dependency "subnet" {
  config_path = "../subnet"
}

# Network çıktıları, modüle değişken olarak aktarılıyor
inputs = {
  vpc_id      = dependency.subnet.outputs.vpc_id
}