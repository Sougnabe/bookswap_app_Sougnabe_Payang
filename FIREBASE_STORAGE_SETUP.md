# Firebase Storage Setup Guide

## 🔴 Error: "object-not-found" 

This error means Firebase Storage is not enabled or not properly configured in your Firebase project.

---

## ✅ Solution: Enable Firebase Storage

### Step 1: Enable Storage in Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **bookswap-app-c198a**
3. Click **Storage** in the left sidebar
4. Click **Get Started**
5. Click **Next** on the security rules prompt
6. Select your storage location (choose closest to your users)
7. Click **Done**

---

### Step 2: Configure Storage Rules

After enabling Storage, you need to set up security rules:

1. In Firebase Console → **Storage** → **Rules** tab
2. Replace the default rules with the following:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    // Book images
    match /book_images/{userId}/{fileName} {
      // Anyone authenticated can read book images
      allow read: if request.auth != null;
      
      // Only the owner can upload images to their folder
      allow write: if request.auth != null && 
                     request.auth.uid == userId &&
                     request.resource.size < 5 * 1024 * 1024 && // Max 5MB
                     request.resource.contentType.matches('image/.*');
      
      // Only the owner can delete their images
      allow delete: if request.auth != null && 
                      request.auth.uid == userId;
    }
    
    // Default deny all other paths
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

3. Click **Publish**

**OR** use the `storage.rules` file in your project root:

```bash
firebase deploy --only storage
```

---

### Step 3: Verify Storage is Working

1. Run your app
2. Go to **Settings** → **Database Setup**
3. Click **Verify Collections** button
4. Check the logs for: `✅ Storage: OK`

---

## 🧪 Alternative: Use Temporary Permissive Rules (Testing Only)

**⚠️ WARNING: Only use this for development/testing!**

For quick testing, you can use these rules (allows anyone to read/write):

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

**Remember to change to proper rules before production!**

---

## 📝 Manual Steps in Firebase Console

If you prefer visual guidance:

### Enable Storage:
1. **Firebase Console** → Your Project
2. Click **Build** → **Storage** (left menu)
3. Click **Get Started**
4. Choose storage location
5. Click **Done**

### Set Rules:
1. **Storage** → **Rules** tab
2. Copy rules from `storage.rules` file
3. Click **Publish**

### Verify:
1. **Storage** → **Files** tab
2. You should see an empty storage bucket
3. Ready to receive uploads!

---

## 🔧 Quick Fix Commands

If you have Firebase CLI installed:

```bash
# Initialize Firebase Storage in your project
firebase init storage

# Deploy storage rules
firebase deploy --only storage

# Check current rules
firebase storage:rules:get
```

---

## 🐛 Common Issues & Solutions

### Issue: "Permission Denied" when uploading
**Solution**: 
- Check if user is authenticated
- Verify storage rules allow the user to write
- Ensure user is uploading to their own folder (`book_images/{userId}/`)

### Issue: "Quota Exceeded"
**Solution**: 
- Check Firebase Console → Storage → Usage
- Free Spark plan has 5GB storage and 1GB/day download
- Upgrade to Blaze plan if needed

### Issue: "Invalid Content Type"
**Solution**: 
- Storage service only accepts images
- Check file is actually an image (jpg, png, etc.)
- Verify file isn't corrupted

### Issue: Storage bucket not found
**Solution**: 
- Verify `storageBucket` in `firebase_options.dart` matches Firebase Console
- Should be: `bookswap-app-c198a.firebasestorage.app`
- Run `flutterfire configure` to regenerate config

---

## 📊 Storage Structure

Your app stores images in this structure:

```
book_images/
├── {userId1}/
│   ├── book_1234567890.jpg
│   ├── book_1234567891.jpg
│   └── book_1234567892.jpg
├── {userId2}/
│   ├── book_1234567893.jpg
│   └── book_1234567894.jpg
└── ...
```

Each user has their own folder identified by their user ID.

---

## ✅ Checklist

Before testing image upload:

- [ ] Firebase Storage enabled in console
- [ ] Storage rules configured and published
- [ ] App has internet connection
- [ ] User is authenticated
- [ ] Storage bucket matches in config
- [ ] Image picker permissions granted (Android: storage permission)

---

## 🎯 Next Steps

After enabling Storage:

1. ✅ Run the app
2. ✅ Sign in with your account
3. ✅ Go to **Settings** → **Database Setup**
4. ✅ Click **Verify Collections** (check storage status)
5. ✅ Try adding a book with an image
6. ✅ Check Firebase Console → Storage → Files to see uploaded images

---

## 💡 Pro Tips

1. **Development**: Use emulator for faster testing
2. **Images**: Compress images before upload (app does this automatically)
3. **Storage**: Monitor usage in Firebase Console
4. **Security**: Always use proper rules in production
5. **Cleanup**: Delete unused images to save quota

---

## 📞 Still Having Issues?

Check:
1. Firebase Console → Storage → Is it enabled?
2. Flutter console → Any error messages?
3. Firebase Console → Storage → Rules → Are they published?
4. App → Settings → Database Setup → Run verification

---

**Your storage bucket**: `bookswap-app-c198a.firebasestorage.app`

**Ready to test!** Enable Storage in Firebase Console and you're good to go! 🚀
