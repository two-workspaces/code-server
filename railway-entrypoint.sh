#!/bin/sh
# Railway entrypoint for code-server. Runs as root, prepares /home/coder (the volume),
# then hands over to the image's own entrypoint as the coder user.
set -eu

H=/home/coder
PORT="${PORT:-8080}"
WORKSPACE="${WORKSPACE:-$H/workspace}"

# Railway mounts the volume empty and owned by root. Seed the home once with the
# usual dotfiles, and give it to coder (uid 1000) so settings, extensions and
# projects persist.
mkdir -p "$H"
if [ ! -f "$H/.railway-seeded" ]; then
  cp -an /etc/skel/. "$H/" 2>/dev/null || true
  mkdir -p "$H/workspace"
  touch "$H/.railway-seeded"
fi
mkdir -p "$WORKSPACE" "$H/.config/code-server" "$H/.local/share/code-server"
# Only walk the whole volume when the top is wrong (first boot, or a restore).
if [ "$(stat -c %u "$H")" != 1000 ]; then
  chown -R coder:coder "$H"
else
  chown coder:coder "$H" "$WORKSPACE" "$H/.config" "$H/.config/code-server" "$H/.local" "$H/.local/share" "$H/.local/share/code-server" 2>/dev/null || true
fi

# Login. PASSWORD comes from the template; HASHED_PASSWORD (argon2) also works.
# With neither, make one and keep it on the volume, so a cleared variable doesn't
# lock the owner out or leave the editor open.
if [ -z "${PASSWORD:-}" ] && [ -z "${HASHED_PASSWORD:-}" ]; then
  f="$H/.config/code-server/railway-password"
  [ -s "$f" ] || { head -c 18 /dev/urandom | base64 | tr -d '/+=' > "$f"; chown coder:coder "$f"; chmod 600 "$f"; }
  PASSWORD="$(cat "$f")"
  export PASSWORD
  echo "PASSWORD is empty, so code-server uses a generated one: $PASSWORD"
  echo "(saved in ~/.config/code-server/railway-password; set PASSWORD to choose your own)"
fi

# Railway counts the kernel's cache of files this container has touched as the
# service's memory, and with no memory pressure it is never freed: one npm install
# shows as hundreds of MB. Drop it for the home volume every 15 minutes.
( while sleep 900; do nice -n 19 drop-file-cache "$H" /tmp || true; done ) &

echo "code-server on port $PORT, opening $WORKSPACE"
# The image's entrypoint (fixuid, ~/entrypoint.d scripts, dumb-init) as coder.
# Updates come with a new image, so the in-app update check is off.
exec setpriv --reuid=coder --regid=coder --init-groups \
  env HOME="$H" USER=coder \
  /usr/bin/entrypoint.sh \
  --bind-addr "0.0.0.0:$PORT" \
  --auth password \
  --disable-telemetry \
  --disable-update-check \
  "$WORKSPACE"
