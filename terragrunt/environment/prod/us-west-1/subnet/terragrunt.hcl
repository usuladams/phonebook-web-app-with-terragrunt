terraform {
  source = "../../../../modules/subnet"

extra_arguments "custom_vars" {
    commands = [
      "apply",
      "plan",
      "import",
      "push",
      "destroy",
      "refresh"
    ]

    required_var_files = ["${get_terragrunt_dir()}/../../../configuration/prod/us-west-1/subnet/subnet.tfvars"]
    #required_var_files = ["${get_terragrunt_dir()}/../../../configuration/dev/us-east-1/${basename(get_terragrunt_dir())}/subnet.tfvars"]
    #required_var_files = ["${get_terragrunt_dir()}/../../configuration/dev/us-east-1/basename(${get_terragrunt_dir()})/terraform.fvars"]
  }
}
