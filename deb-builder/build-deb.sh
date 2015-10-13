#!/bin/bash
set -e

# load product config variables from specified file
PRODUCT_CONFIG=$1
source $PRODUCT_CONFIG
PRODUCT_LOWER=$(echo $PRODUCT | tr '[:upper:]' '[:lower:]')

#--------------------------------------------------------------------------------------------------
# utility functions
#--------------------------------------------------------------------------------------------------

function substitude_vars_in_file {
	sed -i -e 's/PACKAGE/'$PACKAGE'/g' $1
	sed -i -e 's/PRODUCT_LOWER/'$PRODUCT_LOWER'/g' $1
	sed -i -e 's/PRODUCT/'$PRODUCT'/g' $1
	sed -i -e 's/VERSION/'$VERSION'/g' $1
	sed -i -e "s/APP_NAME/$APP_NAME/g" $1
}

#--------------------------------------------------------------------------------------------------
# 1. generate package directory
#--------------------------------------------------------------------------------------------------

# make a copy of package template directory
echo "Copying template directory ..."
rm -rf debs/$PACKAGE
mkdir -p debs/$PACKAGE
cp -r package.template debs/$PACKAGE/$PACKAGE-package
cd debs/$PACKAGE/$PACKAGE-package

# modify debian/control 
echo "Generating files ..."
substitude_vars_in_file "debian/control"

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

# generate desktop shortcut file
SHORTCUT_FILE=jetbrains-$PRODUCT_LOWER.desktop
substitude_vars_in_file shortcut.desktop
mv shortcut.desktop $SHORTCUT_FILE
echo $SHORTCUT_FILE "/usr/share/applications/" > debian/install 

# clean up template files
rm debian/*.template


#--------------------------------------------------------------------------------------------------
# 2. build the .deb package
#--------------------------------------------------------------------------------------------------

# now actually build the .deb package
debuild -b || debuild -S



