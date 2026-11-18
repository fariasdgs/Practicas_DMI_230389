"""Send a movie notification via FCM HTTP v1 with server-side Google credentials."""
import argparse
import json
import os
import re
import subprocess
import urllib.error
import urllib.request


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("project")
    parser.add_argument("movie_id", type=int)
    parser.add_argument("title")
    parser.add_argument("body")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()
    if not re.fullmatch(r"[a-z][a-z0-9-]*", args.project) or args.movie_id < 1:
        parser.error("Invalid Firebase project or movie ID")
    device = os.environ.get("CINEMA_FCM_DEVICE_TOKEN")
    if not device:
        parser.error("Set CINEMA_FCM_DEVICE_TOKEN in the sender environment")
    access = subprocess.check_output(
        ["gcloud", "auth", "application-default", "print-access-token"], text=True
    ).strip()
    payload = {
        "validate_only": args.dry_run,
        "message": {
            "token": device,
            "notification": {"title": args.title, "body": args.body},
            "data": {"movieId": str(args.movie_id)},
        },
    }
    request = urllib.request.Request(
        f"https://fcm.googleapis.com/v1/projects/{args.project}/messages:send",
        data=json.dumps(payload).encode(),
        headers={"Authorization": f"Bearer {access}", "Content-Type": "application/json"},
    )
    try:
        with urllib.request.urlopen(request, timeout=15) as response:
            print(json.load(response)["name"])
    except urllib.error.HTTPError as error:
        raise SystemExit(f"FCM replied with HTTP {error.code}") from None


if __name__ == "__main__":
    main()
