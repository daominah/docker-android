#!/bin/bash

function wait_emulator_to_be_ready () {
  boot_completed=false
  while [ "$boot_completed" == false ]; do
    status=$(adb wait-for-device shell getprop sys.boot_completed | tr -d '\r')
    echo "Boot Status: $status"

    if [ "$status" == "1" ]; then
      boot_completed=true
    else
      sleep 1
    fi
  done
}

function change_language_if_needed() {
  if [ ! -z "${LANGUAGE// }" ] && [ ! -z "${COUNTRY// }" ]; then
    wait_emulator_to_be_ready
    echo "Language will be changed to ${LANGUAGE}-${COUNTRY}"
    adb root && adb shell "setprop persist.sys.language $LANGUAGE; setprop persist.sys.country $COUNTRY; stop; start" && adb unroot
    echo "Language is changed!"
  fi
}

function install_google_play () {
  wait_emulator_to_be_ready
  if [[ $IMG_TYPE == *"playstore"* ]]; then
    echo "Google Play Service will be installed"
    adb install -r "/root/google_play_services.apk"
    echo "Google Play Store will be installed"
    adb install -r "/root/google_play_store.apk"
  else
    echo "not install Google Play because the image does not support"
  fi
}

function enable_proxy_if_needed () {
  if [ "$ENABLE_PROXY_ON_EMULATOR" = true ]; then
    if [ ! -z "${HTTP_PROXY// }" ]; then
      if [[ $HTTP_PROXY == *"http"* ]]; then
        protocol="$(echo $HTTP_PROXY | grep :// | sed -e's,^\(.*://\).*,\1,g')"
        proxy="$(echo ${HTTP_PROXY/$protocol/})"
        echo "[EMULATOR] - Proxy: $proxy"

        IFS=':' read -r -a p <<< "$proxy"

        echo "[EMULATOR] - Proxy-IP: ${p[0]}"
        echo "[EMULATOR] - Proxy-Port: ${p[1]}"

        wait_emulator_to_be_ready
        echo "Enable proxy on Android emulator. Please make sure that docker-container has internet access!"
        adb root

        echo "Set up the Proxy"
        adb shell "content update --uri content://telephony/carriers --bind proxy:s:"0.0.0.0" --bind port:s:"0000" --where "mcc=310" --where "mnc=260""
        sleep 5
        adb shell "content update --uri content://telephony/carriers --bind proxy:s:"${p[0]}" --bind port:s:"${p[1]}" --where "mcc=310" --where "mnc=260""

        if [ ! -z "${HTTP_PROXY_USER}" ]; then
          sleep 2
          adb shell "content update --uri content://telephony/carriers --bind user:s:"${HTTP_PROXY_USER}" --where "mcc=310" --where "mnc=260""
        fi
        if [ ! -z "${HTTP_PROXY_PASSWORD}" ]; then
          sleep 2
          adb shell "content update --uri content://telephony/carriers --bind password:s:"${HTTP_PROXY_PASSWORD}" --where "mcc=310" --where "mnc=260""
        fi

        adb unroot

        # Mobile data need to be restarted for Android 10 or higher
        adb shell svc data disable
        adb shell svc data enable
      else
        echo "Please use http:// in the beginning!"
      fi
    else
      echo "$HTTP_PROXY is not given! Please pass it through environment variable!"
      exit 1
    fi
  fi
}

function check_emulator_popups() {
  echo "Waiting for device..."
  wait_emulator_to_be_ready
  $ANDROID_HOME/platform-tools/adb wait-for-device shell true

  EMU_BOOTED=0
  n=0
  first_launcher=1
  echo 1 > /tmp/failed
  while [[ $EMU_BOOTED = 0 ]];do
      echo "Test for current focus"
      CURRENT_FOCUS=`$ANDROID_HOME/platform-tools/adb shell dumpsys window 2>/dev/null | grep -i mCurrentFocus`
      echo "Current focus: ${CURRENT_FOCUS}"
      case $CURRENT_FOCUS in
        *"Launcher"*)
        if [[ $first_launcher == 1 ]]; then
          echo "Launcher seems to be ready, wait 10 sec for another popup..."
          sleep 10
          first_launcher=0
        else
          echo "Launcher is ready, Android boot completed"
          EMU_BOOTED=1
          rm /tmp/failed
        fi
      ;;
      *"Not Responding: com.android.systemui"*)
        echo "Dismiss System UI isn't responding alert"
        adb shell su root 'kill $(pidof com.android.systemui)'
        first_launcher=1
      ;;
      *"Not Responding: com.google.android.gms"*)
        echo "Dismiss GMS isn't responding alert"
        adb shell input keyevent KEYCODE_ENTER
        first_launcher=1
      ;;
      *"Not Responding: system"*)
        echo "Dismiss Process system isn't responding alert"
        adb shell input keyevent KEYCODE_ENTER
        first_launcher=1
      ;;
      *"ConversationListActivity"*)
        echo "Close Messaging app"
        adb shell input keyevent KEYCODE_ENTER
        first_launcher=1
      ;;
      *)
        n=$((n + 1))
        echo "Waiting Android to boot 10 sec ($n)..."
        sleep 10
        if [ $n -gt 60 ]; then
            echo "Android Emulator does not start in 10 minutes"
            exit 2
        fi
      ;;
      esac
  done
  echo "Android Emulator started."
}

change_language_if_needed
sleep 1
enable_proxy_if_needed
sleep 1
install_google_play
sleep 1
check_emulator_popups
