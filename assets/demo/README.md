# Images and videos to demonstrate 'echasnovski/mini.nvim' functionality

Use video demonstration instead of gif because it allows better resolution with smaller download needs (video seems to load only when started). It also allows pause, but needs manual repeat.

Setup to create demonstration videos with similar "style":
- Open fullscreen terminal and adjust font to be "large enough".
- Open Neovim:
    - Use default 'mini.nvim' colorscheme.
    - Open single buffer with module file to be demonstrated (if possible).
    - Make sure only relative paths are shown, especially in statusline.
    - Consider disabling Lsp diagnostic count.
- Open [simplescreenrecorder](https://www.maartenbaert.be/simplescreenrecorder/) to record mp4:
    - Set "Record fixed rectangle", go to fullscreen, click "Select window", click on present window.
    - Don't track cursor. Don't record audio.
    - Use 'mp4' container.
- Open [screenkey](https://gitlab.com/screenkey/screenkey) with following non-default settings:
    - Display for 1 second.
    - Persistent window.
    - Font = 'UbuntuMono Nerd Font 10'.
    - Backspace mode = 'Normal'.
    - Opacity = 0.1.
- Focus on Neovim terminal window, make fullscreen.
- Switch off `screenkey` (`Left Ctrl` + `Right Ctrl`), start recording with shortcut, switch on `screenkey` (same shortcut).
- Record.
- Wait for latest keys to disappear, switch off `screenkey`, stop recording.
- Save video in `simplescreenrecorder`.

Embed videos to 'mini.nvim':
- Open some editable space on Github (like issue in 'mini.nvim').
- Drag and drop video in that space (creates `https://user-images.githubusercontent.com/` link).
- Copy link and paste to README.
Unfortunately, this is the only way at the moment to embed videos. Uploaded content might expire, so needs a constant check.
