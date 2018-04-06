data "terraform_remote_state" "core_sg" {
  backend = "s3"
  workspace = "my_workspace"
  config { }
}

output "data_output" {
  value = "${data.terraform_remote_state.core_sg.core_ext_sg}"
}
