# BootMake

This program is a very simple GUI for **CDI4DC**. It uses `mkisofs` (for
creating the `ISO`), `ipinj` (for inserting the `IP.BIN` in the generated `ISO`)
and **CDI4DC** (`ISO` to the `CDI`).

**CDI4DC** is part of [IMG4DC](https://github.com/sizious/img4dc) package.

# Usage

Extract the latest release of `cdi4dc` binary in the `Tools` directory. Run the program.
In the first field, select your source directory (where **Sega Dreamcast** files
are located). You can add a custom `IP.BIN` if you want and change the temp `ISO`
image location. And in the last field, enter your desired `CDI` image.

You can change the `CD Label` if needed.

After doing this, just click `Make`.

# Credits

This program is dedicated to **Ron** from dreamcast.es.
Greetings goes to **Xeal**, **DeXT**, **Heiko Eissfeldt** and **Joerg Schilling**
for `libedc` used in `cdi4dc`.

For the about box: **andromeda** for the **XM** module, **Shigeru Miyamoto**
and **Takashi Tezuka** for the _SMB_ sprites.
