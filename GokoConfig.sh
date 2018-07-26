#!/bin/bash -l
#encoding: utf-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

#开始打包操作
#计时
SECONDS=0
user=$(whoami)
#假设脚本放置在与项目相同的路径下
project_path=$(pwd)
#取当前时间字符串添加到文件结尾
now=$(date +"%Y_%m_%d_%H_%M_%S")
#指定项目的scheme名称
scheme="CloudShop"
#指定要打包的配置名
configuration="Debug"
#指定打包所使用的输出方式，目前支持app-store, package, ad-hoc, enterprise, development, 和developer-id，即xcodebuild的method参数
export_method='ad-hoc'
#指定项目地址
workspace_path="$project_path/${scheme}.xcworkspace"
#指定输出路径
output_path="/Users/${user}/Desktop/CIDemo/Debug"
#指定输出归档文件地址
archive_path="$output_path/Demo_${now}.xcarchive"
exportOptionsPlist_path="$output_path/ExportOptions.plist"
#指定输出ipa名称
ipa_name="Demo_${now}.ipa"
#指定输出ipa地址
ipa_path="$output_path/${ipa_name}"
#获取执行命令时的commit message
commit_msg="$1"
#输出设定的变量值
echo "===workspace path: ${workspace_path}==="
echo "===archive path: ${archive_path}==="
echo "===ipa path: ${ipa_path}==="
echo "===export method: ${export_method}==="
echo "===commit msg: $1==="
project_infoplist_path="$project_path/$scheme/Info.plist"
#########------------------------set build name &build Version-------------------------###########
now=$(date +"%Y%m%d%H%M")
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $now" "$project_infoplist_path"
/usr/libexec/PlistBuddy -c "Set :CFBundleName 脉宝云店_测试" "$project_infoplist_path"
#########------------------------set Version-------------------------###########
#CFBundleShortVersionString
#/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString 1.3.2" "$project_infoplist_path"

#########------------------------开始构建-----------------------#########
#先清空前一次build
fastlane gym  \
--workspace ${workspace_path} \
--scheme ${scheme} \
--clean \
--configuration ${configuration} \
--export_options ${exportOptionsPlist_path} \
--archive_path ${archive_path} \
--export_method ${export_method} \
--output_directory ${output_path} \
--output_name ${ipa_name}

#########------------------------上传到蒲公英-----------------------#########
#获取git提交的信息
MSG=`git log -1 --pretty=%B`
#上传到蒲公英，需要更换对应的uKey和_api_key
#curl -F "file=@${ipa_path}" -F "uKey=def1d6e91fe699aa9e8caddba1f04288" -F "_api_key=01fc0b28fd99a04049524a74296b3974" -F "updateDescription=${MSG}" https://qiniu-storage.pgyer.com/apiv1/app/upload

#########------------------------上传符号表-----------------------#########
#上传符号表到Bugtags,用于debug
#SKIP_DEBUG_BUILDS=1     #在Debug模式下编译是否自动上传符号表 0 上传 1不上传
#SKIP_SIMULATOR_BUILDS=1 #在模拟器环境下编译是否自动上传符号表 0上传 1不上传
#APP_KEY="609a4cb1d68e1a71e6f6b0e1607f3dc2"              #请填写应用的App Key
#APP_SECRET="1476c998a6daa69c9267aeef3daab839"           #请填写应用的App Secret，可向应用创建者索要
#SCRIPT_SRC=$(find "$project_path" -name 'Bugtags_dsym_autoupload.sh' | head -1)
#if [ ! "${SCRIPT_SRC}" ]; then
#   echo "Bugtags: err: script not found. Make sure that you're including Bugtags.bundle in your project directory"
#   exit 1
#fi
#source "${SCRIPT_SRC}"

#########------------------------结束-----------------------#########
#输出总用时
echo "===Finished. Total time: ${SECONDS}s==="