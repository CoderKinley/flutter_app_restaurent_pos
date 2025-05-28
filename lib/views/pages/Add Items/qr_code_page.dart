import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class QrCodePage extends StatefulWidget {
  const QrCodePage({super.key});

  @override
  State<QrCodePage> createState() => _QrCodePageState();
}

class QrCodeImage {
  final String path;
  final String title;

  QrCodeImage({required this.path, required this.title});
}

class _QrCodePageState extends State<QrCodePage> {
  List<QrCodeImage> _savedImages = [];
  bool _isLoading = false;
  final TextEditingController _titleController = TextEditingController();

  // Apple-themed color palette
  final Color _primaryColor = const Color(0xFF4CAF50); // Apple green
  final Color _secondaryColor = const Color(0xFF8BC34A); // Light apple green
  final Color _accentColor = const Color(0xFFCDDC39); // Lime accent
  final Color _backgroundColor =
      const Color.fromARGB(255, 245, 245, 245); // Very light green
  final Color _cardColor = Colors.white;
  final Color _textColor = const Color(0xFF2E7D32); // Dark green
  final Color _errorColor = const Color(0xFFC62828); // Red for errors

  @override
  void initState() {
    super.initState();
    _loadSavedImages();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedImages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final directory = await getApplicationDocumentsDirectory();
      final qrCodeDir = Directory('${directory.path}/qr_codes');

      if (!await qrCodeDir.exists()) {
        await qrCodeDir.create(recursive: true);
      }

      final files = await qrCodeDir.list().toList();
      setState(() {
        _savedImages = files
            .where((file) =>
                file.path.endsWith('.png') || file.path.endsWith('.jpg'))
            .map((file) {
          // Extract title from filename
          String fileName = path.basenameWithoutExtension(file.path);
          // If the filename contains an underscore, it's in the new format
          if (fileName.contains('_')) {
            // Get everything before the last underscore (UUID)
            fileName = fileName.substring(0, fileName.lastIndexOf('_'));
          }
          return QrCodeImage(
            path: file.path,
            title: fileName,
          );
        }).toList();
      });
    } catch (e) {
      _showSnackBar("Error loading images: ${e.toString()}", isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    var status = await Permission.photos.request();
    if (status.isGranted) {
      try {
        final pickedFile =
            await ImagePicker().pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          // Show dialog to get title
          final String? title = await showDialog<String>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Enter QR Code Title',
                    style: TextStyle(color: _textColor)),
                content: TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Enter title for this QR code',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('Cancel', style: TextStyle(color: _errorColor)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text('Save', style: TextStyle(color: _primaryColor)),
                    onPressed: () {
                      if (_titleController.text.isNotEmpty) {
                        Navigator.of(context).pop(_titleController.text);
                      }
                    },
                  ),
                ],
              );
            },
          );

          if (title != null && title.isNotEmpty) {
            final directory = await getApplicationDocumentsDirectory();
            final qrCodeDir = Directory('${directory.path}/qr_codes');

            if (!await qrCodeDir.exists()) {
              await qrCodeDir.create(recursive: true);
            }

            final fileName =
                '${title}_${const Uuid().v4()}.${path.extension(pickedFile.path)}';
            final savedImage =
                await File(pickedFile.path).copy('${qrCodeDir.path}/$fileName');

            setState(() {
              _savedImages.add(QrCodeImage(
                path: savedImage.path,
                title: title,
              ));
            });

            _titleController.clear();
            _showSnackBar("QR code saved successfully!");
          }
        }
      } catch (e) {
        _showSnackBar("Failed to save image: ${e.toString()}", isError: true);
      }
    }
  }

  Future<void> _deleteImage(QrCodeImage image) async {
    try {
      final file = File(image.path);
      if (await file.exists()) {
        await file.delete();
        setState(() {
          _savedImages.remove(image);
        });
        _showSnackBar("QR code deleted successfully!");
      }
    } catch (e) {
      _showSnackBar("Failed to delete QR code: ${e.toString()}", isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? _errorColor : _primaryColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "QR Code Images",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(Icons.add_photo_alternate, color: Colors.white),
                  label: Text("Add QR Code",
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _savedImages.isEmpty
                      ? Center(
                          child: Text(
                            "No QR codes added yet",
                            style: TextStyle(
                              fontSize: 18,
                              color: _textColor.withOpacity(0.6),
                            ),
                          ),
                        )
                      : GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.8, // Adjusted for title
                          ),
                          itemCount: _savedImages.length,
                          itemBuilder: (context, index) {
                            final image = _savedImages[index];
                            return Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                            top: Radius.circular(12),
                                          ),
                                          child: Image.file(
                                            File(image.path),
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: IconButton(
                                            icon: Icon(Icons.delete,
                                                color: _errorColor),
                                            onPressed: () =>
                                                _deleteImage(image),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      image.title,
                                      style: TextStyle(
                                        color: _textColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
