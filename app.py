#!/usr/bin/env python3

import os
import sys
import pwd
import shutil
import socket
import subprocess
from pathlib import Path


def run(cmd):
    subprocess.run(cmd, check=True)


def get_ip():
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("192.0.2.1", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except OSError:
        return "127.0.0.1"


def main():
    if os.geteuid() != 0:
        print("Run: sudo python3 desktop.py")
        sys.exit(1)

    username = os.environ.get("SUDO_USER")

    if not username or username == "root":
        print("Normal Linux user se sudo ke saath run karein.")
        sys.exit(1)

    user = pwd.getpwnam(username)
    home = Path(user.pw_dir)

    if not shutil.which("apt-get"):
        print("Ubuntu, Debian ya Kali Linux required hai.")
        sys.exit(1)

    print("[1/5] Installing XFCE and TigerVNC...")
    run(["apt-get", "update"])
    run([
        "apt-get", "install", "-y",
        "xfce4", "xfce4-goodies",
        "tigervnc-standalone-server",
        "tigervnc-tools", "dbus-x11"
    ])

    print("[2/5] Setting VNC password...")
    subprocess.run(
        ["vncpasswd"],
        check=True,
        user=username,
        cwd=str(home)
    )

    vnc_dir = home / ".vnc"
    vnc_dir.mkdir(exist_ok=True)

    xstartup = vnc_dir / "xstartup"
    xstartup.write_text(
        "#!/bin/sh\n"
        "unset SESSION_MANAGER\n"
        "unset DBUS_SESSION_BUS_ADDRESS\n"
        "exec dbus-launch --exit-with-session startxfce4\n"
    )
    xstartup.chmod(0o700)

    os.chown(vnc_dir, user.pw_uid, user.pw_gid)
    os.chown(xstartup, user.pw_uid, user.pw_gid)
    os.chown(vnc_dir / "passwd", user.pw_uid, user.pw_gid)

    print("[3/5] Starting VNC desktop...")
    subprocess.run(
        [
            "vncserver", ":1",
            "-localhost", "yes",
            "-geometry", "1280x800",
            "-depth", "24"
        ],
        check=True,
        user=username,
        cwd=str(home)
    )

    print("[4/5] Detecting server IP...")
    ip = get_ip()

    print("[5/5] Installation complete!")
    print("\n" + "=" * 42)
    print("       DESKTOP READY")
    print("=" * 42)
    print(f"Server IP: {ip}")
    print("VNC Port: 5901")
    print("Desktop: XFCE")
    print("Resolution: 1280x800")
    print("\nSECURE CONNECTION")
    print(f"SSH Tunnel: ssh -L 5901:127.0.0.1:5901 "
          f"{username}@{ip}")
    print("VNC Viewer address: 127.0.0.1:5901")
    print("=" * 42)


if __name__ == "__main__":
    main()
