# Linez App

## Introduction

Linez is a mobile app that allows users to view wait times for their favorite bars in Boston. This app attempts to fix the problem of a college student Ubering across Boston to a popular bar, only to wait an hour in line in the cold. The app allows users to view wait times before they decide on a destination, and attempts to incentivize them to self report wait times if they are near a bar already. 

The app includes a list of bars on one page, and an interactive map of Boston on another. Users can click a bar icon to see details about the wait time and images of the lines depending on what users submit.

This app was developed in Flutter, using a BLoC design pattern for state management. It uses Firebase as a backend for authentication, file storage, database, and serverless functions. 

## Notable Features

The app uses several native mobile features cross platform:
- Location services:
  - Centers the map on the user's location if they are currently in Boston. If the user is outside of Boston, the map will start in the center of the city.
  - Prevents user's from reporting wait times for a particular bar unless they are within a specific distance (to filter out false reports)
- Push notifications:
  - Prompts a user to report a wait time if they pass by a bar while the app is running in the background
- Camera
  - Embedded camera component so users can take pictures of lines and upload without leaving the app
- SMS authentication with confirmation code
- Anonmyous authentication for tracking user engagement
- Google Maps API
  - User location integration
  - Custom clickable location icons
  - Interactive dialogue windows
  
## Challenges

The biggest challenge from a development perspective was probably the responsive design. There many different mobile sizes and edge cases. This required testing on a lot of Android/IOS emulators.

This app relies on a network effect of users submitting information for the benefit of other users. Since it addresses a relatively minor problem, it would be very difficult to support an active user base on this concept alone.

The process for approval and compliance with the Apple Store and Google Play Store is definitely frustrating. It could take a week or longer to push a hot fix to the app itself. Moving as much logic as possible to the backend would help, but a progressive web app approach might just be more practical in a lot of cases.

![IMG_1573](https://github.com/user-attachments/assets/5e1ef201-8db1-480e-a906-e758f114fdb7)
![IMG_1572](https://github.com/user-attachments/assets/a6397179-0a66-4df5-b0ea-a4a7120a78f8)
![IMG_1574](https://github.com/user-attachments/assets/c631e013-6fdc-457c-98b6-0b1e5d106bdd)
![IMG_1575](https://github.com/user-attachments/assets/7358787d-395a-450f-9d5b-121ab15d175d)
