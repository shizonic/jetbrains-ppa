#!/bin/bash
set -e

#--------------------------------------------------------------------------------------------------
# 1. generate package directory
#--------------------------------------------------------------------------------------------------

# load product config variables from specified file
PRODUCT_CONFIG=$1
source $PRODUCT_CONFIG

# make a copy of package template directory
echo "Copying template directory ..."
rm -rf debs/$PACKAGE
mkdir -p debs/$PACKAGE
cp -r package.template debs/$PACKAGE/$PACKAGE-package
cd debs/$PACKAGE/$PACKAGE-package

# modify debian/control 
echo "Generating files ..."
sed -i -e 's/PACKAGE/'$PACKAGE'/g' debian/control

# generate changelog (actually just add real IDE version) 
printf "%s (%s) stable; urgency=low" $PACKAGE $VERSION > debian/changelog
cat debian/changelog.template >> debian/changelog

# generate install script
echo "#!/bin/bash -e" > debian/postinst
cat ../../../$PRODUCT_CONFIG >> debian/postinst
cat debian/postinst.template >> debian/postinst

# generate remove script
echo "#!/bin/bash -e" > debian/postrm
cat ../../../$PRODUCT_CONFIG >> debian/postrm
cat debian/postrm.template >> debian/postrm

# clean up template files
rm debian/*.template


#--------------------------------------------------------------------------------------------------
# 2. build the .deb package
#--------------------------------------------------------------------------------------------------

# now actually build the .deb package
debuild -S


