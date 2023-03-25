FROM dockerproxy.com/apache/airflow:2.5.1-python3.9

USER root
# 编译工具以及更换源
RUN sed -i s@/deb.debian.org/@/mirrors.tuna.tsinghua.edu.cn/@g /etc/apt/sources.list
RUN apt update

RUN apt install build-essential -y
RUN apt install openjdk-17-jdk -y
RUN apt install wget -y

RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
RUN apt-get clean
RUN apt update
RUN apt install postgresql-client-15 -y

# 时区配置
ENV TZ=Asia/Shanghai
ENV DEBIAN_FRONTEND=noninteractive
RUN apt install -y tzdata \
    && ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    && dpkg-reconfigure --frontend noninteractive tzdata \
    && rm -rf /var/lib/apt/lists/*

# 安装依赖
USER airflow
ENV AIRFLOW_HOME=/opt/airflow

RUN pip install --user  -i https://pypi.tuna.tsinghua.edu.cn/simple pandas
RUN pip install --user  -i https://pypi.tuna.tsinghua.edu.cn/simple pyspark
RUN pip install --user  -i https://pypi.tuna.tsinghua.edu.cn/simple polars[all]

COPY requirements.txt ${AIRFLOW_HOME}
RUN pip install --user  -i https://pypi.tuna.tsinghua.edu.cn/simple -r "${AIRFLOW_HOME}/requirements.txt"

COPY dw_tool-0.1-py3-none-any.whl ${AIRFLOW_HOME}
RUN pip install --upgrade --no-deps --force-reinstall ${AIRFLOW_HOME}/dw_tool-0.1-py3-none-any.whl

COPY airflow/dags ${AIRFLOW_HOME}/dags


