# Soulmate Matrimony - Full Stack Application

Welcome to the full-stack version of the **Soulmate** Matrimony application. The application has been restructured into a decoupled frontend-backend architecture to support dynamic database-driven features.

## Project Structure
* **`backend/`**: Node.js Express server configured in an MVC (Model-View-Controller) architecture, connecting to MongoDB Atlas and Firebase Admin SDK.
* **`frontend/`**: The complete Flutter mobile application configured to communicate with the Node.js backend APIs.

---

## 🛠️ Prerequisites
Ensure you have the following installed on your machine:
1. [Node.js](https://nodejs.org/) (v16 or higher)
2. [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.0 or higher)
3. A MongoDB Atlas account and cluster
4. A Firebase Project configured with:
   * **Phone Authentication** (under Build -> Authentication -> Sign-in method)
   * **Google Sign-In** (under Build -> Authentication -> Sign-in method)

---

## 🚀 How to Run the Application

Follow these simple steps to run both the backend and the frontend:

### Step 1: Run the Backend (Node.js Express)
1. Open a terminal and navigate to the `backend` folder:
   ```bash
   cd backend
   ```
2. Verify the `.env` file exists and has your MongoDB Atlas connection string:
   ```env
   PORT=5000
   MONGO_URI=mongodb+srv://rithish:rithish@cluster0.fmzkavt.mongodb.net/Matrimony?retryWrites=true&w=majority
   JWT_SECRET=soulmate_secret_key_2026
   ```
3. Run the development server:
   ```bash
   npm run dev
   ```
   *The server will start on `http://localhost:5000`. On first run, it will automatically connect to MongoDB Atlas and seed the database with the 15 candidate profiles!*

---

### Step 2: Run the Frontend (Flutter)
1. Open a new terminal window and navigate to the `frontend` folder:
   ```bash
   cd frontend
   ```
2. Fetch package dependencies:
   ```bash
   flutter pub get
   ```
3. Launch the application on your emulator or physical device:
   ```bash
   flutter run
   ```
   *By default, the Flutter app connects to `http://10.0.2.2:5000` (which is the default Android emulator address mapping back to your host machine's localhost). If you are running on iOS, Web, or a physical device, make sure to update the `baseUrl` in `lib/services/api_service.dart` to match your local IP address.*

---

## 🔑 Administrative Access & Testing
To log into the **Admin Panel** to create, edit, or delete candidates:
1. Open the app and click **Sign Up**.
2. Create an account with the Full Name set to **`admin`** or email set to **`admin@soulmate.com`**.
3. Complete the verification.
4. When you log in, your account will automatically be assigned the `Admin` role.
5. Navigate to the profile settings tab (the last tab) on the Home Page, and you will see the **Admin Panel** option listed in the menu!
