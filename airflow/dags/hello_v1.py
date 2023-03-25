from airflow import DAG
from airflow.operators.python import PythonOperator
from pendulum import timezone
from datetime import timedelta, datetime
from airflow.operators.empty import EmptyOperator
from airflow.utils.trigger_rule import TriggerRule


def print_hello(person: str):
    print(f"hello {person}")


with DAG(
    "hello_v1",
    default_args={
        "depends_on_past": False,
        "retries": 1,
        "retry_delay": timedelta(minutes=1),
    },
    description="hello_v1",
    schedule_interval="*/5 * * * *",
    start_date=datetime(2022, 1, 1, 20, 30, tzinfo=timezone("Asia/Shanghai")),
    max_active_runs=1,
    catchup=False,
    tags=["finance"],
) as dags:
    dummy = EmptyOperator(task_id="dummy", trigger_rule=TriggerRule.NONE_FAILED)
    hello = PythonOperator(
        task_id="hello",
        python_callable=print_hello,
        op_kwargs={"person": "Harold Finch"},
    )
    hello >> dummy
