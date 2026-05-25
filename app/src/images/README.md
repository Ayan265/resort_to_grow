# Images Folder

Place your personal motivation images here. These images are used by the app during check-in flows.

## Required Images

You need to configure your images in `../config.js`. Here is what each image slot is used for:

| Config Key        | Where It Appears                                    |
|-------------------|-----------------------------------------------------|
| `mainPhoto`       | The circular photo on the main check-in screen      |
| `pleaImage`       | The image shown when you click "Not really"         |
| `motivationLeft`  | Left image on the dual motivation screen            |
| `motivationRight` | Right image on the dual motivation screen           |
| `summaryLeft`     | Left photo ring on the "Today's Progress" page      |
| `summaryRight`    | Right photo ring on the "Today's Progress" page     |

Journey steps (the affirmation screens after clicking "Yes, I am") also each have an `image` field.

## How To Set Up

1. Drop your `.jpg`, `.png`, or `.webp` files into this folder.
2. Open `../config.js` in any text editor.
3. Update the filenames in the `images: { ... }` section. Use a leading `/` before the filename:
   ```js
   images: {
     mainPhoto: '/my-photo.jpg',
     pleaImage: '/motivation.png',
     // ...
   },
   ```
4. Update the `journey` array image fields the same way:
   ```js
   journey: [
     { question: '...', button: '...', image: '/my-journey-photo.jpg' },
   ],
   ```
5. Rebuild the app: `npm run tauri build`

## Tips

- Images look best when they are **square or portrait** oriented.
- Keep files under **500 KB** for fast loading.
- Supported formats: `.jpg`, `.jpeg`, `.png`, `.webp`

## Custom App Icon (System Tray / Taskbar)

The app icon shown in the system tray and taskbar is stored separately in `../src-tauri/icons/`.

To use your own icon:
1. Prepare a **square PNG image** (at least 256×256 pixels).
2. Generate all required sizes. If you have [ImageMagick](https://imagemagick.org/) installed:
   ```bash
   cd app/src-tauri/icons
   convert your-icon.png -resize 32x32 -type TrueColorAlpha PNG32:32x32.png
   convert your-icon.png -resize 128x128 -type TrueColorAlpha PNG32:128x128.png
   convert your-icon.png -resize 256x256 -type TrueColorAlpha PNG32:128x128@2x.png
   convert 128x128@2x.png icon.icns   # macOS
   convert 32x32.png icon.ico    # Windows
   ```
3. Or just manually replace each file with your image at the correct size.
4. Rebuild: `npm run tauri build`

## Privacy

This folder is listed in `.gitignore` so your personal images will **never** be committed to git.
Only the placeholder image (`placeholder.jpg`) is tracked by git.
