helm repo add apache-airflow https://airflow.apache.org
helm repo add kedacore https://kedacore.github.io/charts
helm repo update


kubectl create namespace keda
kubectl create namespace airflow


# docker image load to k3s
sudo docker build --pull --tag airflow:dev .
sudo docker save airflow:dev | sudo k3s ctr images import -

helm install keda kedacore/keda --namespace keda --version "v2.0.0"
helm upgrade --install airflow apache-airflow/airflow --namespace airflow

helm upgrade --install -f k8s-airflow.yaml airflow apache-airflow/airflow --namespace airflow

kubectl describe pods --all-namespaces
kubectl get pods --all-namespaces

helm uninstall airflow --namespace airflow

kubectl -n airflow exec -it airflow-webserver-58768b8cd9-nj5rt  /bin/bash
kubectl -n airflow logs airflow-scheduler-7c78f5659-sn6jk

kubectl port-forward svc/airflow-webserver 1259:8080 --namespace airflow --address '0.0.0.0'
