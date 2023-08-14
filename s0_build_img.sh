set -x


# set the following env values based on file `docker/sdkmanager_list.txt`
# Android 6.0: android-23;google_apis;arm64-v8a
# Android 8.1: android-27;google_apis;arm64-v8a CRASH
# Android 11.0: android-30;google_apis;x86_64
# Android 11.0: android-30;google_apis_playstore;x86_64
# Android 12.0: android-31;google_apis;x86_64
# Android 13.0: android-33;google_apis_playstore;x86_64

export ANDROID_VERSION=11.0
export API_LEVEL=30
export IMG_TYPE=google_apis
export SYS_IMG=x86_64

export dockerImgTag=daominah/android-${API_LEVEL}_${IMG_TYPE}_${SYS_IMG}


export buildArgs=
if [ -n "$ANDROID_VERSION" ]; then buildArgs+="--build-arg ANDROID_VERSION=$ANDROID_VERSION "; fi
if [ -n "$API_LEVEL" ]; then buildArgs+="--build-arg API_LEVEL=$API_LEVEL "; fi
if [ -n "$SYS_IMG" ]; then buildArgs+="--build-arg SYS_IMG=$SYS_IMG "; fi
if [ -n "$IMG_TYPE" ]; then buildArgs+="--build-arg IMG_TYPE=$IMG_TYPE "; fi
echo "buildArgs: $buildArgs"


docker build --tag=${dockerImgTag} --file=docker/Dockerfile $buildArgs .
export isBuiltWell=$?
if [[ $isBuiltWell -eq 0 ]]; then
    echo "built image ${dockerImgTag} with cache"
else
    echo "error when build image, you should try to build --no-cache"
    # docker build --tag=${dockerImgTag} --file=docker/Dockerfile $buildArgs --no-cache .
    # export isBuiltWell=$?
fi

if [[ $isBuiltWell -eq 0 ]]; then
    echo "successfully built, pushing it to to hub.docker.com"
    # docker push ${dockerImgTag}
fi


set +x
