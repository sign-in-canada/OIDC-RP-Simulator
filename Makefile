AWS_ACCOUNT_ID := 333660502760
AWS_REGION := us-east-1
DOCKER_DIR := ./docker
TF_MODULE_DIR := ./terraform

.PHONY: apply docker fmt init plan setup

apply: init
	@terraform -chdir=${TF_MODULE_DIR} apply 

docker:
	docker build \
		-t ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/keycloak:latest \
		-f ./Dockerfile .
	aws ecr get-login-password --region ${AWS_REGION} | docker login \
		--username AWS \
		--password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
	docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/keycloak:latest

fmt:
	@terraform -chdir=${TF_MODULE_DIR} fmt 

init:
	@terraform -chdir=${TF_MODULE_DIR} init

plan: init
	@terraform -chdir=${TF_MODULE_DIR} plan

setup: init
	terraform -chdir=${TF_MODULE_DIR} apply
	$(MAKE) docker
	terraform apply
