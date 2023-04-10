set -x

export dockerImgTag=daominah/docker-android
export dockerCtnName=android

docker rm -f ${dockerCtnName}
docker run --privileged -d \
  -p 6080:6080 -p 5554:5554 -p 5555:5555 -p 4723:4723 \
  -e DEVICE="Nexus 5" -e APPIUM=true \
  --name ${dockerCtnName} ${dockerImgTag}

set +x
