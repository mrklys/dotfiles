#!/bin/sh

export XDG_SESSION_TYPE="x11"
export XDG_CURRENT_DESKTOP="dwm"

startx "$XINITRC"
