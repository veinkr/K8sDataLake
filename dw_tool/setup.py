# -*- coding:utf-8 -*-
"""
filename : setup.py
createtime : 2021/2/8 21:43
author : Demon Finch
"""
from setuptools import setup

setup(
    name="dw_tool",
    version="0.1",
    description="dw_tool",
    packages=["dw_tool"],
    install_requires=[
        "requests",
        "SQLAlchemy",
        "psycopg2-binary",
        "pandas",
        "msgqywx",
        "aiohttp",
        "redis",
        "aredis",
        "clickhouse_driver",
    ],
)
