root_dir=$(pwd)
cd ${root_dir}/terraform
terraform init
terraform apply

cd ${root_dir}/ansible
ansible-playbook -i inventory site.yml
