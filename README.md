# 🛒 POS System - Streamlined Point of Sale Solution

## 🚀 About the Project

The POS system is a comprehensive application developed using Flutter to manage sales transactions, product inventory, and customer interactions in a seamless and efficient manner. The system allows businesses to handle various aspects of their operations, from managing menu items and customers to processing payments and generating receipts.

## ✨ Features

- 📌 **Product Management**: Add, edit, and delete products with images and categories.
- 🛒 **Cart & Order Processing**: Add items to cart, adjust quantities, and process payments.
- 💾 **SQLite Database Integration**: Store and manage product data locally.
- ⏳ **Hold Orders Functionality**: Save incomplete orders and retrieve them later.
- 🔄 **State Management with BLoC**: Efficient app state handling for a smooth user experience.
- 📑 **Receipt Generation**: Display order summaries with itemized lists.
- 📊 **Sales Insights (Upcoming)**: Track sales and generate reports.

## 🛠️ Tech Stack

- **Flutter** (Cross-platform UI)
- **Dart** (Programming Language)
- **SQLite (sqflite)** (Local Database)
- **BLoC Pattern** (State Management)
- **Json Parsing** (handling data exchange between app and server)

## App Screenshots

Here’s a preview of the app's UI:

<div style="display: flex; justify-content: center;">
  <table style="width: 100%; border-collapse: collapse;">
    <tr>
      <td style="text-align: center; padding: 10px;">
        <img src="https://github.com/user-attachments/assets/839e186e-aa15-42ba-850b-8709b3eea187" alt="Menu Page" style="width: 100%; max-width: 500px;">
        <p><b>Menu Page</b></p>
      </td>
      <td style="text-align: center; padding: 10px;">
        <img src="https://github.com/user-attachments/assets/557c50cd-82f0-4d25-8e00-836ee5e23bd2" alt="Order Summary" style="width: 100%; max-width: 500px;">
        <p><b>Order Summary</b></p>
      </td>
    </tr>
    <tr>
      <td style="text-align: center; padding: 10px;">
        <img src="https://github.com/user-attachments/assets/bf33c9b6-4836-4671-a012-13af8cc59983" alt="Payment Page" style="width: 100%; max-width: 500px;">
        <p><b>Payment Page</b></p>
      </td>
      <td style="text-align: center; padding: 10px;">
        <img src="https://github.com/user-attachments/assets/31946f91-db01-4c26-890d-aeb8bd48655d" alt="Hold Orders View" style="width: 100%; max-width: 500px;">
        <p><b>Hold Orders View</b></p>
      </td>
    </tr>
    <tr>
      <td style="text-align: center; padding: 10px;">
        <img src="https://github.com/user-attachments/assets/4e6d1f6c-51b7-493c-8ca3-a91474808218" alt="Extra Image 1" style="width: 100%; max-width: 500px;">
        <p><b>Extra Image 1</b></p>
      </td>
      <td style="text-align: center; padding: 10px;">
        <img src="https://github.com/user-attachments/assets/1f1cc6b1-0c52-4f0c-871d-b1a699266fad" alt="Extra Image 2" style="width: 100%; max-width: 500px;">
        <p><b>Extra Image 2</b></p>
      </td>
    </tr>
  </table>
</div>
## Key Features and Functionality
1. Product Management
Add, edit, delete, and manage menu items using a local SQLite database.

Support for product attributes, such as name, price, description, and category.

Integration with Flutter BLoC to manage product-related operations like loading and updating items.

2. Cart Management
Real-time cart management using the BLoC pattern, where users can add/remove items, modify quantities, and view total amounts.

Ability to hold orders and store them in the local database for later completion or modification.

3. Order Processing
Create new orders by adding selected items to the cart and assigning a table number and customer name.

Display order details, including total price, items, payment type, and employee handling the transaction.

4. Payment Integration
Support for handling different payment methods, including cash and digital payment types.

Automatically calculate change and display it in the UI after completing a transaction.

5. Receipt Generation
Generate itemized receipts with the ability to print or send digitally to customers.

Support for displaying detailed information, such as order ID, date, total price, employee, and POS machine used.

6. Order History and Reports
View historical orders and payments, including the ability to update or cancel held orders.

Track sales performance and employee productivity by referencing past transactions.

7. UI and UX Design
Clean and intuitive interface using Flutter's rich UI components.

Responsive layout to support various screen sizes, ensuring a seamless user experience on both Android and iOS devices.

Custom widgets like LoadingOverlay and flexible cards for displaying order details, making the app interactive and visually appealing.

8. State Management with BLoC
Using BLoC to handle the cart and product data efficiently, ensuring that the app responds dynamically to user inputs.

Organizing events to handle adding/removing items from the cart, fetching product data from the database, and managing UI updates based on the app’s state.

9. Real-Time Data Synchronization
Integration with MQTT for real-time synchronization of order and inventory data, allowing the app to update dynamically without needing to reload or refresh.

10. Hold Order Feature
Ability to save cart items when an order is placed on hold, with an option to retrieve and resume the order later.

Use of SQLite for persisting held orders and enabling smooth transitions between the active and held states.

How It Works
Product Management: Add and manage products with attributes like name, price, and category.

Cart Management: Add items to the cart, modify quantities, and hold orders for later.

Order Processing: Create orders, assign them to tables, and process payments.

Receipt Generation: Generate and print/send receipts to customers.

Order History: View past orders, update held orders, and track sales performance.

Real-Time Sync: Use MQTT for real-time updates on orders and inventory.
## 🔧 Installation

```sh
# Clone the repository
git clone https://github.com/yourusername/pos-system.git

# Navigate to project directory
cd pos-system

# Install dependencies
flutter pub get

# Run the application
flutter run
```

## 🏗️ Project Structure

```plaintext
/lib
  ├── bloc/             # BLoC state management files
  ├── database/         # SQLite helper classes
  ├── models/           # Data models
  ├── pages/            # UI screens
  ├── widgets/          # Reusable UI components
  ├── main.dart         # App entry point
```

## 📌 Contributing

Contributions are welcome! Feel free to submit issues or pull requests to improve this POS system.

## 📜 Author

**Kinley Prnjor**




