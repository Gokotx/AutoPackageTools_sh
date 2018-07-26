#!/bin/bash

#计时
SECONDS=0

#------------环境设置-----------------#
configuration="Release"

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

# # 这里的-f参数判断$myFile是否存在
# if [ -f "$output_directory" ]; then
#  rm -rf "$output_directory"
# fi



#mkdir "${output_path}"
#mkdir "/Users/$USER/Documents/${scheme}/${scheme}_${now}"

# info.plist路径
project_infoplist_path="./${scheme}/Info.plist"

# #取版本号
bundleShortVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleShortVersionString" "${project_infoplist_path}")

#########------------------------set build version-------------------------###########
#取当前时间字符串添加到文件结尾
now=$(date +"%Y%m%d%H%M")
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $now" "$project_infoplist_path"


/usr/libexec/PlistBuddy -c "Set :CFBundleName 脉宝云店_正式" "$project_infoplist_path"

#########------------------------set build version-------------------------###########

# #取build值
bundleVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleVersion" "${project_infoplist_path}")

# #bundleVersion自加1
# #bundleVersion=$(($bundleVersion + 1))
# #/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $bundleVersion" "$project_infoplist_path"





#正式
PGY_USER_Key="b1ff4863fa8cb184f4044f668d7da158"
PGY_API_Key="a33be7817c89360eab0cf16804732130"

fir_token="d4457f73bc10d6969ddb5ebbbf1f189a"

#文件夹名字
dirName="正式${bundleShortVersion}(build${bundleVersion})"

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
fastlane gym  --scheme ${scheme} --clean --configuration ${configuration} --archive_path ${archive_path} --export_method ${export_method}  --export_options ${export_options}  --output_directory ${output_path_var} --output_name ${ipa_name}


##------------上传到fir.im-----------------#
#echo "准备上传fir.im..."
#fir publish ${ipa_allpath} -T "${fir_token}" -c "this is changelog_${now}" true
#if [ $? -eq 0 ];then
#     echo "上传fir.im完成"
#else
#     echo "上传fir.im失败，重新尝试"
#fi


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


#
##  Bugtags Upload dSYM
#BugtagsAPP_KEY="fea29e3307e6b218d9067f2bc74c5746"
#Bugtagssecret_key="4e5ba844bf3372e18df7e847b40450a8"
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
## remove archive
#echo "Bugtags: deleting temporary dSYM archive..."
#/bin/rm -rf "${archive_path}"

#--------------七牛云上传参数-----------#
##BACKUP_SRC="/Users/$USER/Documents"
#BACKUP_DEST_NAME="${dirName}.zip"
#BUCKET="coder" #这个是你七牛空间名称，可以为公开空间或私有空间
#
#if [ -f "$BACKUP_DEST_NAME" ]; then
# rm -rf "$BACKUP_DEST_NAME"
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
#    echo "上传完成"
#    rm -rf "$BACKUP_DEST_NAME"
#else
#    echo "上传失败，重新尝试"
#fi


#输出总用时
echo "===Finished. Total time: ${SECONDS}s==="
