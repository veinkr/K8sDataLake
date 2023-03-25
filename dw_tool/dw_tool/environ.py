import os


def is_docker():
    return os.path.exists("/.dockerenv")


def is_pod():
    return bool([i for i in os.environ.keys() if i.startswith("KUBERNETES")])


def get_host():
    if is_pod():
        ip = os.environ.get("hostIP")
        if ip:
            return ip
        else:
            raise ValueError("hostIP not in environment")
    if is_docker():
        return "172.17.0.1"

    return "127.0.0.1"


if __name__ == "__main__":
    print(is_docker())
    print(is_pod())
    print(get_host())
