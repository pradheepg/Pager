# Pager 📚

[![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS-lightgrey.svg)]()
<!-- [![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE) -->

**Pager** is a native iOS eBook reader application built with **Swift** and **UIKit**. Inspired by the user experience of Apple Books and Amazon Kindle, Pager features a custom pagination engine that dynamically renders raw text strings into book-like pages with a realistic page-curl navigation.

It leverages **Core Data** for robust local persistence, ensuring your reading progress are saved seamlessly.

## 📱 Demo

<!-- <div align="center">
  <img src="https://drive.google.com/file/d/1aPY-rrf5urMcNY7rWhyj1E6fA0Qcc9mJ/view?usp=sharing" alt="App Demo" width="250">

  <p><i>See the app in action.</i></p>
</div> -->
Click here
[Click here][Video_link]

[Video_link]: https://drive.google.com/file/d/1w9fIPCZTSSg6zmj9GD8pfh2B6SxwmclH/view?usp=sharing
---

## ✨ Key Features

* **📖 Custom Text Pagination:** An intelligent engine that takes long strings of text and dynamically calculates page breaks based on the device screen size and font settings.
* **📄 Realistic Navigation:** Implements `UIPageViewController` with a "Page Curl" transition style to mimic turning a physical page.
* **💾 Smart Persistence (Core Data):**
    * **Auto-Resume:** Automatically saves the exact page/character index where you left off.
* **🎯 Reading Goals:** Track daily reading habits.
* **🎨 Dynamic UI:** 100% Programmatic UI implementation handling Safe Areas and different device sizes.

## 🛠 Tech Stack

* **Language:** Swift
* **Frameworks:** UIKit, Core Data, Foundation
* **Architecture:** MVVM 
* **Text Handling:** NSAttributedString / TextKit (for layout calculation)

## 🚀 Installation & Setup

1.  **Clone the repo**
    ```bash
    git clone [https://github.com/pradheepg/Pager.git](https://github.com/pradheepg/Pager.git)
    ```
2.  **Open in Xcode**
    ```bash
    cd Pager
    open Pager.xcodeproj
    ```
3.  **Run**
    * Select an iOS Simulator (iPhone 14/15 recommended).
    * Press `Cmd + R` to build and run.

## 📸 Screenshots

| Library | Reading View | Settings |
|:---:|:---:|:---:|
| <img src="https://github.com/user-attachments/assets/3b91e451-be28-46dd-b075-a3cb453ad6a7" width="180"> | <img src="https://github.com/user-attachments/assets/70974b56-3d4e-4973-8b10-8cd665f541cd" width="180"> | <img src="https://github.com/user-attachments/assets/7c4e934a-adf3-4c1c-9295-48e79354f606" width="180"> |

## 🔮 Future Improvements

* [ ] Add font size and font family customization.
* [ ] Support for parsing local .txt or .json files.
* [ ] Dark Mode support optimization.

## 👤 Author

**Pradheep G**
* GitHub: [@pradheepg](https://github.com/pradheepg)
<!--
## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details. -->
