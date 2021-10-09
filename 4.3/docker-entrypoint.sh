#!/bin/sh
set -e

if [ $(echo "$1" | cut -c1) = "-" ]; then
  echo "$0: assuming arguments for ravend"

  set -- ravend "$@"
fi

if [ $(echo "$1" | cut -c1) = "-" ] || [ "$1" = "ravend" ]; then
  mkdir -p "$RAVENCOIN_DATA"
  chmod 700 "$RAVENCOIN_DATA"
  chown -R ravencoin "$RAVENCOIN_DATA"

  echo "$0: setting data directory to $RAVENCOIN_DATA"

  set -- "$@" -datadir="$RAVENCOIN_DATA"
fi

if [ "$1" = "ravend" ] || [ "$1" = "raven-cli" ] || [ "$1" = "raven-tx" ]; then
  echo
  exec su-exec ravencoin "$@"
fi

echo
exec "$@"