import 'dart:io';
import 'package:image/image.dart' as img;

void main() async {
  print('🎨 Generating PNG icons from SVG...');

  // Create a 1024x1024 image with sage green background
  final image = img.Image(width: 1024, height: 1024);

  // Fill with sage green background (#4CAF50)
  img.fill(image, color: img.ColorRgb8(76, 175, 80));

  // Draw a simple leaf shape (we'll use circles and ellipses to approximate)
  final leaf = img.Image(width: 1024, height: 1024);
  img.fill(leaf, color: img.ColorRgba8(0, 0, 0, 0)); // Transparent

  // Draw leaf body (light yellow-green #F1F8E9)
  img.fillCircle(leaf,
    x: 512,
    y: 512,
    radius: 350,
    color: img.ColorRgb8(241, 248, 233)
  );

  // Composite the leaf onto the background
  img.compositeImage(image, leaf);

  // Save main icon
  final mainIconFile = File('assets/icon/sage_leaf.png');
  await mainIconFile.writeAsBytes(img.encodePng(image));
  print('✅ Created sage_leaf.png');

  // Create foreground icon (transparent background for adaptive icon)
  final foreground = img.Image(width: 1024, height: 1024);
  img.fill(foreground, color: img.ColorRgba8(0, 0, 0, 0)); // Transparent

  // Draw leaf shape
  img.fillCircle(foreground,
    x: 512,
    y: 512,
    radius: 350,
    color: img.ColorRgb8(241, 248, 233)
  );

  final foregroundFile = File('assets/icon/sage_leaf_foreground.png');
  await foregroundFile.writeAsBytes(img.encodePng(foreground));
  print('✅ Created sage_leaf_foreground.png');

  print('🎉 Icon generation complete!');
}
