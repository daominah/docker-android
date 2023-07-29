# Android, Appium in Docker

Run Android 11 (API level 30) emulator as a Docker container. This emulator does not have Google Play Store, apps have to be installed from APK files.

DEPRECATED: In this fork, I try to install Google Play Store.

### Quick start

* [s0_build_img.sh](s0_build_img.sh) to build Docker image.
* [s1_run_ctn.sh](s1_run_ctn.sh) to run the Android emulator.

  ````bash
  # run with mount APK dir add `-v ${hostDir}:/root/tmp`
  docker rm -f android-container; docker run -v /root/apk_installer:/root/tmp --privileged -d -p 6080:6080 -p 5554:5554 -p 5555:5555 -p 4723:4723 -e 'DEVICE=Samsung Galaxy S10' -e APPIUM=true --name android-container daominah/docker-android11
  
  # try proxy
  docker rm -f android-container; docker run -v /root/apk_installer:/root/tmp --privileged -d --network=host -e 'DEVICE=Samsung Galaxy S10' -e APPIUM=true --name android-container -e ENABLE_PROXY_ON_EMULATOR=true -e 'HTTP_PROXY=http://127.0.0.1:24001' daominah/docker-android11
  ````

### Reference

* [adbd cannot run as root on image with Google Play](https://stackoverflow.com/questions/43923996/adb-root-is-not-working-on-emulator-cannot-run-as-root-in-production-builds)
* [Google Play Store missing issue on budtmo/docker-android](https://github.com/budtmo/docker-android/issues/130)
* [Android version and API Level](https://developer.android.com/guide/topics/manifest/uses-sdk-element)
* Download Android SDK [command line tools](https://developer.android.com/studio/index.html#command-line-tools-only) only
  (include [sdkmanager](https://developer.android.com/tools/sdkmanager)).  
  Fix [sdkmanager could not determine SDK root error](https://stackoverflow.com/a/67413427/4097963)
