terraform {
  source = "../../../../modules/webserver"

extra_arguments "custom_vars" {
    commands = [
      "apply",
      "plan",
      "import",
      "push",
      "destroy",
      "refresh"
    ]

    required_var_files = ["${get_terragrunt_dir()}/../../../configuration/dev/us-west-1/webserver/webserver.tfvars"]
    #required_var_files = ["${get_terragrunt_dir()}/../../configuration/dev/us-east-1/basename(${get_terragrunt_dir()})/terraform.fvars"]
  }
}

dependency "subnet" {
  config_path = "../subnet"
}

dependency "secgroup" {
  config_path = "../secgroup"
}

dependency "db" {
  config_path = "../db"
}

# 🔧 Network çıktıları, modüle değişken olarak aktarılıyor
inputs = {
  alb-sg-id   = dependency.secgroup.outputs.alb-sg.id
  myapp-sg-id = dependency.secgroup.outputs.myapp-sg.id
  dbendpoint  = dependency.db.outputs.db-endpoint.address
  vpc_id      = dependency.subnet.outputs.vpc_id
  public_subnet_ids = dependency.subnet.outputs.public-subnet
  private_subnet_ids = dependency.subnet.outputs.private-subnet


}