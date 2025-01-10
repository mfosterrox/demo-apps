from plano import *
from plano.github import *

image_tag = "quay.io/skupper/patient-portal-frontend"

@command
def build(no_cache=False):
    no_cache_arg = "--no-cache" if no_cache else ""

    run(f"podman build {no_cache_arg} --format docker -t {image_tag} .")

@command
def run_():
    run(f"podman run --net host {image_tag} --host localhost --port 8080")

@command
def debug():
    run(f"podman run -it --net host --entrypoint /bin/sh {image_tag}")

@command
def push():
    run("podman login quay.io")
    run(f"podman push {image_tag}")

@command
def update_gesso():
    update_external_from_github("static/gesso", "ssorj", "gesso")
