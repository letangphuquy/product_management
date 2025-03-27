// widgets/product_image_picker.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProductImagePicker extends StatefulWidget {
  final File? image;
  final Function(File) onImagePicked;
  final String defaultAssetImagePath;

  const ProductImagePicker({
    super.key,
    required this.image,
    required this.onImagePicked,
    required this.defaultAssetImagePath,
  });

  @override
  State<ProductImagePicker> createState() => _ProductImagePickerState();
}

class _ProductImagePickerState extends State<ProductImagePicker> {
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final xfile = await picker.pickImage(source: ImageSource.gallery);
    if (xfile != null) {
      final File file = File(xfile.path);
      widget.onImagePicked(file);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: 100,
        height: 100,
        color: Colors.grey[300],
        child: widget.image == null
            ? Image.asset(
                widget.defaultAssetImagePath,
                fit: BoxFit.cover,
              )
            : Image.file(widget.image!, fit: BoxFit.cover),
      ),
    );
  }
}
