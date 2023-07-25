#! /usr/bin/env sh
export VERSION=v2.2.6

wget -O cinny.tar.gz "https://github.com/cinnyapp/cinny/releases/download/$VERSION/cinny-$VERSION.tar.gz"
tar -xzf cinny.tar.gz
rm cinny.tar.gz
cp -rv dist/* sidebar/
DIST_FILE=$(find dist -name index-*.js)
SIDEBAR_FILE=$(find sidebar -name index-*.js)
echo "window.global ||= window;" > "$SIDEBAR_FILE"
minify "$DIST_FILE" >> "$SIDEBAR_FILE"
META_LINE="    <meta http-equiv=\"Content-Security-Policy\" content=\"default-src 'self' data: 'unsafe-inline' http: https:; style-src 'self'; script-src 'self' data: 'unsafe-inline'\"/>"
sed -i "6i $META_LINE" sidebar/index.html
sed -i 's/window.global ||= window;//g' sidebar/index.html