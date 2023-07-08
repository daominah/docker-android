set -x

export dockerImgTag=daominah/docker-android11

docker build --tag=${dockerImgTag} --file=docker/Dockerfile .

docker push ${dockerImgTag}

set +x
