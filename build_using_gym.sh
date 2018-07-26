#!/bin/bash
#/Users/shmily/.jenkins/workspace/脉宝云店
#计时
SECONDS=0

#------------环境设置-----------------#
configuration="Debug"
#configuration="AdHoc_Release"

#假设脚本放置在与项目相同的路径下
project_path=$(pwd)

#获取*.xcodeproj的scheme名称
sechemeFile=$(find . -name '*.xcodeproj' -maxdepth 1  -exec basename {} \;)
scheme="${sechemeFile%.*}"

#指定打包所使用的输出方式，目前支持app-store, package, ad-hoc, enterprise, development, 和developer-id，即xcodebuild的method参数
export_method='ad-hoc'

#指定项目地址
workspace_path="$project_path/${scheme}.xcworkspace"

#获取执行命令时的commit message
commit_msg="$1"

# info.plist路径
project_infoplist_path="./${scheme}/Info.plist"

# #取版本号
bundleShortVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleShortVersionString" "${project_infoplist_path}")


#########------------------------set build version-------------------------###########
#取当前时间字符串添加到文件结尾
now=$(date +"%Y%m%d%H%M")
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $now" "$project_infoplist_path"


bundleName=$(/usr/libexec/PlistBuddy -c "print CFBundleName" "${project_infoplist_path}")
/usr/libexec/PlistBuddy -c "Set :CFBundleName ${bundleName}_测试" "$project_infoplist_path"
# #取build值
bundleVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleVersion" "${project_infoplist_path}")


#/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString 1.3.2" "$project_infoplist_path"
# # 这里的-f参数判断$myFile是否存在
# if [ -f "$output_directory" ]; then
#  rm -rf "$output_directory"
# fis
#mkdir "${output_path}"
#mkdir "/Users/$USER/Documents/${scheme}/${scheme}_${now}"

#########------------------------set build version-------------------------###########
# #bundleVersion自加1
# #bundleVersion=$(($bundleVersion + 1))
# #/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $bundleVersion" "$project_infoplist_path"

#取当前时间字符串添加到文件结尾
# now=$(date +"%Y_%m_%d_%H_%M")
# /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $now" "$project_infoplist_path"

#########------------------------set build version-------------------------###########


#bundleIdentifier=$(/usr/libexec/PlistBuddy -c "print CFBundleIdentifier" "${project_infoplist_path}")
#bundleIdentifierM="$bundleIdentifier.beta"
#/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $bundleIdentifierM" "$project_infoplist_path"
#
#info_array_name=$(find . -name 'Info.plist' -maxdepth 2)
#extensionScheme=""
#
#for data in ${info_array_name[@]}
#do
#if [[ $data =~ $scheme ]]
#then
#echo "包含"
#else
##不包含
##分割的左边
##fstr=`echo $data | cut -d \/ -f 1`
##分割的右边
#extensionScheme=`echo $data | cut -d \/ -f 2`
#fi
#
#done
#
#
## extension info.plist路径
#project_extension_infoplist_path="./${extensionScheme}/Info.plist"
#extensionBundleIdentifier=$(/usr/libexec/PlistBuddy -c "print CFBundleIdentifier" "${project_extension_infoplist_path}")
#extensionBundleIdentifierM="$bundleIdentifierM.$extensionScheme"
#/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $extensionBundleIdentifierM" "$project_extension_infoplist_path"


#测试
PGY_USER_Key="def1d6e91fe699aa9e8caddba1f04288"
PGY_API_Key="01fc0b28fd99a04049524a74296b3974"

fir_token="1db1f7a726fb27d55a5b7bf3f0dbdb23"

#文件夹名字
dirName="测试${bundleShortVersion}(build${bundleVersion})"

#指定输出ipa名称
ipa_name="${dirName}.ipa"

#指定输出ipa固定路径
output_path="/Users/$USER/Documents/${scheme}"

#指定输出ipa每次构建文件夹路径
output_path_var="${output_path}/${dirName}"

#完整输出文件路径
ipa_allpath="${output_path_var}/${ipa_name}"

#指定输出归档文件地址
archive_path="${output_path_var}/${dirName}.xcarchive"

export_options="./ExportOptions.plist"

#------------先清空前一次build  构建--------#
fastlane gym  --scheme ${scheme} --clean --configuration ${configuration} --archive_path ${archive_path} --export_method ${export_method} --export_options ${export_options} --output_directory ${output_path_var} --output_name ${ipa_name}


#------------上传到蒲公英-----------------#
#设置更新说明
MSG=`git log -1 --pretty=%B`
echo "准备上传蒲公英..."
curl -F "file=@${ipa_allpath}" -F "uKey=${PGY_USER_Key}" -F "_api_key=${PGY_API_Key}" -F "updateDescription=${MSG}" http://www.pgyer.com/apiv1/app/upload
if [ $? -eq 0 ];then
echo "上传蒲公英完成"
#rm -rf "${output_path_var}"
else
echo "上传蒲公英失败，重新尝试"
exit 1
fi

#------------上传到fir.im-----------------#
#echo "准备上传fir.im..."
#fir publish ${ipa_allpath} -T "${fir_token}" -c "this is changelog_${now}" true
#if [ $? -eq 0 ];then
#     echo "上传fir.im完成"
#else
#     echo "上传fir.im失败，重新尝试"
#fi




##  Bugtags Upload dSYM
#BugtagsAPP_KEY="609a4cb1d68e1a71e6f6b0e1607f3dc2"
#Bugtagssecret_key="1476c998a6daa69c9267aeef3daab839"
#echo "Bugtags: Uploading dSYM file..."
#ENDPOINT="https://work.bugtags.com/api/apps/symbols/upload"
#
#DSYM_PATH_ZIP="${output_path_var}/${dirName}.app.dSYM.zip"
#DSYM_PATH="${archive_path}/dSYMs/${scheme}.app.dSYM"
#
#DSYM_UUIDs_LIST=$(dwarfdump --uuid "${DSYM_PATH}" | cut -d' ' -f2,3)
## Check if UUIDs exists
#DSYM_UUIDs=$(echo "${DSYM_UUIDs_LIST}" | cut -d' ' -f1)
#echo "Bugtags: dSYM UUIDs -> ${DSYM_UUIDs}"
#
#STATUS=$(curl "${ENDPOINT}" --write-out %{http_code} --silent --output "${output_path_var}/${dirName}_upload.log" -F "file=@${DSYM_PATH_ZIP};type=application/octet-stream" -F "app_key=${BugtagsAPP_KEY}" -F "secret_key=${Bugtagssecret_key}" -F "version_name=${bundleShortVersion}" -F "version_code=${bundleVersion}" -F "uuids=${DSYM_UUIDs_LIST}")
#if [ $STATUS -ne 200 ]; then
#echo "Bugtags error: dSYM archive not succesfully uploaded."
#echo "Bugtags: deleting temporary dSYM archive..."
#exit 0
#fi
## Bugtags Finalize
#echo "Bugtags: dSYM upload complete."
#if [ "$?" -ne 0 ]; then
#echo "Bugtags error: an error was encountered uploading dSYM"
#exit 0
#fi
#
## Remove temp dSYM archive
#echo "Bugtags: deleting temporary dSYM archive..."
#/bin/rm -rf "${archive_path}"



##--------------七牛云上传参数-----------#
##BACKUP_SRC="/Users/$USER/Documents"
#BACKUP_DEST_NAME="${dirName}.zip"
#BUCKET="coder" #这个是你七牛空间名称，可以为公开空间或私有空间
#
#if [ -f "$BACKUP_DEST_NAME" ]; then
#rm -rf "$BACKUP_DEST_NAME"
#fi
##压缩文件
##-o 表示设置所有被压缩文件的最后修改时间为当前压缩时间
#cd "${output_path}"
#zip -q -r -o "$BACKUP_DEST_NAME" "$dirName"
#echo "所有数据打包完成，准备上传..."
#
##上传到七牛云
#qshell account "4yrFQUxTfyIKiQmmX6LBKMNeX1NJ9NZ_nQhNHGbw" "fwrZ4qBbIIrblNmrhoXNrHKYQuqNKXot_MjqSsrD"
#qshell rput "$BUCKET" "$BACKUP_DEST_NAME"  "$BACKUP_DEST_NAME" "http://upload-z2.qiniu.com" true
#if [ $? -eq 0 ];then
#echo "上传完成"
#rm -rf "$BACKUP_DEST_NAME"
#else
#echo "上传失败，重新尝试"
#fi






#输出总用时
echo "===Finished. Total time: ${SECONDS}s==="
#exit

