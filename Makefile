namespace = airflow-test
repository = airflow-test
REAL_VERSION := $(shell date +%s%N)
old_image := $(shell sudo k3s ctr images list |grep $(repository) | cut -d " " -f 1 |sort -r | tail -n +1 |head -n 1 )
is_airflow := $(shell kubectl get namespace $(namespace) 2>/dev/null | grep -c $(namespace) )
is_keda := $(shell kubectl get namespace keda 2>/dev/null | grep -c keda )
keda_version = v2.10.0

ensure-helm-chart:
	@helm repo add apache-airflow https://airflow.apache.org
	@helm repo add kedacore https://kedacore.github.io/charts
	@helm repo update

ensure-keda:
ifeq ($(is_keda), 1)
	@echo keda exists
else
	@echo keda does not exist
	kubectl create namespace keda
endif
	helm upgrade --install keda kedacore/keda --namespace keda --version "$(keda_version)"

ensure-pv:
	@kubectl apply -f ./k8s/airflow-logs-pv.yaml

get-pods:
	watch -n 1 "kubectl get pods \
		--sort-by=.metadata.name \
		--sort-by=.metadata.namespace \
		-n $(namespace)"

build-wheel:
	cd dw_tool && python setup.py sdist bdist_wheel \
	&& mv dist/dw_tool-0.1-py3-none-any.whl ../dw_tool-0.1-py3-none-any.whl \
	&& rm -rf build dist *.egg-info

deploy-dev:
ifeq ($(is_airflow), 1)
	@echo namespace $(namespace) exists
else
	@echo namespace $(namespace) does not exist
	kubectl create namespace $(namespace)
endif
	sudo docker build --pull --tag $(repository):dev-$(REAL_VERSION) -f k8s/Dockerfile .
	sudo docker save $(repository):dev-$(REAL_VERSION) | sudo k3s ctr images import -
	sudo k3s ctr images remove $(old_image)
	helm upgrade --install -f k8s/airflow-value.yaml airflow apache-airflow/airflow \
		--namespace $(namespace) \
		--set images.airflow.repository=$(repository) \
		--set images.airflow.tag=dev-$(REAL_VERSION)

remove-dev:
	helm uninstall airflow --namespace $(namespace)

remove-image:
	sudo k3s ctr images remove $(old_image)

sh-pod: # make sh-pod select=webserver
	kubectl exec -n $(namespace) -it $(shell kubectl get pods -n airflow-dev |grep $(select)| cut -d " " -f 1) -- /bin/bash

log-pod: # make log-pod select=webserver
	kubectl logs -n $(namespace) $(shell kubectl get pods -n airflow-dev |grep $(select)| cut -d " " -f 1) -f




