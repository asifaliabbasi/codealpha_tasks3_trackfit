# TrackFit - Quick Start Guide 🚀

## Installation

### 1. Install Dependencies
```bash
cd codealpha_tasks3_trackfit
flutter pub get
```

### 2. Run the App
```bash
# For Android
flutter run

# For iOS
flutter run -d ios

# For Web
flutter run -d chrome
```

---

## First Time Setup

1. **Launch App** - Beautiful animated splash screen appears
2. **Set Goals** - You'll be prompted to set your fitness goals:
   - Push-ups target (e.g., 50)
   - Daily steps target (e.g., 10,000)
3. **Create Profile** (Optional) - Add your personal info:
   - Name
   - Age
   - Height
   - Weight
   - Gender
   - Bio

---

## Features Overview

### 📊 Dashboard
- **Streak Counter** - See your consecutive workout days with animated fire
- **Quick Actions** - Fast access to:
  - 🏆 Achievements
  - ⚖️ BMI Calculator
  - 💧 Water Tracker
- **Analytics Card** - View all your progress:
  - Plank duration
  - Breathing duration
  - Total push-ups
  - Total steps
- **Weekly Chart** - Visual progress over last 7 days
- **Exercise Cards** - Start workouts:
  - Push-ups
  - Steps (Pedometer)
  - Plank
  - Breathing Exercise

### 🎯 Goals Tab
Set and update your fitness targets:
- Push-ups goal
- Steps goal
- See progress bars on dashboard

### 👤 Profile Tab
Manage your personal information:
- View/Edit profile
- Track BMI changes
- Personal stats

---

## How to Use Each Feature

### 💪 Starting a Workout

#### Push-ups
1. Tap "PushUps" card on dashboard
2. Enter number of push-ups you want to do
3. Tap "Done"
4. Progress is automatically saved

#### Steps (Pedometer)
1. Tap "Steps" card
2. Grant activity recognition permission
3. Tap "Start Tracking"
4. Walk around - steps are counted automatically
5. Tap "Finish" to save

#### Plank
1. Tap "Plank" card
2. Enter duration (minutes:seconds)
3. Tap "Start"
4. Timer counts down
5. Hold your plank position!

#### Breathing Exercise
1. Tap "Lungs" card
2. Enter target duration
3. Tap "Start"
4. Hold your breath for the timer

### 🏆 Achievements
- Tap trophy icon on dashboard
- View all 8 achievements
- Locked achievements show requirements
- Unlocked achievements are highlighted
- Slide-in animations show progress

### ⚖️ BMI Calculator
1. Tap "BMI" button
2. Enter height in cm
3. Enter weight in kg
4. Tap "Calculate BMI"
5. See result with category and color coding

### 💧 Water Tracker
1. Tap "Water" button
2. Tap quick add buttons:
   - +100ml (glass)
   - +250ml (cup)
   - +500ml (bottle)
   - +1000ml (large bottle)
3. Watch progress bar fill up
4. Goal: 2000ml daily
5. Resets automatically each day

### 📈 Weekly Chart
- Automatically appears on dashboard
- Shows last 7 days of workouts
- Push-ups count plotted
- Smooth animated line graph

### 🔥 Streak Tracking
- Workout on consecutive days
- Fire icon animates when streak is active
- Shows days count
- Resets if you skip a day

---

## Tips & Tricks

### 🎉 Trigger Confetti
- Complete your daily goals
- Confetti automatically bursts!
- Works for both push-ups and steps goals

### 🎖️ Unlock All Achievements
To unlock all achievements:
1. **First Steps** - Do any workout
2. **Push Master** - Reach 100 total push-ups
3. **Step Champion** - Walk 10,000 steps
4. **Dedicated** - 7-day workout streak
5. **Committed** - 30-day workout streak
6. **Push Elite** - 500 total push-ups
7. **Marathon Walker** - 50,000 total steps
8. **Legend** - 100-day workout streak

### 📊 Reset Progress
- Go to Dashboard
- Scroll to analytics card
- Tap "Reset Progress"
- Clears all workout history (use with caution!)

### 📜 View History
- Tap "Show History" on dashboard
- See all past workouts with dates
- View individual workout details

---

## Troubleshooting

### Pedometer Not Working
1. **Android:**
   - Go to Settings → Apps → TrackFit → Permissions
   - Enable "Physical activity"
   
2. **iOS:**
   - Go to Settings → Privacy → Motion & Fitness
   - Enable for TrackFit

### Goals Not Showing
1. Make sure you've set goals in Goals tab
2. Restart the app
3. Goals must be > 0

### Charts Not Appearing
- Charts only show when you have workout data
- Complete at least one workout
- Wait a few seconds for data to load

### Confetti Not Playing
- Make sure you've achieved at least one goal
- Confetti only plays once per session
- Restart app to see it again

---

## Keyboard Shortcuts (Desktop/Web)

- **Tab** - Navigate between fields
- **Enter** - Submit forms
- **Esc** - Close dialogs

---

## Data Storage

### Local Database (SQLite)
- All workout data stored locally
- No internet required
- Data persists between app launches

### Shared Preferences
- Water intake (daily)
- Step count (resets daily)
- User preferences

---

## Permissions Required

### Android
- **Physical Activity** - For step counting
- **Storage** - For database

### iOS
- **Motion & Fitness** - For step counting

---

## Performance Tips

1. **Close Background Apps** - For accurate step counting
2. **Keep Phone On You** - For pedometer accuracy
3. **Regular Backups** - Use device backup for safety
4. **Clear Old Data** - Reset progress if too much data

---

## Updates & Changelog

### Version 2.0 (Current)
- ✨ Added animations throughout
- 🏆 New achievements system
- ⚖️ BMI calculator
- 💧 Water intake tracker
- 📊 Weekly progress charts
- 🔥 Streak tracking
- 🎊 Confetti celebrations
- 🎨 Improved UI/UX
- 🐛 Fixed profile bug

### Version 1.0
- Basic fitness tracking
- Push-ups, Plank, Steps, Breathing
- Goal setting
- Profile management

---

## Support

For issues or questions:
1. Check this guide
2. Review IMPROVEMENTS.md
3. Check app logs for errors

---

## Best Practices

### For Accurate Tracking
- ✅ Keep phone in pocket for steps
- ✅ Log workouts immediately
- ✅ Set realistic goals
- ✅ Track daily water intake
- ✅ Update profile regularly

### For Motivation
- ✅ Check achievements daily
- ✅ Maintain your streak
- ✅ Beat weekly chart records
- ✅ Share progress with friends
- ✅ Celebrate small wins

---

**Happy Training! 💪🏃‍♂️🏋️‍♀️**

Stay consistent, track your progress, and achieve your fitness goals with TrackFit!

