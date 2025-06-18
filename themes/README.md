# 🎨 Jellyfin Themes

This directory contains custom themes for Jellyfin to enhance your media server's appearance.

## 🌊 Zesty Cyan Theme

The included **Zesty Cyan Theme** provides a beautiful cyan color scheme with:

- ✨ **Cyan accent colors** (#BBF1DD primary, #6B8A7F secondary)
- 🎨 **Dark color scheme** optimized for media viewing
- 🖼️ **Custom backgrounds** and gradients
- 📝 **Quicksand font** for better typography
- 🎭 **Custom login wallpapers**

### Preview
- **Primary Colors**: Cyan and dark green tones
- **Style**: Modern, clean, dark theme
- **Best For**: Night viewing, reduced eye strain

## 🚀 Auto-Installation

The setup script (`./setup.sh`) will ask if you want to apply the Zesty Cyan theme automatically.

If you choose **Yes**:
- ✅ Theme is automatically copied to Jellyfin
- ✅ Applied immediately after Jellyfin starts
- ✅ No manual configuration needed

If you choose **No**:
- ✅ You can apply themes manually later
- ✅ Jellyfin uses default theme

## 🔧 Manual Installation

To apply the theme manually after setup:

1. **Copy the theme file**:
   ```bash
   docker cp themes/jellyfin/zesty-cyan-theme.css jellyfin:/config/custom.css
   ```

2. **Restart Jellyfin**:
   ```bash
   docker-compose restart jellyfin
   ```

3. **Enable in Jellyfin**:
   - Go to Admin Dashboard → General → Custom CSS
   - The theme should already be loaded

## 🎨 Creating Custom Themes

You can create your own themes by:

1. **Copying the base theme**:
   ```bash
   cp themes/jellyfin/zesty-cyan-theme.css themes/jellyfin/my-custom-theme.css
   ```

2. **Editing colors** in the `:root` section:
   ```css
   :root {
     --accent: 187, 241, 221;         /* Your primary color */
     --accent-off: 107, 138, 127;     /* Your secondary color */
     --dark: 27, 36, 33;              /* Dark background */
     /* ... customize other colors ... */
   }
   ```

3. **Applying your theme**:
   ```bash
   docker cp themes/jellyfin/my-custom-theme.css jellyfin:/config/custom.css
   docker-compose restart jellyfin
   ```

## 🌈 Theme Gallery

### Zesty Cyan
- **Colors**: Cyan (#BBF1DD) with dark greens
- **Feel**: Cool, modern, professional
- **Use Case**: General media viewing

Want to contribute more themes? Submit a pull request! 🎉

## 🔄 Switching Themes

To switch between themes:

1. **Copy desired theme**:
   ```bash
   docker cp themes/jellyfin/THEME_NAME.css jellyfin:/config/custom.css
   ```

2. **Restart Jellyfin**:
   ```bash
   docker-compose restart jellyfin
   ```

3. **Clear browser cache** to see changes immediately

## 🛠️ Troubleshooting

### Theme not applying?
- Check that custom.css exists in Jellyfin config
- Restart Jellyfin container
- Clear browser cache
- Check Jellyfin logs for CSS errors

### Want to disable themes?
- Remove or rename custom.css file
- Restart Jellyfin
- Jellyfin will use default theme

---

**Note**: Themes are cosmetic only and don't affect Jellyfin functionality. You can always revert to the default theme by removing the custom.css file.
