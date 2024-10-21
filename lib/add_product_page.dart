import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddItemPage extends StatefulWidget {
  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final picker = ImagePicker();
  File? _image;
  bool isLoading = false;
  bool isAccessory = false; // To toggle between Product and Accessory
  String availability = 'Available'; // Default availability status

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<void> saveItem() async {
    if (nameController.text.isEmpty || priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All fields are required')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? itemString = isAccessory ? prefs.getString('accessories') : prefs.getString('products');
      List<Map<String, dynamic>> itemList = itemString != null
          ? List<Map<String, dynamic>>.from(jsonDecode(itemString))
          : [];

      if (itemList.any((item) =>
      item['name'].toLowerCase() == nameController.text.toLowerCase())) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${isAccessory ? "Accessory" : "Product"} already exists')),
        );
        return;
      }

      final newItem = {
        'name': nameController.text,
        'price': priceController.text,
        'imageUrl': _image?.path ?? '',
        if (isAccessory) 'availability': availability, // Availability for accessories only
      };

      itemList.add(newItem);

      if (isAccessory) {
        await prefs.setString('accessories', jsonEncode(itemList));
      } else {
        await prefs.setString('products', jsonEncode(itemList));
      }

      Navigator.pop(context, true); // Return to HomePage and indicate success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save ${isAccessory ? "accessory" : "product"}')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text('Add ${isAccessory ? "Accessory" : "Product"}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Switch to toggle between Product and Accessory
            SwitchListTile(
              title: Text('Add ${isAccessory ? "Accessory" : "Product"}',style: const TextStyle(fontWeight: FontWeight.bold),),
              value: isAccessory,
              onChanged: (value) {
                setState(() {
                  isAccessory = value;
                  nameController.clear();
                  priceController.clear();
                  _image = null; // Clear the selected image when switching
                  availability = 'Available'; // Reset availability when switching
                });
              },
            ),
            // Name Text Field
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: '${isAccessory ? "Accessory" : "Product"} Name'),
            ),
            const SizedBox(height: 16),
            // Price Text Field
            TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            // Conditional Availability Dropdown for Accessories Only
            if (isAccessory)
              DropdownButtonFormField<String>(
                value: availability,
                decoration: InputDecoration(labelText: 'Availability'),
                items: <String>['Available', 'Unavailable']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    availability = newValue!;
                  });
                },
              ),
            const SizedBox(height: 16),
            // Image Picker Row
            Row(
              children: [
                _image != null
                    ? Image.file(_image!, width: 100, height: 100)
                    : const Text('No Image Selected',style: TextStyle(fontWeight: FontWeight.bold),),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: pickImage,
                  child: const Text('Select Image',style: TextStyle(fontWeight: FontWeight.bold),),
                ),
              ],
            ),
            const Spacer(),
            // Loading Indicator or Add Button
            isLoading
                ? const CircularProgressIndicator()
                : OutlinedButton(
              onPressed: saveItem,
              child: Text('Add ${isAccessory ? "Accessory" : "Product"}',style: TextStyle(fontWeight: FontWeight.bold),),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}