---
title: Making a Hello World Gameboy ROM
description: Using RGBDS to create a "Hello World" program for the Nintendo Gameboy
date: 2024-12-06 00:50:21 -0500
media_subpath: /assets/images/2024-12-06-gameboy_hello_world.d
tags: [gameboy, rgbds, assembly]
categories: [Gameboy]
---

# Writing a "Hello World" program for the Nintendo Gameboy

![My Gameboy Color](gbc.jpeg){: width="600"}
_My childhood Pokemon Gold/Silver Gameboy Color_

The Nintendo Gameboy is probably my favorite handheld gaming console. I've had A Gameboy Color since I was a child,
and it still sits on my entertainment center today. I started wondering how hard it would be to write a program to run
on the little machine.

Fortunately, it's pretty easy to get set up and developing for the Gameboy thanks to the
[RGBDS toolchain]([https://rgbds.gbdev.io/). In this post, I'll be going through the process of writing a "Hello
World" program and running it on a Gameboy emulator.

>For this post, I'll only be talking about the DMG Gameboy. The Gameboy Color is compatible with DMG games, just with
>beefier hardware and of course a color display.
{: .prompt-info}

I'm going to start with creating the font and the background tilemap that will display our image. After those are
created, we can get to the actual code and use them.

## Creating a Font

In order to write anything, we need a font. The Gameboy doesn't supply anything, nor does RGBDS come
with any assets. So we'll just create one with an image editing program, I'll be using GIMP here. In GIMP, I found
it helpful to use the grid overlay to create 8x8 pixel squares, and then using the 1 pixel brush, draw the characters.

![My GIMP grid settings](gimp.png)
_This is what it looks like with the 8x8 grid setup_

Each character needs to fit within the 8x8 square, as that will be a single tile in the resulting graphics data.
If we save the image as a png, we can use rgbgfx to convert the image into a format the Gameboy can use, and that can
be imported directly into our code.

![My OK-ish Font](font.png)
_Here's my OK-ish font_

Once we have our font.png saved, we can convert it like so:

```
    rgbgfx -u -o font.2bpp font.png
```

The .2bpp stands for "2 bits per pixel", which is the default output mode for rgbgfx, and will give us all 4 colors
of the Gameboy. The `-u` option will generate unique tiles, so all of the blank tiles we have will only yield a single
blank tile in the output. We do need at least one blank tile, since every space that isn't going to be a letter will
need to use the blank space. We have our font tileset, and now we're ready to start using it.

## Creating a Tilemap

So we have a font, but we still have to actually write on something with it. For this, we're going to use a tilemap
that will be applied to the background.

The Gameboy screen is laid out like this (not really to scale):

```
    +-----------------------+
    |     160px width       |
    |                       |
    |                       |
    |                       |
    | 144px height          |
    |                       |
    |                       |
    |                       |
    |                       |
    +-----------------------+
```

With 8x8px tiles, this means that the screen is 20 tiles wide, and 18 tiles tall. A tilemap is always 32x32 tiles, so
it's far larger than the screen can show. For this exercise, we're going to be ignoring the bits of the map outside of
the display area.

We define the tilemap with a bit of assembly.

```
    SECTION "tilemap_data", ROM0
    
tilemap::
    db $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, 0,0,0,0,0,0,0,0,0,0,0,0
    db $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, 0,0,0,0,0,0,0,0,0,0,0,0
    db $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, 0,0,0,0,0,0,0,0,0,0,0,0
    db $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, 0,0,0,0,0,0,0,0,0,0,0,0
    db $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, 0,0,0,0,0,0,0,0,0,0,0,0
    db $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, 0,0,0,0,0,0,0,0,0,0,0,0
    db $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, 0,0,0,0,0,0,0,0,0,0,0,0
    db $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, 0,0,0,0,0,0,0,0,0,0,0,0
    db $1E, $1E, $1E, $07, $04, $0B, $0B, $0E, $1B, $1E, $16, $0E, $11, $0B, $03, $1C, $1E, $1E, $1E, $1E, 0,0,0,0,0,0,0,0,0,0,0,0
    db $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, 0,0,0,0,0,0,0,0,0,0,0,0
    db $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, 0,0,0,0,0,0,0,0,0,0,0,0
    db $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, 0,0,0,0,0,0,0,0,0,0,0,0
    db $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, 0,0,0,0,0,0,0,0,0,0,0,0
    db $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, 0,0,0,0,0,0,0,0,0,0,0,0
    db $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, 0,0,0,0,0,0,0,0,0,0,0,0
    db $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, 0,0,0,0,0,0,0,0,0,0,0,0
    db $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, 0,0,0,0,0,0,0,0,0,0,0,0
    db $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, 0,0,0,0,0,0,0,0,0,0,0,0
tilemap_end::
```
{: file="hello_tilemap.asm"}

Ok, so a quick explanation of what we're looking at here. We declare a `SECTION`, which is a chunk of data,
and we want it to be located in `ROM0`, or just somewhere in the ROM. We then define 2 labels, `tilemap` and
`tilemap_end`. The double colon at the end means to export the label so it can be referenced in other files.

We have 18 lines starting with `db`, one for each row of tiles on the screen (We don't have to care about the rows
below the screen in this example). The `db` which means "define byte" tells
the assembler that we're statically allocating the following list of bytes, and the values that will be in them. We
only care about the first 20, since that's how many tiles wide the screen is, but the remaining 12 must still be set
to something, hence the 0 values at the end of each line. The value $1E(dec 30) is the index of the blank tile in our
tileset. We want everything to be blank except for one line with our text. There's a line about in the middle that
looks like this:

```
    db $1E, $1E, $1E, $07, $04, $0B, $0B, $0E, $1B, $1E, $16, $0E, $11, $0B, $03, $1C, $1E, $1E, $1E, $1E, 0,0,0,0,0,0,0,0,0,0,0,0
```

These indices will give us the tiles to spell out "HELLO, WORLD" roughly centered on the screen. Save this file as
"hello_tilemap.asm" and it's ready to be used by our other code. At this point, we have everything we need to display
our message, now we just need to make the Gameboy actually display it.

## The Gameboy Cartridge Header

## Initialization

## Interrupts
