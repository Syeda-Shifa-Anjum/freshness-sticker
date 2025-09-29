# Deploy Script for Smart Freshness Sticker Web App

## 🌐 Web Deployment Guide

This directory contains the built web version of the Smart Freshness Sticker app.

### Quick Deploy Options:

#### 1. **GitHub Pages**

1. Push this repository to GitHub
2. Go to Settings > Pages
3. Select "Deploy from a branch"
4. Choose `main` branch and `/ (root)` folder
5. Your app will be available at `https://yourusername.github.io/smart_freshness_sticker`

#### 2. **Netlify**

1. Create account at netlify.com
2. Drag and drop the `build/web` folder
3. Or connect your GitHub repo for auto-deployment

#### 3. **Vercel**

1. Install Vercel CLI: `npm i -g vercel`
2. Run `vercel` in the project directory
3. Follow the prompts

#### 4. **Firebase Hosting**

```bash
npm install -g firebase-tools
firebase login
firebase init hosting
firebase deploy
```

#### 5. **Surge.sh**

```bash
npm install -g surge
cd build/web
surge
```

### 📁 File Structure for Deployment:

```
smart_freshness_sticker/
├── index.html          # Landing page (this redirects to build/web/)
├── build/web/          # Actual Flutter web app
│   ├── index.html      # Flutter app entry point
│   ├── main.dart.js    # Compiled Dart code
│   ├── assets/         # App assets
│   └── ...
└── README.md
```

### 🔧 Build Commands:

```bash
# Development
flutter run -d chrome

# Production build
flutter build web

# Production build with custom base URL
flutter build web --base-href "/your-app/"

# Build with WebAssembly (experimental)
flutter build web --wasm
```

### ⚠️ Important Notes:

1. **Camera Access**: Requires HTTPS in production
2. **Mobile Features**: Some features work better on mobile
3. **PWA**: The app can be installed as a Progressive Web App
4. **Offline**: Works offline after first load (service worker)

### 🎯 Live Demo:

Once deployed, users can:

- Access the landing page at your domain
- Click "Launch Web App" to use the Flutter app
- Install as PWA on mobile devices
- Use camera (with HTTPS) to scan stickers

### 📱 Mobile App Links:

Consider adding download links for native apps:

- Google Play Store: `https://play.google.com/store/apps/details?id=your.package`
- Apple App Store: `https://apps.apple.com/app/your-app-id`
