#! /usr/bin/env sh

# Function to get the latest release tag from the Cinny GitHub repository
get_latest_release() {
  curl --silent "https://api.github.com/repos/cinnyapp/cinny/releases/latest" |  # Fetch the latest release data from the GitHub API
    grep '"tag_name":' |  # Extract the line containing the tag name
    sed -E 's/.*"([^"]+)".*/\1/'  # Extract the actual tag name from the JSON response
}

# Extract the current version from the manifest.json file
export LAST_VERSION=$(grep '"version":' manifest.json)

# Get the latest release version from the GitHub API using the get_latest_release function
export VERSION=$(get_latest_release)

# Create a new version string for the manifest.json file
export NEWVERSION="\"version\": \"$VERSION\","

# Update the version in the manifest.json file
sed -i "s|$LAST_VERSION|$NEWVERSION|g" manifest.json

# Download the latest release tarball from the Cinny GitHub repository
wget -O cinny.tar.gz "https://github.com/cinnyapp/cinny/releases/download/$VERSION/cinny-$VERSION.tar.gz"

# Extract the contents of the tarball
tar -xzf cinny.tar.gz

# Remove the downloaded tarball and any existing sidebar directory
rm -rf cinny.tar.gz sidebar

# Copy the extracted distribution files to the sidebar directory
cp -rv dist/ sidebar/

# Find the main JavaScript file in the dist directory
DIST_FILE=$(find dist -name index-*.js)

# Find the main JavaScript file in the sidebar directory
SIDEBAR_FILE=$(find sidebar -name index-*.js)

# Add a line to the sidebar JavaScript file to ensure window.global is defined
echo "window.global ||= window;" > "$SIDEBAR_FILE"

# Minify the distribution JavaScript file and append it to the sidebar JavaScript file
minify "$DIST_FILE" >> "$SIDEBAR_FILE"

# Add a Content-Security-Policy meta tag to the sidebar/index.html file
META_LINE="    <meta http-equiv=\"Content-Security-Policy\" content=\"default-src 'self' data: 'unsafe-inline' http: https:; style-src 'self'; script-src 'self' data: 'unsafe-inline'\"/>"
sed -i "6i $META_LINE" sidebar/index.html

# Remove any script tags from the sidebar/index.html file
sed -i "s|    <script>||g" sidebar/index.html
sed -i "s|    </script>||g" sidebar/index.html

# Remove the window.global definition from the sidebar/index.html file
sed -i 's/window.global ||= window;//g' sidebar/index.html

# Add all changes to git
git add .
