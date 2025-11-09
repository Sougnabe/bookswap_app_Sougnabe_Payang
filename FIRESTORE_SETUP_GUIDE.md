# Firestore Database Setup Guide

## 🎯 Quick Start

Your BookSwap app now has a built-in Database Setup tool! Here's how to use it:

### Step 1: Run the App
```bash
flutter run
```

### Step 2: Access Database Setup
1. Sign in to the app (create an account if needed)
2. Go to **Settings** tab (bottom navigation)
3. Tap on **Database Setup** under Developer Tools
4. Use the setup screen to manage your Firestore database

---

## 📊 Database Collections Structure

Your app uses the following Firestore collections:

### 1. **users** Collection
```
users/{userId}
├── id: string
├── email: string
├── displayName: string
├── isEmailVerified: boolean
└── createdAt: timestamp
```

**Purpose**: Store user profile information

### 2. **book_listings** Collection
```
book_listings/{bookId}
├── id: string
├── title: string
├── author: string
├── condition: number (0-3)
├── imageUrl: string
├── ownerId: string
├── ownerName: string
├── createdAt: timestamp
└── isAvailable: boolean
```

**Purpose**: Store all book listings in the marketplace

**Book Conditions**:
- 0 = New
- 1 = Like New
- 2 = Good
- 3 = Used

### 3. **swap_offers** Collection
```
swap_offers/{offerId}
├── id: string
├── bookId: string
├── bookTitle: string
├── bookImageUrl: string
├── senderId: string
├── senderName: string
├── receiverId: string
├── receiverName: string
├── status: number (0-3)
├── createdAt: timestamp
└── updatedAt: timestamp (optional)
```

**Purpose**: Track swap requests between users

**Swap Status**:
- 0 = Pending
- 1 = Accepted
- 2 = Rejected
- 3 = Completed

### 4. **chats** Collection (with subcollections)
```
chats/{chatId}
└── messages/{messageId}
    ├── id: string
    ├── chatId: string
    ├── senderId: string
    ├── senderName: string
    ├── message: string
    ├── timestamp: timestamp
    └── isRead: boolean
```

**Purpose**: Store chat messages between users discussing swaps

**Note**: `chatId` is the same as `swap_offers` offerId

---

## 🔧 Using the Database Setup Tool

### Features Available:

#### 1. **Verify Collections** ✅
- Checks if all required collections exist
- Verifies read/write permissions
- Shows collection accessibility status

#### 2. **Create Sample Data** 📚
- Creates your user profile in Firestore
- Adds 3 sample books to your account
- Perfect for testing the app

#### 3. **Show Statistics** 📊
- Displays document counts for each collection
- Shows current database state
- Useful for monitoring data

#### 4. **Clear All Data** 🗑️
- Removes all test data from Firestore
- Use with caution - cannot be undone!
- Good for resetting during development

---

## 🔒 Security Rules Setup

### Firestore Rules

1. Go to Firebase Console → Firestore Database → Rules
2. Copy the contents from `firestore.rules` file
3. Paste and publish

**OR** use Firebase CLI:
```bash
firebase deploy --only firestore:rules
```

### Storage Rules

1. Go to Firebase Console → Storage → Rules
2. Copy the contents from `storage.rules` file
3. Paste and publish

**OR** use Firebase CLI:
```bash
firebase deploy --only storage
```

---

## 📇 Firestore Indexes

Your app requires composite indexes for optimal performance. Firestore will prompt you to create them when needed, or create them manually:

### Required Indexes:

1. **book_listings**
   - Collection: `book_listings`
   - Fields: 
     - `isAvailable` (Ascending)
     - `createdAt` (Descending)

2. **book_listings (user listings)**
   - Collection: `book_listings`
   - Fields:
     - `ownerId` (Ascending)
     - `createdAt` (Descending)

3. **swap_offers (sent)**
   - Collection: `swap_offers`
   - Fields:
     - `senderId` (Ascending)
     - `createdAt` (Descending)

4. **swap_offers (received)**
   - Collection: `swap_offers`
   - Fields:
     - `receiverId` (Ascending)
     - `createdAt` (Descending)

5. **messages**
   - Collection Group: `messages`
   - Fields:
     - `timestamp` (Ascending)

### Creating Indexes:

**Option 1: Automatic (Recommended)**
- Run the app and use the features
- When Firestore needs an index, it will show an error with a link
- Click the link to auto-create the index

**Option 2: Manual**
1. Go to Firebase Console → Firestore → Indexes
2. Click "Create Index"
3. Enter the collection and fields as listed above
4. Click "Create"

---

## 🚀 Deployment Checklist

Before going to production:

- [ ] Update Firestore security rules (use provided `firestore.rules`)
- [ ] Update Storage security rules (use provided `storage.rules`)
- [ ] Create all required composite indexes
- [ ] Test all CRUD operations
- [ ] Verify user authentication works
- [ ] Test image upload functionality
- [ ] Remove or hide the Database Setup tool for production

---

## 🐛 Troubleshooting

### "Permission Denied" Errors
- Check if security rules are properly deployed
- Verify user is authenticated
- Ensure user owns the resource they're trying to modify

### "Index Required" Errors
- Click the error link to auto-create the index
- Wait 1-2 minutes for index to build
- Retry the operation

### "Collection Not Found"
- Use the "Verify Collections" button in Database Setup
- Collections are created automatically on first write
- No need to manually create collections

### Authentication Issues
- Verify Firebase is properly configured
- Check SHA-1 certificate is added (Android)
- Ensure email verification is enabled

---

## 💡 Tips

1. **Development**: Use the Database Setup tool to quickly populate test data
2. **Testing**: Create multiple user accounts to test swap functionality
3. **Images**: Use placeholder images during testing (sample data includes Open Library covers)
4. **Production**: Remove the Database Setup tool or add admin-only access
5. **Monitoring**: Check Firebase Console regularly for usage and errors

---

## 📚 Additional Resources

- [Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Firebase Authentication](https://firebase.google.com/docs/auth)
- [Firebase Storage](https://firebase.google.com/docs/storage)
- [Security Rules Guide](https://firebase.google.com/docs/firestore/security/get-started)

---

## 🎉 You're Ready!

Your Firestore database structure is now set up and ready to use. Start by:

1. Running the app
2. Creating an account
3. Using the Database Setup tool to create sample data
4. Exploring all features of the BookSwap app

Happy coding! 📖✨
