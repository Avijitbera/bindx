# StateGen Example App - Visual Guide

## 🏠 Home Screen

The home screen is your starting point, featuring:

### Header Section
- **App Title**: "StateGen Demo"
- **Subtitle**: "Advanced State Management with Code Generation"
- **Icon**: Auto-awesome icon representing the magic of code generation

### Features Overview
Six feature cards showcasing StateGen capabilities:

1. **🔄 Caching** (Blue)
   - Automatic caching with memory/disk strategies

2. **📡 Reactive Streams** (Green)
   - Generate reactive streams from properties

3. **✅ Validation** (Orange)
   - Built-in validation for form fields

4. **⚡ Concurrency** (Purple)
   - Debouncing, throttling, and task queuing

5. **🔁 Retry Logic** (Red)
   - Automatic retry for failed operations

6. **🔒 Mutex Support** (Teal)
   - Thread-safe method execution

### Interactive Demos
Three navigation cards:

1. **User Store Demo** (Blue)
   - Icon: Person
   - Description: "Explore caching, streaming, and concurrent operations"

2. **API Store Demo** (Green)
   - Icon: API
   - Description: "See retry logic, throttling, and API caching in action"

3. **Form Store Demo** (Orange)
   - Icon: Edit Document
   - Description: "Test validation and reactive form fields"

### Footer
- Info icon with setup instructions
- Command to run: `flutter pub run build_runner build`

---

## 👤 User Store Demo Screen

### Info Card (Purple)
- Prominent notice about code generation requirement
- Step-by-step instructions
- Command to run in a code block

### User Information Section (Blue)
Three input fields:
- **Name**: Text input with person icon
- **Age**: Number input with calendar icon
- **Email**: Email input with validation indicator

### Cached Getters Section (Green)
Displays cached values:
- **Full Name**: Cached for 10 minutes
- **User Profile**: Cached for 1 hour with disk persistence

### Concurrent Operations Section (Purple)
Two action buttons:
- **Update Profile (Debounced)**: Demonstrates debouncing
- **Increment Login (Throttled)**: Shows throttling in action
- Status message box showing operation results

### Retry & Timeout Section (Orange)
Two demonstration buttons:
- **Fetch Data (Max 3 Retries)**: Shows retry logic
- **Long Running Task (5s Timeout)**: Demonstrates timeout handling

### Mutex Protected Section (Red)
- **Critical Update (Mutex)**: Thread-safe operation
- Explanation text about mutex protection

### Loading Indicator
- Circular progress indicator when operations are running

---

## 🌐 API Store Demo Screen

### Stats Dashboard (Purple)
Two statistics displayed:
- **API Calls**: Counter showing total requests
- **Status**: Current state (Loading/Idle)

### Cached API Calls Section (Blue)
- **Get Cached Data** button
- Description: "Cached for 5 minutes with disk persistence"

### Concurrent Operations Section (Green)
Two buttons:
- **Fetch Users (Debounced)**: Debounced API call
- **Throttled Call**: Rate-limited operation
- Explanation about debouncing

### Retry Logic Section (Orange)
- **Fetch with Retry** button
- Shows multiple retry attempts in the log
- Description: "Automatically retries on failure (500ms delay)"

### Timeout Handling Section (Red)
- **Slow Endpoint** button
- Description: "Times out after 3 seconds"

### Combined Features Section (Purple)
- **Complex API Call** button
- Combines concurrent + retry + timeout

### Activity Log (Teal)
Scrollable log showing:
- Timestamps for each operation
- Color-coded icons:
  - ✓ Green check for success
  - ⚠ Orange warning for retries
  - ℹ Blue info for general messages
- Monospace font for readability
- Clear button to reset the log

---

## 📝 Form Store Demo Screen

### Form Status Card
Dynamic card showing:
- **Valid State** (Green): "Form Valid" with check icon
- **Invalid State** (Gray): "Fill in the form" with edit icon
- Status description

### Validation Error Banner (Red)
- Appears when validation fails
- Shows specific error message
- Auto-dismisses after 3 seconds

### User Information Section (Blue)
Four required fields with real-time validation:

1. **Username** ⭐
   - Validator: Not empty
   - Green check icon when valid

2. **Email** ⭐
   - Validators: Not empty, Email format
   - Green check icon when valid
   - Shows format error if invalid

3. **Password** ⭐
   - Validators: Not empty, Min length (6)
   - Obscured text
   - Green check icon when valid

4. **Age** ⭐
   - Validator: Min value (18)
   - Number keyboard
   - Green check icon when valid

Each field shows:
- Label with asterisk for required
- Appropriate icon
- Validation rules below
- Real-time validation feedback

### Optional Information Section (Purple)
- **Website** field
  - Validator: URL format
  - Optional field
  - Shows check when valid URL entered

### Reactive Streams Info (Green)
Information card explaining:
- Which fields are streamed
- How to use streams after code generation

### Submit Button
- Large, prominent button
- **Enabled**: When form is valid
- **Disabled**: When form is invalid or submitting
- Shows loading spinner during submission
- Text changes to "Submitting..." during operation

### Success Dialog
After successful submission:
- Green check icon
- "Success!" title
- Explanation about debouncing
- OK button to dismiss and reset

### Features Info Card (Tertiary color)
Lists demonstrated features:
- ✓ Real-time validation with multiple validators
- ✓ Reactive streams for form fields
- ✓ Debounced form submission
- ✓ Cached form validation state

---

## 🎨 Design Elements

### Color Scheme
- **Primary**: Deep Purple (Material 3)
- **Feature Colors**:
  - Blue: Caching, User info
  - Green: Streams, API operations
  - Orange: Validation, Retry
  - Purple: Concurrency, Optional fields
  - Red: Mutex, Timeout
  - Teal: Logs, Additional features

### Typography
- **Headers**: Bold, larger size
- **Body**: Regular weight
- **Monospace**: For code and logs
- **Small**: For descriptions and hints

### Icons
- Meaningful icons for each feature
- Consistent sizing
- Color-coded to match sections

### Cards
- Rounded corners (12px)
- Subtle elevation
- Padding for breathing room
- Color-coded backgrounds for different sections

### Buttons
- Elevated style
- Icon + Label
- Disabled state when loading
- Consistent padding

### Feedback
- Loading indicators
- Success/error messages
- Real-time validation
- Activity logs

---

## 📱 User Flow

1. **Launch App** → Home Screen
2. **Choose Demo** → Navigate to specific demo
3. **Interact** → Click buttons, fill forms
4. **Observe** → See real-time feedback
5. **Learn** → Understand StateGen features

---

## 💡 Interactive Elements

### Buttons
- Change state when pressed
- Show loading indicators
- Provide immediate feedback

### Text Fields
- Real-time validation
- Visual feedback (check icons)
- Error messages

### Logs
- Auto-scroll to latest
- Color-coded entries
- Timestamps

### Dialogs
- Success confirmations
- Clear messaging
- Easy dismissal

---

## 🎯 Key Takeaways

1. **Visual Hierarchy**: Important elements stand out
2. **Color Coding**: Easy to identify feature categories
3. **Real-time Feedback**: Users know what's happening
4. **Clear Instructions**: No confusion about next steps
5. **Interactive**: Everything can be tested
6. **Educational**: Learn by doing

---

**Tip**: Run the app to see all these elements in action! The visual design makes it easy to understand complex StateGen features.
