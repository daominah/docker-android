set -x

export dockerImgTag=daominah/docker-android11


docker build --tag=${dockerImgTag} --file=docker/Dockerfile .
if [[ $? -eq 0 ]]; then
    echo "built image ${dockerImgTag} with cache"
else
    docker build --tag=${dockerImgTag} --file=docker/Dockerfile --no-cache .
fi

docker push ${dockerImgTag}

set +x
