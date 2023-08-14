set -x

export dockerImgTag=daominah/android-30_google_apis_playstore_x86_64
export dockerCtnName=android-container
export optionMount='-v /media/tungdt/LinuxData/work/TuanNghiep/apk_installer:/root/tmp'

# optional env
# "EMULATOR_ARGS=-http-proxy http://127.0.0.1:24001"
# "EMULATOR_GPU=swiftshader_indirect"

docker rm -f ${dockerCtnName}
docker run -d --privileged $optionMount --name ${dockerCtnName}\
    -p 6080:6080 -p 5554:5554 -p 5555:5555 -p 4723:4723 \
    -e "DEVICE=Samsung Galaxy S10" -e "APPIUM=true" -e "EMULATOR_GPU=swiftshader_indirect" \
    ${dockerImgTag}

set +x
