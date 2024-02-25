# vars
PROJECT="mars-deployment"

# targets
cluster:
	@kind create cluster --name $(PROJECT) || echo "Cluster already exists..."

down:
	@kind delete cluster --name $(PROJECT)

# testing
test: down cluster
	@echo "Tests... Cluster will be taken down after"
	@kubectl create ns production
	@helm install $(PROJECT) ./ --wait
