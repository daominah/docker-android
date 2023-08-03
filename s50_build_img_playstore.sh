set -x

export dockerImgTag=daominah/docker-android11-playstore


docker build --tag=${dockerImgTag} --file=docker/Dockerfile --build-arg IMG_TYPE=google_apis_playstore .
if [[ $? -eq 0 ]]; then
    echo "built image ${dockerImgTag} with cache"
else
    docker build --tag=${dockerImgTag} --file=docker/Dockerfile --no-cache .
fi

docker push ${dockerImgTag}

set +x
