#!/usr/bin/env python3
import datetime as dt
import json
import os
import sys


RESET = "\033[0m"
BOLD = "\033[1m"
DIM = "\033[2m"
BG = {
    "base": "\033[48;2;40;42;54m",
    "surface": "\033[48;2;52;55;70m",
    "soft": "\033[48;2;68;71;90m",
    "blue": "\033[48;2;45;70;82m",
    "pink": "\033[48;2;80;53;76m",
    "green": "\033[48;2;45;76;60m",
    "yellow": "\033[48;2;86;76;45m",
    "red": "\033[48;2;84;47;55m",
}
FG = {
    "rose": "\033[38;5;203m",
    "pink": "\033[38;2;80;53;76m",
    "mauve": "\033[38;5;183m",
    "sky": "\033[38;5;117m",
    "mint": "\033[38;5;121m",
    "green": "\033[38;2;45;76;60m",
    "yellow": "\033[38;2;86;76;45m",
    "red": "\033[38;2;84;47;55m",
    "blue": "\033[38;2;45;70;82m",
    "text": "\033[38;5;252m",
    "muted": "\033[38;5;245m",
    "base": "\033[38;2;40;42;54m",
    "surface": "\033[38;2;52;55;70m",
    "soft": "\033[38;2;68;71;90m",
    "dracula_grey": "\033[38;2;98;114;164m",
    "dracula_red": "\033[38;2;255;85;85m",
    "dracula_yellow": "\033[38;2;241;250;140m",
    "dracula_blue": "\033[38;2;139;233;253m",
    "dracula_pink": "\033[38;2;255;121;198m",
    "dracula_green": "\033[38;2;80;250;123m",
    "dracula_white": "\033[38;2;248;248;242m",
}


def color(text, name, bright=False, bg=None):
    prefix = style(name, bright=bright, bg=bg)
    return f"{prefix}{text}{RESET}"


def style(name=None, bright=False, bg=None):
    prefix = FG.get(name, "") if name else ""
    if bg:
        prefix += BG.get(bg, "")
    if bright:
        prefix += BOLD
    return prefix


def segment(icon, label, value, accent="dracula_blue", bg="surface"):
    left = color("", bg)
    body = (
        BG[bg]
        + style(accent, bright=True)
        + icon
        + " "
        + style("dracula_grey")
        + label
        + " "
        + style("dracula_white", bright=True)
        + str(value)
        + RESET
    )
    right = color("", bg)
    return f"{left}{body}{right}"


def mini_segment(icon, value, accent="dracula_grey", bg="base"):
    return (
        color("", bg)
        + BG[bg]
        + style(accent, bright=True)
        + icon
        + " "
        + style("dracula_white")
        + str(value)
        + RESET
        + color("", bg)
    )


def visible_len(text):
    length = 0
    in_escape = False
    for char in text:
        if char == "\033":
            in_escape = True
            continue
        if in_escape:
            if char == "m":
                in_escape = False
            continue
        length += 1
    return length


def truncate(text, max_width):
    if max_width <= 0 or visible_len(text) <= max_width:
        return text

    out = []
    length = 0
    in_escape = False
    for char in text:
        if char == "\033":
            in_escape = True
            out.append(char)
            continue
        if in_escape:
            out.append(char)
            if char == "m":
                in_escape = False
            continue
        if length >= max_width - 1:
            break
        out.append(char)
        length += 1
    return "".join(out) + "…" + RESET


def get(data, path, default=None):
    value = data
    for key in path.split("."):
        if not isinstance(value, dict) or key not in value:
            return default
        value = value[key]
    return default if value is None else value


def pct_value(value):
    try:
        return max(0, min(100, float(value)))
    except (TypeError, ValueError):
        return 0.0


def usage_color(pct):
    if pct >= 90:
        return "dracula_red"
    if pct >= 70:
        return "dracula_yellow"
    return "dracula_green"


def bar(pct, width=12, bg=None):
    pct = pct_value(pct)
    filled = round(width * pct / 100)
    fill = "━" * filled
    empty = "─" * (width - filled)
    suffix = style("dracula_white", bg=bg) if bg else RESET
    return f"{style(usage_color(pct), bright=True, bg=bg)}{fill + empty}{suffix}"


def short_session(data):
    name = get(data, "session_name")
    if name:
        return str(name)
    session_id = str(get(data, "session_id", "session"))
    return session_id[:8] if session_id else "session"


def title_mode(raw_mode):
    if not raw_mode:
        return None
    normalized = str(raw_mode).strip()
    lookup = {
        "default": "Ask",
        "ask": "Ask",
        "plan": "Plan",
        "acceptEdits": "Auto",
        "accept_edits": "Auto",
        "auto": "Auto",
        "bypassPermissions": "Bypass",
        "bypass_permissions": "Bypass",
        "dangerouslySkipPermissions": "Bypass",
    }
    return lookup.get(normalized, normalized[:1].upper() + normalized[1:])


def transcript_permission_mode(path):
    if not path:
        return None
    try:
        with open(path, "rb") as handle:
            handle.seek(0, os.SEEK_END)
            position = handle.tell()
            buffer = b""
            while position > 0:
                step = min(8192, position)
                position -= step
                handle.seek(position)
                buffer = handle.read(step) + buffer
                lines = buffer.splitlines()
                if position > 0 and buffer and not buffer.startswith((b"{", b"[")):
                    lines = lines[1:]
                for raw_line in reversed(lines):
                    if b"permissionMode" not in raw_line and b"permission_mode" not in raw_line:
                        continue
                    try:
                        event = json.loads(raw_line)
                    except json.JSONDecodeError:
                        continue
                    mode = event.get("permissionMode") or event.get("permission_mode")
                    if mode:
                        return mode
    except (OSError, ValueError):
        return None
    return None


def current_mode(data):
    candidates = [
        get(data, "permissionMode"),
        get(data, "permission_mode"),
        get(data, "mode.name"),
        get(data, "mode"),
        get(data, "session.mode"),
    ]
    for candidate in candidates:
        if candidate:
            return title_mode(candidate)
    return title_mode(transcript_permission_mode(get(data, "transcript_path")))


def money(value):
    try:
        amount = float(value or 0)
    except (TypeError, ValueError):
        amount = 0.0
    if amount < 1:
        return f"${amount:.3f}"
    return f"${amount:.2f}"


def duration(ms):
    try:
        seconds = int(float(ms or 0) / 1000)
    except (TypeError, ValueError):
        seconds = 0
    hours, rem = divmod(seconds, 3600)
    minutes, secs = divmod(rem, 60)
    if hours:
        return f"{hours}h{minutes:02d}m"
    return f"{minutes}m{secs:02d}s"


def reset_hint(epoch):
    try:
        epoch = int(float(epoch))
    except (TypeError, ValueError):
        return "n/a"
    if epoch <= 0:
        return "n/a"
    target = dt.datetime.fromtimestamp(epoch)
    now = dt.datetime.now()
    delta = max(0, int((target - now).total_seconds()))
    hours, rem = divmod(delta, 3600)
    minutes = rem // 60
    if hours:
        return f"{hours}h{minutes:02d}m"
    return f"{minutes}m"


def rate_segment(data, window, label):
    root = f"rate_limits.{window}"
    raw_pct = get(data, f"{root}.used_percentage")
    if raw_pct is None:
        return mini_segment("󰔟", f"{label} --", "dracula_grey", "base")
    pct = pct_value(raw_pct)
    reset = reset_hint(get(data, f"{root}.resets_at"))
    accent = usage_color(pct)
    value = f"{label} {bar(pct, 6, bg='base')} {pct:.0f}% ↻{reset}"
    return mini_segment("󰔟", value, accent, "base")


def main():
    try:
        data = json.load(sys.stdin)
    except json.JSONDecodeError:
        data = {}

    model = get(data, "model.display_name") or get(data, "model.id", "Claude")
    current_dir = get(data, "workspace.current_dir") or get(data, "cwd", "")
    folder = os.path.basename(current_dir.rstrip(os.sep)) if current_dir else "~"
    session = short_session(data)
    context_pct = pct_value(get(data, "context_window.used_percentage", 0))
    cost = money(get(data, "cost.total_cost_usd", 0))
    elapsed = duration(get(data, "cost.total_duration_ms", 0))
    effort = get(data, "effort.level")
    style = get(data, "output_style.name")
    mode = current_mode(data)

    accent = color("", "pink") + BG["pink"] + color("󰚩", "dracula_white", bright=True, bg="pink") + RESET + color("", "pink")
    line1_parts = [
        f"{accent} {color(str(model), 'dracula_blue', bright=True)}",
        segment("", "sess", session, "dracula_pink", "surface"),
        segment("", "dir", folder, "dracula_blue", "blue"),
    ]
    if mode:
        line1_parts.append(segment("󰐊", "mode", mode, "dracula_green", "green"))
    if effort:
        line1_parts.append(segment("󰧑", "think", effort, "dracula_pink", "pink"))
    if style:
        line1_parts.append(segment("󰏘", "style", style, "dracula_yellow", "soft"))

    line2_parts = [
        mini_segment("󰪞", f"ctx {bar(context_pct, 14, bg='base')} {context_pct:.0f}%", usage_color(context_pct), "base"),
        mini_segment("", f"{cost}   {elapsed}", "dracula_yellow", "yellow"),
        rate_segment(data, "five_hour", "5h"),
        rate_segment(data, "seven_day", "7d"),
    ]

    columns = int(os.environ.get("COLUMNS", "120") or 120)
    print(truncate("  ".join(line1_parts), columns))
    print(truncate("  ".join(line2_parts), columns))


if __name__ == "__main__":
    main()
