basexInstallationDirectory=/opt/basex/
synopsxBaseDirectory=~/synopsx/
#basexInstallationDirectory=~/temp/synopsxInstallTest/
#synopsxBaseDirectory=~/temp/synopsx/
tempDir=$synopsxBaseDirectory"temp/"

baseXFileUrl=http://files.basex.org/releases/8.3/BaseX83.zip
saxonUrl=http://downloads.sourceforge.net/project/saxon/Saxon-HE/9.6/SaxonHE9-6-0-7J.zip
synopsxBranch=dev
synopsxUrl=https://github.com/ahn-ens-lyon/synopsx/archive/$synopsxBranch".zip"
dbaUrl=https://github.com/ahn-ens-lyon/dba/archive/master.zip
user=`who am i | awk '{print $1}'`


mkdir -p $tempDir
cd $tempDir

echo "Installing BaseX from "$baseXFileUrl" in "$basexInstallationDirectory
wget $baseXFileUrl 
unzip BaseX83.zip
rm BaseX83.zip
mv $basexInstallationDirectory $basexInstallationDirectory.old
mv basex $basexInstallationDirectory
echo "BaseX installed"

echo "Installing Saxon from "$saxonUrl" in "$basexInstallationDirectory"lib"
mkdir -p $tempDir"/saxon"
cd $tempDir"/saxon"
wget $saxonUrl
unzip SaxonHE9-6-0-7J.zip
rm SaxonHE9-6-0-7J.zip
mv *.jar $basexInstallationDirectory"lib"
echo "Saxon installed"


echo "Installing SynopsX from"$synopsxUrl" in "$synopsxBaseDirectory"synopsx"
wget "$synopsxUrl" 
unzip $synopsxBranch".zip"
rm $synopsxBranch".zip"
mv $synopsxBaseDirectory"synopsx/" $synopsxBaseDirectory"synopsx.old/"
mv synopsx-$synopsxBranch $synopsxBaseDirectory"synopsx"
ln -s $synopsxBaseDirectory"synopsx" $basexInstallationDirectory"webapp"
rm $basexInstallationDirectory"webapp/restxq.xqm"

echo "Installing dba from"$dba" in "$synopsxBaseDirectory"/dba"
wget "$dbaUrl" 
unzip master.zip
rm master.zip
rm -fr $synopsxBaseDirectory"dba"
mv dba-master $synopsxBaseDirectory"dba"
rm -fr $basexInstallationDirectory"webapp/dba"
ln -s $synopsxBaseDirectory"dba" $basexInstallationDirectory"webapp"

mkdir $synopsxBaseDirectory"data"
mv $basexInstallationDirectory"data" $basexInstallationDirectory"data.old"
ln -s $synopsxBaseDirectory"data" $basexInstallationDirectory"data"

rm -fr $tempDir
chown -R $user $basexInstallationDirectory
chmod -R u+w $basexInstallationDirectory
chown -R $user $synopsxBaseDirectory
chmod -R u+w $synopsxBaseDirectory

echo "You can run BaseX and SynopsX with: "$basexInstallationDirectory"bin/basexhttp"
