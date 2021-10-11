.PHONY: all

all: cluster

key:
	@if [ ! -d "config/ssh" ]; then \
		echo "Creating ssh public key for cluster installation"; \
		mkdir -p config/ssh; \
		ssh-keygen -t ed25519 -N '' -f config/ssh/okd >/dev/null 2>&1; \
	else \
	  echo "key already exists." > /dev/null 2>&1; \
  	fi

validate:
	tofu validate

builder:
	podman build -t okd-builder:latest builder

cluster: key
	@export TF_VAR_ssh_public_key=$(cat ../config/ssh/okd.pub) && \
	export TF_CLI_ARGS=-compact-warnings && \
	pushd 01-initialize && \
		tofu init && tofu apply -auto-approve -var-file ../terraform.tfvars && popd && \
	pushd 02-installer && \
    	tofu init && tofu apply -auto-approve -var-file ../terraform.tfvars && popd && \
	pushd 03-bootstrap && \
    	tofu init && tofu apply -auto-approve -var-file ../terraform.tfvars && popd && \
	pushd 04-machines && \
    	tofu init && tofu apply -auto-approve -var-file ../terraform.tfvars && popd && \
	pushd 05-lb-dns && \
    	tofu init && tofu apply -auto-approve -var-file ../terraform.tfvars && popd

destroy: ccoctl_cleanup
	@export TF_VAR_ssh_public_key=$(cat ../config/ssh/okd.pub) && \
	export TF_CLI_ARGS=-compact-warnings && \
	pushd 05-lb-dns && \
    	tofu init && tofu destroy -auto-approve -var-file ../terraform.tfvars && popd && \
	pushd 04-machines && \
		tofu init && tofu destroy -auto-approve -var-file ../terraform.tfvars && popd && \
	pushd 03-bootstrap && \
		tofu init && tofu destroy -auto-approve -var-file ../terraform.tfvars && popd && \
	pushd 02-installer && \
	  	tofu init && tofu destroy -auto-approve -var-file ../terraform.tfvars && popd && \
	pushd 01-initialize && \
		tofu init && tofu destroy -auto-approve -var-file ../terraform.tfvars && popd && \
	$(MAKE) cleanup_files >/dev/null 2>&1

ccoctl_cleanup:
	@if [ -d "02-installer/credentials" ]; then \
  		pushd 02-installer && \
  		NAME=$$(tofu output -json credentials_name | jq -r) && \
    	ccoctl gcp delete --name=$${NAME} \
    		--project=$(TF_VAR_cluster_project_id) \
    		--shared-vpc-host-project=$(TF_VAR_shared_net_project_id) \
    		--credentials-requests-dir=credentials && \
    	popd; \
    fi

cleanup_files:
	@if [ -f "02-installer/install-config.yaml" ]; then \
		echo "cleaning up installation config"; \
        rm "02-installer/install-config.yaml" >/dev/null 2>&1; \
    fi; \
    rm -fr "02-installer/clusterconfig" >/dev/null 2>&1; \
    rm -fr "02-installer/credentials" >/dev/null 2>&1; \
    rm -fr "02-installer/ccoctl_output" >/dev/null 2>&1; \
    find . -maxdepth 1 -mindepth 1 -type d | while read dir; do \
    	if [ -f "$${dir}/terraform.tfstate" ]; then \
    	    rm "$${dir}/terraform.tfstate" >/dev/null 2>&1; \
    	    rm "$${dir}/terraform.tfstate.backup" >/dev/null 2>&1; \
    	    rm "$${dir}/terraform.tfstate.*.backup" >/dev/null 2>&1; \
    	fi \
    done; \
    if [ -d "config/ssh" ]; then rm -fr "config/ssh"; fi