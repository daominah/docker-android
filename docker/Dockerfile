FROM appium/appium:v1.22.3-p1

# LABEL maintainer="Budi Utomo <budtmo.os@gmail.com>"
LABEL maintainer="Tung <tung.daothanhtung@gmail.com>"

#=============
# Set WORKDIR
#=============
WORKDIR /root

#==================
# General Packages
#------------------
# xterm
#   Terminal emulator
# supervisor
#   Process manager
# socat
#   Port forwarder
#------------------
#  NoVNC Packages
#------------------
# x11vnc
#   VNC server for X display
#       We use package from ubuntu 18.10 to fix crashing issue
# openbox
#   Windows manager
# feh
#   ScreenBackground
# menu
#   Debian menu
# python-numpy
#   Numpy, For faster performance: https://github.com/novnc/websockify/issues/77
# net-tools
#   Netstat
#------------------
#  Video Recording
#------------------
# ffmpeg
#   Video recorder
# jq
#   Sed for JSON data
#------------------
#    KVM Package
# for emulator x86
# https://help.ubuntu.com/community/KVM/Installation
#------------------
# qemu-kvm
# libvirt-bin
# ubuntu-vm-builder
# bridge-utils
#==================
ADD docker/configs/x11vnc.pref /etc/apt/preferences.d/

RUN apt-get update
RUN apt-get install -qy procps net-tools telnet iputils-ping vim gettext-base curl
RUN apt-get install -qy locate

RUN apt-get -qqy update && apt-get -qqy install --no-install-recommends \
    xterm \
    supervisor \
    socat \
    x11vnc \
    openbox \
    feh \
    menu \
    python-numpy \
    net-tools \
    ffmpeg \
    jq \
    qemu-kvm \
    libvirt-bin \
    ubuntu-vm-builder \
    bridge-utils \
 && apt clean all \
 && rm -rf /var/lib/apt/lists/*

#=======
# noVNC
# Use same commit id that docker-selenium uses
# https://github.com/elgalu/docker-selenium/blob/236b861177bd2917d864e52291114b1f5e4540d7/Dockerfile#L412-L413
#=======
ENV NOVNC_SHA="b403cb92fb8de82d04f305b4f14fa978003890d7" \
    WEBSOCKIFY_SHA="558a6439f14b0d85a31145541745e25c255d576b"
RUN  wget -nv -O noVNC.zip "https://github.com/kanaka/noVNC/archive/${NOVNC_SHA}.zip" \
 && unzip -x noVNC.zip \
 && rm noVNC.zip  \
 && mv noVNC-${NOVNC_SHA} noVNC \
 && wget -nv -O websockify.zip "https://github.com/kanaka/websockify/archive/${WEBSOCKIFY_SHA}.zip" \
 && unzip -x websockify.zip \
 && mv websockify-${WEBSOCKIFY_SHA} ./noVNC/utils/websockify \
 && rm websockify.zip \
 && ln noVNC/vnc_auto.html noVNC/index.html

#======================
# Install SDK packages
#======================

ARG BROWSER=android
ARG CHROME_DRIVER=2.40
ARG GOOGLE_PLAY_SERVICE=23.12.13
ARG GOOGLE_PLAY_STORE=35.2.17
ARG APP_RELEASE_VERSION=1.5-p0
# PROCESSOR seems like unused
ARG PROCESSOR=x86_64

#==============================================
# Download proper version of chromedriver
# to be able to use Chrome browser in emulator
#==============================================
RUN wget -nv -O chrome.zip "https://chromedriver.storage.googleapis.com/${CHROME_DRIVER}/chromedriver_linux64.zip" \
 && unzip -x chrome.zip \
 && rm chrome.zip

#================================================================
# Download Google Play Services APK and Play Store from apklinker
#================================================================
RUN wget -nv -O google_play_services.apk "https://www.apklinker.com/wp-content/uploads/uploaded_apk/64304544b4494/com.google.android.gms_23.12.13-040700-520023152_231213022_MinAPI23_(x86)(nodpi)_apklinker.com.apk"
RUN wget -nv -O google_play_store.apk "https://www.apklinker.com/wp-content/uploads/uploaded_apk/643274c038256/com.android.vending_35.2.17-21-0-PR-521597291_83521710_MinAPI21_(arm64-v8a,armeabi-v7a,x86,x86_64)(nodpi)_apklinker.com.apk"


#===============================================================================
#===============================================================================
# The following build arg pick emulator system image, some notes:
# * ARM64 emulation on a x86_64 host currently is only possible up to API level 27
#   (https://stackoverflow.com/a/74819011/4097963).
# * My test phone Samsung A02S has Android 12.
# * They say Android 11 can run ARM apk but many apps still crash.
#   (https://developer.android.com/studio/releases/emulator#30-0-0)

#ARG ANDROID_VERSION=6.0
#ARG API_LEVEL=23
#ARG ANDROID_VERSION=8.1
#ARG API_LEVEL=27
ARG ANDROID_VERSION=11.0
ARG API_LEVEL=30
#ARG ANDROID_VERSION=12.0
#ARG API_LEVEL=31
#ARG ANDROID_VERSION=13.0
#ARG API_LEVEL=33

#ARG SYS_IMG=x86
ARG SYS_IMG=x86_64
#ARG SYS_IMG=arm64-v8a

# "playstore" image cannot run adbd root
# some API_LEVEL, SYS_IMG do not have playstore
ARG IMG_TYPE=google_apis
#ARG IMG_TYPE=google_apis_playstore

#===============================================================================
#===============================================================================


ENV ANDROID_VERSION=$ANDROID_VERSION \
    API_LEVEL=$API_LEVEL \
    PROCESSOR=$PROCESSOR \
    SYS_IMG=$SYS_IMG \
    IMG_TYPE=$IMG_TYPE \
    BROWSER=$BROWSER \
    CHROME_DRIVER=$CHROME_DRIVER \
    GOOGLE_PLAY_SERVICE=$GOOGLE_PLAY_SERVICE \
    GOOGLE_PLAY_STORE=$GOOGLE_PLAY_STORE \
    APP_RELEASE_VERSION=$APP_RELEASE_VERSION \
    APP_TYPE=Emulator
ENV PATH ${PATH}:${ANDROID_HOME}/build-tools

RUN yes | sdkmanager --licenses && \
    sdkmanager "platforms;android-${API_LEVEL}" "system-images;android-${API_LEVEL};${IMG_TYPE};${SYS_IMG}" "emulator"

# try to solve Vulkan error:
# cannot add `/opt/android/emulator/qemu/linux-x86_64/lib64/vulkan/libvulkan.so`
# /opt/android/emulator/lib/advancedFeatures.ini
# /opt/android/emulator/lib/advancedFeaturesCanary.ini

RUN ln -s /opt/android/emulator/lib64 /opt/android/emulator/qemu/linux-x86_64/lib64
ENV advancedFeatures=/opt/android/system-images/android-$API_LEVEL/$IMG_TYPE/$SYS_IMG/advancedFeatures.ini
RUN cat $advancedFeatures
RUN cp $advancedFeatures $HOME/.android/advancedFeatures.ini

#================================================
# noVNC Default Configurations
# These Configurations can be changed through -e
#================================================
ENV DISPLAY=:0 \
    SCREEN=0 \
    SCREEN_WIDTH=1600 \
    SCREEN_HEIGHT=900 \
    SCREEN_DEPTH=24+32 \
    LOCAL_PORT=5900 \
    TARGET_PORT=6080 \
    TIMEOUT=1 \
    VIDEO_PATH=/tmp/video \
    LOG_PATH=/var/log/supervisor

#================================================
# openbox configuration
# Update the openbox configuration files to:
#   + Use a single virtual desktop to prevent accidentally switching
#   + Add background
#================================================
ADD images/logo_dockerandroid.png /root/logo.png
ADD src/.fehbg /root/.fehbg
ADD src/rc.xml /etc/xdg/openbox/rc.xml
RUN echo /root/.fehbg >> /etc/xdg/openbox/autostart

#======================
# Workarounds
#======================
# Fix emulator from crashing when running as root user.
# See https://github.com/budtmo/docker-android/issues/223
ENV QTWEBENGINE_DISABLE_SANDBOX=1

#===============
# Expose Ports
#---------------
# 4723
#   Appium port
# 6080
#   noVNC port
# 5554
#   Emulator port
# 5555
#   ADB connection port
#===============
EXPOSE 4723 6080 5554 5555

#======================
# Add Emulator Devices
#======================
COPY devices ${ANDROID_HOME}/devices

#===================
# Run docker-appium
#===================
COPY src /root/src
COPY supervisord.conf /root/

# https://developer.android.com/studio/run/emulator-acceleration#command-gpu:
# auto, host, swiftshader_indirect, angle_indirect, guest.
ENV EMULATOR_GPU=auto
# https://developer.android.com/studio/run/emulator-networking.html#proxy:
# go to menu `Extended controls`: `Settings`: `Proxy`, alternatively, you can
# configure a proxy from the command line with the -http-proxy <proxy> option
# when starting the emulator,
# example docker run: -e 'EMULATOR_ARGS=-http-proxy http://127.0.0.1:24001'
ENV EMULATOR_ARGS=""

RUN chmod -R +x /root/src && chmod +x /root/supervisord.conf

HEALTHCHECK --interval=2s --timeout=40s --retries=1 \
    CMD timeout 40 adb wait-for-device shell 'while [[ -z $(getprop sys.boot_completed) ]]; do sleep 1; done'

RUN ln -s ${ANDROID_HOME}/emulator/emulator /usr/bin/

COPY daominah_bashrc /root/.bashrc
COPY daominah_bash_history /root/.bash_history


RUN updatedb


CMD /usr/bin/supervisord --configuration /root/supervisord.conf
#CMD bash
