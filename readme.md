#  Android, Appium in Docker

In this fork, I try to install Google Play Store.

### Quick start

* [s0_build_img.sh](s0_build_img.sh) to build Docker image.
* [s1_run_ctn.sh](s1_run_ctn.sh) to run the Android emulator. 

  ````bash
  export dockerImgTag=daominah/docker-android
  export dockerCtnName=android
  docker run --privileged -d \
    -p 6080:6080 -p 5554:5554 -p 5555:5555 -p 4723:4723 \
    -e DEVICE="Samsung Galaxy S6" -e APPIUM=true \
    --name ${dockerCtnName} ${dockerImgTag}
  ````

### Reference

* [Google Play Store missing issue on budtmo/docker-android](https://github.com/budtmo/docker-android/issues/130)
* [Android version and API Level](https://developer.android.com/guide/topics/manifest/uses-sdk-element)
* 