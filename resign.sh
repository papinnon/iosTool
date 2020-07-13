#!/bin/sh
TARGET_APP_PATH=$1
ENTITLEMENTS="Entitlements.plist"
# todo : add auto Entitlements
cat <<EOF > ./Entitlements.plist

EOF
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier com.ss.iphone.ugc.Awemeelon" "$TARGET_APP_PATH/Info.plist"
#----------------------------------------

# 5. 给MachO文件上执行权限
# 拿到MachO文件的路径
APP_BINARY=`plutil -convert xml1 -o - $TARGET_APP_PATH/Info.plist|grep -A1 Exec|tail -n1|cut -f2 -d\>|cut -f1 -d\<`
#上可执行权限
chmod +x "$TARGET_APP_PATH/$APP_BINARY"

#----------------------------------------
# 6. 重签名第三方 FrameWorks
TARGET_APP_FRAMEWORKS_PATH="$TARGET_APP_PATH/Frameworks"
if [ -d "$TARGET_APP_FRAMEWORKS_PATH" ];
then
for FRAMEWORK in "$TARGET_APP_FRAMEWORKS_PATH/"*
do

# 签名
/usr/bin/codesign --force --sign "$EXPANDED_CODE_SIGN_IDENTITY" "$FRAMEWORK"
done
fi

/usr/bin/codesign -fs "$EXPANDED_CODE_SIGN_IDENTITY" --no-strict --entitlements=$ENTITLEMENTS $TARGET_APP_PATH
