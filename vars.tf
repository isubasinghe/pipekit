variable "ec2_instance_name" {
  default = "developer-machine"
}

variable "ec2_instance_type" {
  default = "t2.xlarge"
}


variable "ec2_storage_size" {
  default = 30
}

variable "sshkeyname" {
  type = string 
  description = "The name of the ssh key to use with the file extension stripped off" 
}

variable "sshkey" {
  type = string 
  description = "contents of ec2_ssh_key_name's file"
}
