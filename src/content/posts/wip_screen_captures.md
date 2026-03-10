---
title: Custom Screen Capture Flow
date: 2024-07-25
summary: An adventure in making scripts to capture screen shots and recordings.
cowsay: A picture is worth a thousand words
---

I've recently been going down the path of madness known as customizing my desktop and I figured I'd
share some neat scripts and setups I've done along the way.

Today I'll go into some scripts I've been working on to capture screen shots and recordings. They
allow selecting regions of the screen and specific windows, and I also made it so you can edit them
afterwards.

## Background

My entire system and home folder is managed by [NixOS](https://nixos.org), so I have a
[configuration repository](https://github.com/Bwc9876/nix-conf) where all my scripts and configs can
be found, I'll reference them throughout this post and provide links to the current version of each
so you can see if I've updated them since this post.

Currently I use [Hyprland](https://hyprland.org) as my window manager, and have been duct-taping
components together to make my own little Desktop Environment around it.

I also like to use [NuShell](https://nushell.sh) as my shell, and these scripts will be written in
it. If you haven't checked out NuShell yet, I highly recommend it!

## Screenshots

First is the script to take screenshots. This is a relatively simple script as it simply builds on
top of [grimblast](https://github.com/hyprwm/contrib/tree/main/grimblast) with some nice QoL
features.

To install grimblast, all I have to do is add it to my `environment.systemPackages`:

```nix
{
  environment.systemPackages = with pkgs; [
    # ...
    grimblast
    libnotify # For notifications
    xdg-utils # For opening files
    # ...
  ];
}
```

Grimblast will automatically save screenshots to `XDG_SCREENSHOTS_DIR`, I manually set this in my
_home manager_ config with:

```nix
{
  xdg.userDirs.extraConfig.XDG_SCREENSHOTS_DIR = "${config.home.homeDirectory}/Pictures/Screenshots";
}
```

Grimblast will name the screenshots with the current date and time, which works for me.

Now along to actually using grimblast, I'll create a new script and put in in my config somewhere,
we'll call it `screenshot.nu`. I usually like to place any non-nix files in a folder called `res` at
the root of my config, we'll get to actually calling this script once we're done writing it.

To start out we need to call grimblast, I like to use `copysave` as the action as I like having it
immediately in my clipboard, and having it saved for later. I'll also add `--freeze` which simply
freezes the screen while I select the region to capture.

```nushell
let file_path = grimblast --freeze copysave
```

grimblast will then return the path to the saved screenshot, which we save in `file_path`. If the
user were to cancel the selection (press escape), `file_path` would be empty, so we want to make
sure to check for that so we're not trying to open a non-existent file.

```nushell
if $file_path == "" {
    exit 1
}
```

Now the main part, we'll send a notification that the screenshot was saved, and have options for it.

I want four actions for the screenshot:

- Open
- Open Folder
- Edit
- Delete

Also since grimblast saves the screenshot as a png, I can pass it as the icon of the notification.

```nushell
let choice = notify-send --app-name=screengrab -i $file_path -t 7500 --action=open=Open --action=folder="Show In Folder" --action=edit=Edit --action=delete=Delete "Screenshot taken" $"Screenshot saved to ($file_path) and copied to clipboard"
```

A long command here, `notify-send` allows us to send a notification to the currently running
notification daemon. In my case I'm using
[swaync](https://github.com/ErikReider/SwayNotificationCenter).

- `--app-name` is the name of the application that sent the notification, I say screengrab here so
  swaync will show an icon in addition to the image, also so I can play a camera shutter sound when
  the notification is sent.
- `-i` is the icon to display in the notification, in this case the screenshot we just took.
- `-t` is the time in milliseconds to show the notification
- `--action` is actions to display in the notification, `name=Text`
- First position argument is the notification title, and second is the body.

With that we get a neat notification when we screenshot.

![A notification that I just took a screenshot with the screenshot visible](@assets/blog/wip1_screenshot_notif.webp)

Now we need to handle each action, the chosen action is returned by notify-send, so we can match on
that.

- "Open" and "Open Folder" are pretty simple, just pass `$file_path` and `$file_path | path dirname`
  to `xdg-open`
- "Edit" I'll simply pass the file path to my editor, I chose
  [swappy](https://github.com/jtheoof/swappy) because of it's simplicity and ease of use.
- "Delete" I'll just remove the file.

```nushell
match $choice {
    "open" => {
        xdg-open $file_path
    }
    "folder" => {
        xdg-open ($file_path | path dirname)
    }
    "edit" => {
        swappy -f $file_path
    }
    "delete" => {
        rm $file_path
    }
}
```

And that's it! I now have a fairly robust screenshot script.

### Screenshot Invocation

Now in terms of actually calling it I'll be binding it to `Win` + `Shift` + `S` in Hyprland, as well
as `PrintScreen`.

In home manager I simply have to add these strings to my Hyprland binds

```nix
{
  wayland.windowManager.hyprland.settings.bind = [
      # ...
      ",Print,exec,nu ${../res/screenshot.nu}"
      "SUPER SHIFT,S,exec,nu ${../res/screenshot.nu}"
      # ...
  ];
}
```

Now by switching to my new config (and making sure to stage `screenshot.nu` of course), I can take
screenshots with a keybind!

## Screen Recordings

This will be a bit more involved mainly because something like grimblast doesn't exist for screen
recordings. Looking at existing solutions I couldn't find any that I really liked, mostly because
they involved some additional UI. To be clear this script will be for _simple_, _short_ recordings,
long-term stuff I'll still prefer to use something like OBS.

For the actual screen recording I'll be using [wf-recorder](https://github.com/ammen99/wf-recorder).

```nix
{
  environment.systemPackages = with pkgs; [
    # ...
    wf-recorder
    libnotify # For notifications
    xdg-utils # For opening files
    slurp # Will explain this later
    # ...
  ];
}
```

First and foremost location, I chose to use `~/Videos/Captures` for my recordings. I didn't set an
environment variable for this, it'll be hardcoded in the script.

```nushell
let date_format = "%Y-%m-%d_%H-%M-%S"

let captures_folder = $"($env.HOME)/Videos/Captures"

if not ($captures_folder | path exists) {
    mkdir $captures_folder
}

let out_name = date now | format date $"($captures_folder)/($date_format).mp4"
```

This will handle determining the folder and name for the recordings, and creating the folder if it
doesn't exist.

Next up I want to have a similar selection process to the screenshot script, to do this I'll use
[slurp](https://github.com/emersion/slurp) to select areas of the screen, which is what grimblast
uses under the hood.

In addition, grimblast does some communication with Hyprland to get window information such as
position and size, this lets you select a window to take a screenshot of. I'll be getting that info
manually from Hyprland using NuShell instead:

```nushell
let workspaces = hyprctl monitors -j | from json | get activeWorkspace.id
let windows = hyprctl clients -j | from json | where workspace.id in $workspaces
let geom = $windows | each { |w| $"($w.at.0),($w.at.1) ($w.size.0)x($w.size.1)" } | str join "\n"
```

This gets all the geometry in a format `slurp` will be able to parse and use.

```nushell
let stat = do { echo $geom | slurp -d } | complete

if $stat.exit_code == 1 {
    echo "No selection made"
    exit
}
```

I do `complete` here to get the exit code of the slurp command, if it's 1 then the user cancelled
the selection and similar to the screenshot script I'll exit.

Now it's time to actually record, the stdout of `slurp` contains the geometry that we want to
capture, so we'll pass that to `wf-recorder` with the `-g` flag:

```nushell
wf-recorder -g ($stat.stdout) -F fps=30 -f $out_name
```

Pretty simple command, `-g` is the geometry to record, `-F` is the format options, and `-f` is the
output file.

Now we'll run into an issue if we run this script and start recording, there's no way to stop it!
I'll cover how we're going to get around that when it comes to setting up keybinds.

Assuming `wf-recorder` stops, we'll send a notification to the user that the recording is done:

```nushell
let action = notify-send --app-name=simplescreenrecorder --icon=simplescreenrecorder -t 7500 --action=open=Open --action=folder="Show In Folder" --action=delete=Delete "Recording finished" $"File saved to ($out_name)"
```

![A notification that I just took a screen recording with a video camera icon visible](@assets/blog/wip1_screenrec_notif.webp)

Most arguments are the same here as the screenshot script, the only difference is the icon and app
name. The actions are also basically the same, so I'll leave out the explanation and just show the
handler:

```nushell
match $action {
    "open" => {
        xdg-open $out_name
    }
    "folder" => {
        xdg-open $captures_folder
    }
    "delete" => {
        rm $out_name
    }
}
```

### Start/Stop Recording

Now to actually call the script, I'll bind it to `Win` + `Shift` + `R` in Hyprland.

However, we're going to do something special with the `exec` line here. Instead of simply calling
the script we're going to check if `wf-recorder` is already running, if this is the case we can send
`SIGINT` to it to make it stop recording, meaning our script will continue and show the
notification.

```nix
{
  wayland.windowManager.hyprland.settings.bindr = [
      # ...
      "SUPER SHIFT,R,exec,pkill wf-recorder --signal SIGINT || nu ${../res/screenrec.nu}"
      # ...
  ];
}
```

`pkill` here will exit with code `1` if it doesn't find any processes to kill, so the `||` will run
our script if `pkill` fails.

Note that I did this on `bindr`, this means the keybind will only happen once the R key is
_released_ rather than pressed. This is to prevent a weird issue I ran into where the recording
would stop immediately after starting.

And that's it! We can now screen record with ease. It won't record audio (might do an additional
keybind in the future) and it also doesn't copy the recording to the clipboard, but it works pretty
well for short videos.

## Full Scripts

### Screenshot Script

```nushell
#!/usr/bin/env nu

let file_path = grimblast --freeze copysave area

if $file_path == "" {
    exit 1;
}

let choice = notify-send --app-name=screengrab -i $file_path -t 7500 --action=open=Open --action=folder="Show In Folder" --action=edit=Edit --action=delete=Delete "Screenshot taken" $"Screenshot saved to ($file_path) and copied to clipboard"

match $choice {
    "open" => {
        xdg-open $file_path
    }
    "folder" => {
        xdg-open ($file_path | path dirname)
    }
    "edit" => {
        swappy -f $file_path
    }
    "delete" => {
        rm $file_path
    }
}
```

[Most recent version on GitHub](https://github.com/Bwc9876/nix-conf/blob/main/res/screenshot.nu)

### Recording Script

```nushell
#!/usr/bin/env nu

let date_format = "%Y-%m-%d_%H-%M-%S"

let captures_folder = $"($env.HOME)/Videos/Captures"

if not ($captures_folder | path exists) {
    mkdir $captures_folder
}

let out_name = date now | format date $"($captures_folder)/($date_format).mp4"

let workspaces = hyprctl monitors -j | from json | get activeWorkspace.id
let windows = hyprctl clients -j | from json | where workspace.id in $workspaces
let geom = $windows | each { |w| $"($w.at.0),($w.at.1) ($w.size.0)x($w.size.1)" } | str join "\n"

let stat = do { echo $geom | slurp -d } | complete

if $stat.exit_code == 1 {
    echo "No selection made"
    exit
}

wf-recorder -g ($stat.stdout) -F fps=30 -f $out_name

let action = notify-send --app-name=simplescreenrecorder --icon=simplescreenrecorder -t 7500 --action=open=Open --action=folder="Show In Folder" --action=delete=Delete "Recording finished" $"File saved to ($out_name)"

match $action {
    "open" => {
        xdg-open $out_name
    }
    "folder" => {
        xdg-open $captures_folder
    }
    "delete" => {
        rm $out_name
    }
}
```

[Most recent version on GitHub](https://github.com/Bwc9876/nix-conf/blob/main/res/screenrec.nu)
