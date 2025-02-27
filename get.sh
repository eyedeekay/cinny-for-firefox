#! /usr/bin/env sh

get_latest_release() {
  curl --silent "https://api.github.com/repos/cinnyapp/cinny/releases/latest" | # Get latest release from GitHub API
    jq -r .tag_name                                         # Extract tag value using jq
}

export LAST_VERSION=$(jq -r '.version' manifest.json)       # Get current version from manifest.json using jq
export VERSION=$(get_latest_release)                        # Get latest version
export NEWVERSION="\"version\": \"$VERSION\","              # Format new version

# Update manifest.json with the new version
jq --arg version "$VERSION" '.version = $version' manifest.json > manifest.json.tmp && mv manifest.json.tmp manifest.json

# Download and extract the latest release
wget -O cinny.tar.gz "https://github.com/cinnyapp/cinny/releases/download/$VERSION/cinny-$VERSION.tar.gz"
tar -xzf cinny.tar.gz
rm -rf cinny.tar.gz sidebar
cp -rv dist/ sidebar/

# Modify JavaScript files
DIST_FILE=$(find dist -name index-*.js)
SIDEBAR_FILE=$(find sidebar -name index-*.js)
echo "window.global ||= window;" > "$SIDEBAR_FILE"
minify "$DIST_FILE" >> "$SIDEBAR_FILE"

# Update HTML file
META_LINE="    <meta http-equiv=\"Content-Security-Policy\" content=\"default-src 'self' data: 'unsafe-inline' http: https:; style-src 'self'; script-src 'self' data: 'unsafe-inline'\"/>"
sed -i "6i $META_LINE" sidebar/index.html
sed -i "s|    <script>||g" sidebar/index.html
sed -i "s|    </script>||g" sidebar/index.html
sed -i 's/window.global ||= window;//g' sidebar/index.html

# Commit changes
git add .
