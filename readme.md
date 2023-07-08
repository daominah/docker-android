# Android, Appium in Docker

In this fork, I try to install Google Play Store.

### Quick start

* [s0_build_img.sh](s0_build_img.sh) to build Docker image.
* [s1_run_ctn.sh](s1_run_ctn.sh) to run the Android emulator.

  ````bash
  # run with mount APK dir add `-v ${hostDir}:/root/tmp`
  docker rm -f android-container; docker run -v /root/apk_installer:/root/tmp --privileged -d -p 6080:6080 -p 5554:5554 -p 5555:5555 -p 4723:4723 -e 'DEVICE=Samsung Galaxy S10' -e APPIUM=true --name android-container daominah/docker-android11
  ````

### Reference

* [Google Play Store missing issue on budtmo/docker-android](https://github.com/budtmo/docker-android/issues/130)
* [Android version and API Level](https://developer.android.com/guide/topics/manifest/uses-sdk-element)
* Download Android SDK [command line tools](https://developer.android.com/studio/index.html#command-line-tools-only) only
  (include [sdkmanager](https://developer.android.com/tools/sdkmanager)).  
  Fix [sdkmanager could not determine SDK root error](https://stackoverflow.com/a/67413427/4097963)
