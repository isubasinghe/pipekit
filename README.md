# Argo Workflows - Terraform Scripts
Terraform Scripts to get Argo Workflows up and running on AWS quickly 

## Instructions 
1. Install terraform 
2. Setup AWS for terraform 
3. Add an ssh key on AWS named $SSH_KEY_NAME with contents $SSH_KEY 
4. Set the variables `sshkeyname` to $SSH_KEY_NAME and `sshkey` to $SSH_KEY 
5. Run `terraform plan -var-file=aws.tfvars`
6. Run `terraform apply plan`

