@ECHO OFF
REM  A Simple Script to build a simple APK without ant/gradle
REM  Copyright 2016 Wanghong Lin 
REM  
REM  Licensed under the Apache License, Version 2.0 (the "License");
REM  you may not use this file except in compliance with the License.
REM  You may obtain a copy of the License at
REM  
REM  	http://www.apache.org/licenses/LICENSE-2.0
REM  
REM  Unless required by applicable law or agreed to in writing, software
REM  distributed under the License is distributed on an "AS IS" BASIS,
REM  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
REM  See the License for the specific language governing permissions and
REM  limitations under the License.
REM  

REM  create a simple Android application to test this script
REM  
REM  $ android create project -n MyApplication -p MyApplication -k com.example -a MainActivity --target 8
REM 
REM  copy this script to the root of your Android project and run

if "%ANDROID_HOME%"=="" (
    echo 'ANDROID_HOME not set'
    goto exit
)

if not exist %ANDROID_HOME% (
    echo "Invalid ANDROID_HOME ---> %ANDROID_HOME%"
    goto exit
)

if "%JAVA_HOME%"=="" (
    echo 'ANDROID_HOME not set'
    goto exit
)

if not exist "%JAVA_HOME%" (
    echo "Invalid JAVA_HOME ---> %JAVA_HOME%"
    goto exit
)

for %%I in (%cd%) do (
    set "_APK_BASENAME=%%~nI"
)

echo Run with configuration: 
echo     apk name: %_APK_BASENAME%

set _ADB=%ANDROID_HOME%/platform-tools/adb
set _INTERMEDIATE="bin/gen/%_APK_BASENAME%.apk.unaligned"
set _JAVAC="%JAVA_HOME%/bin/javac"
set _JAR_SIGNER="%JAVA_HOME%/bin/jarsigner"
set _KEY_TOOL="%JAVA_HOME%/bin/keytool"
set "_SRC_DIR=%cd%\src"
set "_BIN_DIR=%cd%\bin"
set _KEY_STORE=%userprofile%/.keystore
set _KEY_STORE_PASSWORD='android'

%_ADB% logcat
