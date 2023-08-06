PKRDIR ?= packer
ANSDIR ?= ansible

default: build

build:
	@echo "Building image..."
	@cd $(PKRDIR) && packer build -var-file=./vars/ubuntu_server_2204_amd64.pkrvars.hcl ./templates/ubuntu_server_2204_amd64.pkr.hcl

delete:
	@echo "Deleting image..."
	rm -rf $(PKRDIR)/output/*

lint:
	@echo "Linting repo..."
	docker run \
		--rm \
		--platform linux/amd64 \
		-v ${PWD}:/tmp/lint \
		-e RUN_LOCAL=true \
		-e USE_FIND_ALGORITHM=true \
		github/super-linter
