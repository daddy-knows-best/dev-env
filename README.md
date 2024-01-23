# dev-env
dev-env for Daddy Knows Best

# history
01/22/2024 downgraded python version to 3.10.6

# installed packages

* pyenv
* pipenv
* ansible
* pre-commit
* detect-secrets (Yelp)
* docker in docker, kubectl
* github action: pre-commit, docker-publish

# how to run

```
$ docker compose pull
[+] Pulling 14/14
 ✔ dev-env 13 layers [⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]      0B/0B      Pulled                                        225.6s
   ✔ 445a6a12be2b Already exists                                                                     0.0s
   ✔ 5e8cb166128c Already exists                                                                     0.0s
   ✔ 1f4f7116f9c7 Already exists                                                                     0.0s
   ✔ 89bc601657a4 Pull complete                                                                    136.5s
   ✔ d2964040b138 Pull complete                                                                    136.7s
   ✔ 58ee2e35305f Pull complete                                                                    136.8s
   ✔ ff7916016ca2 Pull complete                                                                    152.8s
   ✔ a137eb12f207 Pull complete                                                                    202.9s
   ✔ f0c43ee4ac0a Pull complete                                                                    203.5s
   ✔ 93093980a774 Pull complete                                                                    205.3s
   ✔ 706010b009a5 Pull complete                                                                    223.1s
   ✔ c54d94ba6b3c Pull complete                                                                    223.3s
   ✔ 5ac553ae35ad Pull complete                                                                    223.4s

$ docker compose run --rm dev-env
03:06:30 ubuntu@3ae73b23d384 dev-env ±|main|→ ls
Dockerfile  LICENSE  README.md  docker-compose.yaml
03:06:33 ubuntu@3ae73b23d384 dev-env ±|main|→
03:28:53 ubuntu@78e06ea681cd dev-env ±|main|→ pyenv versions
  system
* 3.11.5 (set by /home/ubuntu/.pyenv/version)
03:29:01 ubuntu@78e06ea681cd dev-env ±|main|→ ansible --version
ansible [core 2.15.4]
  config file = None
  configured module search path = ['/home/ubuntu/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /home/ubuntu/.pyenv/versions/3.11.5/lib/python3.11/site-packages/ansible
  ansible collection location = /home/ubuntu/.ansible/collections:/usr/share/ansible/collections
  executable location = /home/ubuntu/.pyenv/versions/3.11.5/bin/ansible
  python version = 3.11.5 (main, Sep 16 2023, 18:50:11) [GCC 11.4.0] (/home/ubuntu/.pyenv/versions/3.11.5/bin/python3.11)
  jinja version = 3.1.2
  libyaml = True
03:29:05 ubuntu@78e06ea681cd dev-env ±|main|→
```

# build in my 2011 mbp ubuntu 22.04

The laptop is quite old one, but that is still working as it was supposed to be. It is a little noisy when it's building images, not a big problem for me.

```
 time docker compose build --no-cache
[+] Building 809.0s (17/17) FINISHED                                                                                            docker:default
 => [dev-env internal] load .dockerignore                                                                                                 0.0s
 => => transferring context: 2B                                                                                                           0.0s
 => [dev-env internal] load build definition from Dockerfile                                                                              0.0s
 => => transferring dockerfile: 3.53kB                                                                                                    0.0s
 => [dev-env internal] load metadata for docker.io/library/ubuntu:22.04                                                                   0.3s
 => CACHED [dev-env  1/13] FROM docker.io/library/ubuntu:22.04@sha256:aabed3296a3d45cede1dc866a24476c4d7e093aa806263c27ddaadbdce3c1054    0.0s
 => [dev-env  2/13] RUN groupadd --gid 1000 ubuntu &&  useradd -s /bin/bash --uid 1000 --gid 1000 -m ubuntu                               0.4s
 => [dev-env  3/13] RUN apt update                                                                                                       13.8s
 => [dev-env  4/13] RUN set -ex &&   apt install -y     sudo     vim     git     curl     build-essential     libbz2-dev     libffi-de  129.3s
 => [dev-env  5/13] RUN echo 'eval "$(pyenv init -)"' >> ~/.bashrc                                                                        0.7s
 => [dev-env  6/13] RUN echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc                                                             0.9s
 => [dev-env  7/13] RUN set -ex &&  curl https://pyenv.run | bash &&  pyenv install 3.11 &&  pyenv global 3.11 &&  pip install --upgra  422.1s
 => [dev-env  8/13] RUN set -ex &&  pip install   ansible  pipenv  pre-commit   detect-secrets                                           91.3s
 => [dev-env  9/13] RUN set -ex &&  cd /home/ubuntu &&  cp .bashrc .bashrc_copy &&  bash -c "$(curl -fsSL https://raw.githubusercontent.  2.5s
 => [dev-env 10/13] RUN set -ex &&   bash -c "curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -  14.5s
 => [dev-env 11/13] RUN set -ex &&   bash -c "for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt  95.6s
 => [dev-env 12/13] RUN set -ex &&  echo '    PubkeyAcceptedKeyTypes +ssh-rsa' | sudo tee -a /etc/ssh/ssh_config &&  echo '    HostKeyAl  0.7s
 => [dev-env 13/13] WORKDIR /dev-env                                                                                                      0.1s
 => [dev-env] exporting to image                                                                                                         36.3s
 => => exporting layers                                                                                                                  36.3s
 => => writing image sha256:c00c590052633bbaf3b07e46f6a90dffcba4b6756f628455cbf9f4e41005a5d0                                              0.0s
 => => naming to ghcr.io/daddy-knows-best/dev-env:main                                                                                    0.0s

real    13m29.358s
user    0m3.432s
sys     0m2.600s
```
