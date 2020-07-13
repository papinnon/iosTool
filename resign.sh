#!/bin/sh
TARGET_APP_PATH=$1
ENTITLEMENTS="Entitlements.plist"

# todo: Add search local project for CFBundleIdentifier and corresponding identity
security cms -D -i $TARGET_APP_PATH/embedded.mobileprovision > ./tmp_mobileprovision.txt
cat <<EOF > ./Entitlements.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
EOF
sed -n "`grep -n "Entitlements" ./tmp_mobileprovision.txt|cut -d ':' -f1`,`grep -n '</dict>' ./tmp_mobileprovision.txt|xargs |cut -d ':' -f1`p" ./tmp_mobileprovision.txt >> ./Entitlements.plist
cat <<EOF >> ./Entitlements.plist
</plist>
EOF
rm ./tmp_mobileprovision.txt

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
rm $ENTITLEMENTS
