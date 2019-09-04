#!/bin/bash

echostderr() { printf "%s\n" "$*" >&2; }

if [ $# -ne 5 ]; then
	echo "Usage: "`basename "$0"`" <bundle-name> <extension title> <vendor short name> <vendor name> <CammelCaseName>"
	echo ""
	echo "Example: "`basename "$0"`" \"contao-fancy-functions-bundle\" \"Contao Fancy Functions Bundle\" \"musterm23\" \"Max Mustermann\" \"ContaoFancyFunctions\""
	echo ""
	echo "Please DON'T append \"Bundle\" or \"Extension\" to the CammelCaseName! It will be added automatically."
	echo ""
	echo "Execute this script in the directory that should contain your project directory."
	echo ""
	echo "Short Vendor Name is interpreted as GitHub user name!"
else
	bundle_name="$1"
	title="$2"
	vendor="$3"
	vendor_name="$4"
	cammel_case="$5"

	if [ -d "$bundle_name" ] || [ -f "$bundle_name" ]; then
		echostderr "Directory \"$bundle_name\" exists already!"
		exit 1
	fi

	git clone https://github.com/contao/skeleton-bundle
	if [ $? -ne 0 ]; then
		echostderr "git clone failed!"
		exit 2
	fi
	echo "Cloned Contao Skeleton Bundle from GitHub"

	mv skeleton-bundle/ "$bundle_name"/
	if [ $? -ne 0 ]; then
		echostderr "Cannot rename directory."
		exit 3
	fi
	echo "Renamed to $bundle_name/"

	cd "$bundle_name"/

	rm -rf .git/
	echo "Removed .git directory"

	rm LICENSE
	echo "Removed LICENSE file"

	sed -i "s/^(c) John Doe$/(c) ""$vendor_name""/gm" .php_cs.dist
	sed -i "s/\[package name\]/""$bundle_name""/gm" .php_cs.dist
	echo "Updated .php_cs.dist file"

	sed -i "s/^(c) John Doe$/(c) ""$vendor_name""/gm" composer.json
	sed -i "s/^\s*\"name\": \"contao\/skeleton-bundle\",\s*$/    \"name\": \"""$vendor""\/""$bundle_name""\",/gm" composer.json
	sed -i "s/^\s*\"description\": \"[[:alnum:] ]*\",\s*$/    \"description\": \"""$title""\",/gm" composer.json
	sed -i "s/^\s*\"name\": \"Leo Feyer\",\s*$/            \"name\": \"""$vendor_name""\",/gm" composer.json
	sed -i "s/^\s*\"homepage\": \"https:\/\/github\.com\/leofeyer\"\s*$/            \"homepage\": \"https:\/\/github.com\/""$vendor""\"/gm" composer.json
	sed -i "s/^\s*\"contao\/core-bundle\": \"4\.4\.\*\",\s*$/        \"contao\/core-bundle\": \"~4.4\",/gm" composer.json
	sed -i "s/^\s*\"contao-manager-plugin\": \"Contao\\\\\\\\SkeletonBundle\\\\\\\\ContaoManager\\\\\\\\Plugin\"\s*$/        \"contao-manager-plugin\": \"Contao\\\\\\\\""$cammel_case""Bundle\\\\\\\\ContaoManager\\\\\\\\Plugin\"/gm" composer.json
	sed -i "s/^\s*\"Contao\\\\\\\\SkeletonBundle\\\\\\\\\": \"src\/\"\s*$/            \"Contao\\\\\\\\""$cammel_case""Bundle\\\\\\\\\": \"src\/\"/gm" composer.json
	sed -i "s/^\s*\"Contao\\\\\\\\SkeletonBundle\\\\\\\\Tests\\\\\\\\\": \"tests\/\"\s*$/            \"Contao\\\\\\\\""$cammel_case""Bundle\\\\\\\\Tests\\\\\\\\\": \"tests\/\"/gm" composer.json
	sed -i "s/^\s*\"issues\": \"https:\/\/github\.com\/contao\/skeleton-bundle\/issues\",\s*$/        \"issues\": \"https:\/\/github\.com\/""$vendor""\/""$bundle_name""\/issues\",/gm" composer.json
	sed -i "s/^\s*\"source\": \"https:\/\/github\.com\/contao\/skeleton-bundle\"\s*$/        \"source\": \"https:\/\/github\.com\/""$vendor""\/""$bundle_name""\"/gm" composer.json
	echo "Updated composer.json file"

	sed -i "s/Contao Skeleton Bundle/""$title""/gm" phpunit.xml.dist
	echo "Updated phpunit.xml.dist file"

	mv src/ContaoSkeletonBundle.php src/"$cammel_case"Bundle.php
	sed -i "s/namespace Contao\\\\SkeletonBundle;/namespace ""$vendor""\\\\""$cammel_case""Bundle;/gm" src/"$cammel_case"Bundle.php
	sed -i "s/ContaoSkeletonBundle/""$cammel_case""Bundle/gm" src/"$cammel_case"Bundle.php
	echo "Updated and renamed src/ContaoSkeletonBundle.php."

	sed -i "s/Contao\\\\SkeletonBundle/""$vendor""\\\\""$cammel_case""Bundle/gm" src/ContaoManager/Plugin.php
	sed -i "s/ContaoSkeletonBundle/""$cammel_case""Bundle/gm" src/ContaoManager/Plugin.php
	echo "Updated src/ContaoManager/Plugin.php"

	mv src/DependencyInjection/ContaoSkeletonExtension.php src/DependencyInjection/"$cammel_case"Extension.php
	sed -i "s/ContaoSkeletonExtension/""$cammel_case""Extension/gm" src/DependencyInjection/"$cammel_case"Extension.php
	sed -i "s/Contao\\\\SkeletonBundle/""$vendor""\\\\""$cammel_case""Bundle/gm" src/DependencyInjection/"$cammel_case"Extension.php
	echo "Updated and renamed src/DependencyInjection/ContaoSkeletonExtension.php."

	mv tests/ContaoSkeletonBundleTest.php tests/"$cammel_case"BundleTest.php
	sed -i "s/ContaoSkeletonBundle/""$cammel_case""Bundle/gm" tests/"$cammel_case"BundleTest.php
	sed -i "s/Contao\\\\SkeletonBundle/""$vendor""\\\\""$cammel_case""Bundle/gm" tests/"$cammel_case"BundleTest.php
	echo "Updated and renamed tests/ContaoSkeletonBundleTest.php."
	
	#For usage of JetBrain IDEs
	printf "\n# idea\n/.idea" >> .gitignore
	echo "Updated .gitignore file"

	echo "README.md NOT updated"
fi
