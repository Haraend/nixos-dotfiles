import subprocess
import sys
import urllib.parse


def extract_url(raw: str) -> str:
    if raw.startswith("webapp-open:"):
        raw = raw[len("webapp-open:") :]
    parsed = urllib.parse.urlparse(raw)
    query = urllib.parse.parse_qs(parsed.query)
    if "url" in query and query["url"]:
        return query["url"][0]
    path = urllib.parse.unquote(parsed.path.lstrip("/"))
    if path.startswith("http://") or path.startswith("https://"):
        return path
    return urllib.parse.unquote(raw.lstrip("/"))


def main() -> None:
    raw = sys.argv[1] if len(sys.argv) > 1 else ""
    url = extract_url(raw)
    if not url.startswith(("http://", "https://")):
        return
    subprocess.Popen(["xdg-open", url], start_new_session=True)


if __name__ == "__main__":
    main()
