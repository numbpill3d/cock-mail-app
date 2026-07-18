#!/bin/bash

RELEASE_PGP_FINGERPRINT="0482D84022F52DF1C4E7CD43293ACD0907D9495A"
URL_PGP="https://alpinelinux.org/keys/ncopa.asc"
URL_DOWNLOADS="https://alpinelinux.org/downloads/"

deps="sha256sum curl gpg"
for dep in $deps
do
    type $dep >/dev/null 2>/dev/null
    if [[ $? -ne 0 ]]
    then
        echo "Dependency not found: $dep"
        echo "Dependencies: $dependencies"
        exit 1
    fi
done

set -e

urldecode() {
    arg="$1"

    i="0"
    while [ "$i" -lt ${#arg} ]; do
        c0=${arg:$i:1}
        if [ "x$c0" = "x%" ]; then
            c1=${arg:$((i+1)):1}
            c2=${arg:$((i+2)):1}
            printf "\x$c1$c2"
            i=$((i+3))
        else
            echo -n "$c0"
            i=$((i+1))
        fi
    done
}

# Create cache
mkdir -p cache/gnupg
chmod 700 cache/gnupg

# Import PGP key
if [[ ! -f 'cache/ncopa.asc' ]]
then
    echo "importing PGP key"
    curl -so 'cache/ncopa.asc' "$URL_PGP"
    gpg --homedir=cache/gnupg --import cache/ncopa.asc
    echo "$RELEASE_PGP_FINGERPRINT:6:" | gpg --homedir=cache/gnupg --import-ownertrust -
fi

# Fetch download list
echo "Fetching download list"
DOWNLOADS="$(curl -s "$URL_DOWNLOADS")"

url_encoded="$(echo "$DOWNLOADS" | grep 'minirootfs.*x86_64.*green-button' | awk -F'"' '{print $2}' | perl -pe 's/&#x([0-9a-fA-F]{2});/%\1/g')"

if [[ ! "$url_encoded" ]]
then
    echo "Unable to get alpine download link!"
    exit 1
fi

url_base="$(urldecode "$url_encoded")"
url_sha256="$url_base.sha256"
url_asc="$url_base.asc"

echo "Download URL: $url_base"

base_filename="$(echo "$url_base" | perl -pe 's,.*/,,')"

if [[ -f "$base_filename" ]]
then
    echo "$base_filename exists, not downloading"
    exit 0
fi

echo "Downloading"
curl -so "$base_filename" "$url_base"
curl -so "$base_filename.sha256" "$url_sha256"
curl -so "$base_filename.asc" "$url_asc"

echo "Checksum"
sha256sum -c "$base_filename.sha256"
echo "PGP verify"
gpg --homedir=cache/gnupg --verify "$base_filename.asc"

echo "Linking"

#latest_tar="$(ls alpine*.tar.gz | sort -n | tail -1)"
ln -sf "$base_filename" "latest.tar.gz"

echo "Extracting"
mkdir -p alpine
pushd alpine

tar xf ../latest.tar.gz

popd

echo all finished!
