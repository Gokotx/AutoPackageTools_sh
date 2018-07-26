#!/bin/bash


#/Users/shmily/.jenkins/workspace/脉宝云店


#测试
PGY_USER_Key="def1d6e91fe699aa9e8caddba1f04288"
PGY_API_Key="01fc0b28fd99a04049524a74296b3974"

ipa_name="测试1.4.2(build201711061638)"

#完整输出文件路径
ipa_allpath="/Users/maibaotest/Documents/CloudShop/${ipa_name}/${ipa_name}.ipa”

#------------上传到蒲公英-----------------#
#设置更新说明
MSG=`git log -1 --pretty=%B`
echo "准备上传蒲公英..."
curl -F "file=@${ipa_allpath}" -F "uKey=${PGY_USER_Key}" -F "_api_key=${PGY_API_Key}" -F "updateDescription=${MSG}" http://www.pgyer.com/apiv1/app/upload
if [ $? -eq 0 ];then
     echo "上传蒲公英完成"
else
     echo "上传蒲公英失败，重新尝试"
fi

