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

REM  use the latest build tool version
REM  and the oldest platform version for compatibility
for /F %%v in ('dir /b "%ANDROID_HOME%/build-tools"') do (
    set _BUILD_TOOLS_VERSION=%%v
)

for /F %%v in ('dir /b "%ANDROID_HOME%/platforms"') do (
    set _PLATFORM=%%v
)
 
for %%I in (%cd%) do (
    set "_APK_BASENAME=%%~nI"
)

echo Build with configuration: 
echo     build tools version: %_BUILD_TOOLS_VERSION%
echo     platform: %_PLATFORM%
echo     apk name: %_APK_BASENAME%

set _ANDROID_CP=%ANDROID_HOME%/platforms/%_PLATFORM%/android.jar
set _AAPT=%ANDROID_HOME%/build-tools/%_BUILD_TOOLS_VERSION%/aapt
set _DX=%ANDROID_HOME%/build-tools/%_BUILD_TOOLS_VERSION%/dx
set _ZIPALIGN=%ANDROID_HOME%/build-tools/%_BUILD_TOOLS_VERSION%/zipalign
set _ADB=%ANDROID_HOME%/platform-tools/adb
set _INTERMEDIATE="bin/gen/%_APK_BASENAME%.apk.unaligned"
set _JAVAC="%JAVA_HOME%/bin/javac"
set _JAR_SIGNER="%JAVA_HOME%/bin/jarsigner"
set _KEY_TOOL="%JAVA_HOME%/bin/keytool"
set "_SRC_DIR=%cd%/src"
set "_BIN_DIR=%cd%/bin"
set _KEY_STORE=%userprofile%/.keystore
set _KEY_STORE_PASSWORD='android'

if exist %_INTERMEDIATE% (
    del %_INTERMEDIATE%
)

if not exist %_BIN_DIR% (
    mkdir %_BIN_DIR%
)

if exist jni (
    echo Compiling native sources
    call ndk-build
)

%_AAPT%  package -f -m -J gen -M AndroidManifest.xml -S res -I %_ANDROID_CP%

for /r %%f in (*.java) do (
    %_JAVAC% -classpath %_ANDROID_CP%;bin -d bin -target 1.7 -source 1.7 %%f
)

call %_DX% --dex --output=classes.dex bin

call %_AAPT% package -f -M AndroidManifest.xml -S res -I %_ANDROID_CP% -F %_APK_BASENAME%.apk.unaligned

call %_AAPT% add %_APK_BASENAME%.apk.unaligned classes.dex

if not exist %_KEY_STORE% (
    call %_KEY_TOOL% -genkey -v -storepass %_KEY_STORE_PASSWORD% -alias androiddebugkey -keypass %_KEY_STORE_PASSWORD% -keyalg RSA -keysize 2048 -validity 10000 -dname "C=US, O=Android, CN=Android Debug"
)

echo .
echo Signing apk
call %_JAR_SIGNER% -keystore %_KEY_STORE% -storepass %_KEY_STORE_PASSWORD% %_APK_BASENAME%.apk.unaligned androiddebugkey

echo .
echo Allinging apk
call %_ZIPALIGN% -f 4 %_APK_BASENAME%.apk.unaligned %_APK_BASENAME%-debug.apk
