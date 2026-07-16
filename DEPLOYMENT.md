# Deployment Guide - Render & Mobile Testing

## Backend Deployment on Render

### Prerequisites
- Render account (free tier available)
- MongoDB Atlas account (free tier available)
- Git repository (GitHub, GitLab, or Bitbucket)

### Step 1: Prepare Backend

1. **Push backend code to Git repository**
   ```bash
   cd backend
   git init
   git add .
   git commit -m "Initial commit"
   git branch -M main
   git remote add origin <your-repo-url>
   git push -u origin main
   ```

2. **Configure MongoDB Atlas**
   - Create a free MongoDB Atlas account
   - Create a cluster
   - Create a database user with read/write permissions
   - Whitelist IP address `0.0.0.0/0` (allows all IPs for Render)
   - Copy the connection string

### Step 2: Deploy to Render

1. **Create a new Web Service on Render**
   - Go to [render.com](https://render.com)
   - Click "New +" → "Web Service"
   - Connect your Git repository
   - Select the `backend` folder as root directory (if needed)

2. **Configure Environment Variables**
   - **PORT**: `10000`
   - **MONGO_URI**: Your MongoDB connection string
   - **JWT_SECRET**: Generate a secure random string (use: `openssl rand -base64 32`)

3. **Build Settings**
   - **Build Command**: `npm install`
   - **Start Command**: `node server.js`

4. **Deploy**
   - Click "Create Web Service"
   - Wait for deployment to complete (2-3 minutes)
   - Copy the deployed URL (e.g., `https://bloom-ivf-backend.onrender.com`)

### Step 3: Seed Database (Optional)

After deployment, seed the database:
```bash
# SSH into your Render service or use Render shell
# Run: node seed.js
```

Or add a build script in package.json:
```json
"scripts": {
  "postinstall": "node seed.js"
}
```

## Mobile App Configuration

### Step 1: Update API URL

Edit `lib/config/app_config.dart`:
```dart
class AppConfig {
  // Replace with your Render URL
  static const String productionApiUrl = 'https://your-render-app-url.onrender.com/api';
  
  static const String localApiUrl = 'http://localhost:4000/api';
  
  // Set to true when using production backend
  static const bool useProduction = true;
  
  static String get apiUrl => useProduction ? productionApiUrl : localApiUrl;
}
```

### Step 2: Build for Mobile

**For Android:**
```bash
flutter build apk --release
```

**For iOS:**
```bash
flutter build ios --release
```

## Testing with Mobile Hotspot

### Option 1: Using Local Backend (Development)

1. **Find your computer's IP address**
   - Windows: `ipconfig` (look for IPv4 Address)
   - Mac/Linux: `ifconfig` or `ip a`

2. **Update backend to allow external connections**
   - Server already configured to listen on `0.0.0.0` (done)

3. **Configure Flutter app**
   - Set `useProduction = false` in `app_config.dart`
   - Update `localApiUrl` to your computer's IP:
   ```dart
   static const String localApiUrl = 'http://192.168.1.100:4000/api';
   ```

4. **Connect mobile to same network**
   - Enable mobile hotspot on your phone
   - Connect computer to the hotspot
   - Or connect phone to computer's hotspot

5. **Allow firewall access**
   - Windows: Allow Node.js through Windows Firewall
   - Mac: Allow incoming connections for Node.js

### Option 2: Using Render Backend (Production)

1. **Deploy backend to Render** (follow steps above)

2. **Configure Flutter app**
   - Set `useProduction = true` in `app_config.dart`
   - Update `productionApiUrl` with your Render URL

3. **Build and install app**
   - No network restrictions - works from anywhere

## Troubleshooting

### ClientException Error
If you encounter "ClientException" errors:

1. **Check API URL is correct**
   - Ensure URL includes `/api` suffix
   - Verify no typos in the URL

2. **Verify backend is running**
   - Check Render dashboard for service status
   - Test health endpoint: `https://your-url.onrender.com/api/health`

3. **Check CORS configuration**
   - Backend already has CORS enabled
   - Verify no CORS errors in browser console

4. **Network connectivity**
   - Ensure mobile device has internet connection
   - Test URL in mobile browser

5. **Firewall issues (local development)**
   - Allow Node.js through firewall
   - Temporarily disable firewall for testing

### Render Deployment Issues

1. **Build fails**
   - Check Render logs for specific errors
   - Ensure all dependencies are in package.json

2. **Database connection fails**
   - Verify MongoDB Atlas IP whitelist includes `0.0.0.0/0`
   - Check connection string format
   - Ensure database user has correct permissions

3. **Service crashes**
   - Check Render logs
   - Verify environment variables are set correctly
   - Ensure PORT is set to 10000

## Security Notes

- **Never commit .env file** to Git
- **Use strong JWT_SECRET** in production
- **Enable MongoDB Atlas authentication**
- **Consider adding rate limiting** for production
- **Use HTTPS only** in production (Render provides this automatically)

## Production Checklist

- [ ] Backend deployed to Render
- [ ] MongoDB Atlas configured with IP whitelist
- [ ] Environment variables set in Render
- [ ] Database seeded with initial data
- [ ] Flutter app configured with production URL
- [ ] App tested on physical device
- [ ] HTTPS working correctly
- [ ] All API endpoints functioning
