set -x

export dockerImgTag=daominah/docker-android

docker build --tag=${dockerImgTag} --file=docker/Dockerfile .

set +x
